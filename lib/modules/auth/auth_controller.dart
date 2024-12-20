import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  final ApiProvider _apiProvider = ApiProvider();

  final RxString username = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Use a small delay to ensure the widget tree is built
    Future.delayed(Duration.zero, checkLoginStatus);
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final savedUsername = storage.read('saved_username');
    final savedPassword = storage.read('saved_password');
    final savedRemember = storage.read('remember_login') ?? false;

    if (savedRemember && savedUsername != null && savedPassword != null) {
      username.value = savedUsername;
      password.value = savedPassword;
      rememberLogin.value = true;
    }
  }

  void toggleRememberLogin(bool? value) {
    rememberLogin.value = value ?? false;
  }

  void checkLoginStatus() {
    final token = storage.read('token');
    if (token != null) {
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

        // Save credentials if remember login is enabled
        if (rememberLogin.value) {
          storage.write('saved_username', username.value);
          storage.write('saved_password', password.value);
          storage.write('remember_login', true);
        } else {
          // Clear saved credentials if remember login is disabled
          storage.remove('saved_username');
          storage.remove('saved_password');
          storage.remove('remember_login');
        }

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
    // Only remove the token, keep saved credentials if remember login is enabled
    storage.remove('token');

    // Reset current values but don't clear saved credentials
    final savedUsername = storage.read('saved_username');
    final savedPassword = storage.read('saved_password');
    final savedRemember = storage.read('remember_login') ?? false;

    username.value = savedRemember ? (savedUsername ?? '') : '';
    password.value = savedRemember ? (savedPassword ?? '') : '';
    rememberLogin.value = savedRemember;

    Get.offAllNamed(Routes.auth);
  }
}
