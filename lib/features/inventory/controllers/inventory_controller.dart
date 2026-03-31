import 'dart:math';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';

class InventoryController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  
  final RxList<Part> parts = <Part>[].obs;
  final RxList<Part> filteredParts = <Part>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Use a stream for real-time updates
    db.watchAllParts().listen((data) {
      parts.assignAll(data);
      _filterParts();
    });
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _filterParts();
  }

  void _filterParts() {
    if (searchQuery.value.isEmpty) {
      filteredParts.assignAll(parts);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredParts.assignAll(
        parts.where((p) => 
          p.name.toLowerCase().contains(query) || 
          (p.barcode?.toLowerCase().contains(query) ?? false) ||
          p.category.toLowerCase().contains(query)
        ).toList(),
      );
    }
  }

  Future<void> addPart({
    required String name,
    String? barcode,
    required String category,
    required double costPrice,
    required double defaultSellingPrice,
    required double minimumSellingPrice,
    required int stockQuantity,
  }) async {
    try {
      await db.addPart(PartsCompanion.insert(
        name: name,
        barcode: drift.Value(barcode),
        category: category,
        costPrice: costPrice,
        defaultSellingPrice: defaultSellingPrice,
        minimumSellingPrice: minimumSellingPrice,
        stockQuantity: stockQuantity,
      ));
    } catch (e) {
      Get.snackbar('Error', 'Failed to add part: $e');
    }
  }

  Future<void> updatePartDetails(Part part) async {
    try {
      await db.updatePart(part);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update part: $e');
    }
  }

  Future<void> deletePart(int id) async {
    try {
      await db.deletePart(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete part: $e');
    }
  }

  String generateUniqueBarcode() {
    final random = Random();
    const chars = '0123456789';
    String code = '';
    
    // Generate a 10-digit numeric barcode
    do {
      code = List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
    } while (parts.any((p) => p.barcode == code));
    
    return code;
  }
}
