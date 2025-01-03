import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'sync_controller.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiProvider>(
      () => ApiProvider(),
      fenix: true,
    );
    Get.lazyPut<SyncController>(
      () => SyncController(),
      fenix: true, // This ensures the controller persists even when not in use
    );
  }
}
