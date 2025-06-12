import 'package:flutter/material.dart';
import '../Models/cart.dart';
import '../Models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<String, TextEditingController> _instructionControllers = {};

  @override
  void dispose() {
    for (var controller in _instructionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _increaseQuantity(CartItem item) {
    setState(() {
      Cart.addItem(item.item);
    });
  }

  void _decreaseQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        Cart.removeItem(item.item);
        _instructionControllers.remove(item.item.name)?.dispose();
      }
    });
  }

  void _updateSpecialInstruction(CartItem item) {
    final instruction = _instructionControllers[item.item.name]?.text ?? '';
    setState(() {
      item.specialInstruction = instruction;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Instruction saved for ${item.item.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Cart.items;
    final total = Cart.total;

    // Group cart items by restaurantId
    final Map<String, Map<String, dynamic>> groupedCart = {};

    for (var item in cartItems) {
      final restaurantId = item.item.restaurantId ?? 'unknown';
      final restaurantName = item.item.restaurantName ?? 'Unknown Restaurant';

      if (!groupedCart.containsKey(restaurantId)) {
        groupedCart[restaurantId] = {
          'name': restaurantName,
          'items': <CartItem>[],
        };
      }

      groupedCart[restaurantId]!['items'].add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text("Your cart is empty.",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: groupedCart.entries.map((entry) {
                      final restaurantId = entry.key;
                      final restaurantData = entry.value;
                      final restaurantName = restaurantData['name'] as String;
                      final List<CartItem> items = restaurantData['items'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...items.map((cartItem) {
                            _instructionControllers.putIfAbsent(
                              cartItem.item.name,
                              () => TextEditingController(),
                            );

                            return Dismissible(
                              key: Key(cartItem.item.name),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                color: Colors.redAccent,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (direction) {
                                setState(() {
                                  Cart.removeItem(cartItem.item);
                                  _instructionControllers
                                      .remove(cartItem.item.name)
                                      ?.dispose();
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${cartItem.item.name} removed from cart'),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.asset(
                                              cartItem.item.imageUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItem.item.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  cartItem.item.description ??
                                                      'No description available',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '\$${cartItem.item.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFFF6F00),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    _decreaseQuantity(cartItem),
                                              ),
                                              Text('${cartItem.quantity}',
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    _increaseQuantity(cartItem),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Special Instructions',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _instructionControllers[
                                            cartItem.item.name],
                                        decoration: InputDecoration(
                                          hintText:
                                              'Add any special requests here...',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 16),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () =>
                                              _updateSpecialInstruction(
                                                  cartItem),
                                          icon: const Icon(Icons.save,
                                              color: Color(0xFFFF6F00)),
                                          label: const Text(
                                            'Save',
                                            style: TextStyle(
                                                color: Color(0xFFFF6F00)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Estimated Delivery",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "25-35 min",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: \$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Checkout not implemented.")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Confirm Order",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
