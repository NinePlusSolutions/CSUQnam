import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
import 'package:flutter_getx_boilerplate/models/local/shaved_status_update.dart';
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

  // Lists for dropdown
  final RxList<Map<String, dynamic>> farms = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> teams = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> lots = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> years = <Map<String, dynamic>>[].obs;

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
    teams.clear();
    productTeamId.value = 0;
    productionTeam.value = '';
    showTeamDropdown.value = false;

    // Reset lots
    lots.clear();
    farmLotId.value = 0;
    lot.value = '';
    showLotDropdown.value = false;

    // Reset years
    years.clear();
    yearShaved.value = 0;
    tappingAge.value = '';
    showYearDropdown.value = false;
  }

  Future<void> onFarmSelected(int farmId, String farmName) async {
    try {
      // Reset all dropdowns first
      resetDropdowns();

      // Update farm values
      this.farmId.value = farmId;
      farm.value = farmName;

      // Fetch teams for selected farm
      await fetchTeams(farmId);

      // Show team dropdown
      showTeamDropdown.value = true;
    } catch (e) {
      print('Error selecting farm: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách tổ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> onTeamSelected(int teamId, String teamName) async {
    try {
      // Reset lot and year dropdowns
      lots.clear();
      farmLotId.value = 0;
      lot.value = '';
      showLotDropdown.value = false;

      years.clear();
      yearShaved.value = 0;
      tappingAge.value = '';
      showYearDropdown.value = false;

      // Update team values
      productTeamId.value = teamId;
      productionTeam.value = teamName;

      // Fetch lots for selected team
      await fetchLots(teamId);

      // Show lot dropdown
      showLotDropdown.value = true;
    } catch (e) {
      print('Error selecting team: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách lô: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> onLotSelected(int lotId, String lotName) async {
    try {
      // Reset year dropdown
      years.clear();
      yearShaved.value = 0;
      tappingAge.value = '';
      showYearDropdown.value = false;

      // Update lot values
      farmLotId.value = lotId;
      lot.value = lotName;

      // Fetch years for selected lot
      await fetchYears(lotId);

      // Show year dropdown
      showYearDropdown.value = true;
    } catch (e) {
      print('Error selecting lot: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách năm: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn lưu cập nhật này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await saveLocalUpdate();
              submitInventory();
            },
            child: const Text('Xác nhận'),
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

    // Convert RxInt to int for statusCounts
    final Map<String, int> convertedStatusCounts = {};
    statusCounts.forEach((key, value) {
      convertedStatusCounts[key] = value.value;
    });

    Get.put(UpdateTreeController());
    Get.to(
      () => UpdateTreeScreen(
        farm: farm.value,
        lot: lot.value,
        team: productionTeam.value,
        row: row.value,
        statusCounts: convertedStatusCounts,
      ),
      arguments: {
        'farmId': farmId.value,
        'farmName': farm.value,
        'productTeamId': productTeamId.value,
        'productTeamName': productionTeam.value,
        'farmLotId': farmLotId.value,
        'farmLotName': lot.value,
        'treeLineName': row.value,
        'shavedStatusId': selectedShavedStatus.value!.id,
        'shavedStatusName': selectedShavedStatus.value!.name,
        'note': note.value,
      },
    )!
        .then((value) {
      if (value != null && value is Map) {
        // Nếu là chuyển sang hàng tiếp theo
        if (value['row'] != null) {
          row.value = value['row'];
          // Reset các giá trị
          selectedShavedStatus.value = null;
          statusCounts.clear();
          note.value = '';
          update(['row']);
        } else {
          // Nếu hoàn thành cập nhật
          showFinishDialog();
        }
      }
    });
  }

  void showFinishDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Bạn đã cập nhật thành công!'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Đóng'),
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
    try {
      isLoading.value = true;
      await Future.wait([
        fetchProfile(),
        fetchFarms(),
        fetchStatusData(),
        fetchShavedStatusData(),
      ]);
    } catch (e) {
      print('Error initializing data: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải dữ liệu: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _apiProvider.getProfile();

      if (response.data?.farmByUserResponse.isNotEmpty == true) {
        final farmData = response.data!.farmByUserResponse[0];

        farm.value = farmData.farm.farmName;
        farmId.value = farmData.farm.farmId;

        lot.value = farmData.farmLot.farmLotName;
        farmLotId.value = farmData.farmLot.farmLotId;

        productionTeam.value = farmData.productTeam.productTeamName;
        productTeamId.value = farmData.productTeam.productTeamId;

        tappingAge.value = farmData.ageShaved.toString();
        yearShaved.value = farmData.ageShaved;
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> fetchFarms() async {
    try {
      final response = await _apiProvider.getFarms();
      if (response.data?['status'] == true && response.data?['data'] != null) {
        final farmList =
            List<Map<String, dynamic>>.from(response.data?['data']);
        farms.value = farmList;
        if (farmList.isNotEmpty) {
          final defaultFarm = farmList[0];
          farm.value = defaultFarm['name'];
          farmId.value = defaultFarm['id'];
          await onFarmSelected(defaultFarm['id'], defaultFarm['name']);
        }
      }
    } catch (e) {
      print('Error fetching farms: $e');
      farms.clear();
    }
  }

  Future<void> fetchTeams(int farmId) async {
    try {
      final response = await _apiProvider.getTeams(farmId);
      if (response.data?['status'] == true && response.data?['data'] != null) {
        final teamList =
            List<Map<String, dynamic>>.from(response.data?['data']);
        teams.value = teamList;
        if (teamList.isNotEmpty) {
          final defaultTeam = teamList[0];
          await onTeamSelected(defaultTeam['id'], defaultTeam['name']);
        }
      }
    } catch (e) {
      print('Error fetching teams: $e');
      teams.clear();
    }
  }

  Future<void> fetchLots(int productTeamId) async {
    try {
      final response = await _apiProvider.getLots(productTeamId);
      if (response.data?['status'] == true && response.data?['data'] != null) {
        final lotList = List<Map<String, dynamic>>.from(response.data?['data']);
        lots.value = lotList;
        if (lotList.isNotEmpty) {
          final defaultLot = lotList[0];
          await onLotSelected(defaultLot['id'], defaultLot['name']);
        }
      }
    } catch (e) {
      print('Error fetching lots: $e');
      lots.clear();
    }
  }

  Future<void> fetchYears(int farmLotId) async {
    try {
      final response = await _apiProvider.getYears(farmLotId);
      if (response.data?['status'] == true && response.data?['data'] != null) {
        final yearList =
            List<Map<String, dynamic>>.from(response.data?['data']);
        years.value = yearList;
        if (yearList.isNotEmpty) {
          final defaultYear = yearList[0];
          onYearSelected(defaultYear['yearShaved']);
        }
      }
    } catch (e) {
      print('Error fetching years: $e');
      years.clear();
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

  Future<void> fetchShavedStatusData() async {
    try {
      final response = await _apiProvider.fetchShavedStatus();
      shavedStatusData.value = response.data;
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

  void showShavedStatusBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn trạng thái cạo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShavedStatusGroup('BO1', [
                      _buildStatusItem('BO1', 'BO1'),
                      _buildStatusItem('BO1.1', 'BO1.1'),
                      _buildStatusItem('BO1.2', 'BO1.2'),
                      _buildStatusItem('BO1.3', 'BO1.3'),
                      _buildStatusItem('BO1.4', 'BO1.4'),
                      _buildStatusItem('BO1.5', 'BO1.5'),
                      _buildStatusItem('BO1.6', 'BO1.6'),
                    ]),
                    const SizedBox(height: 16),
                    _buildShavedStatusGroup('BO2', [
                      _buildStatusItem('BO2', 'BO2'),
                      _buildStatusItem('BO2.7', 'BO2.7'),
                      _buildStatusItem('BO2.8', 'BO2.8'),
                      _buildStatusItem('BO2.9', 'BO2.9'),
                      _buildStatusItem('BO2.10', 'BO2.10'),
                      _buildStatusItem('BO2.11', 'BO2.11'),
                      _buildStatusItem('BO2.12', 'BO2.12'),
                    ]),
                    const SizedBox(height: 16),
                    _buildShavedStatusGroup('HO', [
                      _buildStatusItem('HO', 'HO'),
                      _buildStatusItem('HO.1', 'HO.1'),
                      _buildStatusItem('HO.2', 'HO.2'),
                      _buildStatusItem('HO.3', 'HO.3'),
                      _buildStatusItem('HO.4', 'HO.4'),
                      _buildStatusItem('HO.5', 'HO.5'),
                      _buildStatusItem('HO.6', 'HO.6'),
                      _buildStatusItem('HO.7', 'HO.7'),
                      _buildStatusItem('HO.8', 'HO.8'),
                    ]),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: selectedShavedStatus.value != null
                              ? () {
                                  Get.back();
                                  _showConfirmDialog();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Xác nhận'),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildShavedStatusGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items,
        ),
      ],
    );
  }

  Widget _buildStatusItem(String id, String label) {
    final item = ShavedStatusItem(id: 1, name: label);
    return Obx(() {
      final isSelected = selectedShavedStatus.value?.name == label;
      return InkWell(
        onTap: () {
          if (isSelected) {
            selectedShavedStatus.value = null;
          } else {
            selectedShavedStatus.value = item;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.blue[100]!,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }
}
