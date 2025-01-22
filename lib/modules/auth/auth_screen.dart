import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/auth/auth_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<AuthController> {
  AuthScreen({super.key}) {
    // Set initial values from controller
    _usernameController.text = controller.username.value;
    _passwordController.text = controller.password.value;

    // Listen for changes
    ever(controller.username, (value) {
      if (_usernameController.text != value) {
        _usernameController.text = value;
        // Maintain cursor position
        _usernameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _usernameController.text.length),
        );
      }
    });

    ever(controller.password, (value) {
      if (_passwordController.text != value) {
        _passwordController.text = value;
        // Maintain cursor position
        _passwordController.selection = TextSelection.fromPosition(
          TextPosition(offset: _passwordController.text.length),
        );
      }
    });
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          onChanged: (value) =>
                              controller.username.value = value,
                          decoration: const InputDecoration(
                            labelText: "Tài khoản",
                            hintText: "Nhập tài khoản",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => TextField(
                              controller: _passwordController,
                              onChanged: (value) =>
                                  controller.password.value = value,
                              obscureText: controller.isPasswordHidden.value,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                hintText: "Nhập mật khẩu",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordHidden.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      controller.isPasswordHidden.value =
                                          !controller.isPasswordHidden.value,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            )),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Obx(() => Checkbox(
                                  value: controller.rememberLogin.value,
                                  onChanged: (value) =>
                                      controller.toggleRememberLogin(value),
                                )),
                            const Text("Ghi nhớ đăng nhập"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.onLogin(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Đăng nhập",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
