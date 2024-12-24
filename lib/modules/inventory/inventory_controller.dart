import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
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
  final RxString tappingAge = 'N/A'.obs;
  final List<String> tappingAges = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  final RxString farm = 'N/A'.obs;
  final RxString productionTeam = 'N/A'.obs;
  final RxString lot = 'N/A'.obs;
  final RxString row = 'N/A'.obs;

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

  final RxList<String> farms =
      ['Nông trường 1', 'Nông trường 2', 'Nông trường 3'].obs;
  final RxList<String> lots = ['Lô A', 'Lô B', 'Lô C', 'Lô D'].obs;
  final RxList<String> teams = ['Tổ 1', 'Tổ 2', 'Tổ 3', 'Tổ 4'].obs;
  final RxList<String> rows =
      ['Hàng 1', 'Hàng 2', 'Hàng 3', 'Hàng 4', 'Hàng 5'].obs;

  final Map<String, List<String>> lotsMap = {
    'Nông trường 1': ['Lô A', 'Lô B', 'Lô C'],
    'Nông trường 2': ['Lô D', 'Lô E', 'Lô F'],
    'Nông trường 3': ['Lô G', 'Lô H', 'Lô I'],
  };

  final Map<String, List<String>> rowsMap = {
    'Lô A': ['Hàng 1', 'Hàng 2', 'Hàng 3'],
    'Lô B': ['Hàng 4', 'Hàng 5', 'Hàng 6'],
    'Lô C': ['Hàng 7', 'Hàng 8', 'Hàng 9'],
    'Lô D': ['Hàng 10', 'Hàng 11', 'Hàng 12'],
    'Lô E': ['Hàng 13', 'Hàng 14', 'Hàng 15'],
    'Lô F': ['Hàng 16', 'Hàng 17', 'Hàng 18'],
    'Lô G': ['Hàng 19', 'Hàng 20', 'Hàng 21'],
    'Lô H': ['Hàng 22', 'Hàng 23', 'Hàng 24'],
    'Lô I': ['Hàng 25', 'Hàng 26', 'Hàng 27'],
  };

  final ApiProvider _apiProvider = ApiProvider();

  final farmId = 0.obs;
  final productTeamId = 0.obs;
  final farmLotId = 0.obs;
  final shavedStatus = 0.obs;

  List<String> getLotsForFarm(String farm) {
    return lotsMap[farm] ?? [];
  }

  List<String> getRowsForLot(String lot) {
    return rowsMap[lot] ?? [];
  }

  void updateFarm(String newFarm) {
    farm.value = newFarm;
    final lots = getLotsForFarm(newFarm);
    if (lots.isNotEmpty) {
      lot.value = lots.first;
      final rows = getRowsForLot(lots.first);
      if (rows.isNotEmpty) {
        row.value = rows.first;
      }
    }
  }

  void updateLot(String newLot) {
    lot.value = newLot;
    final rows = getRowsForLot(newLot);
    if (rows.isNotEmpty) {
      row.value = rows.first;
    }
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
            statusId: int.parse(status.id.toString()),
            statusName: status.name,
            value: count.value.toString(),
          ));
        }
      }

      final localUpdate = LocalTreeUpdate(
        farmId: int.parse(farmId.value.toString()),
        farmName: farm.value,
        productTeamId: int.parse(productTeamId.value.toString()),
        productTeamName: productionTeam.value,
        farmLotId: int.parse(farmLotId.value.toString()),
        farmLotName: lot.value,
        treeLineName: row.value,
        shavedStatus: shavedStatus.value,
        dateCheck: now,
        statusUpdates: statusUpdates,
        note: note.value,
      );

      // Chuyển đổi sang JSON và xử lý DateTime
      final Map<String, dynamic> updateJson = localUpdate.toJson();
      updateJson['dateCheck'] = now.toIso8601String(); // Chuyển DateTime sang String

      // Chuyển đổi statusUpdates sang JSON
      updateJson['statusUpdates'] = statusUpdates.map((status) => status.toJson()).toList();

      print('Local update to save: $updateJson');

      // Đọc updates hiện có
      List<Map<String, dynamic>> existingUpdates = [];
      final storedData = storage.read('local_updates');
      if (storedData != null) {
        if (storedData is List) {
          existingUpdates = List<Map<String, dynamic>>.from(storedData);
        } else if (storedData is String) {
          // Xóa dữ liệu cũ nếu không đúng định dạng
          await storage.remove('local_updates');
        }
      }

      // Thêm update mới
      existingUpdates.add(updateJson);

      // Lưu lại vào storage
      await storage.write('local_updates', existingUpdates);
      print('Saved updates: $existingUpdates');

      // Refresh sync screen data
      final syncController = Get.find<SyncController>();
      syncController.loadPendingUpdates();

      Get.back();
      Get.snackbar(
        'Thành công',
        'Đã lưu cập nhật thành công',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      print('Error saving local update: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Lỗi',
        'Không thể lưu cập nhật. Vui lòng thử lại',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void submitInventory() {
    showFinishDialog();
  }

  void showFinishDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.orange,
            ),
            SizedBox(width: 8),
            Text('Xác nhận'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn kết thúc không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              bool hasUpdates = false;
              statusCounts.forEach((key, value) {
                if (value.value > 0) {
                  hasUpdates = true;
                }
              });

              if (!hasUpdates) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Thông báo'),
                    content: const Text(
                        'Không có trạng thái cây nào được cập nhật. Bạn có muốn qua hàng tiếp theo không?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Không'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          row.value = getRowsForLot(lot.value)[
                              (getRowsForLot(lot.value).indexOf(row.value) +
                                      1) %
                                  getRowsForLot(lot.value).length];
                          statusCounts.forEach((key, value) {
                            value.value = 0;
                          });
                          update(['row']);
                          update(['status_counts']);
                        },
                        child: const Text('Có'),
                      ),
                    ],
                  ),
                );
              } else {
                await saveLocalUpdate();
                Get.delete<UpdateTreeController>();
                Get.put(UpdateTreeController());

                Map<String, int> finalCounts = {};
                statusCounts.forEach((key, value) {
                  if (value.value > 0) {
                    finalCounts[key] = value.value;
                  }
                });

                final result = await Get.to<Map<String, dynamic>>(
                  () => UpdateTreeScreen(
                    farm: farm.value,
                    lot: lot.value,
                    team: productionTeam.value,
                    row: row.value,
                    statusCounts: finalCounts,
                  ),
                );

                if (result != null) {
                  statusCounts.forEach((key, value) {
                    value.value = 0;
                  });
                  row.value = result['row'] as String;
                  update(['row']);
                  update(['status_counts']);

                  Get.snackbar(
                    'Thành công',
                    'Đã lưu dữ liệu kiểm kê',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );

                  final currentRowIndex =
                      getRowsForLot(lot.value).indexOf(row.value);
                  if (currentRowIndex < getRowsForLot(lot.value).length - 1) {
                    row.value = getRowsForLot(lot.value)[currentRowIndex + 1];
                  }
                }
              }
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchStatusData();
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
        shavedStatus.value = farmData.ageShaved;
      }
    } catch (e) {
      print('Error fetching profile: $e');
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
