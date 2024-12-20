import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class SyncController extends GetxController {
  final storage = GetStorage();
  final RxList<Map<String, dynamic>> pendingUpdates =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingUpdates();
  }

  Future<void> loadPendingUpdates() async {
    isLoading.value = true;
    try {
      final String? updatesJson = storage.read('local_updates');
      print('Loading updates from storage: $updatesJson');

      if (updatesJson != null) {
        final List<dynamic> updates = jsonDecode(updatesJson);
        print('Decoded updates: $updates');

        // Convert to List<Map<String, dynamic>> and ensure all fields are present
        final List<Map<String, dynamic>> validUpdates = updates.map((update) {
          return {
            'farm': update['farm'] as String,
            'lot': update['lot'] as String,
            'team': update['team'] as String,
            'row': update['row'] as String,
            'statusCounts':
                Map<String, int>.from(update['statusCounts'] as Map),
            'tapAge': update['tapAge'] as String,
            'updatedAt': update['updatedAt'] as String,
          };
        }).toList();

        // Sort by most recent first
        validUpdates.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['updatedAt'] as String);
          final DateTime dateB = DateTime.parse(b['updatedAt'] as String);
          return dateB.compareTo(dateA);
        });

        pendingUpdates.value = validUpdates;
        print('Loaded ${pendingUpdates.length} updates');
      } else {
        print('No updates found in storage');
        pendingUpdates.clear();
      }
    } catch (e) {
      print('Error loading updates: $e');
      pendingUpdates.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncAll() async {
    isLoading.value = true;
    try {
      // Here you would send the data to your server
      await Future.delayed(const Duration(seconds: 2)); // Simulated API call

      // Clear local storage after successful sync
      await storage.write('local_updates', '[]');
      pendingUpdates.clear();

      Get.back(result: true);
    } catch (e) {
      print('Error syncing updates: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể đồng bộ dữ liệu. Vui lòng thử lại sau.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('HH:mm dd/MM/yyyy').format(date);
  }
}
