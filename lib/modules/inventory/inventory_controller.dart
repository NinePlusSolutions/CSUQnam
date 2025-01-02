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

  String get _currentBatchId =>
      storage.read('current_batch_id')?.toString() ?? '';
  String get _currentSyncKey => '${syncStorageKey}_$_currentBatchId';
  String get currentHistoryKey => '${historyStorageKey}_$_currentBatchId';

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

  final isEditMode = false.obs;

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

  void onFarmSelected(int farmId, String farmName) {
    this.farmId.value = farmId;
    farm.value = farmName;

    // Clear previous selections
    productTeamId.value = 0;
    productionTeam.value = '';
    farmLotId.value = 0;
    lot.value = '';
    tappingAge.value = '';
    yearShaved.value = 0;

    // Find the selected farm and update selectedFarm
    final selectedFarm = farmResponses.value.firstWhereOrNull(
      (farm) => farm.farmId == farmId,
    );

    if (selectedFarm != null) {
      this.selectedFarm.value = selectedFarm;
      // Only show team dropdown if the farm has teams
      showTeamDropdown.value = selectedFarm.productTeamResponse.isNotEmpty;
    } else {
      this.selectedFarm.value = null;
      showTeamDropdown.value = false;
    }

    // Reset dependent selections
    selectedTeam.value = null;
    selectedLot.value = null;
    showLotDropdown.value = false;
    showYearDropdown.value = false;
  }

  void onTeamSelected(int teamId, String teamName) {
    productTeamId.value = teamId;
    productionTeam.value = teamName;

    // Clear lot selections
    farmLotId.value = 0;
    lot.value = '';
    tappingAge.value = '';
    yearShaved.value = 0;

    // Find the selected team from the current farm
    if (selectedFarm.value != null) {
      final selectedTeam =
          selectedFarm.value!.productTeamResponse.firstWhereOrNull(
        (team) => team.productTeamId == teamId,
      );

      if (selectedTeam != null) {
        this.selectedTeam.value = selectedTeam;
        // Only show lot dropdown if the team has lots
        showLotDropdown.value = selectedTeam.farmLotResponse.isNotEmpty;
      } else {
        this.selectedTeam.value = null;
        showLotDropdown.value = false;
      }
    }

    // Reset dependent selections
    selectedLot.value = null;
    showYearDropdown.value = false;
  }

  void onLotSelected(int lotId, String lotName) {
    farmLotId.value = lotId;
    lot.value = lotName;

    // Clear age selections
    tappingAge.value = '';
    yearShaved.value = 0;

    // Find the selected lot from the current team
    if (selectedTeam.value != null) {
      final selectedLot = selectedTeam.value!.farmLotResponse.firstWhereOrNull(
        (lot) => lot.farmLotId == lotId,
      );

      if (selectedLot != null) {
        this.selectedLot.value = selectedLot;
        // Only show year dropdown if the lot has age shaved responses
        final hasValidAges = selectedLot.ageShavedResponse
            .where((age) => age.value != null)
            .isNotEmpty;
        showYearDropdown.value = hasValidAges;
      } else {
        this.selectedLot.value = null;
        showYearDropdown.value = false;
      }
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

  void setEditMode(bool value) {
    isEditMode.value = value;
    if (value) {
      // Load current shaved status if available
      final storedData = storage.read(currentHistoryKey);
      if (storedData is List && storedData.isNotEmpty) {
        // Reset all status counts first
        for (var status in statusList) {
          statusCounts[status.name] = RxInt(0);
        }

        // Find matching records
        final List<Map<String, dynamic>> matchingRecords = [];
        for (var item in storedData) {
          if (item is Map<String, dynamic>) {
            if (item['farmId'].toString() == farmId.value.toString() &&
                item['productTeamId'].toString() ==
                    productTeamId.value.toString() &&
                item['farmLotId'].toString() == farmLotId.value.toString() &&
                item['treeLineName'] == row.value &&
                item['tappingAge'] == tappingAge.value) {
              matchingRecords.add(item);
            }
          }
        }

        // Get the latest record for shaved status and note
        final latestRecord =
            matchingRecords.isNotEmpty ? matchingRecords.last : null;

        if (latestRecord != null) {
          // Sum up all status counts from matching records
          for (var record in matchingRecords) {
            if (record['statusUpdates'] is List) {
              final statusUpdates = record['statusUpdates'] as List;
              for (var update in statusUpdates) {
                if (update is Map<String, dynamic>) {
                  final statusName = update['statusName']?.toString();
                  final value =
                      int.tryParse(update['value']?.toString() ?? '0') ?? 0;
                  if (statusName != null &&
                      statusCounts.containsKey(statusName)) {
                    statusCounts[statusName]!.value +=
                        value; // Add values from all records
                  }
                }
              }
            }
          }

          // Load shaved status from latest record
          final shavedId = latestRecord['shavedStatusId'];
          if (shavedId != null && shavedStatusData.value != null) {
            // Find the status item in all groups
            ShavedStatusItem? foundStatus;
            for (var group in shavedStatusData.value!.toJson().entries) {
              try {
                foundStatus = group.value.firstWhere(
                  (status) => status.id == shavedId,
                  orElse: () => throw StateError('Not found'),
                );
                break; // Exit loop if found
              } catch (e) {
                // Continue searching in next group if not found
                continue;
              }
            }
            selectedShavedStatus.value = foundStatus;
          }

          // Load note from latest record
          final storedNote = latestRecord['note'];
          if (storedNote != null) {
            note.value = storedNote.toString();
            noteController.text = storedNote.toString();
          }
        }
      }
    }
  }

  void saveCurrentStatus() {
    if (isEditMode.value) {
      // When saving in edit mode, replace old records with a new one
      final now = DateTime.now();
      final statusUpdates = <Map<String, dynamic>>[];

      for (var status in statusList) {
        if (statusCounts[status.name]!.value > 0) {
          statusUpdates.add({
            'statusId': status.id,
            'statusName': status.name,
            'value': statusCounts[status.name]!.value.toString(),
          });
        }
      }

      final newRecord = {
        'dateCheck': now.toIso8601String(),
        'farmId': farmId.value,
        'productTeamId': productTeamId.value,
        'farmLotId': farmLotId.value,
        'treeLineName': row.value,
        'tappingAge': tappingAge.value,
        'shavedStatusId': selectedShavedStatus.value?.id,
        'shavedStatusName': selectedShavedStatus.value?.name,
        'statusUpdates': statusUpdates,
        'note': note.value,
      };

      // Get existing data
      final List<dynamic> existingData = storage.read(currentHistoryKey) ?? [];

      // Remove old records for this location
      existingData.removeWhere((item) {
        if (item is Map<String, dynamic>) {
          return item['farmId'].toString() == farmId.value.toString() &&
              item['productTeamId'].toString() ==
                  productTeamId.value.toString() &&
              item['farmLotId'].toString() == farmLotId.value.toString() &&
              item['treeLineName'] == row.value &&
              item['tappingAge'] == tappingAge.value;
        }
        return false;
      });

      // Add new record
      existingData.add(newRecord);

      // Save back to storage
      storage.write(currentHistoryKey, existingData);

      // Reset edit mode
      isEditMode.value = false;
    } else {
      // Normal inventory mode - add to existing values
      final now = DateTime.now();
      final statusUpdates = <Map<String, dynamic>>[];

      for (var status in statusList) {
        if (statusCounts[status.name]!.value > 0) {
          statusUpdates.add({
            'statusId': status.id,
            'statusName': status.name,
            'value': statusCounts[status.name]!.value.toString(),
          });
        }
      }

      final newRecord = {
        'dateCheck': now.toIso8601String(),
        'farmId': farmId.value,
        'productTeamId': productTeamId.value,
        'farmLotId': farmLotId.value,
        'treeLineName': row.value,
        'tappingAge': tappingAge.value,
        'shavedStatusId': selectedShavedStatus.value?.id,
        'shavedStatusName': selectedShavedStatus.value?.name,
        'statusUpdates': statusUpdates,
        'note': note.value,
      };

      // Get existing data
      final List<dynamic> existingData = storage.read(currentHistoryKey) ?? [];

      // Add new record
      existingData.add(newRecord);

      // Save back to storage
      storage.write(currentHistoryKey, existingData);

      // Reset all counts to zero
      for (var status in statusList) {
        statusCounts[status.name]!.value = 0;
      }

      // Reset shaved status and note
      selectedShavedStatus.value = null;
      note.value = '';
      noteController.text = '';
    }

    // Show success message
    Get.snackbar(
      'Thành công',
      'Đã lưu thông tin kiểm kê',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> saveLocalUpdate() async {
    try {
      // Check if any status has been updated
      final hasUpdates = statusCounts.values.any((count) => count.value > 0);
      if (!hasUpdates && selectedShavedStatus.value == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng cập nhật ít nhất một trạng thái hoặc trạng thái cạo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate batch ID
      final batchId = _currentBatchId;
      if (batchId.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy đợt kiểm kê hiện tại',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate tapping age
      if (tappingAge.value.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng nhập tuổi cạo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      int parsedTappingAge;
      try {
        parsedTappingAge = int.parse(tappingAge.value);
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Tuổi cạo không hợp lệ',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Create status updates list
      final statusUpdates = <Map<String, dynamic>>[];
      statusCounts.forEach((statusName, count) {
        if (count.value > 0) {
          final status = statusList.firstWhere((s) => s.name == statusName);
          statusUpdates.add({
            'statusId': status.id.toString(),
            'statusName': statusName,
            'value': count.value.toString(),
          });
        }
      });

      final update = LocalTreeUpdate(
        inventoryBatchId: int.parse(batchId),
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
                  statusId: int.parse(status['statusId']),
                  statusName: status['statusName'],
                  value: status['value'],
                ))
            .toList(),
        note: note.value,
        averageAgeToShave: parsedTappingAge,
      );

      final updateJson = {
        'inventoryBatchId': update.inventoryBatchId.toString(),
        'farmId': update.farmId.toString(),
        'farmName': update.farmName,
        'productTeamId': update.productTeamId.toString(),
        'productTeamName': update.productTeamName,
        'farmLotId': update.farmLotId.toString(),
        'farmLotName': update.farmLotName,
        'treeLineName': update.treeLineName,
        'shavedStatusId': update.shavedStatusId.toString(),
        'shavedStatusName': update.shavedStatusName,
        'tappingAge': update.tappingAge,
        'dateCheck': update.dateCheck.toIso8601String(),
        'statusUpdates': update.statusUpdates
            .map((status) => {
                  'statusId': status.statusId.toString(),
                  'statusName': status.statusName,
                  'value': status.value,
                })
            .toList(),
        'note': update.note,
        'averageAgeToShave': update.averageAgeToShave.toString(),
      };

      print('Local update to save: $updateJson');

      if (isEditMode.value) {
        // In edit mode, override existing data in both storages

        // 1. Override in sync storage
        List<Map<String, dynamic>> syncData = [];
        final storedSyncData = storage.read(_currentSyncKey);
        if (storedSyncData != null && storedSyncData is List) {
          syncData = List<Map<String, dynamic>>.from(storedSyncData);
        }

        final syncIndex = syncData.indexWhere((item) =>
            item['farmId'].toString() == farmId.value.toString() &&
            item['productTeamId'].toString() ==
                productTeamId.value.toString() &&
            item['farmLotId'].toString() == farmLotId.value.toString() &&
            item['treeLineName'] == row.value);

        if (syncIndex != -1) {
          // Override existing sync data
          syncData[syncIndex] = updateJson;
        } else {
          syncData.add(updateJson);
        }
        await storage.write(_currentSyncKey, syncData);

        // 2. Override in history storage
        List<Map<String, dynamic>> historyData = [];
        final storedHistoryData = storage.read(currentHistoryKey);
        if (storedHistoryData != null && storedHistoryData is List) {
          historyData = List<Map<String, dynamic>>.from(storedHistoryData);
        }

        final historyIndex = historyData.indexWhere((item) =>
            item['farmId'].toString() == farmId.value.toString() &&
            item['productTeamId'].toString() ==
                productTeamId.value.toString() &&
            item['farmLotId'].toString() == farmLotId.value.toString() &&
            item['treeLineName'] == row.value);

        if (historyIndex != -1) {
          // Override existing history data
          historyData[historyIndex] = updateJson;
        } else {
          historyData.add(updateJson);
        }
        await storage.write(currentHistoryKey, historyData);
      } else {
        // Normal mode - add to existing values
        // Save to sync storage
        List<Map<String, dynamic>> existingUpdates = [];
        final storedData = storage.read(_currentSyncKey);
        if (storedData != null && storedData is List) {
          existingUpdates = List<Map<String, dynamic>>.from(storedData);
        }
        existingUpdates.add(updateJson);
        await storage.write(_currentSyncKey, existingUpdates);

        // Save to history storage
        List<dynamic> existingData =
            storage.read(currentHistoryKey) as List<dynamic>? ?? [];
        existingData.add(updateJson);
        storage.write(currentHistoryKey, existingData);
      }

      // Reset form
      statusCounts.forEach((key, value) => value.value = 0);
      note.value = '';
      noteController.clear();
      selectedShavedStatus.value = null;
      isEditMode.value = false;

      // Refresh pending updates count
      final syncController = Get.find<SyncController>();
      await syncController.refreshPendingUpdates();

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon success
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green[700],
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  const Text(
                    'Thành công',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Message
                  const Text(
                    'Đã lưu thông tin kiểm kê thành công',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Button group
                  Column(
                    children: [
                      // Primary action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(); // Đóng dialog
                            Get.offNamed(Routes.sync);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Đến màn hình đồng bộ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Secondary action button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            final currentRow = int.parse(row.value);
                            if (currentRow < totalRows) {
                              row.value = (currentRow + 1).toString();
                            }
                            statusCounts
                                .forEach((key, value) => value.value = 0);
                            note.value = '';
                            noteController.clear();
                            selectedShavedStatus.value = null;
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[700],
                            side: BorderSide(color: Colors.green[700]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Chuyển qua hàng tiếp theo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
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
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: screenWidth * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fact_check_rounded,
                  color: Colors.green[700],
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Xác nhận thông tin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Location info in a decorated container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildLocationInfoRow(
                      Icons.location_on,
                      'Nông trường:',
                      farm.value,
                      Colors.green[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildLocationInfoRow(
                      Icons.group,
                      'Tổ:',
                      productionTeam.value,
                      Colors.green[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildLocationInfoRow(
                      Icons.grid_view,
                      'Lô:',
                      lot.value,
                      Colors.green[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildLocationInfoRow(
                      Icons.calendar_today,
                      'Tuổi cạo:',
                      '$tappingAge tuổi',
                      Colors.green[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildLocationInfoRow(
                      Icons.format_list_numbered,
                      'Hàng:',
                      row.value,
                      Colors.green[700]!,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Tree status section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.forest,
                          color: Colors.green[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Số lượng theo trạng thái',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Total tree count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[700]!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green[700]!.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tổng số cây',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[700]!.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusCounts.values
                                      .fold<int>(
                                        0,
                                        (sum, count) => sum + count.value,
                                      )
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Individual status counts
                        ...statusList.map((condition) {
                          final count = statusCounts[condition.name] ?? 0;
                          if (count == 0) return const SizedBox.shrink();

                          final color =
                              statusColors[condition.name] ?? Colors.grey;
                          return Container(
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  condition.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                        }).where((widget) => widget != const SizedBox.shrink()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Shaved status in a decorated container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.face,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trạng thái mặt cạo: ${selectedShavedStatus.value?.name ?? ''}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (note.value.isNotEmpty) ...[
                const SizedBox(height: 20),
                // Note in a separate container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ghi chú',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
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
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        saveLocalUpdate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildLocationInfoRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 4),
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
              _showErrorMessage(
                  'Lỗi', 'Không thể tải dữ liệu từ máy chủ. Vui lòng thử lại.');
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
