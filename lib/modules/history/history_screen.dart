import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/tree_condition_history.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize InventoryController
    final inventoryController = Get.put(InventoryController());
    inventoryController.fetchStatusData();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch sử đồng bộ dữ liệu kiểm kê',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        if (controller.histories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có lịch sử dữ liệu kiểm kê',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final groupedData = controller.groupHistoryData();
        return ListView.builder(
          itemCount: groupedData.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = groupedData[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForLevel(item['level']),
                          size: 24,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          controller.formatDateTime(item['dateCheck']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var entry in (item['details'] as Map<String, int>).entries)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: controller.getStatusColor(entry.key).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: controller.getStatusColor(entry.key),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: TextStyle(
                                color: controller.getStatusColor(entry.key),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  IconData _getIconForLevel(String level) {
    switch (level) {
      case 'farm':
        return Icons.landscape;
      case 'team':
        return Icons.group;
      case 'lot':
        return Icons.grid_on;
      case 'year':
        return Icons.calendar_today;
      case 'line':
        return Icons.straighten;
      default:
        return Icons.info;
    }
  }
}
