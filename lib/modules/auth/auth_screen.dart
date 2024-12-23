import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/auth/auth_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 50.hp,
                  width: 100.wp,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Hero(
                        tag: 'appLogo',
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                children: [
                  Obx(() => TextField(
                        controller: TextEditingController(
                            text: controller.username.value),
                        // onChanged: (value) => controller.username.value = value,
                        decoration: const InputDecoration(
                          labelText: "Tài khoản",
                          hintText: "Nhập tài khoản",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(136, 216, 74, 1),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromRGBO(136, 216, 74, 1),
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  Obx(() => TextField(
                        controller: TextEditingController(
                            text: controller.password.value),
                        onChanged: (value) => controller.password.value = value,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Mật khẩu",
                          hintText: "Nhập mật khẩu",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(136, 216, 74, 1),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromRGBO(136, 216, 74, 1),
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => Checkbox(
                              value: controller.rememberLogin.value,
                              onChanged: controller.toggleRememberLogin,
                              activeColor:
                                  const Color.fromRGBO(136, 216, 74, 1),
                            )),
                        const Text(
                          'Ghi nhớ thông tin đăng nhập',
                          // style: context.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: controller.onLogin,
                          child: Container(
                            width: double.infinity,
                            height: 45,
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(136, 216, 74, 1),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                              child: Text(
                                "Đăng nhập",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        )),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
