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

  String get _currentBatchId => _storage.read('current_batch_id')?.toString() ?? '';
  String get _currentSyncKey => '${syncStorageKey}_${_currentBatchId}';
  String get _currentHistoryKey => '${historyStorageKey}_${_currentBatchId}';

  final RxList<LocalTreeUpdate> pendingUpdates = <LocalTreeUpdate>[].obs;
  final isSyncing = false.obs;
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
              final dateCheck = DateTime.parse(item['dateCheck']);
              final List<LocalStatusUpdate> statusUpdates = [];

              if (item['statusUpdates'] is List) {
                for (var status in item['statusUpdates']) {
                  if (status is Map<String, dynamic>) {
                    statusUpdates.add(LocalStatusUpdate(
                      statusId: status['statusId'],
                      statusName: status['statusName'],
                      value: status['value'],
                    ));
                  }
                }
              }

              final update = LocalTreeUpdate(
                farmId: item['farmId'],
                farmName: item['farmName'],
                productTeamId: item['productTeamId'],
                productTeamName: item['productTeamName'],
                farmLotId: item['farmLotId'],
                farmLotName: item['farmLotName'],
                treeLineName: item['treeLineName'],
                shavedStatusId: item['shavedStatusId'],
                shavedStatusName: item['shavedStatusName'],
                tappingAge: item['tappingAge'],
                dateCheck: dateCheck,
                statusUpdates: statusUpdates,
                note: item['note'],
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
                    // Create new LocalStatusUpdate instance with updated value
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

                // Update the grouped entry with merged status updates and latest date
                groupedUpdates[key] = LocalTreeUpdate(
                  farmId: update.farmId,
                  farmName: update.farmName,
                  productTeamId: update.productTeamId,
                  productTeamName: update.productTeamName,
                  farmLotId: update.farmLotId,
                  farmLotName: update.farmLotName,
                  treeLineName: update.treeLineName,
                  shavedStatusId: update.shavedStatusId,
                  shavedStatusName: update.shavedStatusName,
                  tappingAge: update.tappingAge,
                  dateCheck: update.dateCheck.isAfter(existingUpdate.dateCheck)
                      ? update.dateCheck
                      : existingUpdate.dateCheck,
                  statusUpdates: existingStatusMap.values.toList(),
                  note: update.note,
                );
              } else {
                // If this is the first update with this key, add it to the map
                groupedUpdates[key] = update;
              }
            }
          } catch (e) {
            print('Error parsing item: $e');
          }
        }

        // Convert map values to list and sort by dateCheck
        final updates = groupedUpdates.values.toList()
          ..sort((a, b) => b.dateCheck.compareTo(a.dateCheck));

        pendingUpdates.value = updates;
      } else {
        pendingUpdates.clear();
      }
    } catch (e) {
      print('Error loading pending updates: $e');
      pendingUpdates.clear();
    }
  }

  Future<void> syncUpdates() async {
    if (pendingUpdates.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Thông báo',
          'Không có dữ liệu cần đồng bộ',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      });
      return;
    }

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

    try {
      isSyncing.value = true;
      syncProgress.value = 0.0;

      // Convert LocalTreeUpdate to TreeCondition
      final treeConditions = pendingUpdates.map((update) {
        final details = update.statusUpdates
            .map((statusUpdate) => TreeConditionDetail(
                  statusId: statusUpdate.statusId,
                  value: statusUpdate.value, // Use the count value directly
                ))
            .toList();

        return TreeCondition(
          farmId: update.farmId,
          productTeamId: update.productTeamId,
          farmLotId: update.farmLotId,
          treeLineName: "Hàng ${update.treeLineName}",
          shavedStatus: update.shavedStatusId,
          description: update.note,
          dateCheck: update.dateCheck,
          treeConditionDetails: details,
        );
      }).toList();
      final request = TreeConditionRequest(
        treeConditionList: treeConditions,
      );
      final response = await _apiProvider.syncTreeCondition(request);

      if (response.statusCode == 200 && response.data['status'] == true) {
        // Clear local storage after successful sync
        await _storage.write(_currentSyncKey, []);
        pendingUpdates.clear();

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
      isSyncing.value = false;
      syncProgress.value = 0.0;
    }
  }

  Future<void> syncSingleUpdate(LocalTreeUpdate update) async {
    try {
      isSyncing.value = true;

      // Convert single update to TreeCondition
      final details = update.statusUpdates
          .map((statusUpdate) => TreeConditionDetail(
                statusId: statusUpdate.statusId,
                value: statusUpdate.value, // Use the count value directly
              ))
          .toList();

      final treeCondition = TreeCondition(
        farmId: update.farmId,
        productTeamId: update.productTeamId,
        farmLotId: update.farmLotId,
        treeLineName: "Hàng ${update.treeLineName}",
        shavedStatus: update.shavedStatusId,
        description: update.note,
        dateCheck: update.dateCheck,
        treeConditionDetails: details,
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
        // Remove synced update from local storage
        final List<Map<String, dynamic>> existingUpdates = [];
        final storedData = _storage.read(_currentSyncKey);
        if (storedData != null && storedData is List) {
          existingUpdates.addAll(List<Map<String, dynamic>>.from(storedData));
        }

        // Remove the synced update
        existingUpdates.removeWhere((item) =>
            item['farmId'] == update.farmId &&
            item['farmLotId'] == update.farmLotId &&
            item['treeLineName'] == update.treeLineName &&
            item['dateCheck'] == update.dateCheck.toIso8601String());

        await _storage.write(_currentSyncKey, existingUpdates);
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
      isSyncing.value = false;
    }
  }

  Future<void> clearSyncedData() async {
    try {
      if (_currentBatchId.isEmpty) {
        print('No active batch found');
        return;
      }

      // Get existing history data
      final historyData = _storage.read(_currentHistoryKey) ?? [];
      final syncData = _storage.read(_currentSyncKey) ?? [];

      // Add sync data to history before clearing
      if (syncData is List) {
        List<dynamic> newHistory = List.from(historyData);
        newHistory.addAll(syncData);
        await _storage.write(_currentHistoryKey, newHistory);
      }

      // Clear sync data
      await _storage.write(_currentSyncKey, []);
      pendingUpdates.clear();

    } catch (e) {
      print('Error clearing synced data: $e');
    }
  }

  Future<void> deleteSingleUpdate(LocalTreeUpdate update) async {
    try {
      final List<Map<String, dynamic>> existingUpdates = [];
      final storedData = _storage.read(_currentSyncKey);
      if (storedData != null && storedData is List) {
        existingUpdates.addAll(List<Map<String, dynamic>>.from(storedData));
      }

      // Remove the update
      existingUpdates.removeWhere((item) =>
          item['farmId'] == update.farmId &&
          item['farmLotId'] == update.farmLotId &&
          item['treeLineName'] == update.treeLineName &&
          item['dateCheck'] == update.dateCheck.toIso8601String());

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
}
