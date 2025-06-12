import 'package:flutter/material.dart';
import '../Models/cart.dart';
import '../Pages/cart_page.dart';

class StickyCartBar extends StatelessWidget {
  const StickyCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cartItems = Cart.items;
    final total = Cart.total;

    if (cartItems.isEmpty) return const SizedBox.shrink(); // nothing if empty

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'You have ${cartItems.length} item(s) in your cart',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View Cart', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
