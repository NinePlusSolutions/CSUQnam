import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'No Internet Connection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineIndicatorController extends GetxController {
  static OfflineIndicatorController get to => Get.find();
  final isOffline = false.obs;

  void setOfflineStatus(bool status) {
    isOffline.value = status;
  }
}
