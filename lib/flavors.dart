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

}
