import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:io';

class AuthController extends GetxController {
  final _apiProvider = Get.find<ApiProvider>();
  final storage = GetStorage();

  final username = ''.obs;
  final password = ''.obs;
  final rememberLogin = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    try {
      final savedRemember = storage.read('remember_login') ?? true;
      rememberLogin.value = savedRemember;

      if (savedRemember) {
        final savedUsername = storage.read('username');
        final savedPassword = storage.read('password');

        print(
            'Loading saved credentials: $savedUsername, $savedPassword'); // Debug log

        if (savedUsername != null && savedPassword != null) {
          username.value = savedUsername;
          password.value = savedPassword;
        }
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  void toggleRememberLogin(bool? value) {
    if (value != null) {
      rememberLogin.value = value;
      storage.write('remember_login', value);

      if (!value) {
        // If remember login is turned off, clear saved credentials
        storage.remove('username');
        storage.remove('password');
        username.value = '';
        password.value = '';
      }
    }
  }

  void checkLoginStatus() {
    final token = storage.read('token');
    if (token != null) {
      Get.offAllNamed(Routes.home);
    }
  }

  Future<void> onLogin() async {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đầy đủ thông tin',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _apiProvider.login(
        username.value.trim(),
        password.value.trim(),
      );

      if (response.statusCode == 200) {
        final token = response.data["data"]['token'];

        // Save credentials if remember login is enabled
        if (rememberLogin.value) {
          await storage.write('username', username.value.trim());
          await storage.write('password', password.value.trim());
          await storage.write('remember_login', true);
        }

        await storage.write('token', token);
        print(
            'Saved credentials after login: ${username.value}, ${password.value}, remember: ${rememberLogin.value}'); // Debug log

        // Fetch and save profile data
        final profileResponse = await _apiProvider.getProfile();
        if (profileResponse.status) {
          await storage.write('profile_data', jsonEncode(profileResponse.data));
        }

        // Fetch and save status data
        final statusResponse = await _apiProvider.getStatus();
        if (statusResponse.statusCode == 200) {
          await storage.write('status_data', jsonEncode(statusResponse.data));
        }

        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Lỗi',
          'Sai tài khoản hoặc mật khẩu',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        'Lỗi',
        'Đã có lỗi xảy ra. Vui lòng thử lại sau',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> hasUnsyncedData() async {
    final storedData = storage.read('local_updates');
    return storedData != null && (storedData as List).isNotEmpty;
  }

  Future<void> onLogout() async {
    try {
      // Kiểm tra dữ liệu chưa đồng bộ
      if (await hasUnsyncedData()) {
        Get.snackbar(
          'Cảnh báo',
          'Vui lòng đồng bộ dữ liệu trước khi đăng xuất',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Kiểm tra kết nối mạng
      final hasInternet = await checkInternetConnection();
      if (!hasInternet) {
        Get.snackbar(
          'Lỗi kết nối',
          'Vui lòng kiểm tra kết nối mạng trước khi đăng xuất',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final shouldRemember = rememberLogin.value;

      if (!shouldRemember) {
        // If remember login is off, clear credentials
        await storage.remove('username');
        await storage.remove('password');
        await storage.remove('remember_login');
      }

      // Always remove token and cached data
      await storage.remove('token');
      await storage.remove('profile_data');
      await storage.remove('status_data');

      print(
          'Credentials after logout - remember: $shouldRemember, username: ${storage.read('username')}, password: ${storage.read('password')}'); // Debug log

      Get.offAllNamed('/auth');
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'Lỗi',
        'Đã có lỗi xảy ra khi đăng xuất. Vui lòng thử lại.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
