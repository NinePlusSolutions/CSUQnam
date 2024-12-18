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
  final RxMap<String, Color> statusColors = <String, Color>{
    'N': Colors.blue, // Cây cạo ngữa
    'U': Colors.green, // Cây cạo úp
    'UN': Colors.teal, // Cây cạo úp ngữa
    'C': Colors.purple, // Cây hữ hiệu sẽ đưa vào cạo
    'KB': Colors.orange, // Cây khô miệng cạo
    'K': Colors.red, // Cây không phát triển
    'KG': Colors.pink, // Cây cạo không hiệu quả
    'O': Colors.grey, // Hố trống
    'M': Colors.brown, // Hố bị mất do lấn chiếm
    'B': Colors.red[700]!, // Cây bệnh
    'B4,5': Colors.red[900]!, // Cây bệnh cấp 4,5
  }.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatusData();
  }

  Future<void> fetchStatusData() async {
    try {
      final response = await _apiProvider.getStatus();
      final statusResponse = StatusResponse.fromJson(response.data);

      // Clear existing status list and counts
      statusList.clear();
      statusCounts.clear();

      // Map API response to StatusInfo objects
      final statuses = statusResponse.data
          .map((item) => StatusInfo(item.name, item.description))
          .toList();

      // Update the status list and initialize counts
      statusList.addAll(statuses);
      for (var status in statusList) {
        statusCounts[status.code] = 0.obs;
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
        StatusInfo('KC', 'Cây không phát triển'),
        StatusInfo('O', 'Hố trống(cây chết)'),
        StatusInfo('M', 'Hố bị mất do lấn chiếm'),
        StatusInfo('B', 'Cây bênh'),
        StatusInfo('B4,5', 'Cây bệnh 4,5'),
      ];

      statusList.addAll(defaultStatuses);
      for (var status in statusList) {
        statusCounts[status.code] = 0.obs;
      }
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
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text('Xác nhận'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn kết thúc không? Tác vụ này sẽ không được hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              // Chuyển đổi từ RxMap<String, RxInt> sang Map<String, int>
              final Map<String, int> finalCounts = {};
              statusCounts.forEach((key, value) {
                if (value.value > 0) {
                  finalCounts[key] = value.value;
                }
              });

              Get.delete<UpdateTreeController>(); // Xóa controller cũ nếu có
              final controller = Get.put(UpdateTreeController());

              final result = await Get.to<Map<String, dynamic>>(
                () => UpdateTreeScreen(
                  farm: farm.value,
                  lot: lot.value,
                  team: productionTeam.value,
                  row: row.value,
                  statusCounts: finalCounts,
                ),
              );

              // Nếu có kết quả trả về từ màn hình UpdateTree
              if (result != null) {
                // Reset dữ liệu cho hàng mới
                statusCounts.forEach((key, value) {
                  value.value = 0;
                });
                row.value = result['row'] as String;
                // Cập nhật UI
                update(['row']); // Cập nhật widget có ID là 'row'
                update([
                  'status_counts'
                ]); // Cập nhật widget có ID là 'status_counts'
              }
            },
            child: Text(
              'Đồng ý',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }
}
