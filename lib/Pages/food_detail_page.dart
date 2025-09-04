import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import '../Models/cart.dart';
import 'cart_page.dart';

class FoodDetailPage extends StatelessWidget {
  final MenuItem item;

  const FoodDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final averageRating = item.reviews.isEmpty
        ? 0
        : item.reviews.fold(0.0, (sum, r) => sum + r.rating) /
            item.reviews.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F00),
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (item.reviews.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amberAccent),
                  const SizedBox(width: 4),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Food title and description
            Text(
              item.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              item.description ?? "No description available.",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            // Pricing
            Row(
              children: [
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                if (item.originalPrice != null)
                  Text(
                    "\$${item.originalPrice!.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),

            // Rating row
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  averageRating > 0
                      ? averageRating.toStringAsFixed(1)
                      : "No ratings yet",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reviews section
            // Reviews section with review count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Customer Reviews",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "(${item.reviews.length} reviews)",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const Divider(thickness: 1.2),
            const SizedBox(height: 8),

            if (item.reviews.isEmpty)
              const Text("No reviews yet.",
                  style: TextStyle(color: Colors.grey))
            else
              ...item.reviews.map(
                (r) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      r.reviewer,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(r.comment),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(r.rating.toString()),
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 80), // For spacing above sticky button
          ],
        ),
      ),

      // Sticky Add to Cart button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(28),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {
            Cart.addItem(item);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Add to Cart",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
