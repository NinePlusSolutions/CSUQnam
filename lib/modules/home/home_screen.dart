import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import '../sync/sync_controller.dart';
import '../auth/auth_controller.dart';
import 'package:get_storage/get_storage.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Trang chủ',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.green,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _showLogoutConfirmation,
        ),
      ],
    );
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showLogoutConfirmation() {
    final syncController = Get.find<SyncController>();
    if (syncController.pendingUpdates.isNotEmpty) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cảnh báo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đang có thông tin cần đồng bộ, nếu thoát là sẽ xóa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await syncController.clearAllData();
                          Get.back(); // Close dialog
                          await controller.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Đồng ý'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      controller.logout();
    }
  }

  Future<void> _handleLogout() async {
    // Kiểm tra kết nối mạng
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      Get.snackbar(
        'Lỗi kết nối',
        'Vui lòng kiểm tra kết nối mạng trước khi đăng xuất',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final storage = GetStorage();
    final localUpdates = storage.read('local_updates');

    if (localUpdates != null &&
        localUpdates is List &&
        localUpdates.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Cảnh báo'),
          content: const Text(
            'Bạn có dữ liệu cần phải đồng bộ, nếu vẫn tiếp tục, dữ liệu sẽ bị xóa. Bạn có chắc chắn muốn tiếp tục không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                storage.erase();
                Get.offAllNamed('/auth');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      );
    } else {
      storage.erase();
      Get.offAllNamed('/auth');
    }
  }

  Widget _buildBody() {
    final syncController = Get.put(SyncController());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Xin chào!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chọn tác vụ bạn muốn thực hiện',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            Obx(() {
              return _buildActionButton(
                icon: Icons.inventory_2_outlined,
                label: 'Kiểm kê',
                color: Colors.green,
                description: controller.isLoadingBatch.value
                    ? 'Đang tải...'
                    : controller.currentBatchName.value.isEmpty
                        ? 'Chưa có đợt kiểm kê'
                        : controller.currentBatchName.value,
                onTap: controller.handleInventoryPress,
              );
            }),
            const SizedBox(height: 16),
            Obx(() => _buildActionButton(
                  icon: Icons.sync,
                  label: 'Đồng bộ',
                  color: Colors.blue,
                  hasBadge: syncController.pendingUpdates.isNotEmpty,
                  onTap: () => Get.toNamed('/sync'),
                )),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.history_rounded,
              label: 'Lịch sử đồng bộ',
              color: Colors.purple,
              description: 'Xem lịch sử đồng bộ dữ liệu',
              onTap: () => Get.toNamed('/history'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool hasBadge = false,
    String? description,
  }) {
    Widget iconWidget = Icon(
      icon,
      color: Colors.white,
      size: 32,
    );

    if (hasBadge) {
      iconWidget = badges.Badge(
        position: badges.BadgePosition.topEnd(top: -8, end: -6),
        badgeContent: const Text(
          '!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.red,
          padding: EdgeInsets.all(6),
        ),
        child: iconWidget,
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: iconWidget,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description ??
                            (label == 'Kiểm kê'
                                ? 'Cập nhật thông tin cây'
                                : 'Đồng bộ dữ liệu mới nhất'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
