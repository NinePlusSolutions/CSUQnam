import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
import 'package:flutter_getx_boilerplate/models/tree_condition/tree_condition_request.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SyncController extends GetxController {
  final _apiProvider = Get.find<ApiProvider>();
  final _storage = GetStorage();

  final pendingUpdates = <LocalTreeUpdate>[].obs;
  final isSyncing = false.obs;
  final syncProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingUpdates();
  }

  void loadPendingUpdates() {
    try {
      final List<dynamic> storedData = _storage.read('local_updates') ?? [];
      print('Loaded data from storage: $storedData');

      if (storedData.isEmpty) {
        pendingUpdates.clear();
        return;
      }

      final List<LocalTreeUpdate> updates = storedData.map((json) {
        if (json is! Map<String, dynamic>) {
          print('Invalid data format: $json');
          throw const FormatException('Invalid data format');
        }

        try {
          // Convert statusUpdates from List<dynamic> to List<Map<String, dynamic>>
          if (json['statusUpdates'] is List) {
            final List<dynamic> statusList = json['statusUpdates'];
            json['statusUpdates'] = statusList.map((status) {
              if (status is! Map<String, dynamic>) {
                print('Invalid status format: $status');
                throw const FormatException('Invalid status format');
              }
              // Đảm bảo các trường có kiểu dữ liệu đúng
              return {
                'statusId': int.parse(status['statusId'].toString()),
                'statusName': status['statusName'].toString(),
                'value': status['value'].toString(),
              };
            }).toList();
          }

          print('Converting JSON to LocalTreeUpdate: $json');
          return LocalTreeUpdate.fromJson(json);
        } catch (e) {
          print('Error converting JSON: $e');
          print('Problematic JSON: $json');
          rethrow;
        }
      }).toList();

      pendingUpdates.value = updates;
      print('Successfully loaded ${updates.length} updates');
    } catch (e, stackTrace) {
      print('Error loading pending updates: $e');
      print('Stack trace: $stackTrace');
      pendingUpdates.clear();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Lỗi',
          'Không thể tải dữ liệu cập nhật',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
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
          shavedStatus: update.shavedStatus,
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
