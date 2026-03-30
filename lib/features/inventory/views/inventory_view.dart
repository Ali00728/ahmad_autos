import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/database/database.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/part_list_tile.dart';
import 'add_part_view.dart';
import '../../../core/constants/app_colors.dart';

class InventoryView extends StatelessWidget {
  final InventoryController controller = Get.put(InventoryController());

  InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            onPressed: () => controller.updateSearch(''),
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Search',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search by name, barcode, or category...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
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

          // Parts List
          Expanded(
            child: Obx(() {
              if (controller.filteredParts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isEmpty 
                            ? 'No parts in inventory yet' 
                            : 'No matching parts found',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (controller.searchQuery.value.isEmpty)
                        const Text('Tap the + button to add your first part'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: controller.filteredParts.length,
                itemBuilder: (context, index) {
                  final part = controller.filteredParts[index];
                  return PartListTile(
                    part: part,
                    onTap: () => Get.to(() => AddPartView(part: part)),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddPartView()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Part', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
