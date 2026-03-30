import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database.dart';

class PartListTile extends StatelessWidget {
  final Part part;
  final VoidCallback onTap;

  const PartListTile({
    super.key,
    required this.part,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStockColor(part.stockQuantity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.settings_suggest_outlined,
            color: _getStockColor(part.stockQuantity),
          ),
        ),
        title: Text(
          part.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Category: ${part.category}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              'Price: Rs. ${part.defaultSellingPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStockColor(part.stockQuantity).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Stock: ${part.stockQuantity}',
                style: TextStyle(
                  color: _getStockColor(part.stockQuantity),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              _getStockIcon(part.stockQuantity),
              size: 16,
              color: _getStockColor(part.stockQuantity),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor(int quantity) {
    if (quantity <= 0) return AppColors.error;
    if (quantity < 5) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStockIcon(int quantity) {
    if (quantity <= 0) return Icons.error_outline;
    if (quantity < 5) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline;
  }
}
