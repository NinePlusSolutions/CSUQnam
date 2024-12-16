import 'package:get/get.dart';

class StatusInfo {
  final String code;
  final String description;

  StatusInfo(this.code, this.description);
}

class InventoryController extends GetxController {
  final RxList<StatusInfo> statusList = <StatusInfo>[].obs;
  final RxMap<String, RxInt> statusCounts = <String, RxInt>{}.obs;
  final RxString note = ''.obs;

  // Farm, lot, and row information
  final RxString farm = 'Nông trường 1'.obs;
  final RxString productionTeam = 'Tổ 1'.obs;
  final RxString lot = 'Lô A'.obs;
  final RxString row = 'Hàng 1'.obs;

  // Danh sách các giá trị cho dropdown
  final List<String> farms = [
    'Nông trường 1',
    'Nông trường 2',
    'Nông trường 3',
    'Nông trường 4',
    'Nông trường 5',
  ];

  final List<String> teams = [
    'Tổ 1',
    'Tổ 2',
    'Tổ 3',
    'Tổ 4',
    'Tổ 5',
  ];

  final Map<String, List<String>> lotsByFarm = {
    'Nông trường 1': ['Lô A', 'Lô B', 'Lô C', 'Lô D'],
    'Nông trường 2': ['Lô E', 'Lô F', 'Lô G', 'Lô H'],
    'Nông trường 3': ['Lô I', 'Lô J', 'Lô K', 'Lô L'],
    'Nông trường 4': ['Lô M', 'Lô N', 'Lô O', 'Lô P'],
    'Nông trường 5': ['Lô Q', 'Lô R', 'Lô S', 'Lô T'],
  };

  final Map<String, List<String>> rowsByLot = {
    'Lô A': ['Hàng 1', 'Hàng 2', 'Hàng 3', 'Hàng 4'],
    'Lô B': ['Hàng 5', 'Hàng 6', 'Hàng 7', 'Hàng 8'],
    'Lô C': ['Hàng 9', 'Hàng 10', 'Hàng 11', 'Hàng 12'],
    'Lô D': ['Hàng 13', 'Hàng 14', 'Hàng 15', 'Hàng 16'],
  };

  // Lấy danh sách lô dựa trên nông trường
  List<String> getLotsForFarm(String farmName) {
    return lotsByFarm[farmName] ?? [];
  }

  // Lấy danh sách hàng dựa trên lô
  List<String> getRowsForLot(String lotName) {
    return rowsByLot[lotName] ?? [];
  }

  // Cập nhật lô khi thay đổi nông trường
  void updateFarm(String newFarm) {
    farm.value = newFarm;
    final lots = getLotsForFarm(newFarm);
    if (lots.isNotEmpty) {
      lot.value = lots.first;
      updateLot(lots.first);
    }
  }

  // Cập nhật hàng khi thay đổi lô
  void updateLot(String newLot) {
    lot.value = newLot;
    final rows = getRowsForLot(newLot);
    if (rows.isNotEmpty) {
      row.value = rows.first;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with status options and their descriptions
    final statuses = [
      StatusInfo('N', 'Cây cạo ngửa'),
      StatusInfo('U', 'Cây cạo úp'),
      StatusInfo('UN', 'Cây cạo úp ngửa'),
      StatusInfo('KB', 'Cây khô miệng cạo'),
      StatusInfo('KG', 'Cây cạo không hiệu quả'),
      StatusInfo('KC', 'Cây không phát triển'),
      StatusInfo('O', 'Hố trống, cây chết'),
      StatusInfo('M', 'Hố bị mất do lấn chiểm'),
      StatusInfo('B', 'Cây bệnh'),
      StatusInfo('B4', 'Cây bệnh cấp 4'),
      StatusInfo('B5', 'Cây bệnh cấp 5'),
    ];

    statusList.addAll(statuses);
    for (var status in statusList) {
      statusCounts[status.code] = 0.obs;
    }
  }

  void incrementStatus(String status) {
    final currentCount = statusCounts[status] ?? 0.obs;
    currentCount.value++;
  }

  void decrementStatus(String status) {
    final currentCount = statusCounts[status] ?? 0.obs;
    if (currentCount.value > 0) {
      currentCount.value--;
    }
  }

  int getCount(String status) {
    return statusCounts[status]?.value ?? 0;
  }

  void updateNote(String value) {
    note.value = value;
  }

  void submitInventory() {
    // TODO: Implement inventory submission
    Get.back();
  }
}
