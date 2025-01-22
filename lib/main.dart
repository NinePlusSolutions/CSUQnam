import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_getx_boilerplate/di.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';
import 'package:flutter_getx_boilerplate/shared/services/connectivity_service.dart';
import 'package:flutter_getx_boilerplate/widgets/offline_indicator.dart';
import 'package:get/get.dart';
import 'app.dart';

FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  // Khởi tạo OfflineIndicatorController sau khi DependencyInjection đã hoàn tất
  Get.put(OfflineIndicatorController());
  runApp(const App());

  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..loadingStyle = EasyLoadingStyle.custom
    // ..indicatorSize = 45.0
    ..radius = 10.0
    // ..progressColor = Colors.yellow
    ..backgroundColor = ColorConstants.lightGray
    ..indicatorColor = hexToColor('#64DEE0')
    ..textColor = hexToColor('#64DEE0')
    // ..maskColor = Colors.red
    ..userInteractions = false
    ..dismissOnTap = false
    ..animationStyle = EasyLoadingAnimationStyle.scale;
}
