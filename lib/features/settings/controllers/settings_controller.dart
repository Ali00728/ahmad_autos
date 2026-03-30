import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/database.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

// Top-level functions for compute()
String _serializeBackup(Map<String, dynamic> data) => jsonEncode(data);
Map<String, dynamic> _deserializeBackup(String json) => jsonDecode(json);

class SettingsController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final RxBool isProcessing = false.obs;

  Future<void> exportBackup() async {
    isProcessing.value = true;
    try {
      // 1. Fetch all records and convert them to JSON
      final partList = await db.getAllParts();
      final saleList = await (db.select(db.sales)).get();
      final saleItemList = await (db.select(db.saleItems)).get();

      final backupData = {
        'parts': partList.map((p) => p.toJson()).toList(),
        'sales': saleList.map((s) => s.toJson()).toList(),
        'saleItems': saleItemList.map((si) => si.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.1.0',
      };

      // 2. Serialize in background isolate
      final jsonString = await compute(_serializeBackup, backupData);

      // 3. Save and share as before
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ahmad_autos_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], text: 'Ahmad Autos Backup (Drift)');
      
      Get.snackbar('Success', 'Backup exported successfully');
    } catch (e) {
      Get.snackbar('Error', 'Export failed: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      isProcessing.value = true;
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // 1. Parse in background
      final Map<String, dynamic> backupData = await compute(_deserializeBackup, jsonString);

      // 2. Atomic Restore
      await db.transaction(() async {
        // Clear all
        await (db.delete(db.saleItems)).go();
        await (db.delete(db.sales)).go();
        await (db.delete(db.parts)).go();

        // Import Parts
        if (backupData['parts'] != null) {
          for (var item in backupData['parts']) {
            await db.into(db.parts).insert(Part.fromJson(item));
          }
        }
        // Import Sales
        if (backupData['sales'] != null) {
          for (var item in backupData['sales']) {
            await db.into(db.sales).insert(Sale.fromJson(item));
          }
        }
        // Import SaleItems
        if (backupData['saleItems'] != null) {
          for (var item in backupData['saleItems']) {
            await db.into(db.saleItems).insert(SaleItem.fromJson(item));
          }
        }
      });

      // 3. Refresh
      if (Get.isRegistered<InventoryController>()) Get.find<InventoryController>().updateSearch('');
      if (Get.isRegistered<DashboardController>()) Get.find<DashboardController>().fetchMetrics();

      Get.snackbar('Success', 'Backup imported successfully. Data restored.');
    } catch (e) {
      Get.snackbar('Error', 'Import failed: $e');
    } finally {
      isProcessing.value = false;
    }
  }
}
