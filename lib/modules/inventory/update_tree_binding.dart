import 'package:get/get.dart';
import 'update_tree_controller.dart';

class UpdateTreeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpdateTreeController());
  }
}
