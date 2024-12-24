import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/shared/services/download_services.dart';
import 'package:get/get.dart';

import 'shared/services/services.dart';

class DependencyInjection {
  static Future<void> init() async {
    await Get.putAsync(() => StorageService.init());
    Get.put(() => DownloadServices());
    Get.put(ApiProvider(), permanent: true);
    // Get.put(() => NotificationHandler()); // Uncomment this line if you have NotificationHandler class
  }
}
