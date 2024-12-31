import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/models/response/user/user.dart';
import 'package:flutter_getx_boilerplate/models/inventory/inventory_batch.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class TreeStatus {
  final String id;
  final String name;
  final List<String> descriptions;

  TreeStatus(
      {required this.id, required this.name, required this.descriptions});
}

class HomeController extends GetxController {
  final _apiProvider = Get.find<ApiProvider>();
  final storage = GetStorage();

  // Selected values for tree update
  final selectedTreeStatus = Rx<String?>(null);
  final selectedDescription = Rx<String?>(null);

  // Track updated trees in current session
  final updatedTrees = <String>{}.obs;
  final updatedTreesCount = 0.obs;

  // Tree statuses based on the diagram
  final treeStatuses = [
    TreeStatus(
      id: 'cay_cao',
      name: 'Cây cạo',
      descriptions: [
        'N (Cây cạo ngửa)',
        'U (Cây cạo úp)',
        'UN (Cây cạo úp ngửa)',
        'C (Cây hữu hiệu sẽ đưa vào cao)'
      ],
    ),
    TreeStatus(
      id: 'cay_khong_hieu_qua',
      name: 'Cây không hiệu quả',
      descriptions: [
        'Kb (Cây khô miếng cạo)',
        'K (Cây không phát triển)',
        'KG (Cây cạo không hiệu quả)'
      ],
    ),
    TreeStatus(
      id: 'ho_trong',
      name: 'Hố trống',
      descriptions: ['O (Hố trống cây chết)', 'M (Hố bị mất do lấn chiếm)'],
    ),
  ];

  final treeDetails = {
    'Cây 1': {
      'farm': 'Nông trường quảng nam',
      'lot': 'L12',
      'row': '2',
      'status': 'Đã cạo',
      'description': 'Cây tươi tốt, xanh ngắt, ngon',
      'updatedTime': '2024-12-10 14:00'
    },
    // Add more tree details here
  };

  Map<String, String> getTreeDetails(String treeId) {
    return treeDetails[treeId] ??
        {
          'farm': 'N/A',
          'lot': 'N/A',
          'row': 'N/A',
          'status': 'N/A',
          'description': 'N/A',
          'updatedTime': 'N/A'
        };
  }

  // Selected values for filters
  final selectedFarm = Rx<String?>(null);
  final selectedProductionTeam = Rx<String?>(null);
  final selectedLot = Rx<String?>(null);
  final selectedRow = Rx<String?>(null);

  // Lists for dropdowns
  final farms = <String>['Nông trường A', 'Nông trường B', 'Nông trường C'].obs;
  final productionTeams = <String>[].obs;
  final lots = <String>[].obs;
  final rows = <String>[].obs;

  // Show trees flag
  final showTrees = false.obs;
  final isUpdatedTree = false.obs;
  // Get descriptions for selected status
  List<String> getDescriptionsForStatus(String status) {
    final treeStatus = treeStatuses.firstWhere(
      (element) => element.name == status,
      orElse: () => TreeStatus(id: '', name: '', descriptions: []),
    );
    return treeStatus.descriptions;
  }

  void onTreeSelected(String treeId) {
    // Reset selected status and description when a new tree is selected
    selectedTreeStatus.value = null;
    selectedDescription.value = null;
  }

  void onTreeStatusSelected(String? status) {
    selectedTreeStatus.value = status;
    selectedDescription.value = null;
  }

  void onDescriptionSelected(String? description) {
    selectedDescription.value = description;
  }

  bool isTreeUpdated(String treeId) {
    return updatedTrees.contains(treeId);
  }

  final updatedTreeDetails = <String, Map<String, String>>{}.obs;

  void updateTreeStatus(String treeId) {
    if (selectedTreeStatus.value != null && selectedDescription.value != null) {
      print(
          'Updating tree $treeId with status: ${selectedTreeStatus.value} and description: ${selectedDescription.value}');

      updatedTrees.add(treeId);
      updatedTreesCount.value = updatedTrees.length;
      storage.write('updatedTrees', updatedTrees.toList());
      storage.write('updatedTreesCount', updatedTreesCount.value);

      // Store updated tree details
      updatedTreeDetails[treeId] = {
        'farm': selectedFarm.value ?? 'N/A',
        'lot': selectedLot.value ?? 'N/A',
        'row': selectedRow.value ?? 'N/A',
        'status': selectedTreeStatus.value!,
        'description': selectedDescription.value!,
        'updatedTime': DateTime.now().toString()
      };

      Get.back();
      selectedTreeStatus.value = null;
      selectedDescription.value = null;
    }
  }

  void cancelUpdateTreeStatus() {
    Get.back();
    selectedTreeStatus.value = null;
    selectedDescription.value = null;
  }

