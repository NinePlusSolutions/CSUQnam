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

    // Nhóm theo nông trường và tổ
    final teamGroups =
        groupBy(histories, (h) => '${h.farmId}_${h.productTeamId}');

    teamGroups.forEach((teamKey, teamHistories) {
      final firstTeamItem = teamHistories.first;

      // Kiểm tra số lượng lô trong tổ
      final lotGroups = groupBy(teamHistories, (h) => h.farmLotId);

      if (lotGroups.length > 1) {
        // Nhiều lô -> show "Nông trường - Tổ: Dữ liệu"
        result.add({
          'farmName': firstTeamItem.farmName,
          'details': {
            'team': firstTeamItem.productTeamName,
          },
          'statusDetails': _calculateStatusCounts(teamHistories),
          'level': 'team',
          'dateCheck': firstTeamItem.dateCheck,
        });
      } else {
        // Chỉ có 1 lô
        final lotHistories = lotGroups.values.first;
        final firstLotItem = lotHistories.first;

        // Kiểm tra số lượng tuổi cạo trong lô
        final uniqueAges = lotHistories.map((h) => h.yearShaved).toSet();

        if (uniqueAges.length > 1) {
          // 1 lô nhiều tuổi -> show "Nông trường - Tổ -> Lô: Dữ liệu"
          result.add({
            'farmName': firstLotItem.farmName,
            'details': {
              'team': firstLotItem.productTeamName,
              'lot': firstLotItem.farmLotName,
            },
            'statusDetails': _calculateStatusCounts(lotHistories),
            'level': 'lot',
            'dateCheck': firstLotItem.dateCheck,
          });
        } else {
          // 1 lô 1 tuổi -> show "Nông trường - Tổ -> Lô -> Tuổi cạo: Dữ liệu"
          final age = uniqueAges.first;
          result.add({
            'farmName': firstLotItem.farmName,
            'details': {
              'team': firstLotItem.productTeamName,
              'lot': firstLotItem.farmLotName,
              'age': age.toString(),
            },
            'statusDetails': _calculateStatusCounts(lotHistories),
            'level': 'year',
            'dateCheck': firstLotItem.dateCheck,
          });
        }
      }
    });

    // Sắp xếp theo thời gian mới nhất
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
