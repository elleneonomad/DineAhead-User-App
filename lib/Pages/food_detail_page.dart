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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          item.name,
          style: const TextStyle(
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Color(0xFFFF6F00)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: (item.imageUrl.startsWith('http') || item.imageUrl.startsWith('https'))
                ? Image.network(
                    item.imageUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    item.imageUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 20),

          // Info Card
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6F00),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description ?? "No description available.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "\$${item.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (item.originalPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              "\$${item.originalPrice!.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            averageRating > 0
                                ? averageRating.toStringAsFixed(1)
                                : "No ratings",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Customer Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Customer Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6F00),
                ),
              ),
              Text(
                "(${item.reviews.length} reviews)",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 8),

          if (item.reviews.isEmpty)
            const Text("No reviews yet.",
                style: TextStyle(color: Colors.grey, fontSize: 14))
          else
            ...item.reviews.map(
              (r) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.person, color: Color(0xFFFF6F00)),
                  ),
                  title: Text(
                    r.reviewer,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      r.comment,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        r.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star,
                          size: 16, color: Colors.orangeAccent),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),

      // Sticky Add to Cart Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Cart.addItem(item);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6F00),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Add to Cart",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
