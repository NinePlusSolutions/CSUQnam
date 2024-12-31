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
              controller.clearSyncedData();
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

  void _showCardActions(LocalTreeUpdate update) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sync, color: Colors.green),
              ),
              title: const Text(
                'Đồng bộ mục này',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Đồng bộ dữ liệu của ${update.farmName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                Get.back();
                controller.syncSingleUpdate(update);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: const Text(
                'Xóa mục này',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Xóa dữ liệu của ${update.farmName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(update);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  void _showDeleteConfirmation(LocalTreeUpdate update) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content:
            Text('Bạn có chắc chắn muốn xóa dữ liệu của ${update.farmName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSingleUpdate(update);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeStatusSection(List<LocalStatusUpdate> statusUpdates) {
    final inventoryController = Get.find<InventoryController>();
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.park, color: Colors.green[700], size: 18),
              const SizedBox(width: 6),
              const Text(
                'Trạng thái cây',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusUpdates.map((status) {
              return Obx(() {
                final color =
                    inventoryController.statusColors[status.statusName] ??
                        Colors.grey;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status.statusName,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(LocalTreeUpdate update) {
    return GestureDetector(
      onTap: () => _showCardActions(update),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with location info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.green.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.green[700], size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(update.dateCheck),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Farm name with icon
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.green[700], size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          update.farmName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location details
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildLocationInfo(
                            icon: Icons.group,
                            label: 'Tổ',
                            value: update.productTeamName,
                          ),
                          VerticalDivider(
                            color: Colors.green.withOpacity(0.2),
                            thickness: 1,
                            indent: 4,
                            endIndent: 4,
                          ),
                          _buildLocationInfo(
                            icon: Icons.grid_view,
                            label: 'Lô',
                            value: update.farmLotName,
                          ),
                          VerticalDivider(
                            color: Colors.green.withOpacity(0.2),
                            thickness: 1,
                            indent: 4,
                            endIndent: 4,
                          ),
                          _buildLocationInfo(
                            icon: Icons.calendar_today,
                            label: 'Tuổi cạo',
                            value: '${update.tappingAge} tuổi',
                          ),
                          VerticalDivider(
                            color: Colors.green.withOpacity(0.2),
                            thickness: 1,
                            indent: 4,
                            endIndent: 4,
                          ),
                          _buildLocationInfo(
                            icon: Icons.format_list_numbered,
                            label: 'Hàng',
                            value: update.treeLineName,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tree status updates
            _buildTreeStatusSection(update.statusUpdates),

            // Shaved status
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.face, color: Colors.green[700], size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Trạng thái mặt cạo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      update.shavedStatusName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Note section if exists
            if (update.note != null && update.note!.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, color: Colors.orange[700], size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        update.note!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green[700], size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
