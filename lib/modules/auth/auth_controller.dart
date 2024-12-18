import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  final ApiProvider _apiProvider = ApiProvider();

  final username = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    if (storage.read('token') != null) {
      Get.offAllNamed(Routes.home);
    }
  }

  Future<void> onLogin() async {
    if (username.value.isEmpty || password.value.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đầy đủ thông tin',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiProvider.login(username.value, password.value);

      if (response.statusCode == 200) {
        final token = response.data["data"]['token'];
        storage.write('token', token);
        Get.offAllNamed(Routes.home);
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onLogout() {
    storage.remove('token');
    Get.offAllNamed(Routes.auth);
  }
}
