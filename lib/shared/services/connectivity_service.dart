import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_getx_boilerplate/widgets/offline_indicator.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  Future<ConnectivityService> init() async {
    await _initConnectivity();
    _setupConnectivityStream();
    return this;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      print('Initial connectivity check result: $result');
      _updateConnectionStatus(result);
    } catch (e) {
      print('Connectivity check failed: $e');
    }
  }

  void _setupConnectivityStream() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        print('Connectivity changed to: $result');
        _updateConnectionStatus(result);
      },
      onError: (error) {
        print('Connectivity stream error: $error');
      },
    );
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final bool isOffline = result == ConnectivityResult.none;
    print('Updating offline status: $isOffline (Result: $result)');
    OfflineIndicatorController.to.setOfflineStatus(isOffline);
  }
}
