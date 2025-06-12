import 'restaurants.dart';

class CartItem {
  final MenuItem item;
  int quantity;
  String? specialInstruction;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.specialInstruction,
  });

  double get totalPrice => item.price * quantity;
}
