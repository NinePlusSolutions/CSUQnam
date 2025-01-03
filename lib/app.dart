import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_getx_boilerplate/app_binding.dart';
import 'package:flutter_getx_boilerplate/lang/translation_service.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:flutter_getx_boilerplate/shared/services/storage_service.dart';
import 'package:flutter_getx_boilerplate/theme/theme_data.dart';
import 'package:flutter_getx_boilerplate/widgets/offline_indicator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/smart_management.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import 'flavors.dart';
import 'pages/my_home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: F.title,
      debugShowCheckedModeBanner: false,
      enableLog: true,
      initialRoute: AppPages.initial,
      defaultTransition: Transition.cupertino,
      getPages: AppPages.routes,
      initialBinding: AppBinding(),
      smartManagement: SmartManagement.keepFactory,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      locale: Locale(StorageService.lang ??
          TranslationService.fallbackLocale.languageCode),
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: Stack(
              children: [
                child!,
                Obx(() {
                  final isOffline = OfflineIndicatorController.to.isOffline.value;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    top: isOffline ? 0 : -30,
                    left: 0,
                    right: 0,
                    child: const OfflineIndicator(),
                  );
                }),
              ],
            ),
          ),
        );
      },
      themeMode:
          StorageService.themeMode == 2 ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
