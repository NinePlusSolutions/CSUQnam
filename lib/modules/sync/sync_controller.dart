import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
import 'package:flutter_getx_boilerplate/models/tree_condition/tree_condition_request.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';

class SyncController extends GetxController {
  final _apiProvider = Get.find<ApiProvider>();
  final GetStorage _storage = GetStorage();

  static const String syncStorageKey = 'local_updates';
  static const String historyStorageKey = 'history_updates';

  String get _currentBatchId =>
      _storage.read('current_batch_id')?.toString() ?? '';
  String get _currentSyncKey => '${syncStorageKey}_$_currentBatchId';
  String get _currentHistoryKey => '${historyStorageKey}_$_currentBatchId';

  final RxList<LocalTreeUpdate> pendingUpdates = <LocalTreeUpdate>[].obs;
  final isLoading = false.obs;
  final syncProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingUpdates();
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> loadPendingUpdates() async {
    try {
      final storedData = _storage.read(_currentSyncKey);
      print('Loaded data from storage: $storedData');

      if (storedData != null && storedData is List) {
        final Map<String, LocalTreeUpdate> groupedUpdates = {};

        for (var item in storedData) {
          try {
            if (item is Map<String, dynamic>) {
              // Chỉ xử lý những record chưa được sync
              if (item['isSynced'] == true) continue;

              final dateCheck = DateTime.parse(item['dateCheck']);
              final List<LocalStatusUpdate> statusUpdates = [];

              if (item['statusUpdates'] is List) {
                for (var status in item['statusUpdates']) {
                  if (status is Map<String, dynamic>) {
                    statusUpdates.add(LocalStatusUpdate(
                      statusId: int.parse(status['statusId'] ?? '0'),
                      statusName: status['statusName'] ?? '',
                      value: status['value']?.toString() ?? '0',
                    ));
                  }
                }
              }

              final update = LocalTreeUpdate(
                inventoryBatchId: int.parse(item['inventoryBatchId'] ?? '0'),
                farmId: int.parse(item['farmId'] ?? '0'),
                farmName: item['farmName'] ?? '',
                productTeamId: int.parse(item['productTeamId'] ?? '0'),
                productTeamName: item['productTeamName'] ?? '',
                farmLotId: int.parse(item['farmLotId'] ?? '0'),
                farmLotName: item['farmLotName'] ?? '',
                treeLineName: item['treeLineName'] ?? '',
                shavedStatusId: int.parse(item['shavedStatusId'] ?? '0'),
                shavedStatusName: item['shavedStatusName'] ?? '',
                tappingAge: item['tappingAge'] ?? '',
                dateCheck: dateCheck,
                statusUpdates: statusUpdates,
                note: item['note'],
                averageAgeToShave: int.parse(item['averageAgeToShave'] ?? '0'),
              );

              // Create a unique key for grouping
              final key =
                  '${update.farmId}_${update.productTeamId}_${update.farmLotId}_${update.tappingAge}_${update.treeLineName}';

              if (groupedUpdates.containsKey(key)) {
                // If we already have an update with this key, merge the status updates
                final existingUpdate = groupedUpdates[key]!;

                // Create a map of existing status updates for easy lookup
                Map<int, LocalStatusUpdate> existingStatusMap = {
                  for (var status in existingUpdate.statusUpdates)
                    status.statusId: status
                };

                // Merge status updates
                for (var newStatus in update.statusUpdates) {
                  if (existingStatusMap.containsKey(newStatus.statusId)) {
                    // Add values for existing status
                    final existingValue =
                        int.parse(existingStatusMap[newStatus.statusId]!.value);
                    final newValue = int.parse(newStatus.value);

                    // Create new instance with updated value
                    existingStatusMap[newStatus.statusId] = LocalStatusUpdate(
                      statusId: newStatus.statusId,
                      statusName: newStatus.statusName,
                      value: (existingValue + newValue).toString(),
                    );
                  } else {
                    // Add new status
                    existingStatusMap[newStatus.statusId] = newStatus;
                  }
                }

                // Update the existing update with merged status updates
                existingUpdate.statusUpdates.clear();
                existingUpdate.statusUpdates.addAll(existingStatusMap.values);
              } else {
                // Add new update to the map
                groupedUpdates[key] = update;
              }
            }
          } catch (e) {
            print('Error parsing sync item: $e');
          }
        }

        // Convert grouped updates to list and sort by date
        final List<LocalTreeUpdate> sortedUpdates =
            groupedUpdates.values.toList();
        sortedUpdates.sort((a, b) => b.dateCheck.compareTo(a.dateCheck));

        pendingUpdates.value = sortedUpdates;
      } else {
        pendingUpdates.clear();
      }
    } catch (e) {
      print('Error loading pending updates: $e');
      pendingUpdates.clear();
    }
  }

