import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/inventory/inventory_batch.dart';
import '../../../routes/app_pages.dart';

class InventoryBatchList extends StatelessWidget {
  final List<InventoryBatch> batches;

  const InventoryBatchList({Key? key, required this.batches}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: batches.map((batch) {
        final formattedStartDate = DateFormat('dd/MM/yyyy').format(batch.startDate);
        final formattedEndDate = DateFormat('dd/MM/yyyy').format(batch.endDate);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: batch.isCompleted
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: batch.isCompleted
                    ? () {
                        Get.back();
                        Get.toNamed(Routes.inventory);
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: batch.isCompleted
                              ? Colors.green[700]
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: batch.isCompleted
                                ? Colors.green[700]
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$formattedStartDate - $formattedEndDate',
                            style: TextStyle(
                              fontSize: 14,
                              color: batch.isCompleted
                                  ? Colors.green[700]
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (!batch.isCompleted) ...[
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
                            'Đợt kiểm kê đã kết thúc',
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
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
