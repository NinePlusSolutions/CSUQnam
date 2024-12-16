import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'inventory_controller.dart';

class UpdateTreeScreen extends StatelessWidget {
  final String farm;
  final String lot;
  final String team;
  final String row;
  final Map<String, int> statusCounts;

  const UpdateTreeScreen({
    Key? key,
    required this.farm,
    required this.lot,
    required this.team,
    required this.row,
    required this.statusCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildStatusList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                farm,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
                  value: lot,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.groups,
                  label: 'Tổ',
                  value: team,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.view_week,
                  label: 'Hàng',
                  value: row,
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
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: statusCounts.length,
      itemBuilder: (context, index) {
        final status = statusCounts.keys.elementAt(index);
        final count = statusCounts[status]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              _getStatusDescription(status),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
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
        return Colors.orange[700]!;
      case 'KG':
        return Colors.red[700]!;
      case 'KC':
        return Colors.red;
      case 'O':
        return Colors.black;
      case 'M':
        return Colors.indigo;
      case 'B':
        return Colors.amber[900]!;
      case 'B4':
        return Colors.brown;
      case 'B5':
        return Colors.brown[900]!;
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
        return 'Cây ươm nối';
      case 'KB':
        return 'Khoảng trống';
      case 'KG':
        return 'Khoảng gãy';
      case 'KC':
        return 'Khoảng chết';
      case 'O':
        return 'Cây già';
      case 'M':
        return 'Cây mới';
      case 'B':
        return 'Cây bệnh';
      case 'B4':
        return 'Cây bệnh cấp 4';
      case 'B5':
        return 'Cây bệnh cấp 5';
      default:
        return 'Không xác định';
    }
  }
}
