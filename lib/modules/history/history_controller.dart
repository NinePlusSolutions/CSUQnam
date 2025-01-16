import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/tree_condition_history.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class HistoryController extends GetxController {
  final _apiProvider = Get.find<ApiProvider>();
  final isLoading = false.obs;
  final histories = <TreeConditionHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistories();
  }

  Future<void> fetchHistories() async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.getTreeConditionHistory();
      histories.value = response.data.treeConditionList;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải lịch sử đồng bộ',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Color getStatusColor(String status) {
    final inventoryController = Get.find<InventoryController>();
    return inventoryController.statusColors[status] ?? Colors.grey;
  }

  // Nhóm dữ liệu theo các cấp độ khác nhau
  List<Map<String, dynamic>> groupHistoryData() {
    final result = <Map<String, dynamic>>[];

    // Đầu tiên nhóm theo tổ
    final teamGroups =
        groupBy(histories, (h) => '${h.farmId}_${h.productTeamId}');

    teamGroups.forEach((teamKey, teamHistories) {
      final firstTeamItem = teamHistories.first;

      // Kiểm tra số lượng lô trong tổ
      final lotGroups = groupBy(teamHistories, (h) => h.farmLotId);

      if (lotGroups.length > 1) {
        // Nếu có nhiều lô -> hiển thị theo tổ
        result.add({
          'title':
              '${firstTeamItem.farmName} - ${firstTeamItem.productTeamName}',
          'details': _calculateStatusCounts(teamHistories),
          'level': 'team',
          'dateCheck': firstTeamItem.dateCheck,
          'icon': Icons.group,
        });
      } else {
        // Nếu chỉ có 1 lô
        final lotHistories = lotGroups.values.first;
        final firstLotItem = lotHistories.first;

        // Kiểm tra số lượng tuổi cạo trong lô
        final yearGroups = groupBy(lotHistories, (h) => h.yearShaved);

        if (yearGroups.length > 1) {
          // Nếu có nhiều tuổi cạo -> hiển thị theo lô
          result.add({
            'title':
                '${firstLotItem.farmName} - ${firstLotItem.productTeamName} - ${firstLotItem.farmLotName}',
            'details': _calculateStatusCounts(lotHistories),
            'level': 'lot',
            'dateCheck': firstLotItem.dateCheck,
            'icon': Icons.grid_on,
          });
        } else {
          // Nếu chỉ có 1 tuổi cạo
          final yearHistories = yearGroups.values.first;
          final firstYearItem = yearHistories.first;

          // Kiểm tra số lượng hàng trong tuổi cạo
          final lineGroups = groupBy(yearHistories, (h) => h.treeLineName);

          if (lineGroups.length > 1) {
            // Nếu có nhiều hàng -> hiển thị theo tuổi cạo
            result.add({
              'title':
                  '${firstYearItem.farmName} - ${firstYearItem.productTeamName} - ${firstYearItem.farmLotName} - Tuổi cạo ${firstYearItem.yearShaved}',
              'details': _calculateStatusCounts(yearHistories),
              'level': 'year',
              'dateCheck': firstYearItem.dateCheck,
              'icon': Icons.calendar_today,
            });
          } else {
            // Nếu chỉ có 1 hàng -> hiển thị theo hàng
            result.add({
              'title':
                  '${firstYearItem.farmName} - ${firstYearItem.productTeamName} - ${firstYearItem.farmLotName} - Hàng ${firstYearItem.treeLineName}',
              'details': _calculateStatusCounts(yearHistories),
              'level': 'line',
              'dateCheck': firstYearItem.dateCheck,
              'icon': Icons.straighten,
            });
          }
        }
      }
    });

    // Sắp xếp kết quả theo thời gian kiểm tra
    result.sort((a, b) => b['dateCheck'].compareTo(a['dateCheck']));
    return result;
  }

  // Tính toán số lượng theo từng trạng thái
  Map<String, int> _calculateStatusCounts(
      List<TreeConditionHistory> histories) {
    final counts = <String, int>{};
    for (var history in histories) {
      for (var detail in history.treeConditionDetails) {
        counts[detail.statusName] =
            (counts[detail.statusName] ?? 0) + int.parse(detail.value);
      }
    }
    return counts;
  }
}
