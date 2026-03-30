import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DataClassName('Part')
class Parts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get category => text()();
  RealColumn get costPrice => real()();
  RealColumn get defaultSellingPrice => real()();
  RealColumn get minimumSellingPrice => real()();
  IntColumn get stockQuantity => integer()();
}

@DataClassName('Sale')
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get saleDate => dateTime()();
  RealColumn get totalAmount => real()();
}

@DataClassName('SaleItem')
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id, onDelete: KeyAction.cascade)();
  IntColumn get partId => integer().references(Parts, #id)();
  IntColumn get quantity => integer()();
  RealColumn get actualSoldPrice => real()();
}

@DriftDatabase(tables: [Parts, Sales, SaleItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Helper methods for migration parity
  // Parts
  Future<List<Part>> getAllParts() => select(parts).get();
  Stream<List<Part>> watchAllParts() => select(parts).watch();
  Future<int> addPart(PartsCompanion part) => into(parts).insert(part);
  Future<bool> updatePart(Part part) => update(parts).replace(part);
  Future<int> deletePart(int id) => (delete(parts)..where((t) => t.id.equals(id))).go();

  // Sales
  Future<int> addSale(SalesCompanion sale) => into(sales).insert(sale);
  
  Future<List<Sale>> getSalesByRange(DateTime start, DateTime end) {
    return (select(sales)
          ..where((t) => t.saleDate.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm(expression: t.saleDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<Sale>> getSalesByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return getSalesByRange(start, end);
  }

  // SaleItems
  Future<int> addSaleItem(SaleItemsCompanion item) => into(saleItems).insert(item);
  Future<List<SaleItem>> getItemsForSale(int saleId) => (select(saleItems)..where((t) => t.saleId.equals(saleId))).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ahmad_autos.sqlite'));
    return NativeDatabase(file);
  });
}
