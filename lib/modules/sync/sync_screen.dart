import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/local/local_tree_update.dart';
import 'package:flutter_getx_boilerplate/modules/inventory/inventory_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'sync_controller.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncController controller = Get.find<SyncController>();

  @override
  void initState() {
    super.initState();
    final inventoryController = Get.put(InventoryController());
    inventoryController.fetchStatusData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPendingUpdates();
    });
  }

  Color _getStatusColor(String status) {
    final inventoryController = Get.find<InventoryController>();
    return inventoryController.statusColors[status] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đồng bộ dữ liệu',
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _showClearConfirmation,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isSyncing.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 16),
                Text(
                  'Đang đồng bộ... ${(controller.syncProgress.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.pendingUpdates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không có dữ liệu cần đồng bộ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                controller.loadPendingUpdates();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: controller.pendingUpdates.length,
                itemBuilder: (context, index) {
                  final update = controller.pendingUpdates[index];
                  return _buildUpdateItem(update);
                },
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _showSyncConfirmation,
                child: const Text(
                  'Đồng bộ tất cả',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
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
        content: const Text(
          'Bạn có chắc chắn muốn đồng bộ không? Tác vụ này sẽ không được hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.syncUpdates();
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

  void _showClearConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red[700], size: 24),
            const SizedBox(width: 8),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả dữ liệu cập nhật không? Tác vụ này sẽ không được hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearPendingUpdates();
            },
            child: Text(
              'Đồng ý',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(LocalTreeUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(update),
          const Divider(height: 1),
          _buildStatusUpdates(update.statusUpdates),
          const Divider(height: 1),
          _buildShavedStatus(update),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm dd/MM/yyyy').format(update.dateCheck),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LocalTreeUpdate update) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            icon: Icons.location_on,
            label: 'Nông trường',
            value: update.farmName,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.group,
                  label: 'Đội sản xuất',
                  value: update.productTeamName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.grid_4x4,
                  label: 'Lô',
                  value: update.farmLotName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.format_list_numbered,
                  label: 'Hàng',
                  value: update.treeLineName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Tuổi cạo',
                  value: update.tappingAge ?? 'Chưa có',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            icon: Icons.local_offer,
            label: 'Trạng thái cạo',
            value: update.shavedStatusName,
          ),
          if (update.note?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _buildInfoItem(
              icon: Icons.note,
              label: 'Ghi chú',
              value: update.note!,
            ),
          ],
        ],
      ),
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

  Widget _buildStatusUpdates(List<LocalStatusUpdate> statusUpdates) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Cập nhật:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: statusUpdates.length,
            itemBuilder: (context, index) {
              final status = statusUpdates[index];
              final color = _getStatusColor(status.statusName);
              return Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      status.statusName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShavedStatus(LocalTreeUpdate update) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.face, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Trạng thái mặt cạo:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue[200]!,
                width: 1,
              ),
            ),
            child: Text(
              update.shavedStatusName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}