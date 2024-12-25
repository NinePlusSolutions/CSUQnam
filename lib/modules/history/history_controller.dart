import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/tree_condition_history.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
}
