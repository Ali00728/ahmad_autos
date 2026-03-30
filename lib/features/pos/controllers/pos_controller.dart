import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../models/cart_item.dart';

class PosController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxList<Part> availableProducts = <Part>[].obs;
  final RxList<Part> filteredProducts = <Part>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    debounce(searchQuery, (_) => _filterProducts(), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchProducts() async {
    try {
      final data = await db.getAllParts();
      availableProducts.assignAll(data);
      _filterParts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  void _filterParts() {
    _filterProducts();
  }

  void _filterProducts() {
    if (searchQuery.value.isEmpty) {
      filteredProducts.assignAll(availableProducts);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredProducts.assignAll(
        availableProducts.where((p) {
          return p.name.toLowerCase().contains(query) || 
                 (p.barcode?.toLowerCase().contains(query) ?? false) ||
                 p.category.toLowerCase().contains(query);
        }).toList(),
      );
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void addToCart(Part part) {
    if (part.stockQuantity <= 0) {
      Get.snackbar('Out of Stock', '${part.name} is currently out of stock.');
      return;
    }

    final existingIndex = cartItems.indexWhere((item) => item.part.id == part.id);
    if (existingIndex != -1) {
      final item = cartItems[existingIndex];
      if (item.quantity < part.stockQuantity) {
        item.quantity++;
        cartItems[existingIndex] = item;
        cartItems.refresh();
      } else {
        Get.snackbar('Stock Limit', 'Cannot add more. Stock limit reached.');
      }
    } else {
      cartItems.add(CartItem(part: part));
    }
  }

  void incrementQuantity(int index) {
    final item = cartItems[index];
    if (item.quantity < item.part.stockQuantity) {
      item.quantity++;
      cartItems[index] = item;
      cartItems.refresh();
    } else {
      Get.snackbar('Stock Limit', 'Cannot add more. Stock limit reached.');
    }
  }

  void decrementQuantity(int index) {
    final item = cartItems[index];
    if (item.quantity > 1) {
      item.quantity--;
      cartItems[index] = item;
      cartItems.refresh();
    } else {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }

  void clearCart() {
    cartItems.clear();
  }

  void updateItemPrice(int index, double newPrice) {
    if (index >= 0 && index < cartItems.length) {
      final item = cartItems[index];
      item.actualSoldPrice = newPrice;
      cartItems[index] = item;
      cartItems.refresh();
    }
  }

  double get grandTotal => cartItems.fold(0, (sum, item) => sum + item.subTotal);

  Future<void> checkout() async {
    if (cartItems.isEmpty) return;

    try {
      await db.transaction(() async {
        // 1. Create Sale
        final saleId = await db.addSale(SalesCompanion.insert(
          saleDate: DateTime.now(),
          totalAmount: grandTotal,
        ));

        // 2. Process Cart Items
        for (var item in cartItems) {
          // Record sale item
          await db.addSaleItem(SaleItemsCompanion.insert(
            saleId: saleId,
            partId: item.part.id,
            quantity: item.quantity,
            actualSoldPrice: item.actualSoldPrice,
          ));

          // 3. Deduct Stock
          final part = item.part;
          final updatedPart = Part(
            id: part.id,
            name: part.name,
            barcode: part.barcode,
            category: part.category,
            costPrice: part.costPrice,
            defaultSellingPrice: part.defaultSellingPrice,
            minimumSellingPrice: part.minimumSellingPrice,
            stockQuantity: part.stockQuantity - item.quantity,
          );
          await db.updatePart(updatedPart);
        }
      });

      // Cleanup
      clearCart();
      await fetchProducts();
      
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchMetrics();
      }
      
      Get.snackbar('Success', 'Sale recorded successfully');
    } catch (e) {
      print('Checkout Error: $e');
      Get.snackbar('Error', 'Checkout failed: $e');
    }
  }
}
