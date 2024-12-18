import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:get/get.dart';
import 'models/inventory_section.dart';

class UpdateTreeController extends GetxController {
  final RxList<InventorySection> sections = <InventorySection>[].obs;
  final RxBool hasData = false.obs;

  void addSection(InventorySection section) {
    if (section.statusCounts.isNotEmpty) {
      sections.add(section);
      hasData.value = true;
    }
  }

  void addNextRow(InventorySection section) {
    final currentRow = section.row;
    final rowNumber = int.parse(currentRow.split(' ')[1]);
    final nextRow = 'Hàng ${rowNumber + 1}';

    final inventoryController = Get.find<InventoryController>();
    inventoryController.row.value = nextRow;
    inventoryController.update(['row']);

    Get.back(result: {
      'row': nextRow,
      'statusCounts': section.statusCounts,
    });
  }

  Future<void> syncData() async {
    await Future.delayed(const Duration(seconds: 1));
    sections.clear();
    hasData.value = false;
    Get.back();
  }
}
