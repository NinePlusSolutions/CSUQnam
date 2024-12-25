import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
import 'package:flutter_getx_boilerplate/models/local/shaved_status_update.dart';
import 'package:flutter_getx_boilerplate/models/profile/profile_response.dart';
import 'package:flutter_getx_boilerplate/models/response/shaved_status_response.dart';
import 'package:flutter_getx_boilerplate/models/response/status_response.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/update_tree_controller.dart';
import 'package:flutter_getx_boilerplate/modules/sync/sync_controller.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'update_tree_screen.dart';

class StatusInfo {
  final String name;
  final String description;
  int id;

  StatusInfo(this.name, this.description, {this.id = 0});
}

class InventoryController extends GetxController {
  final storage = GetStorage();
  final RxList<StatusInfo> statusList = <StatusInfo>[].obs;
  final RxMap<String, Color> statusColors = <String, Color>{}.obs;
  final RxMap<String, RxInt> statusCounts = <String, RxInt>{}.obs;
  final RxString note = ''.obs;
  final RxString tappingAge = ''.obs;
  final RxInt yearShaved = 0.obs;
  final RxString row = '1'.obs;
  final totalRows = 50;

  // Farm info
  final RxString farm = ''.obs;
  final RxInt farmId = 0.obs;
  final RxString productionTeam = ''.obs;
  final RxInt productTeamId = 0.obs;
  final RxString lot = ''.obs;
  final RxInt farmLotId = 0.obs;

  // Local data
  final Rx<List<FarmResponse>> farmResponses = Rx<List<FarmResponse>>([]);
  final Rx<FarmResponse?> selectedFarm = Rx<FarmResponse?>(null);
  final Rx<ProductTeamResponse?> selectedTeam = Rx<ProductTeamResponse?>(null);
  final Rx<FarmLotResponse?> selectedLot = Rx<FarmLotResponse?>(null);

  // Visibility flags for dropdowns
  final RxBool showTeamDropdown = false.obs;
  final RxBool showLotDropdown = false.obs;
  final RxBool showYearDropdown = false.obs;

  final RxBool isEditingEnabled = true.obs;
  final RxBool isLoading = false.obs;

  final List<Color> _statusColorPalette = [
    Colors.blue, // 1
    Colors.green, // 2
    Colors.teal, // 3
    Colors.purple, // 4
    Colors.orange, // 5
    Colors.red, // 6
    Colors.pink, // 7
    Colors.brown, // 9
    Colors.red[700]!, // 10
    Colors.red[900]!, // 11
  ];

  final ApiProvider _apiProvider = ApiProvider();

  final Rxn<ShavedStatusData> shavedStatusData = Rxn<ShavedStatusData>();
  final Rxn<ShavedStatusItem> selectedShavedStatus = Rxn<ShavedStatusItem>();
  final RxString selectedType = RxString('');

  List<String> getRowNumbers() {
    return List.generate(totalRows, (index) => (index + 1).toString());
  }

  void resetDropdowns() {
    // Reset teams
    productTeamId.value = 0;
    productionTeam.value = '';
    showTeamDropdown.value = false;

    // Reset lots
    farmLotId.value = 0;
    lot.value = '';
    showLotDropdown.value = false;

    // Reset years
    yearShaved.value = 0;
    tappingAge.value = '';
    showYearDropdown.value = false;
  }

