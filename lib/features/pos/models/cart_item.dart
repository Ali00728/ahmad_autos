import '../../../core/database/database.dart';

class CartItem {
  final Part part;
  int quantity;
  double actualSoldPrice;

  CartItem({
    required this.part,
    this.quantity = 1,
    double? actualSoldPrice,
  }) : actualSoldPrice = actualSoldPrice ?? part.defaultSellingPrice;

  double get subTotal => actualSoldPrice * quantity;
}
