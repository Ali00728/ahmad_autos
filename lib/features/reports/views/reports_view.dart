import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/reports_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database.dart';

class ReportsView extends StatelessWidget {
  final ReportsController controller = Get.put(ReportsController());

  ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales Reports'),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.selectedSales.isEmpty) {
                return _buildEmptyState();
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  ...controller.selectedSales.map((sale) => _buildSaleTile(sale)).toList(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() => SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Daily'), icon: Icon(Icons.calendar_view_day)),
                    ButtonSegment(value: true, label: Text('Monthly'), icon: Icon(Icons.calendar_month)),
                  ],
                  selected: {controller.isMonthly.value},
                  onSelectionChanged: (val) => controller.setMonthly(val.first),
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showDatePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    controller.isMonthly.value
                        ? DateFormat('MMMM yyyy').format(controller.selectedDate.value)
                        : DateFormat('EEEE, d MMMM yyyy').format(controller.selectedDate.value),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )),
                  const Icon(Icons.edit_calendar, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Revenue',
                'Rs. ${controller.totalRevenue.value.toStringAsFixed(0)}',
                Icons.account_balance_wallet,
                AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Sales Count',
                '${controller.totalTransactions.value}',
                Icons.shopping_bag,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Items Sold',
                '${controller.totalItemsSold.value}',
                Icons.inventory_2,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSaleTile(Sale sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Order #${sale.id}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(DateFormat('hh:mm a').format(sale.saleDate)),
          trailing: Text(
            'Rs. ${sale.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: controller.getSaleDetails(sale.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: snapshot.data!.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item['name']} x${item['quantity']}')),
                          Text('Rs. ${item['total'].toStringAsFixed(0)}'),
                        ],
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No sales found for this period', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.updateDate(picked);
    }
  }
}
