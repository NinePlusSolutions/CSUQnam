import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                                child: Text(team.productTeamName ?? 'Unknown Team'),
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
                child: Obx(() => DropdownButton<String>(
                      value: controller.row.value.isEmpty
                          ? null
                          : controller.row.value,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Chọn hàng'),
                      items: controller.getRowNumbers().map((row) {
                        return DropdownMenuItem<String>(
                          value: row,
                          child: Text('Hàng $row'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.row.value = value;
                        }
                      },
                    )),
              ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
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
}
