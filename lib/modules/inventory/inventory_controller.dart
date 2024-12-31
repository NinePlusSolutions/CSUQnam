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
  final _apiProvider = Get.find<ApiProvider>();
  final storage = GetStorage();

  // Storage keys
  static const String syncStorageKey = 'local_updates';
  static const String historyStorageKey = 'history_updates';

  final farm = ''.obs;
  final farmId = 0.obs;
  final productionTeam = ''.obs;
  final productTeamId = 0.obs;
  final lot = ''.obs;
  final farmLotId = 0.obs;
  final yearShaved = 0.obs;
  final tappingAge = ''.obs;
  final rowNumber = 0.obs;

  final RxList<StatusInfo> statusList = <StatusInfo>[].obs;
  final RxMap<String, Color> statusColors = <String, Color>{}.obs;
  final RxMap<String, RxInt> statusCounts = <String, RxInt>{}.obs;
  final RxString note = ''.obs;
  final noteController = TextEditingController();
  final RxString row = '1'.obs;
  final totalRows = 50;

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
      _showErrorMessage('Lỗi', 'Không thể chọn nông trường: $e');
    }
  }

  Future<void> onTeamSelected(int teamId, String? teamName) async {
    try {
      // Reset lot and year dropdowns
      resetLotAndYearDropdowns();

      // Find selected team from local data
      final selectedTeam = selectedFarm.value?.productTeamResponse.firstWhere(
        (team) => team.productTeamId == teamId,
      );

      // Update values
      productTeamId.value = teamId;
      productionTeam.value = teamName ?? '';
      if (selectedTeam != null) {
        this.selectedTeam.value = selectedTeam;
        if (selectedTeam.farmLotResponse.isNotEmpty) {
          showLotDropdown.value = true;
        } else {
          resetLotAndYearDropdowns();
        }
      }
      updateHeaderValues();
    } catch (e) {
      print('Error selecting team: $e');
      _showErrorMessage('Error', 'Failed to select team: $e');
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
      _showErrorMessage('Error', 'Failed to select lot: $e');
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

  void _handleEndInventory() {
    // Close the dialog first
    Get.back();
    // Schedule navigation and state updates after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        isLoading.value = true;
        await Get.toNamed('/sync');
      } finally {
        isLoading.value = false;
      }
    });
  }

  void _handleNextRow() {
    // Close the dialog first
    Get.back();
    // Schedule state updates after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset values for next row
      selectedShavedStatus.value = null;
      statusCounts.forEach((key, value) {
        value.value = 0;
      });
      note.value = '';
      noteController.text = ''; // Reset text controller
      // Increment row number
      final currentRow = int.parse(row.value);
      if (currentRow < totalRows) {
        row.value = (currentRow + 1).toString();
      }
    });
  }

  Future<void> saveLocalUpdate() async {
    try {
      if (!isEditingEnabled.value) {
        return;
      }

      final statusUpdates = <Map<String, dynamic>>[];
      statusCounts.forEach((statusName, count) {
        if (count.value > 0) {
          final status = statusList.firstWhere((s) => s.name == statusName);
          statusUpdates.add({
            'statusId': status.id,
            'statusName': status.name,
            'value': count.value.toString(),
          });
        }
      });

      final update = LocalTreeUpdate(
        farmId: farmId.value,
        farmName: farm.value,
        productTeamId: productTeamId.value,
        productTeamName: productionTeam.value,
        farmLotId: farmLotId.value,
        farmLotName: lot.value,
        treeLineName: row.value,
        shavedStatusId: selectedShavedStatus.value?.id ?? 0,
        shavedStatusName: selectedShavedStatus.value?.name ?? '',
        tappingAge: tappingAge.value,
        dateCheck: DateTime.now(),
        statusUpdates: statusUpdates
            .map((status) => LocalStatusUpdate(
                  statusId: status['statusId'],
                  statusName: status['statusName'],
                  value: status['value'],
                ))
            .toList(),
        note: note.value,
      );

      final updateJson = {
        'farmId': update.farmId,
        'farmName': update.farmName,
        'productTeamId': update.productTeamId,
        'productTeamName': update.productTeamName,
        'farmLotId': update.farmLotId,
        'farmLotName': update.farmLotName,
        'treeLineName': update.treeLineName,
        'shavedStatusId': update.shavedStatusId,
        'shavedStatusName': update.shavedStatusName,
        'tappingAge': update.tappingAge,
        'dateCheck': update.dateCheck.toIso8601String(),
        'statusUpdates': update.statusUpdates
            .map((status) => {
                  'statusId': status.statusId,
                  'statusName': status.statusName,
                  'value': status.value,
                })
            .toList(),
        'note': update.note,
      };

      print('Local update to save: $updateJson');

      // Save to sync storage
      List<Map<String, dynamic>> existingUpdates = [];
      final storedData = storage.read(syncStorageKey);
      if (storedData != null && storedData is List) {
        existingUpdates = List<Map<String, dynamic>>.from(storedData);
      }
      existingUpdates.add(updateJson);
      await storage.write(syncStorageKey, existingUpdates);

      // Save to history storage
      List<Map<String, dynamic>> historyUpdates = [];
      final historyData = storage.read(historyStorageKey);
      if (historyData != null && historyData is List) {
        historyUpdates = List<Map<String, dynamic>>.from(historyData);
      }
      historyUpdates.add(updateJson);
      await storage.write(historyStorageKey, historyUpdates);

      print('Saved updates: $existingUpdates');

      // Reset form
      statusCounts.forEach((key, value) => value.value = 0);
      note.value = '';
      noteController.clear();
      selectedShavedStatus.value = null;

      Get.back();
      Get.snackbar(
        'Thành công',
        'Đã lưu thông tin kiểm kê',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Cập nhật lại danh sách trong SyncController
      final syncController = Get.find<SyncController>();
      syncController.loadPendingUpdates();
    } catch (e) {
      print('Error saving local update: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể lưu thông tin kiểm kê',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showConfirmDialog() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: screenWidth * 0.9, // Make dialog wider
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Xác nhận thông tin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Location info
              _buildInfoRow('Nông trường:', farm.value),
              _buildInfoRow('Tổ:', productionTeam.value),
              _buildInfoRow('Lô:', lot.value),
              _buildInfoRow('Hàng:', row.value),
              const SizedBox(height: 16),
              // Tree status section
              const Text(
                'Số lượng theo trạng thái:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Tree status counts with colors
              ...statusList.map((condition) {
                final count = statusCounts[condition.name] ?? 0;
                if (count == 0) return const SizedBox.shrink();

                final color = statusColors[condition.name] ?? Colors.grey;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        condition.name,
                        style: TextStyle(
                          fontSize: 15,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Shaved status
              _buildInfoRow('Trạng thái mặt cạo:',
                  selectedShavedStatus.value?.name ?? ''),
              if (note.value.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoRow('Ghi chú:', note.value),
              ],
              const SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      saveLocalUpdate();
                    },
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void submitInventory() {
    if (selectedShavedStatus.value == null) {
      _showErrorMessage('Lỗi', 'Vui lòng chọn trạng thái cạo');
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
                _showSuccessMessage('Thành công', 'Đã lưu thông tin cập nhật');
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
                _showErrorMessage('Lỗi',
                    'Không thể lưu thông tin cập nhật. Vui lòng thử lại.');
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    // Tự động đóng popup sau 1.5 giây
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.back();
    });
  }

  void _showErrorMessage(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red[700],
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    // Tự động đóng popup sau 1.5 giây
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.back();
    });
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
              _showErrorMessage('Lỗi',
                  'Không thể tải dữ liệu từ máy chủ. Vui lòng thử lại sau.');
            }
          }
        }
      } on SocketException catch (_) {
        // No internet connection
        if (!hasStoredData) {
          _showErrorMessage('Lỗi kết nối',
              'Không có kết nối mạng. Vui lòng kiểm tra lại kết nối của bạn.');
        }
      }
    } catch (e) {
      print('Error in initData: $e');
      if (!hasStoredData) {
        _showErrorMessage(
            'Lỗi', 'Không thể tải dữ liệu. Vui lòng thử lại sau.');
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
            productionTeam.value = defaultTeam.productTeamName ?? "";
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
      productionTeam.value = selectedTeam.value!.productTeamName ?? "";
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
      final response = await _apiProvider.fetchShavedStatus();
      await storage.write('shaved_status_data', jsonEncode(response.data));
      shavedStatusData.value = response.data;
    } catch (e) {
      print('Error fetching shaved status: $e');
      _showErrorMessage('Lỗi', 'Không thể tải dữ liệu trạng thái cạo');
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
      _showErrorMessage('Thiếu thông tin', 'Vui lòng chọn nông trường');
      return;
    }

    if (productTeamId.value == 0 || productionTeam.value.isEmpty) {
      _showErrorMessage('Thiếu thông tin', 'Vui lòng chọn tổ sản xuất');
      return;
    }

    if (farmLotId.value == 0 || lot.value.isEmpty) {
      _showErrorMessage('Thiếu thông tin', 'Vui lòng chọn lô');
      return;
    }

    if (tappingAge.value.isEmpty) {
      _showErrorMessage('Thiếu thông tin', 'Vui lòng chọn tuổi cạo');
      return;
    }

    if (row.value.isEmpty) {
      _showErrorMessage('Thiếu thông tin', 'Vui lòng chọn hàng');
      return;
    }

    // Show bottom sheet
    final expandedStatus = <String, bool>{};
    for (var key in shavedStatusData.value!.toJson().keys) {
      expandedStatus[key] = false;
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
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
                    color:
                        Theme.of(Get.context!).primaryColor.withOpacity(0.05),
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
                        final isExpanded = expandedStatus[entry.key] ?? false;
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
                              // Header with expand/collapse
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    expandedStatus[entry.key] = !isExpanded;
                                  });
                                },
                                child: Container(
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(Get.context!)
                                                .primaryColor,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color:
                                            Theme.of(Get.context!).primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Status grid
                              if (isExpanded)
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
                              backgroundColor:
                                  Theme.of(Get.context!).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
          );
        },
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
      if (apiResponse.status) {
        await storage.write('profile_data', jsonEncode(apiResponse.data));
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
              if (defaultTeam.productTeamName != null) {
                selectedTeam.value = defaultTeam;
                productionTeam.value = defaultTeam.productTeamName!;
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
      } else {
        throw Exception('Failed to get profile data');
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
      await storage.write('status_data', jsonEncode(response.data));
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
