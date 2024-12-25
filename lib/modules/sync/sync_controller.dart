import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
import 'package:flutter_getx_boilerplate/models/tree_condition/tree_condition_request.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SyncController extends GetxController {
  final _apiProvider = Get.find<ApiProvider>();
  final GetStorage _storage = GetStorage();

  final RxList<LocalTreeUpdate> pendingUpdates = <LocalTreeUpdate>[].obs;
  final isSyncing = false.obs;
  final syncProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingUpdates();
  }

  Future<void> loadPendingUpdates() async {
    try {
      final storedData = _storage.read('local_updates');
      print('Loaded data from storage: $storedData');

      if (storedData != null && storedData is List) {
        final List<LocalTreeUpdate> updates = [];

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

              updates.add(LocalTreeUpdate(
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
              ));
              print('Loaded update with tapping age: ${item['tappingAge']}');
            }
          } catch (e) {
            print('Error parsing item: $e');
            print('Problematic item: $item');
          }
        }

        print('Successfully loaded ${updates.length} updates');
        pendingUpdates.value = updates;
      } else {
        print('No valid data found in storage');
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

    try {
      isSyncing.value = true;
      syncProgress.value = 0.0;

      // Convert LocalTreeUpdate to TreeCondition
      final treeConditions = pendingUpdates.map((update) {
        final details = update.statusUpdates
            .map((statusUpdate) => TreeConditionDetail(
                  statusId: statusUpdate.statusId,
                  value: statusUpdate.value,
                ))
            .toList();

        return TreeCondition(
          farmId: update.farmId,
          productTeamId: update.productTeamId,
          farmLotId: update.farmLotId,
          treeLineName: update.treeLineName,
          shavedStatus: update.shavedStatusId,
          dateCheck: update.dateCheck,
          treeConditionDetails: details,
        );
      }).toList();

      // Create request
      final request = TreeConditionRequest(treeConditionList: treeConditions);

      // Send to server
      final response = await _apiProvider.syncTreeCondition(request);

      if (response.statusCode == 200) {
        // Clear local storage after successful sync
        await _storage.write('local_updates', []);
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

  Future<void> clearPendingUpdates() async {
    try {
      await _storage.write('local_updates', []);
      pendingUpdates.clear();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Thành công',
          'Đã xóa tất cả dữ liệu cập nhật',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('Error clearing pending updates: $e');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Lỗi',
          'Không thể xóa dữ liệu cập nhật',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    }
  }
}
