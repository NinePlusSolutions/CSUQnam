import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_screen.dart';
import 'package:flutter_getx_boilerplate/modules/modules.dart';
import 'package:flutter_getx_boilerplate/modules/updated_trees/updated_trees_screen.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/update_tree_binding.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/update_tree_screen.dart';
import 'package:flutter_getx_boilerplate/modules/sync/sync_binding.dart';
import 'package:flutter_getx_boilerplate/modules/sync/sync_screen.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      children: [
        GetPage(
          name: Routes.onboard,
          page: () => const OnboardScreen(),
        ),
      ],
    ),
    GetPage(
      name: Routes.auth,
      page: () => AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.inventory,
      page: () => const InventoryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => InventoryController());
      }),
    ),
    GetPage(
      name: '/updated-trees',
      page: () => UpdatedTreesScreen(),
    ),
    GetPage(
      name: Routes.updateTree,
      page: () => const UpdateTreeScreen(
        farm: '',
        lot: '',
        team: '',
        row: '',
        statusCounts: {},
      ),
      binding: UpdateTreeBinding(),
    ),
    GetPage(
      name: Routes.sync,
      page: () => const SyncScreen(),
      binding: SyncBinding(),
    ),
  ];
}
