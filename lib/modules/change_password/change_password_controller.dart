import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';

class ChangePasswordController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isCurrentPasswordHidden = true.obs;
  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  void toggleCurrentPasswordVisibility() => isCurrentPasswordHidden.toggle();
  void toggleNewPasswordVisibility() => isNewPasswordHidden.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.toggle();

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading(true);
      final response = await _apiProvider.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPasswordNew: confirmPasswordController.text,
      );

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar(
          'Thành công',
          'Đổi mật khẩu thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          response.data['message'] ??
              'Mật khẩu cũ không chính xác. Vui lòng thử lại',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Mật khẩu cũ không chính xác. Vui lòng thử lại',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
