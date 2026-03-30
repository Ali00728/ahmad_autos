import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database.dart';

class QuickTapGrid extends StatelessWidget {
  final PosController controller = Get.find<PosController>();

  QuickTapGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return const Center(child: Text('No products available.'));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final part = controller.filteredProducts[index];
          final bool isOutOfStock = part.stockQuantity <= 0;

          return InkWell(
            onTap: () => controller.addToCart(part),
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Icon(
                          Icons.settings_outlined,
                          size: 40,
                          color: isOutOfStock ? Colors.grey : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      part.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${part.defaultSellingPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock: ${part.stockQuantity}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isOutOfStock ? AppColors.error : Colors.grey.shade600,
                          ),
                        ),
                        if (isOutOfStock)
                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.error),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
