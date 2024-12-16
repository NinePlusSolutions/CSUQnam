import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/auth/auth_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 50.hp,
                  width: 100.wp,
                  // decoration: BoxDecoration(
                  //   color: context.colors.primary.withOpacity(.2),
                  // ),
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
                _buildThemeButton(),
                Positioned(
                  top: 48,
                  right: 16,
                  child: PopupMenuButton<String>(
                    onSelected: (String item) {
                      controller.onChangeLanguage(item);
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      const PopupMenuItem(
                        value: 'vi',
                        child: Text('Vietnamese'),
                      ),
                    ],
                    child: const Icon(Icons.language),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Form(
                key: controller.formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    InputFieldWidget(
                      label: "Tài khoản",
                      controller: controller.emailController,
                      hint: 'email_hint'.tr,
                    ),
                    const Space(),
                    InputFieldWidget(
                      label: "Mật khẩu",
                      controller: controller.passwordController,
                      hint: 'enter_password'.tr,
                      isHideContent: true,
                    ),
                    const Space(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (bool? value) {
                              //  controller.rememberMe.value = value ?? false;
                            },
                          ),
                          Text(
                            'Ghi nhớ thông tin đăng nhập',
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Space(height: 40),
                    // ButtonWidget(
                    //   text: "Đăng nhập",
                    //   onPressed: controller.onLogin,
                    //   labelStyle: const TextStyle(
                    //       fontWeight: FontWeight.bold, color: Colors.white),
                    // ),
                    GestureDetector(
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
                    ),
                    const Space(height: 40),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Positioned _buildThemeButton() {
    const darkIcon = Icon(
      Icons.dark_mode,
      color: Colors.black,
    );

    const lightIcon = Icon(
      Icons.light_mode,
      color: Colors.white,
    );

    return Positioned(
      top: 40,
      left: 16,
      child: IconButton(
        onPressed: controller.onChangeTheme,
        icon: Obx(
          () => !controller.isDarkMode.value ? darkIcon : lightIcon,
        ),
      ),
    );
  }
}
