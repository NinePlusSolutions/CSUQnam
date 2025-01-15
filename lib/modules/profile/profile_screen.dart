import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  void _showFeatureInDevelopment() {
    Get.snackbar(
      'Thông báo',
      'Tính năng đang được phát triển',
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2E7D32),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header with Avatar
              const SizedBox(height: 20),
              // Avatar Container
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(() => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: DecorationImage(
                          image: NetworkImage(
                            controller.avatarUrl.isNotEmpty
                                ? controller.avatarUrl
                                : 'https://ui-avatars.com/api/?name=${controller.fullName}&background=2E7D32&color=fff',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
              ),
              // Spacing for profile info
              const SizedBox(height: 20),
              // Profile Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Obx(() => Text(
                          controller.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Profile Options
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // _buildProfileOption(
                    //   icon: Icons.person_outline,
                    //   title: 'Thông tin cá nhân',
                    //   onTap: _showFeatureInDevelopment,
                    //   enabled: false,
                    // ),
                    // _buildProfileOption(
                    //   icon: Icons.notifications_outlined,
                    //   title: 'Thông báo',
                    //   onTap: _showFeatureInDevelopment,
                    //   enabled: false,
                    // ),
                    _buildProfileOption(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      onTap: () => Get.toNamed('/change-password'),
                      enabled: true,
                    ),
                    // _buildProfileOption(
                    //   icon: Icons.settings_outlined,
                    //   title: 'Cài đặt',
                    //   onTap: _showFeatureInDevelopment,
                    //   enabled: false,
                    // ),
                    // _buildProfileOption(
                    //   icon: Icons.help_outline,
                    //   title: 'Trợ giúp & Hỗ trợ',
                    //   onTap: _showFeatureInDevelopment,
                    //   enabled: false,
                    // ),
                    const SizedBox(height: 20),
                    // Logout Button
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: ElevatedButton.icon(
                    //     onPressed: () {},
                    //     icon: const Icon(Icons.logout),
                    //     label: const Text('Đăng xuất'),
                    //     style: ElevatedButton.styleFrom(
                    //       foregroundColor: Colors.white,
                    //       backgroundColor: Colors.red.shade600,
                    //       padding: const EdgeInsets.symmetric(vertical: 15),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       elevation: 2,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final color = enabled ? const Color(0xFF2E7D32) : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: color,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
