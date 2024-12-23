import 'package:flutter_getx_boilerplate/api/api_constants.dart';

enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return '[Dev]Cao Su QNam';
      case Flavor.prod:
        return 'Cao Su QNam';
      default:
        return 'title';
    }
  }

  static String get toBaseurl {
    switch (appFlavor) {
      case Flavor.dev:
        return ApiConstants.baseUrlDev;
      case Flavor.prod:
        return ApiConstants.baseUrlProd;
      default:
        return ApiConstants.baseUrlProd;
    }
  }
}
