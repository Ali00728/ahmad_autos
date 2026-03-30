import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../controllers/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';

class AddPartView extends StatefulWidget {
  final Part? part;

  const AddPartView({super.key, this.part});

  @override
  State<AddPartView> createState() => _AddPartViewState();
}

class _AddPartViewState extends State<AddPartView> {
  final InventoryController controller = Get.find<InventoryController>();

  final nameController = TextEditingController();
  final barcodeController = TextEditingController();
  final categoryController = TextEditingController();
  final costPriceController = TextEditingController();
  final defaultPriceController = TextEditingController();
  final minPriceController = TextEditingController();
  final stockController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.part != null) {
      nameController.text = widget.part!.name;
      barcodeController.text = widget.part!.barcode ?? '';
      categoryController.text = widget.part!.category;
      costPriceController.text = widget.part!.costPrice.toString();
      defaultPriceController.text = widget.part!.defaultSellingPrice.toString();
      minPriceController.text = widget.part!.minimumSellingPrice.toString();
      stockController.text = widget.part!.stockQuantity.toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    barcodeController.dispose();
    categoryController.dispose();
    costPriceController.dispose();
    defaultPriceController.dispose();
    minPriceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.part == null ? 'Add New Spare Part' : 'Edit Spare Part'),
        actions: [
          if (widget.part != null)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Delete Part',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('General Information'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(nameController, 'Part Name', Icons.settings_suggest, validator: (v) => v!.isEmpty ? 'Name required' : null),
                      const SizedBox(height: 16),
                      _buildTextField(barcodeController, 'Barcode (Optional)', Icons.qr_code_scanner),
                      const SizedBox(height: 16),
                      _buildTextField(categoryController, 'Category', Icons.category_outlined, validator: (v) => v!.isEmpty ? 'Category required' : null),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Pricing & Inventory'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField(costPriceController, 'Cost Price', Icons.money, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField(stockController, 'Stock Quantity', Icons.inventory, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(defaultPriceController, 'Default Sell', Icons.sell, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField(minPriceController, 'Min. Sell', Icons.price_check, isNumber: true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _savePart,
                  child: Text(
                    widget.part == null ? 'CREATE PART' : 'UPDATE PART',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  void _savePart() {
    if (_formKey.currentState!.validate()) {
      if (widget.part != null) {
        final updatedPart = Part(
          id: widget.part!.id,
          name: nameController.text,
          barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
          category: categoryController.text,
          costPrice: double.tryParse(costPriceController.text) ?? 0,
          defaultSellingPrice: double.tryParse(defaultPriceController.text) ?? 0,
          minimumSellingPrice: double.tryParse(minPriceController.text) ?? 0,
          stockQuantity: int.tryParse(stockController.text) ?? 0,
        );
        controller.updatePartDetails(updatedPart);
      } else {
        controller.addPart(
          name: nameController.text,
          barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
          category: categoryController.text,
          costPrice: double.tryParse(costPriceController.text) ?? 0,
          defaultSellingPrice: double.tryParse(defaultPriceController.text) ?? 0,
          minimumSellingPrice: double.tryParse(minPriceController.text) ?? 0,
          stockQuantity: int.tryParse(stockController.text) ?? 0,
        );
      }
      Get.back();
      Get.snackbar('Success', 'Part saved successfully');
    }
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Delete Part',
      middleText: 'Are you sure you want to delete ${widget.part!.name}?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        controller.deletePart(widget.part!.id);
        Get.back(); // Close dialog
        Get.back(); // Close screen
        Get.snackbar('Deleted', 'Part removed from inventory');
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
