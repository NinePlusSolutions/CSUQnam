import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:get/get.dart';
import 'update_tree_controller.dart';
import 'models/inventory_section.dart';

class UpdateTreeScreen extends GetView<UpdateTreeController> {
  final String farm;
  final String lot;
  final String team;
  final String row;
  final Map<String, int> statusCounts;

  const UpdateTreeScreen({
    super.key,
    required this.farm,
    required this.lot,
    required this.team,
    required this.row,
    required this.statusCounts,
  });

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final shavedStatusName = arguments['shavedStatusName'] as String;
    final tappingAge = arguments['tappingAge'] as String? ?? 'Chưa có';

    // Thêm section hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.addSection(
        InventorySection(
          farm: farm,
          lot: lot,
          team: team,
          row: row,
          statusCounts: Map.fromEntries(
            statusCounts.entries.where((entry) => entry.value > 0),
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết kiểm kê',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.sync, color: Colors.white),
              onPressed: () => Get.toNamed('/sync'),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.hasData.value
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderItem(
                          icon: Icons.location_on,
                          label: 'Nông trường',
                          value: farm,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildHeaderItem(
                                icon: Icons.group,
                                label: 'Đội sản xuất',
                                value: team,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildHeaderItem(
                                icon: Icons.grid_4x4,
                                label: 'Lô',
                                value: lot,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildHeaderItem(
                                icon: Icons.format_list_numbered,
                                label: 'Hàng',
                                value: row,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildHeaderItem(
                                icon: Icons.calendar_today,
                                label: 'Tuổi cạo',
                                value: tappingAge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildHeaderItem(
                          icon: Icons.local_offer,
                          label: 'Trạng thái cạo',
                          value: shavedStatusName,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.sections.length,
                      itemBuilder: (context, index) {
                        final section = controller.sections[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // _buildSectionHeader(section),
                              _buildStatusGrid(section.statusCounts),
                              if (index == controller.sections.length - 1)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      onPressed: () =>
                                          controller.addNextRow(section),
                                      child: const Text(
                                        'Tiếp tục hàng tiếp theo',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget _buildHeaderItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(InventorySection section) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'C',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '1',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              Text(
                'Kg',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '1',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid(Map<String, int> statusCounts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: statusCounts.length,
      itemBuilder: (context, index) {
        final status = statusCounts.keys.elementAt(index);
        final count = statusCounts[status]!;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getStatusColor(status).withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSyncConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sync, color: Colors.green[700], size: 24),
            const SizedBox(width: 8),
            const Text('Xác nhận đồng bộ'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đồng bộ không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.syncData();
              Get.snackbar(
                'Thành công',
                'Đồng bộ dữ liệu thành công',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            },
            child: Text(
              'Đồng ý',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final inventoryController = Get.find<InventoryController>();
    return inventoryController.statusColors[status] ?? Colors.grey;
  }
}
