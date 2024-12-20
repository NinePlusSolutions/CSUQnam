import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/response/status_response.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/update_tree_controller.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:get/get.dart';
import 'update_tree_screen.dart';

class StatusInfo {
  final String code;
  final String description;

  StatusInfo(this.code, this.description);
}

class InventoryController extends GetxController {
  final RxList<StatusInfo> statusList = <StatusInfo>[].obs;
  final RxMap<String, RxInt> statusCounts = <String, RxInt>{}.obs;
  final RxString note = ''.obs;
  final RxString tappingAge = 'Năm 1'.obs;

  // Farm, lot, and row information
  final RxString farm = 'Nông trường 1'.obs;
  final RxString productionTeam = 'Tổ 1'.obs;
  final RxString lot = 'Lô A'.obs;
  final RxString row = 'Hàng 1'.obs;

  // Trạng thái cho phép chỉnh sửa
  final RxBool isEditingEnabled = true.obs;

  // Danh sách dữ liệu mẫu cho các dropdown
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

  // Map màu cho từng trạng thái
  final RxMap<String, Color> statusColors = <String, Color>{}.obs;
  final RxBool isLoading = false.obs;

  // List of predefined colors for statuses
  final List<Color> _statusColorPalette = [
    Colors.blue, // 1
    Colors.green, // 2
    Colors.teal, // 3
    Colors.purple, // 4
    Colors.orange, // 5
    Colors.red, // 6
    Colors.pink, // 7
    Colors.grey, // 8
    Colors.brown, // 9
    Colors.red[700]!, // 10
    Colors.red[900]!, // 11
  ];

  @override
  void onInit() {
    super.onInit();
    fetchStatusData();
  }

  Future<void> fetchStatusData() async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.getStatus();
      final statusResponse = StatusResponse.fromJson(response.data);

      statusList.clear();
      statusCounts.clear();

      final statuses = statusResponse.data
          .map((item) => StatusInfo(item.name, item.description))
          .toList();

      statusList.addAll(statuses);

      for (var item in statusResponse.data) {
        // Assign color based on item's ID (1-based index)
        // If ID is out of range, use grey as default
        final colorIndex = (item.id - 1) % _statusColorPalette.length;
        statusColors[item.name] = _statusColorPalette[colorIndex];
        statusCounts[item.name] = 0.obs;
      }
    } catch (e) {
      print('Error fetching status data: $e');
      // In case of error, initialize with default values
      final defaultStatuses = [
        StatusInfo('N', 'Cây cạo ngửa'),
        StatusInfo('U', 'Cây cạo úp'),
        StatusInfo('UN', 'Cây cạo úp ngửa'),
        StatusInfo('KB', 'Cây khô miệng cạo'),
        StatusInfo('KG', 'Cây cạo không hiệu quả'),
        StatusInfo('K', 'Cây không phát triển'),
        StatusInfo('O', 'Hố trống(cây chết)'),
        StatusInfo('M', 'Hố bị mất do lấn chiếm'),
        StatusInfo('B', 'Cây bênh'),
        StatusInfo('B4,5', 'Cây bệnh 4,5'),
      ];

      statusList.addAll(defaultStatuses);
      for (var status in statusList) {
        statusCounts[status.code] = 0.obs;
        statusColors[status.code] = Colors.grey;
      }
    } finally {
      isLoading.value = false;
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

              // Check if any tree status was updated
              bool hasUpdates = false;
              statusCounts.forEach((key, value) {
                if (value.value > 0) {
                  hasUpdates = true;
                }
              });

              if (!hasUpdates) {
                // If no updates, show dialog to move to next row
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
                          // Increment row and reload trees
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
                }
              }
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}