  Future<void> syncUpdates() async {
    try {
      isLoading.value = true;

      // Lấy tất cả dữ liệu từ storage
      final storedData = _storage.read(_currentSyncKey);
      if (storedData == null || storedData is! List) {
        throw Exception('No data to sync');
      }

      final List<Map<String, dynamic>> allUpdates =
          List<Map<String, dynamic>>.from(storedData);

      // Map để gom nhóm tất cả records (cả đã sync và chưa sync)
      final Map<String, LocalTreeUpdate> groupedAllUpdates = {};

      // Xử lý tất cả records
      for (var item in allUpdates) {
        try {
          final dateCheck = DateTime.parse(item['dateCheck']);
          final List<LocalStatusUpdate> statusUpdates = [];

          if (item['statusUpdates'] is List) {
            for (var status in item['statusUpdates']) {
              if (status is Map<String, dynamic>) {
                statusUpdates.add(LocalStatusUpdate(
                  statusId: int.parse(status['statusId'] ?? '0'),
                  statusName: status['statusName'] ?? '',
                  value: status['value']?.toString() ?? '0',
                ));
              }
            }
          }

          final update = LocalTreeUpdate(
            inventoryBatchId: int.parse(item['inventoryBatchId'] ?? '0'),
            farmId: int.parse(item['farmId'] ?? '0'),
            farmName: item['farmName'] ?? '',
            productTeamId: int.parse(item['productTeamId'] ?? '0'),
            productTeamName: item['productTeamName'] ?? '',
            farmLotId: int.parse(item['farmLotId'] ?? '0'),
            farmLotName: item['farmLotName'] ?? '',
            treeLineName: item['treeLineName'] ?? '',
            shavedStatusId: int.parse(item['shavedStatusId'] ?? '0'),
            shavedStatusName: item['shavedStatusName'] ?? '',
            tappingAge: item['tappingAge'] ?? '',
            dateCheck: dateCheck,
            statusUpdates: statusUpdates,
            note: item['note'],
            averageAgeToShave: int.parse(item['averageAgeToShave'] ?? '0'),
          );

          // Create a unique key for grouping
          final key =
              '${update.farmId}_${update.productTeamId}_${update.farmLotId}_${update.tappingAge}_${update.treeLineName}';

          if (groupedAllUpdates.containsKey(key)) {
            // If we already have an update with this key, merge the status updates
            final existingUpdate = groupedAllUpdates[key]!;

            // Create a map of existing status updates for easy lookup
            Map<int, LocalStatusUpdate> existingStatusMap = {
              for (var status in existingUpdate.statusUpdates)
                status.statusId: status
            };

            // Merge status updates
            for (var newStatus in update.statusUpdates) {
              if (existingStatusMap.containsKey(newStatus.statusId)) {
                // Add values for existing status
                final existingValue =
                    int.parse(existingStatusMap[newStatus.statusId]!.value);
                final newValue = int.parse(newStatus.value);

                // Create new instance with updated value
                existingStatusMap[newStatus.statusId] = LocalStatusUpdate(
                  statusId: newStatus.statusId,
                  statusName: newStatus.statusName,
                  value: (existingValue + newValue).toString(),
                );
              } else {
                // Add new status
                existingStatusMap[newStatus.statusId] = newStatus;
              }
            }

            // Update the existing update with merged status updates
            existingUpdate.statusUpdates.clear();
            existingUpdate.statusUpdates.addAll(existingStatusMap.values);
          } else {
            // Add new update to the map
            groupedAllUpdates[key] = update;
          }
        } catch (e) {
          print('Error processing update for sync: $e');
        }
      }

      // Convert all updates to TreeCondition objects for API request
      final treeConditions = groupedAllUpdates.values.map((update) {
        final details = update.statusUpdates.map((status) {
          return TreeConditionDetail(
            statusId: status.statusId,
            statusName: status.statusName,
            value: status.value, // Sửa lại không parse sang int nữa
          );
        }).toList();

        return TreeCondition(
          inventoryBatchId: update.inventoryBatchId,
          farmId: update.farmId,
          farmName: update.farmName,
          productTeamId: update.productTeamId,
          productTeamName: update.productTeamName,
          farmLotId: update.farmLotId,
          farmLotName: update.farmLotName,
          treeLineName: "Hàng ${update.treeLineName}",
          shavedStatus: update.shavedStatusId,
          shavedStatusName: update.shavedStatusName,
          description: update.note,
          dateCheck: update.dateCheck,
          treeConditionDetails: details,
          averageAgeToShave: update.averageAgeToShave,
        );
      }).toList();

      final request = TreeConditionRequest(
        treeConditionList: treeConditions,
      );

      final response = await _apiProvider.syncTreeCondition(request);

      if (response.statusCode == 200 && response.data['status'] == true) {
        // Đánh dấu tất cả records là đã sync
        for (var i = 0; i < allUpdates.length; i++) {
          allUpdates[i] = {...allUpdates[i], 'isSynced': true};
        }

        // Lưu lại vào storage
        await _storage.write(_currentSyncKey, allUpdates);

        // Refresh danh sách pending updates (chỉ hiển thị những record chưa sync)
        await loadPendingUpdates();

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Thành công',
            'Đã đồng bộ dữ liệu thành công',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        });
      } else {
        throw Exception('Sync failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing updates: $e');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Lỗi',
          'Không thể đồng bộ dữ liệu. Vui lòng thử lại',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncSingleUpdate(LocalTreeUpdate update) async {
    try {
      isLoading.value = true;

      // Convert single update to TreeCondition
      final details = update.statusUpdates.map((statusUpdate) {
        return TreeConditionDetail(
          statusId: statusUpdate.statusId,
          statusName: statusUpdate.statusName,
          value: statusUpdate.value, // Sửa lại không parse sang int nữa
        );
      }).toList();

      final treeCondition = TreeCondition(
        inventoryBatchId: update.inventoryBatchId,
        farmId: update.farmId,
        farmName: update.farmName,
        productTeamId: update.productTeamId,
        productTeamName: update.productTeamName,
        farmLotId: update.farmLotId,
        farmLotName: update.farmLotName,
        treeLineName: "Hàng ${update.treeLineName}",
        shavedStatus: update.shavedStatusId,
        shavedStatusName: update.shavedStatusName,
        description: update.note,
        dateCheck: update.dateCheck,
        treeConditionDetails: details,
        averageAgeToShave: update.averageAgeToShave,
      );

      // Create request with single item
      final request = TreeConditionRequest(
        treeConditionList: [treeCondition],
      );

      // Check internet connection first
      final hasInternet = await checkInternetConnection();
      if (!hasInternet) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Lỗi kết nối',
            'Không có kết nối mạng. Vui lòng kiểm tra lại kết nối của bạn.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        });
        return;
      }

      // Send to server
      final response = await _apiProvider.syncTreeCondition(request);

      if (response.statusCode == 200) {
        // Get existing updates from storage
        final List<Map<String, dynamic>> existingUpdates = [];
        final storedData = _storage.read(_currentSyncKey);
        if (storedData != null && storedData is List) {
          existingUpdates.addAll(List<Map<String, dynamic>>.from(storedData));
        }

        // Find and mark the synced update
        for (var i = 0; i < existingUpdates.length; i++) {
          if (existingUpdates[i]['farmId'].toString() ==
                  update.farmId.toString() &&
              existingUpdates[i]['farmLotId'].toString() ==
                  update.farmLotId.toString() &&
              existingUpdates[i]['treeLineName'] == update.treeLineName &&
              existingUpdates[i]['dateCheck'] ==
                  update.dateCheck.toIso8601String()) {
            existingUpdates[i] = {...existingUpdates[i], 'isSynced': true};
          }
        }

        // Save back to storage
        await _storage.write(_currentSyncKey, existingUpdates);

        // Reload pending updates to refresh UI
        await loadPendingUpdates();

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Thành công',
            'Đã đồng bộ dữ liệu của ${update.farmName}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        });
      } else {
        throw Exception('Sync failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing single update: $e');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Lỗi',
          'Không thể đồng bộ dữ liệu. Vui lòng thử lại',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearAllData() async {
    try {
      final List<Map<String, dynamic>> existingUpdates = [];
      final storedData = _storage.read(_currentSyncKey);
      if (storedData != null && storedData is List) {
        existingUpdates.addAll(List<Map<String, dynamic>>.from(storedData));
      }

      // Mark all records as synced
      for (var i = 0; i < existingUpdates.length; i++) {
        existingUpdates[i] = {...existingUpdates[i], 'isSynced': true};
      }

      // Save back to storage
      await _storage.write(_currentSyncKey, existingUpdates);
      await loadPendingUpdates(); // Reload to update UI

      Get.back(); // Close confirmation dialog
      Get.snackbar(
        'Thành công',
        'Đã xóa tất cả dữ liệu',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error clearing data: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể xóa dữ liệu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteSingleUpdate(LocalTreeUpdate update) async {
    try {
      final List<Map<String, dynamic>> existingUpdates = [];
      final storedData = _storage.read(_currentSyncKey);
      if (storedData != null && storedData is List) {
        existingUpdates.addAll(List<Map<String, dynamic>>.from(storedData));
      }

      // Find and mark the update as synced
      for (var i = 0; i < existingUpdates.length; i++) {
        if (existingUpdates[i]['farmId'].toString() ==
                update.farmId.toString() &&
            existingUpdates[i]['farmLotId'].toString() ==
                update.farmLotId.toString() &&
            existingUpdates[i]['treeLineName'] == update.treeLineName &&
            existingUpdates[i]['dateCheck'] ==
                update.dateCheck.toIso8601String()) {
          existingUpdates[i] = {...existingUpdates[i], 'isSynced': true};
        }
      }

      // Save back to storage
      await _storage.write(_currentSyncKey, existingUpdates);
      await loadPendingUpdates();

      Get.snackbar(
        'Thành công',
        'Đã xóa dữ liệu của ${update.farmName}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting single update: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể xóa dữ liệu: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshPendingUpdates() async {
    await loadPendingUpdates();
  }
}
