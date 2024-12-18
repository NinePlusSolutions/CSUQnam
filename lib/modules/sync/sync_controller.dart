import 'package:get/get.dart';

class SyncController extends GetxController {
  final RxList<Map<String, dynamic>> pendingUpdates = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingUpdates();
  }

  Future<void> loadPendingUpdates() async {
    isLoading.value = true;
    try {
      // TODO: Load từ local storage hoặc API
      await Future.delayed(const Duration(seconds: 1));
      // Mẫu dữ liệu
      pendingUpdates.value = [
        {
          'farm': 'Nông trường 1',
          'lot': 'Lô A',
          'team': 'Tổ 1',
          'row': 'Hàng 1',
          'statusCounts': {'N': 2, 'KG': 3},
          'updatedAt': DateTime.now().subtract(const Duration(hours: 1)),
        },
        {
          'farm': 'Nông trường 1',
          'lot': 'Lô A',
          'team': 'Tổ 1',
          'row': 'Hàng 2',
          'statusCounts': {'U': 1, 'KC': 2},
          'updatedAt': DateTime.now().subtract(const Duration(minutes: 30)),
        },
      ];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncAll() async {
    isLoading.value = true;
    try {
      // TODO: Gửi dữ liệu lên server
      await Future.delayed(const Duration(seconds: 2));
      pendingUpdates.clear();
      Get.back(result: true);
    } finally {
      isLoading.value = false;
    }
  }
}
