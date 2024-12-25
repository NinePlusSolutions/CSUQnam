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

  Widget _buildUpdateItem(LocalTreeUpdate update) {
    return GestureDetector(
      onTap: () => _showCardActions(update),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   width: double.infinity,
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   decoration: BoxDecoration(
              //     color: Colors.green,
              //     border: Border(
              //       bottom: BorderSide(
              //         color: Colors.grey[300]!,
              //         width: 1,
              //       ),
              //     ),
              //   ),
              //   child: Row(
              //     children: [
              //       const Icon(Icons.location_on,
              //           color: Colors.white, size: 20),
              //       const SizedBox(width: 8),
              //       Expanded(
              //         child: Text(
              //           update.farmName,
              //           style: const TextStyle(
              //             fontSize: 16,
              //             fontWeight: FontWeight.w600,
              //             color: Colors.white,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Other info
              Container(
                // padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  // border: Border(
                  //   bottom: BorderSide(
                  //     color: Colors.grey[300]!,
                  //     width: 1,
                  //   ),
                  // ),
                ),
                child: _buildHeader(update),
              ),
              // Status updates
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusUpdates(update.statusUpdates),
                    const SizedBox(height: 20),
                    _buildShavedStatusAndNote(update),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LocalTreeUpdate update) {
    return Container(
      // margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Phần header với nền xanh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    update.farmName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phần thông tin chi tiết
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Hàng 1: Đội sản xuất và Lô
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.group,
                        label: 'Đội sản xuất',
                        value: update.productTeamName,
                        highlight: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.grid_view,
                        label: 'Lô',
                        value: update.farmLotName,
                        highlight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Hàng 2: Hàng và Tuổi cạo
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.format_list_numbered,
                        label: 'Hàng',
                        value: update.treeLineName,
                        highlight: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Tuổi cạo',
                        value: update.tappingAge ?? 'Chưa có',
                        highlight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool highlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? Colors.green.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? Colors.green.withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: highlight ? Colors.green : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: highlight ? Colors.green : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '---' : value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: highlight ? Colors.green[700] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdates(List<LocalStatusUpdate> statusUpdates) {
    final inventoryController = Get.find<InventoryController>();
    return Column(
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
            return Obx(() {
              final color =
                  inventoryController.statusColors[status.statusName] ??
                      Colors.grey;
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildShavedStatusAndNote(LocalTreeUpdate update) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.face, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Thông tin mặt cạo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trạng thái',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        update.shavedStatusName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (update.note != null && update.note!.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          update.note!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
