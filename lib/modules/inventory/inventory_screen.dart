import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
import 'package:flutter_getx_boilerplate/modules/sync/sync_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'inventory_controller.dart';

class InventoryScreen extends GetView<InventoryController> {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kiểm kê',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => Switch(
                value: controller.isEditingEnabled.value,
                onChanged: (value) {
                  controller.isEditingEnabled.value = value;
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.green[300],
              )),
          IconButton(
            icon: const Icon(
              Icons.history,
              color: Colors.white,
            ),
            onPressed: () => _showHistoryDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusGrid(),
                    const SizedBox(height: 24),
                    _buildNoteSection(),
                    // _buildFinishButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditDialog(),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Row(
              children: [
                // Bên trái: Nông trường và Tổ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                                controller.farm.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.groups_outlined,
                              size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                                controller.productionTeam.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                // Bên phải: Lô, Tuổi cạo và Hàng
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.grid_view_outlined,
                              size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                                controller.lot.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                                'Tuổi cạo: ${controller.tappingAge.value}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.straighten_outlined,
                              size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                                controller.row.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.green[700],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    // Store original values
    final originalFarmId = controller.farmId.value;
    final originalFarm = controller.farm.value;
    final originalTeamId = controller.productTeamId.value;
    final originalTeam = controller.productionTeam.value;
    final originalLotId = controller.farmLotId.value;
    final originalLot = controller.lot.value;
    final originalAge = controller.tappingAge.value;
    final originalRow = controller.row.value;

    if (controller.selectedLot.value != null) {
      final hasValidAges = controller.selectedLot.value?.ageShavedResponse
              .where((age) => age.value != null)
              .isNotEmpty ??
          false;
      controller.showYearDropdown.value = hasValidAges;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Farm dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<int>(
                  value: controller.farmId.value == 0
                      ? null
                      : controller.farmId.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Chọn nông trường'),
                  items: controller.farmResponses.value.map((farm) {
                    return DropdownMenuItem<int>(
                      value: farm.farmId,
                      child: Text(farm.farmName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selectedFarm = controller.farmResponses.value
                          .firstWhere((farm) => farm.farmId == value);
                      controller.onFarmSelected(
                          selectedFarm.farmId, selectedFarm.farmName);
                    }
                  },
                ),
              ),

              // Team dropdown
              Obx(() => controller.showTeamDropdown.value
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<int>(
                        value: controller.productTeamId.value == 0
                            ? null
                            : controller.productTeamId.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Chọn tổ'),
                        items: controller
                                .selectedFarm.value?.productTeamResponse
                                .map((team) {
                              return DropdownMenuItem<int>(
                                value: team.productTeamId,
                                child: Text(
                                    team.productTeamName ?? 'Unknown Team'),
                              );
                            }).toList() ??
                            [],
                        onChanged: (value) {
                          if (value != null) {
                            final selectedTeam = controller
                                .selectedFarm.value!.productTeamResponse
                                .firstWhere(
                              (team) => team.productTeamId == value,
                            );
                            controller.onTeamSelected(
                              selectedTeam.productTeamId,
                              selectedTeam.productTeamName,
                            );
                          }
                        },
                      ),
                    )
                  : const SizedBox()),

              // Lot dropdown
              Obx(() => controller.showLotDropdown.value
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<int>(
                        value: controller.farmLotId.value == 0
                            ? null
                            : controller.farmLotId.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Chọn lô'),
                        items: controller.selectedTeam.value?.farmLotResponse
                                .map((lot) {
                              return DropdownMenuItem<int>(
                                value: lot.farmLotId,
                                child: Text(lot.farmLotName),
                              );
                            }).toList() ??
                            [],
                        onChanged: (value) {
                          if (value != null) {
                            final selectedLot = controller
                                .selectedTeam.value!.farmLotResponse
                                .firstWhere(
                              (lot) => lot.farmLotId == value,
                            );
                            controller.onLotSelected(
                                selectedLot.farmLotId, selectedLot.farmLotName);
                          }
                        },
                      ),
                    )
                  : const SizedBox()),

              // Year dropdown
              Obx(() => controller.showYearDropdown.value
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        value: controller.tappingAge.value.isEmpty
                            ? null
                            : controller.tappingAge.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Chọn tuổi cạo'),
                        items: controller.selectedLot.value?.ageShavedResponse
                                .where((age) => age.value != null)
                                .map((age) => age.value.toString())
                                .toSet() // Remove duplicates
                                .toList()
                                .map((ageStr) {
                              return DropdownMenuItem<String>(
                                value: ageStr,
                                child: Text('$ageStr tuổi'),
                              );
                            }).toList() ??
                            [],
                        onChanged: (value) {
                          if (value != null) {
                            controller.tappingAge.value = value;
                            controller.yearShaved.value = int.parse(value);
                          }
                        },
                      ),
                    )
                  : const SizedBox()),

              // Row input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  initialValue: controller.row.value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập số hàng',
                    labelText: 'Chọn hàng',
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) return;

                    final number = int.tryParse(value);
                    if (number != null && number > 0) {
                      controller.row.value = number.toString();
                    } else {
                      Get.snackbar(
                        'Thông báo',
                        'Vui lòng nhập số hàng hợp lệ',
                        backgroundColor: Colors.red[100],
                      );
                    }
                  },
                ),
              ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Restore all original values
                      controller.farmId.value = originalFarmId;
                      controller.farm.value = originalFarm;
                      controller.productTeamId.value = originalTeamId;
                      controller.productionTeam.value = originalTeam;
                      controller.farmLotId.value = originalLotId;
                      controller.lot.value = originalLot;
                      controller.tappingAge.value = originalAge;
                      controller.row.value = originalRow;
                      Get.back();
                    },
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Validate required fields
                      if (controller.productTeamId.value == 0) {
                        Get.snackbar(
                          'Thông báo',
                          'Vui lòng chọn tổ',
                          backgroundColor: Colors.red[100],
                        );
                        return;
                      }
                      if (controller.farmLotId.value == 0) {
                        Get.snackbar(
                          'Thông báo',
                          'Vui lòng chọn lô',
                          backgroundColor: Colors.red[100],
                        );
                        return;
                      }
                      if (controller.tappingAge.value.isEmpty) {
                        Get.snackbar(
                          'Thông báo',
                          'Vui lòng chọn tuổi cạo',
                          backgroundColor: Colors.red[100],
                        );
                        return;
                      }

                      Get.back(); // Close dialog if all validations pass
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      final isEditing = controller.isEditingEnabled.value;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2,
        ),
        itemCount: controller.statusList.length,
        itemBuilder: (context, index) {
          final status = controller.statusList[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isEditing
                      ? _getStatusColor(status.name).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
              border: Border.all(
                color: isEditing
                    ? _getStatusColor(status.name).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showStatusDescription(context, status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isEditing
                              ? _getStatusColor(status.name).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isEditing
                                ? _getStatusColor(status.name)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final count = controller.getCount(status.name);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.remove,
                        onPressed: (count > 0 && isEditing)
                            ? () => controller.decrementStatus(status.name)
                            : null,
                        color: isEditing
                            ? _getStatusColor(status.name)
                            : Colors.grey,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isEditing ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      _buildControlButton(
                        icon: Icons.add,
                        onPressed: isEditing
                            ? () => controller.incrementStatus(status.name)
                            : null,
                        color: isEditing
                            ? _getStatusColor(status.name)
                            : Colors.grey,
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                onPressed == null ? Colors.grey[200] : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: onPressed == null ? Colors.grey : color,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String code) {
    final controller = Get.find<InventoryController>();
    return controller.statusColors[code] ?? Colors.grey;
  }

  void _showStatusDescription(BuildContext context, StatusInfo status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(status.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(status.name).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status.name),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      status.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: controller.noteController,
            onChanged: (value) => controller.note.value = value,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú (nếu có)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(Get.context!).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton(
            onPressed: controller.isEditingEnabled.value
                ? () {
                    controller.showShavedStatusBottomSheet();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //     const Icon(Icons.check_circle_outline, size: 20),
                //   const SizedBox(width: 8),
                Text(
                  'Kết thúc kiểm kê',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.isEditingEnabled.value
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void _showHistoryDialog() {
    final storedData = controller.storage.read('local_updates');
    final List<LocalTreeUpdate> updates = [];

    if (storedData is List) {
      for (var item in storedData) {
        if (item is Map<String, dynamic>) {
          final update = LocalTreeUpdate(
            farmId: item['farmId'] ?? 0,
            farmName: item['farmName'] ?? '',
            productTeamId: item['productTeamId'] ?? 0,
            productTeamName: item['productTeamName'] ?? '',
            farmLotId: item['farmLotId'] ?? 0,
            farmLotName: item['farmLotName'] ?? '',
            treeLineName: item['treeLineName'] ?? '',
            shavedStatusId: item['shavedStatusId'] ?? 0,
            shavedStatusName: item['shavedStatusName'] ?? '',
            tappingAge: item['tappingAge'] ?? 0,
            dateCheck:
                DateTime.tryParse(item['dateCheck'] ?? '') ?? DateTime.now(),
            statusUpdates: (item['statusUpdates'] as List?)
                    ?.map((status) => LocalStatusUpdate(
                          statusId: status['statusId'] ?? 0,
                          statusName: status['statusName'] ?? '',
                          value: status['value']?.toString() ?? '0',
                        ))
                    .toList() ??
                [],
            note: item['note'],
          );

          if (update.farmId == controller.farmId.value &&
              update.productTeamId == controller.productTeamId.value &&
              update.farmLotId == controller.farmLotId.value &&
              update.tappingAge.toString() == controller.tappingAge.value &&
              update.treeLineName == controller.row.value) {
            updates.add(update);
          }
        }
      }
    }

    updates.sort((a, b) => b.dateCheck.compareTo(a.dateCheck));

    // Tính tổng số cây từ tất cả status updates
    int totalTrees = 0;
    final Map<int, String> allStatuses = {};

    if (updates.isNotEmpty) {
      for (var update in updates) {
        for (var status in update.statusUpdates) {
          totalTrees += int.tryParse(status.value) ?? 0;
          allStatuses[status.statusId] = status.statusName;
        }
      }
    }

    // Map để theo dõi trạng thái mở/đóng của mỗi status
    final expandedStatus = <int, bool>{};
    for (var statusId in allStatuses.keys) {
      expandedStatus[statusId] = false;
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: Get.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Thông tin kiểm kê',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.close),
                              onPressed: () => Get.back(),
                            ),
                          ],
                        ),
                      ),

                      if (updates.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Chưa có thông tin kiểm kê cho vị trí này',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Card thông tin cơ bản
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      // _buildInfoRow(
                                      //   'Đợt kiểm kê',
                                      //   controller.currentBatchName.value,
                                      //   icon: Icons.inventory,
                                      // ),
                                      const Divider(height: 16),
                                      _buildInfoRow(
                                        'Nông trường',
                                        updates.first.farmName,
                                        icon: Icons.location_on,
                                      ),
                                      _buildInfoRow(
                                        'Đội',
                                        updates.first.productTeamName,
                                        icon: Icons.groups,
                                      ),
                                      _buildInfoRow(
                                        'Lô',
                                        updates.first.farmLotName,
                                        icon: Icons.grid_view,
                                      ),
                                      _buildInfoRow(
                                        'Hàng',
                                        updates.first.treeLineName,
                                        icon: Icons.format_list_numbered,
                                      ),
                                      _buildInfoRow(
                                        'Tuổi cạo',
                                        updates.first.tappingAge.toString(),
                                        icon: Icons.calendar_today,
                                      ),
                                      _buildInfoRow(
                                        'Thời gian',
                                        DateFormat('HH:mm dd/MM/yyyy')
                                            .format(updates.first.dateCheck),
                                        icon: Icons.access_time,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tổng số cây
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.forest,
                                        color: Colors.green[700]),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Tổng số cây: $totalTrees',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Danh sách trạng thái
                              const Text(
                                'Chi tiết trạng thái:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...allStatuses.entries.map((entry) {
                                final statusId = entry.key;
                                final statusName = entry.value;
                                int statusCount = 0;

                                // Tính tổng số cây cho trạng thái này
                                for (var update in updates) {
                                  for (var status in update.statusUpdates) {
                                    if (status.statusId == statusId) {
                                      statusCount +=
                                          int.tryParse(status.value) ?? 0;
                                    }
                                  }
                                }

                                final color = _getStatusColor(statusName);
                                final isExpanded =
                                    expandedStatus[statusId] ?? false;

                                return Column(
                                  children: [
                                    // Status header
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          expandedStatus[statusId] =
                                              !isExpanded;
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: color.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_down
                                                  : Icons.keyboard_arrow_right,
                                              color: color,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                statusName,
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '$statusCount cây',
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Status details when expanded
                                    if (isExpanded)
                                      ...updates.map((update) {
                                        final statusUpdate =
                                            update.statusUpdates.firstWhere(
                                                (s) => s.statusId == statusId,
                                                orElse: () => LocalStatusUpdate(
                                                    statusId: statusId,
                                                    statusName: statusName,
                                                    value: '0'));
                                        final value =
                                            int.tryParse(statusUpdate.value) ??
                                                0;
                                        if (value > 0) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                left: 32, bottom: 8, right: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  DateFormat('HH:mm dd/MM/yyyy')
                                                      .format(update.dateCheck),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  '$value cây',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
          ],
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