  Map<String, String> getUpdatedTreeDetails(String treeId) {
    return updatedTreeDetails[treeId] ??
        {
          'farm': 'N/A',
          'lot': 'N/A',
          'row': 'N/A',
          'status': 'N/A',
          'description': 'N/A',
          'updatedTime': 'N/A'
        };
  }

  void loadUpdatedTrees() {
    final storedTrees = storage.read<List>('updatedTrees') ?? [];
    updatedTrees.addAll(storedTrees.map((e) => e.toString()));
    updatedTreesCount.value = updatedTrees.length;
  }

  void clearUpdatedTreesStatus() {
    updatedTrees.clear();
    updatedTreesCount.value = 0;
    updatedTreeDetails.clear();
    storage.write('updatedTrees', []);
    storage.write('updatedTreesCount', 0);
  }

  void onFarmSelected(String? farm) {
    selectedFarm.value = farm;
    selectedProductionTeam.value = null;
    selectedLot.value = null;
    selectedRow.value = null;
    showTrees.value = false;
    clearUpdatedTreesStatus();

    if (farm != null) {
      productionTeams.value = ['Tổ 1', 'Tổ 2', 'Tổ 3'];
    } else {
      productionTeams.clear();
    }
    lots.clear();
    rows.clear();
  }

  void onProductionTeamSelected(String? team) {
    selectedProductionTeam.value = team;
    selectedLot.value = null;
    selectedRow.value = null;
    showTrees.value = false;
    clearUpdatedTreesStatus();

    if (team != null) {
      lots.value = ['Lô A', 'Lô B', 'Lô C'];
    } else {
      lots.clear();
    }
    rows.clear();
  }

  void onLotSelected(String? lot) {
    selectedLot.value = lot;
    selectedRow.value = null;
    showTrees.value = false;
    clearUpdatedTreesStatus();

    if (lot != null) {
      rows.value = ['Hàng 1', 'Hàng 2', 'Hàng 3'];
    } else {
      rows.clear();
    }
  }

  void onRowSelected(String? row) {
    selectedRow.value = row;
    clearUpdatedTreesStatus();

    if (row != null) {
      showTrees.value = true;
    } else {
      showTrees.value = false;
    }
  }

  final user = Rx<User?>(null as User?);

  final searchController = TextEditingController();

  final currentBatchName = ''.obs;
  final isLoadingBatch = false.obs;
  final Rxn<InventoryBatch> currentBatch = Rxn<InventoryBatch>();
  final inventoryBatches = <dynamic>[].obs;
  final hasActiveBatch = false.obs;

  Future<void> fetchInventoryBatch() async {
    try {
      isLoadingBatch.value = true;

      // Try to get data from local storage first
      final storedData = storage.read('inventory_batches');
      if (storedData != null) {
        final decodedData = jsonDecode(storedData);
        processInventoryBatchData(decodedData);
      }

      // Try to get fresh data from API
      try {
        final response = await _apiProvider.getInventoryBatches();
        if (response.isNotEmpty) {
          // Save to local storage
          await storage.write('inventory_batches', jsonEncode(response));
          processInventoryBatchData(response);
        }
      } catch (e) {
        print('Error fetching fresh inventory data: $e');
        // Continue with stored data if API fails
      }
    } catch (e) {
      print('Error in fetchInventoryBatch: $e');
    } finally {
      isLoadingBatch.value = false;
    }
  }

  void processInventoryBatchData(dynamic data) {
    try {
      if (data != null && data is List && data.isNotEmpty) {
        // Update observable list
        inventoryBatches.value = data;

        // Find active batch
        final activeBatchData = data.firstWhereOrNull(
          (batch) => batch['isCompleted'] == false,
        );

        if (activeBatchData != null) {
          final activeBatch = InventoryBatch.fromJson(
              Map<String, dynamic>.from(activeBatchData));
          currentBatch.value = activeBatch;
          currentBatchName.value = activeBatch.name;
          hasActiveBatch.value = true;
        } else {
          // Nếu không có batch active, lấy batch mới nhất
          final latestBatchData = data.last;
          final latestBatch = InventoryBatch.fromJson(
              Map<String, dynamic>.from(latestBatchData));
          currentBatch.value = latestBatch;
          currentBatchName.value = latestBatch.name;
          hasActiveBatch.value = true;
        }
      } else {
        // Nếu không có dữ liệu
        currentBatch.value = null;
        currentBatchName.value = '';
        hasActiveBatch.value = false;
      }
    } catch (e) {
      print('Error processing inventory batch data: $e');
      currentBatch.value = null;
      currentBatchName.value = '';
      hasActiveBatch.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchInventoryBatch();
  }

  Future<void> handleInventoryPress() async {
    if (currentBatch.value == null) {
      Get.snackbar(
        'Thông báo',
        'Hiện tại chưa có đợt kiểm kê nào',
        backgroundColor: Colors.orange[100],
      );
      return;
    }
    Get.toNamed('/inventory');
  }
}
