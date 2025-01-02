import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/inventory/inventory_batch.dart';
import '../../../routes/app_pages.dart';

class InventoryBatchList extends StatelessWidget {
  final List<InventoryBatch> batches;

  const InventoryBatchList({super.key, required this.batches});

  @override
  Widget build(BuildContext context) {
    // Sắp xếp batches: đợt chưa hoàn thành lên đầu, sau đó sắp xếp theo ngày bắt đầu mới nhất
    final sortedBatches = batches.toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.startDate.compareTo(a.startDate);
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedBatches.length,
      itemBuilder: (context, index) {
        final batch = sortedBatches[index];
        final isActive = !batch.isCompleted;
        final formattedStartDate =
            DateFormat('dd/MM/yyyy').format(batch.startDate);
        final formattedEndDate = DateFormat('dd/MM/yyyy').format(batch.endDate);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: isActive
                    ? () {
                        Get.back();
                        Get.toNamed(Routes.inventory, arguments: {'batchId': batch.id});
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Đợt kiểm kê ${batch.name}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.green[700]
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Đang diễn ra',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: isActive
                                      ? Colors.green[700]
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$formattedStartDate - $formattedEndDate',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isActive
                                        ? Colors.green[700]
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (!isActive) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Đã kết thúc',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isActive)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.green[700],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
