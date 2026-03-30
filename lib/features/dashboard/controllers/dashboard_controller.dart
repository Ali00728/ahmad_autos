import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';

class DashboardController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  
  final RxDouble todayRevenue = 0.0.obs;
  final RxInt todayItemsSold = 0.obs;
  final RxList<Part> lowStockParts = <Part>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMetrics();
    
    // Auto refresh low stock when parts change
    db.watchAllParts().listen((_) {
      _fetchLowStock();
    });
  }

  Future<void> fetchMetrics() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 1. Fetch Today's Sales
      final sales = await db.getSalesByDate(startOfDay);

      double revenue = 0.0;
      int itemsSold = 0;

      for (var sale in sales) {
        revenue += sale.totalAmount;
        
        // Sum items for this sale
        final items = await db.getItemsForSale(sale.id);
        for (var item in items) {
          itemsSold += item.quantity;
        }
      }

      todayRevenue.value = revenue;
      todayItemsSold.value = itemsSold;

      // 2. Fetch Low Stock
      await _fetchLowStock();
    } catch (e) {
      print('Dashboard Metrics Error: $e');
    }
  }

  Future<void> _fetchLowStock() async {
    final lowStock = await (db.select(db.parts)..where((t) => t.stockQuantity.isSmallerThan(const drift.Variable(5)))).get();
    lowStockParts.assignAll(lowStock);
  }
}
