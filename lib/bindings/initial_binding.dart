import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiProvider(), permanent: true);
  }
}
