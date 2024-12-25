import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SyncProgressDialog extends StatelessWidget {
  final RxList<SyncStep> steps;

  const SyncProgressDialog({
    Key? key,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Đang đồng bộ dữ liệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Column(
                  children: steps.map((step) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          _buildStatusIcon(step.status),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (step.status == SyncStatus.error)
                                  Text(
                                    step.errorMessage ?? 'Đã xảy ra lỗi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[700],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.waiting:
        return Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(4),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        );
      case SyncStatus.inProgress:
        return Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(4),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case SyncStatus.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 16,
            color: Colors.green[700],
          ),
        );
      case SyncStatus.error:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            size: 16,
            color: Colors.red[700],
          ),
        );
    }
  }
}

enum SyncStatus {
  waiting,
  inProgress,
  completed,
  error,
}

class SyncStep {
  final String title;
  final SyncStatus status;
  final String? errorMessage;

  SyncStep({
    required this.title,
    required this.status,
    this.errorMessage,
  });

  SyncStep copyWith({
    String? title,
    SyncStatus? status,
    String? errorMessage,
  }) {
    return SyncStep(
      title: title ?? this.title,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
