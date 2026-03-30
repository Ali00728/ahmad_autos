import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';
import '../../../core/constants/app_colors.dart';

class CartListWidget extends StatelessWidget {
  final PosController controller = Get.find<PosController>();

  CartListWidget({super.key});

  void _showPriceNegotiationDialog(int index) {
    final item = controller.cartItems[index];
    final TextEditingController priceController = 
        TextEditingController(text: item.actualSoldPrice.toStringAsFixed(0));
    final RxDouble currentInput = item.actualSoldPrice.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Negotiate Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.part.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Actual Sold Price',
                prefixText: 'Rs. ',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                currentInput.value = double.tryParse(val) ?? 0.0;
              },
            ),
            const SizedBox(height: 8),
            Obx(() {
              final bool isBelowMin = currentInput.value < item.part.minimumSellingPrice;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Min. Price: Rs. ${item.part.minimumSellingPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isBelowMin ? AppColors.error : Colors.grey,
                      fontWeight: isBelowMin ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isBelowMin)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Warning: Price below minimum limit!',
                        style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null) {
                controller.updateItemPrice(index, newPrice);
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.cartItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('Cart is empty', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.cartItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = controller.cartItems[index];

                // Check if price is negotiated
                final bool isNegotiated = item.actualSoldPrice != item.part.defaultSellingPrice;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.part.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: InkWell(
                    onTap: () => _showPriceNegotiationDialog(index),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rs. ${item.actualSoldPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: isNegotiated ? AppColors.warning : Colors.grey.shade700,
                            fontWeight: isNegotiated ? FontWeight.bold : FontWeight.normal,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dotted,
                          ),
                        ),
                        if (isNegotiated)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.edit_note, size: 14, color: AppColors.warning),
                          ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => controller.decrementQuantity(index),
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.incrementQuantity(index),
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.success, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          'Rs. ${item.subTotal.toStringAsFixed(0)}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        
        // Checkout Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Obx(() => Text(
                    'Rs. ${controller.grandTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.cartItems.isEmpty) return;
                    
                    Get.defaultDialog(
                      title: 'Confirm Checkout',
                      middleText: 'Total Amount: Rs. ${controller.grandTotal.toStringAsFixed(0)}\nAre you sure you want to complete this sale?',
                      textConfirm: 'Complete Sale',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back(); // Close dialog
                        controller.checkout();
                      },
                    );
                  },
                  child: const Text('Complete Sale'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
