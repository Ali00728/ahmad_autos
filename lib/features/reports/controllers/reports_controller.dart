import 'package:get/get.dart';
import '../../../core/database/database.dart';

class ReportsController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isMonthly = false.obs;
  final RxList<Sale> selectedSales = <Sale>[].obs;
  final RxBool isLoading = false.obs;

  // Aggregated Metrics
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalTransactions = 0.obs;
  final RxInt totalItemsSold = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  void setMonthly(bool value) {
    isMonthly.value = value;
    fetchReports();
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
    fetchReports();
  }

  Future<void> fetchReports() async {
    isLoading.value = true;
    try {
      DateTime start;
      DateTime end;

      if (isMonthly.value) {
        start = DateTime(selectedDate.value.year, selectedDate.value.month, 1);
        end = DateTime(selectedDate.value.year, selectedDate.value.month + 1, 1);
      } else {
        start = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
        end = start.add(const Duration(days: 1));
      }

      final sales = await db.getSalesByRange(start, end);
      selectedSales.assignAll(sales);

      // Aggregate Metrics
      double revenue = 0;
      int itemsCount = 0;

      for (var sale in sales) {
        revenue += sale.totalAmount;
        final items = await db.getItemsForSale(sale.id);
        for (var item in items) {
          itemsCount += item.quantity;
        }
      }

      totalRevenue.value = revenue;
      totalTransactions.value = sales.length;
      totalItemsSold.value = itemsCount;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getSaleDetails(int saleId) async {
    final items = await db.getItemsForSale(saleId);
    final List<Map<String, dynamic>> details = [];

    for (var item in items) {
      // Find part name (This could be optimized with a JOIN in database.dart later)
      final part = (await (db.select(db.parts)..where((t) => t.id.equals(item.partId))).getSingleOrNull());
      details.add({
        'name': part?.name ?? 'Unknown Part',
        'quantity': item.quantity,
        'price': item.actualSoldPrice,
        'total': item.quantity * item.actualSoldPrice,
      });
    }
    return details;
  }
}
