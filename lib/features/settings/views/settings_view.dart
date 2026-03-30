import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Database Backup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Secure your business data by exporting a JSON backup, or restore from a previous file.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Export Section
            _buildSettingCard(
              'Export Data',
              'Saves all parts, sales, and categories into a portable JSON file.',
              Icons.cloud_upload_outlined,
              AppColors.primary,
              () => controller.exportBackup(),
            ),

            const SizedBox(height: 16),

            // Import Section
            _buildSettingCard(
              'Import Data',
              'Restore your database from a backup file. WARNING: This replaces all current data.',
              Icons.cloud_download_outlined,
              AppColors.warning,
              () => _showImportConfirmation(),
            ),

            const Spacer(),
            
            // Version Info
            const Center(
              child: Text(
                'v1.0.0 - Ahmad Autos POS',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      // Loading Overlay
      floatingActionButton: Obx(() => controller.isProcessing.value
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: AppColors.primary,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : const SizedBox()),
    );
  }

  void _showImportConfirmation() {
    Get.defaultDialog(
      title: 'Warning!',
      middleText: 'Importing a backup will PERMANENTLY REPLACE your existing inventory and sales records. Are you sure you want to proceed?',
      textConfirm: 'Import Now',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.importBackup();
      },
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
