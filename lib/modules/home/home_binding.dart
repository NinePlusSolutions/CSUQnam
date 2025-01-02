import 'package:flutter_getx_boilerplate/modules/auth/auth_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:flutter_getx_boilerplate/modules/sync/sync_controller.dart';
import 'package:get/get.dart';

import 'home_controller.dart';
import 'package:flutter_getx_boilerplate/modules/profile/profile_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        apiClient: Get.find(),
      ),
    );

    // Initialize controllers
    Get.put(AuthController(), permanent: true);  // Make AuthController permanent
    Get.put(SyncController());  // Initialize SyncController
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
