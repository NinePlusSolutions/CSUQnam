import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: const Text(
        'Offline Mode',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 11,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w400,
        ),
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
