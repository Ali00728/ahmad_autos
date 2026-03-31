import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';
import '../widgets/quick_tap_grid.dart';
import '../widgets/cart_list_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/widgets/barcode_scanner_dialog.dart';

class PosView extends StatelessWidget {
  final PosController controller = Get.put(PosController());

  PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          IconButton(
            onPressed: () => controller.clearCart(),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Cart',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isLargeScreen = constraints.maxWidth > 800;

          if (isLargeScreen) {
            return Row(
              children: [
                // Product Selection Grid (Left)
                Expanded(
                  flex: 3,
                  child: _buildProductSection(context),
                ),
                // Vertical Divider
                const VerticalDivider(width: 1),
                // Cart Summary (Right)
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: CartListWidget(),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                // Product Selection Grid (Top)
                Expanded(
                  flex: 3,
                  child: _buildProductSection(context),
                ),
                // Cart Summary (Bottom) - Pull up sheet style or fixed
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: CartListWidget(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildProductSection(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: controller.updateSearch,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: IconButton(
                onPressed: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => const BarcodeScannerDialog(),
                  );
                  if (result != null) {
                    controller.handleBarcodeScan(result);
                  }
                },
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                tooltip: 'Scan Barcode',
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // Product Grid
        Expanded(
          child: QuickTapGrid(),
        ),
      ],
    );
  }
}
