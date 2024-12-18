import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/services/services.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  final storage = GetStorage();

  _initScreen() async {
    await Future.delayed(const Duration(seconds: 1));

    if (Platform.isIOS) {
      FlutterNativeSplash.remove();
    }
    final firstInstall = StorageService.firstInstall;
    await Future.delayed(const Duration(milliseconds: 300));
    // if (firstInstall) {
    //   NavigatorHelper.toOnBoardScreen();
    // }
    if (storage.read('token') != null) {
      Get.offAllNamed(Routes.home);
    } else {
      NavigatorHelper.toAuth();
    }
    // final accessToken = StorageService.token;
    // if (accessToken != null) {
    //   NavigatorHelper.toHome();
    // } else {
    //   NavigatorHelper.toAuth();
    // }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'appLogo',
          child: Image.asset(
            "assets/images/logo.png",
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
