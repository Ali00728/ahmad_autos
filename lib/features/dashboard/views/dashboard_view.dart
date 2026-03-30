import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../../inventory/views/inventory_view.dart';
import '../../pos/views/pos_view.dart';
import '../../settings/views/settings_view.dart';
import '../../reports/views/reports_view.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ahmad Autos - Command Center'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SettingsView()),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'System Settings',
          ),
          IconButton(
            onPressed: () => controller.fetchMetrics(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const Text(
              'Business Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Today\'s Revenue',
                    controller.todayRevenue,
                    Icons.payments,
                    AppColors.primary,
                    isCurrency: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Items Sold',
                    controller.todayItemsSold,
                    Icons.shopping_basket,
                    AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions Section
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Inventory',
                    Icons.inventory_2,
                    () => Get.to(() => InventoryView()),
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'POS Checkout',
                    Icons.point_of_sale,
                    () => Get.to(() => PosView()),
                    AppColors.accent,
                    textColor: AppColors.textBody,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Sales Reports',
                    Icons.analytics,
                    () => Get.to(() => ReportsView()),
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Settings',
                    Icons.settings,
                    () => Get.to(() => SettingsView()),
                    Colors.blueGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Low Stock Alerts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error),
                ),
                Obx(() => Text(
                  '${controller.lowStockParts.length} Parts',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                )),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.lowStockParts.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.success, size: 40),
                      const SizedBox(height: 8),
                      const Text('All stock levels are healthy!'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.lowStockParts.length,
                itemBuilder: (context, index) {
                  final part = controller.lowStockParts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.red.shade100),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                      ),
                      title: Text(part.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(part.category),
                      trailing: Text(
                        '${part.stockQuantity} Left',
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, Rx value, IconData icon, Color color, {bool isCurrency = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Obx(() => Text(
            isCurrency ? 'Rs. ${value.value.toStringAsFixed(0)}' : value.value.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap, Color bgColor, {Color textColor = Colors.white}) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 30),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