  Future<void> onFarmSelected(int farmId, String farmName) async {
    try {
      // Reset all dropdowns first
      resetDropdowns();

      // Find selected farm from local data
      selectedFarm.value = farmResponses.value.firstWhere(
        (farm) => farm.farmId == farmId,
      );

      // Update values
      this.farmId.value = farmId;
      farm.value = farmName;

      // Show team dropdown if farm has teams
      showTeamDropdown.value =
          selectedFarm.value?.productTeamResponse.isNotEmpty ?? false;
    } catch (e) {
      print('Error selecting farm: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể chọn nông trường: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> onTeamSelected(int teamId, String teamName) async {
    try {
      // Reset lot and year dropdowns
      resetLotAndYearDropdowns();

      // Find selected team from local data
      selectedTeam.value = selectedFarm.value?.productTeamResponse.firstWhere(
        (team) => team.productTeamId == teamId,
      );

      // Update values
      productTeamId.value = teamId;
      productionTeam.value = teamName;

      // Show lot dropdown if team has lots
      showLotDropdown.value =
          selectedTeam.value?.farmLotResponse.isNotEmpty ?? false;
    } catch (e) {
      print('Error selecting team: $e');
      Get.snackbar(
        'Error',
        'Failed to select team: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> onLotSelected(int lotId, String lotName) async {
    try {
      // Reset year dropdown
      resetYearDropdown();

      // Find selected lot from local data
      selectedLot.value = selectedTeam.value?.farmLotResponse.firstWhere(
        (lot) => lot.farmLotId == lotId,
      );

      // Update values
      farmLotId.value = lotId;
      lot.value = lotName;

      // Show year dropdown if lot has valid ages
      final hasValidAges = selectedLot.value?.ageShavedResponse
              .where((age) => age.value != null)
              .isNotEmpty ??
          false;
      showYearDropdown.value = hasValidAges;

      // If there's only one valid age, select it automatically
      if (hasValidAges) {
        final validAges = selectedLot.value!.ageShavedResponse
            .where((age) => age.value != null)
            .map((age) => age.value.toString())
            .toSet()
            .toList();

        if (validAges.length == 1) {
          tappingAge.value = validAges.first;
          yearShaved.value = int.parse(validAges.first);
        }
      }
    } catch (e) {
      print('Error selecting lot: $e');
      Get.snackbar(
        'Error',
        'Failed to select lot: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onYearSelected(int year) {
    yearShaved.value = year;
    tappingAge.value = year.toString();
  }

  void incrementStatus(String status) {
    if (isEditingEnabled.value) {
      final currentCount = statusCounts[status] ?? 0.obs;
      currentCount.value++;
    }
  }

  void decrementStatus(String status) {
    if (isEditingEnabled.value) {
      final currentCount = statusCounts[status] ?? 0.obs;
      if (currentCount.value > 0) {
        currentCount.value--;
      }
    }
  }

  int getCount(String status) {
    return statusCounts[status]?.value ?? 0;
  }

  void updateNote(String value) {
    note.value = value;
  }

  Future<void> saveLocalUpdate() async {
    try {
      final now = DateTime.now();
      print('Current tapping age: ${tappingAge.value}'); // Debug log
      final List<LocalStatusUpdate> statusUpdates = [];
      for (var status in statusList) {
        final count = statusCounts[status.name] ?? 0.obs;
        if (count.value > 0) {
          statusUpdates.add(LocalStatusUpdate(
            statusId: status.id,
            statusName: status.name,
            value: count.value.toString(),
          ));
        }
      }

      if (statusUpdates.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng cập nhật ít nhất một trạng thái',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final localUpdate = LocalTreeUpdate(
        farmId: farmId.value,
        farmName: farm.value,
        productTeamId: productTeamId.value,
        productTeamName: productionTeam.value,
        farmLotId: farmLotId.value,
        farmLotName: lot.value,
        treeLineName: row.value,
        shavedStatusId: selectedShavedStatus.value!.id,
        shavedStatusName: selectedShavedStatus.value!.name,
        tappingAge: tappingAge.value,
        statusUpdates: statusUpdates,
        note: note.value,
        dateCheck: now,
      );

      final Map<String, dynamic> updateJson = {
        'farmId': localUpdate.farmId,
        'farmName': localUpdate.farmName,
        'productTeamId': localUpdate.productTeamId,
        'productTeamName': localUpdate.productTeamName,
        'farmLotId': localUpdate.farmLotId,
        'farmLotName': localUpdate.farmLotName,
        'treeLineName': localUpdate.treeLineName,
        'shavedStatusId': localUpdate.shavedStatusId,
        'shavedStatusName': localUpdate.shavedStatusName,
        'tappingAge': localUpdate.tappingAge,
        'dateCheck': now.toIso8601String(),
        'statusUpdates': statusUpdates
            .map((status) => {
                  'statusId': status.statusId,
                  'statusName': status.statusName,
                  'value': status.value,
                })
            .toList(),
        'note': localUpdate.note,
      };

      print('Local update to save: $updateJson');

      List<Map<String, dynamic>> existingUpdates = [];
      final storedData = storage.read('local_updates');
      if (storedData != null && storedData is List) {
        existingUpdates = List<Map<String, dynamic>>.from(storedData);
      }

      existingUpdates.add(updateJson);
      await storage.write('local_updates', existingUpdates);
      print('Saved updates: $existingUpdates');

      // Cập nhật lại danh sách trong SyncController
      if (Get.isRegistered<SyncController>()) {
        final syncController = Get.find<SyncController>();
        await syncController.loadPendingUpdates();
      }

      Get.snackbar(
        'Thành công',
        'Đã lưu dữ liệu kiểm kê',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error saving local update: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể lưu dữ liệu kiểm kê: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showConfirmDialog() {
    // Kiểm tra các trường bắt buộc
    if (farmId.value == 0 || farm.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn nông trường',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (productTeamId.value == 0 || productionTeam.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn tổ sản xuất',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (farmLotId.value == 0 || lot.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn lô',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (tappingAge.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn tuổi cạo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (row.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn hàng',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedShavedStatus.value == null) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn trạng thái cạo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Kiểm tra xem có ít nhất một trạng thái được cập nhật
    bool hasStatusUpdate = false;
    statusCounts.forEach((_, count) {
      if (count.value > 0) {
        hasStatusUpdate = true;
      }
    });

    if (!hasStatusUpdate) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng cập nhật ít nhất một trạng thái cây',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Build status summary text
    String statusSummary = '';
    int totalTrees = 0;
    statusCounts.forEach((status, count) {
      if (count.value > 0) {
        totalTrees += count.value;
        statusSummary += '• $status: ${count.value} cây\n';
      }
    });

    Get.dialog(
      AlertDialog(
        title: const Column(
          children: [
            Icon(
              Icons.save_outlined,
              size: 40,
              color: Colors.blue,
            ),
            SizedBox(height: 8),
            Text(
              'Xác nhận thông tin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin cơ bản',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Lô:', lot.value),
                      _buildInfoRow('Đội:', productionTeam.value),
                      _buildInfoRow('Hàng:', row.value),
                      _buildInfoRow('Trạng thái cạo:',
                          selectedShavedStatus.value?.name ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số lượng cây theo trạng thái',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusSummary,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const Divider(),
                      Text(
                        'Tổng số cây: $totalTrees',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                if (note.value.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            label: const Text('Hủy'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              await saveLocalUpdate();
              // Reset values for next row
              selectedShavedStatus.value = null;
              statusCounts.forEach((key, value) {
                value.value = 0;
              });
              note.value = '';
              // Increment row number
              final currentRow = int.parse(row.value);
              if (currentRow < totalRows) {
                row.value = (currentRow + 1).toString();
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Xác nhận'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void submitInventory() {
    if (selectedShavedStatus.value == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn trạng thái cạo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Build status summary text
    String statusSummary = '';
    int totalTrees = 0;
    statusCounts.forEach((status, count) {
      if (count.value > 0) {
        totalTrees += count.value;
        final color = statusColors[status] ?? Colors.black;
        statusSummary += '• $status: ${count.value} cây\n';
      }
    });

    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận thông tin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin cập nhật:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Lô 1: ${lot.value}'),
              Text('Đội: ${productionTeam.value}'),
              Text('Hàng: ${row.value}'),
              Text('Trạng thái cạo: ${selectedShavedStatus.value?.name}'),
              const SizedBox(height: 12),
              const Text(
                'Số lượng cây theo trạng thái:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(statusSummary),
              const SizedBox(height: 8),
              Text(
                'Tổng số cây: $totalTrees',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (note.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Ghi chú:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(note.value),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Chỉnh sửa'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await saveLocalUpdate();
              // Reset values for next row
              selectedShavedStatus.value = null;
              statusCounts.forEach((key, value) {
                value.value = 0;
              });
              note.value = '';
              // Increment row number
              final currentRow = int.parse(row.value);
              if (currentRow < totalRows) {
                row.value = (currentRow + 1).toString();
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void showFinishDialog() {
    // Build status summary text
    String statusSummary = '';
    statusCounts.forEach((status, count) {
      if (count.value > 0) {
        statusSummary += '$status: ${count.value}\n';
      }
    });

    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận cập nhật'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin cập nhật:'),
            const SizedBox(height: 8),
            Text('Lô: ${lot.value}'),
            Text('Đội: ${productionTeam.value}'),
            Text('Hàng: ${row.value}'),
            Text('Trạng thái cạo: ${selectedShavedStatus.value?.name}'),
            const SizedBox(height: 8),
            const Text('Số lượng cây theo trạng thái:'),
            Text(statusSummary),
            if (note.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Ghi chú: ${note.value}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await saveLocalUpdate();
                Get.snackbar(
                  'Thành công',
                  'Đã lưu thông tin cập nhật',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                // Reset values
                selectedShavedStatus.value = null;
                statusCounts.forEach((key, value) {
                  value.value = 0;
                });
                note.value = '';
                // Increment row number
                final currentRow = int.parse(row.value);
                if (currentRow < totalRows) {
                  row.value = (currentRow + 1).toString();
                }
              } catch (e) {
                Get.snackbar(
                  'Lỗi',
                  'Không thể lưu thông tin cập nhật. Vui lòng thử lại.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    bool hasStoredData = false;
    try {
      isLoading.value = true;

      // Try to get data from local storage first
      final storedStatusData = storage.read('status_data');
      final storedProfileData = storage.read('profile_data');
      final storedShavedStatusData = storage.read('shaved_status_data');

      // Try to use stored data first
      if (storedStatusData != null &&
          storedProfileData != null &&
          storedShavedStatusData != null) {
        try {
          final statusData = jsonDecode(storedStatusData);
          final profileData = jsonDecode(storedProfileData);
          final shavedStatusData = jsonDecode(storedShavedStatusData);

          processStatusData(statusData);
          processProfileData(profileData);
          this.shavedStatusData.value =
              ShavedStatusData.fromJson(shavedStatusData);
          hasStoredData = true;
        } catch (e) {
          print('Error processing stored data: $e');
        }
      }

      // Check network connection before making API calls
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // We have network connection, try API calls
          try {
            await fetchProfile();
            await fetchStatusData();
            await fetchShavedStatusData();
            return; // Exit if API calls are successful
          } catch (e) {
            print('Error fetching data from API: $e');
            if (!hasStoredData) {
              Get.snackbar(
                'Lỗi',
                'Không thể tải dữ liệu từ máy chủ. Vui lòng thử lại sau.',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        }
      } on SocketException catch (_) {
        // No internet connection
        if (!hasStoredData) {
          Get.snackbar(
            'Lỗi kết nối',
            'Không có kết nối mạng. Vui lòng kiểm tra lại kết nối của bạn.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error in initData: $e');
      if (!hasStoredData) {
        Get.snackbar(
          'Lỗi',
          'Không thể tải dữ liệu. Vui lòng thử lại sau.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void processStatusData(dynamic data) {
    try {
      final statusResponse = StatusResponse.fromJson(data);

      statusList.clear();
      statusCounts.clear();

      final statuses = statusResponse.data
          .map((item) => StatusInfo(item.name, item.description, id: item.id))
          .toList();

      statusList.addAll(statuses);

      for (var item in statusResponse.data) {
        final colorIndex = (item.id - 1) % _statusColorPalette.length;
        statusColors[item.name] = _statusColorPalette[colorIndex];
        statusCounts[item.name] = 0.obs;
      }
    } catch (e) {
      print('Error processing status data: $e');
    }
  }

  void processProfileData(dynamic data) {
    try {
      final profileData = ProfileResponse.fromJson(data);

      if (profileData.farmByUserResponse.isNotEmpty) {
        final farmByUser = profileData.farmByUserResponse[0];
        if (farmByUser.farmResponse.isNotEmpty) {
          farmResponses.value = farmByUser.farmResponse;

          final defaultFarm = farmByUser.farmResponse[0];
          selectedFarm.value = defaultFarm;
          farm.value = defaultFarm.farmName;
          farmId.value = defaultFarm.farmId;

          if (defaultFarm.productTeamResponse.isNotEmpty) {
            final defaultTeam = defaultFarm.productTeamResponse[0];
            selectedTeam.value = defaultTeam;
            productionTeam.value = defaultTeam.productTeamName;
            productTeamId.value = defaultTeam.productTeamId;
            showTeamDropdown.value = true;

            if (defaultTeam.farmLotResponse.isNotEmpty) {
              final defaultLot = defaultTeam.farmLotResponse[0];
              selectedLot.value = defaultLot;
              lot.value = defaultLot.farmLotName;
              farmLotId.value = defaultLot.farmLotId;
              showLotDropdown.value = true;

              if (defaultLot.ageShavedResponse.isNotEmpty) {
                final defaultAge = defaultLot.ageShavedResponse[0].value;
                if (defaultAge != null) {
                  yearShaved.value = defaultAge;
                  tappingAge.value = defaultAge.toString();
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error processing profile data: $e');
    }
  }

  void updateHeaderValues() {
    if (selectedFarm.value != null) {
      farm.value = selectedFarm.value!.farmName;
      farmId.value = selectedFarm.value!.farmId;
    }

    if (selectedTeam.value != null) {
      productionTeam.value = selectedTeam.value!.productTeamName;
      productTeamId.value = selectedTeam.value!.productTeamId;
    }

    if (selectedLot.value != null) {
      lot.value = selectedLot.value!.farmLotName;
      farmLotId.value = selectedLot.value!.farmLotId;
    }
  }

  void resetTeamDropdown() {
    productTeamId.value = 0;
    productionTeam.value = '';
    showTeamDropdown.value = false;
  }

  void resetLotAndYearDropdowns() {
    farmLotId.value = 0;
    lot.value = '';
    showLotDropdown.value = false;
    resetYearDropdown();
  }

  void resetYearDropdown() {
    yearShaved.value = 0;
    tappingAge.value = '';
    showYearDropdown.value = false;
  }

  Future<void> fetchShavedStatusData() async {
    try {
      final storage = Get.find<GetStorage>();
      final localData = await storage.read('shaved_status_data');

      if (localData != null) {
        final response = ShavedStatusResponse.fromJson(jsonDecode(localData));
        shavedStatusData.value = response.data;
      } else {
        final response = await _apiProvider.fetchShavedStatus();
        await storage.write('shaved_status_data', jsonEncode(response));
        shavedStatusData.value = response.data;
      }
    } catch (e) {
      print('Error fetching shaved status: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải dữ liệu trạng thái cạo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildShavedStatusGroup(String title, List<ShavedStatusItem> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Obx(() => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (selectedShavedStatus.value?.id == item.id) {
                      selectedShavedStatus.value = null;
                      selectedType.value = '';
                    } else {
                      selectedShavedStatus.value = item;
                      selectedType.value = title;
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedShavedStatus.value?.id == item.id
                          ? Theme.of(Get.context!).primaryColor.withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: selectedShavedStatus.value?.id == item.id
                            ? Theme.of(Get.context!).primaryColor
                            : Colors.grey[200]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              color: selectedShavedStatus.value?.id == item.id
                                  ? Theme.of(Get.context!).primaryColor
                                  : Colors.black87,
                              fontWeight:
                                  selectedShavedStatus.value?.id == item.id
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (selectedShavedStatus.value?.id == item.id)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: Theme.of(Get.context!).primaryColor,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }

  void showShavedStatusBottomSheet() {
    // Kiểm tra các trường bắt buộc trước
    if (farmId.value == 0 || farm.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn nông trường',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (productTeamId.value == 0 || productionTeam.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn tổ sản xuất',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (farmLotId.value == 0 || lot.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn lô',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (tappingAge.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn tuổi cạo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (row.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn hàng',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Kiểm tra xem có ít nhất một trạng thái được cập nhật
    bool hasStatusUpdate = false;
    statusCounts.forEach((_, count) {
      if (count.value > 0) {
        hasStatusUpdate = true;
      }
    });

    if (!hasStatusUpdate) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng cập nhật ít nhất một trạng thái cây',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show bottom sheet
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn trạng thái cạo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(Get.context!).primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(Get.context!).primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      shavedStatusData.value!.toJson().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(Get.context!)
                                  .primaryColor
                                  .withOpacity(0.05),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(Get.context!).primaryColor,
                              ),
                            ),
                          ),
                          _buildShavedStatusGroup(entry.key, entry.value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Bottom buttons
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(Get.context!).padding.bottom + 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                            color: Theme.of(Get.context!)
                                .primaryColor
                                .withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Theme.of(Get.context!).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: selectedShavedStatus.value != null
                            ? () {
                                Get.back();
                                _showConfirmDialog();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Theme.of(Get.context!).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> fetchProfile() async {
    try {
      final apiResponse = await _apiProvider.getProfile();

      if (apiResponse.data != null) {
        final profileData = apiResponse.data!;
        if (profileData.farmByUserResponse.isNotEmpty) {
          final farmByUser = profileData.farmByUserResponse[0];
          if (farmByUser.farmResponse.isNotEmpty) {
            farmResponses.value = farmByUser.farmResponse;

            final defaultFarm = farmByUser.farmResponse[0];
            selectedFarm.value = defaultFarm;
            farm.value = defaultFarm.farmName;
            farmId.value = defaultFarm.farmId;

            if (defaultFarm.productTeamResponse.isNotEmpty) {
              final defaultTeam = defaultFarm.productTeamResponse[0];
              selectedTeam.value = defaultTeam;
              productionTeam.value = defaultTeam.productTeamName;
              productTeamId.value = defaultTeam.productTeamId;
              showTeamDropdown.value = true;

              if (defaultTeam.farmLotResponse.isNotEmpty) {
                final defaultLot = defaultTeam.farmLotResponse[0];
                selectedLot.value = defaultLot;
                lot.value = defaultLot.farmLotName;
                farmLotId.value = defaultLot.farmLotId;
                showLotDropdown.value = true;

                if (defaultLot.ageShavedResponse.isNotEmpty) {
                  final defaultAge = defaultLot.ageShavedResponse[0].value;
                  if (defaultAge != null) {
                    yearShaved.value = defaultAge;
                    tappingAge.value = defaultAge.toString();
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<void> fetchStatusData() async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.getStatus();
      final statusResponse = StatusResponse.fromJson(response.data);

      statusList.clear();
      statusCounts.clear();

      final statuses = statusResponse.data
          .map((item) => StatusInfo(item.name, item.description, id: item.id))
          .toList();

      statusList.addAll(statuses);

      for (var item in statusResponse.data) {
        final colorIndex = (item.id - 1) % _statusColorPalette.length;
        statusColors[item.name] = _statusColorPalette[colorIndex];
        statusCounts[item.name] = 0.obs;
      }
    } catch (e) {
      print('Error fetching status data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
