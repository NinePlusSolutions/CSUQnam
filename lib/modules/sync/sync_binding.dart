import 'package:get/get.dart';
import 'sync_controller.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SyncController>(
      () => SyncController(),
      fenix: true, // This ensures the controller persists even when not in use
    );
  }
}
