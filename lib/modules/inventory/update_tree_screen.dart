import 'package:flutter/material.dart';
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
              onPressed: _showSyncConfirmation,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.hasData.value) {
          return const Center(
            child: Text(
              'Không có dữ liệu nào cần đồng bộ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sections.length,
          itemBuilder: (context, index) {
            final section = controller.sections[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(section),
                  const Divider(),
                  _buildStatusGrid(section.statusCounts),
                  if (index == controller.sections.length - 1)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => controller.addNextRow(section),
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
        );
      }),
    );
  }

  Widget _buildSectionHeader(InventorySection section) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                section.farm,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.grid_4x4,
                  label: 'Lô',
                  value: section.lot,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.groups,
                  label: 'Tổ',
                  value: section.team,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.view_week,
                  label: 'Hàng',
                  value: section.row,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
    switch (status) {
      case 'N':
        return Colors.blue;
      case 'U':
        return Colors.green;
      case 'UN':
        return Colors.purple;
      case 'KB':
        return Colors.orange;
      case 'KG':
        return Colors.red;
      case 'KC':
        return Colors.red[700]!;
      case 'O':
        return Colors.grey;
      case 'M':
        return Colors.indigo;
      case 'B':
        return Colors.orange[300]!;
      case 'B4':
        return Colors.brown;
      case 'B5':
        return Colors.brown[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'N':
        return 'Cây non';
      case 'U':
        return 'Cây ươm';
      case 'UN':
        return 'Cây ươm non';
      case 'KB':
        return 'Kiến thiết cơ bản';
      case 'KG':
        return 'Kinh doanh';
      case 'KC':
        return 'Cây già cỗi';
      case 'O':
        return 'Cây chết';
      case 'M':
        return 'Cây mất';
      case 'B':
        return 'Cây bệnh';
      case 'B4':
        return 'Bệnh cấp 4';
      case 'B5':
        return 'Bệnh cấp 5';
      default:
        return 'Không xác định';
    }
  }
}
