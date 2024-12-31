import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/widgets/offline_indicator.dart';
import 'package:get/get.dart';

class NetworkTimeoutDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkTimeoutDialog({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.signal_wifi_connected_no_internet_4_rounded,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Network Issue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The request is taking longer than expected. Please check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    OfflineIndicatorController.to.setOfflineStatus(true);
                  },
                  child: const Text('Work Offline'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onRetry();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showNetworkTimeoutDialog({
  required VoidCallback onRetry,
}) {
  Get.dialog(
    NetworkTimeoutDialog(onRetry: onRetry),
    barrierDismissible: false,
  );
}
