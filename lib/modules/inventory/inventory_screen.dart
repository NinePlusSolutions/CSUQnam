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
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border:
                            Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.submitInventory,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 15),
                            child: Center(
                              child: Text(
                                'Kết thúc',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text('Chỉnh sửa thông tin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown Nông trường
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Nông trường',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.farm.value,
              items: controller.farms
                  .map((farm) => DropdownMenuItem(
                        value: farm,
                        child: Text(farm),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.farm.value = value;
                }
              },
            ),
            const SizedBox(height: 16),
            // Dropdown Lô
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Lô',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.lot.value,
              items: controller.lots
                  .map((lot) => DropdownMenuItem(
                        value: lot,
                        child: Text(lot),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.lot.value = value;
                }
              },
            ),
            const SizedBox(height: 16),
            // Dropdown Tổ sản xuất
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tổ sản xuất',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.productionTeam.value,
              items: controller.teams
                  .map((team) => DropdownMenuItem(
                        value: team,
                        child: Text(team),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.productionTeam.value = value;
                }
              },
            ),
            const SizedBox(height: 16),
            // Dropdown Hàng
            Obx(() {
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Hàng',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: controller.row.value,
                items: controller.rows
                    .map((row) => DropdownMenuItem(
                          value: row,
                          child: Text(row),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.row.value = value;
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Thành công',
                'Đã cập nhật thông tin',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            },
            child: Text(
              'Cập nhật',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
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
                      ? _getStatusColor(status.code).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
              border: Border.all(
                color: isEditing
                    ? _getStatusColor(status.code).withOpacity(0.2)
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
                              ? _getStatusColor(status.code).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.code,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isEditing
                                ? _getStatusColor(status.code)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final count = controller.getCount(status.code);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.remove,
                        onPressed: (count > 0 && isEditing)
                            ? () => controller.decrementStatus(status.code)
                            : null,
                        color: isEditing
                            ? _getStatusColor(status.code)
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
                            ? () => controller.incrementStatus(status.code)
                            : null,
                        color: isEditing
                            ? _getStatusColor(status.code)
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
                color: _getStatusColor(status.code).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(status.code).withOpacity(0.2),
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
                      color: _getStatusColor(status.code),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.code,
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
            onChanged: controller.updateNote,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú (nếu có)',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
