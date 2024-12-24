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
    // Extract only the number from the row string
    final rowNumber = int.tryParse(currentRow) ?? 1;
    final nextRow = (rowNumber + 1).toString();

    final inventoryController = Get.find<InventoryController>();
    inventoryController.row.value = nextRow;

    // Reset status counts for the next row
    inventoryController.statusCounts.forEach((key, value) {
      value.value = 0;
    });

    // Reset selected shaved status and note
    inventoryController.selectedShavedStatus.value = null;
    inventoryController.note.value = '';

    // Return to inventory screen with next row number
    Get.back(result: {'row': nextRow});
  }

  Future<void> syncData() async {
    await Future.delayed(const Duration(seconds: 1));
    sections.clear();
    hasData.value = false;
    Get.back();
  }
}
