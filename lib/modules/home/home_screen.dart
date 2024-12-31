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
    final syncController = Get.find<SyncController>();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.inventory_2_outlined,
                  label: 'Kiểm kê',
                  color: Colors.green,
                  onTap: controller.handleInventoryPress,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.sync,
                  label: 'Đồng bộ',
                  color: Colors.blue,
                  countBuilder: () => syncController.pendingUpdates.length,
                  onTap: () => Get.toNamed('/sync'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.history_rounded,
                  label: 'Lịch sử đồng bộ',
                  color: Colors.purple,
                  onTap: () => Get.toNamed('/history'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int Function()? countBuilder,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 32),
                if (countBuilder != null)
                  Obx(() {
                    final count = countBuilder();
                    if (count > 0) {
                      return Positioned(
                        right: -12,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
