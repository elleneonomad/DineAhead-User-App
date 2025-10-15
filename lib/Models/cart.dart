import 'cart_item_model.dart';
import 'restaurants.dart';
class Cart {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static void addItem(MenuItem item) {
    final index = _items.indexWhere((element) => element.item.id == item.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(item: item));
    }
  }

  static void removeItem(MenuItem item) {
    _items.removeWhere((element) => element.item.id == item.id);
  }

  static void clear() {
    _items.clear();
  }

  static double get total =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);
}
