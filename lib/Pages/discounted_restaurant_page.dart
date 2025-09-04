import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import 'restaurant_details_page.dart';

class DiscountedRestaurantsPage extends StatelessWidget {
  final List<Restaurant> discountedRestaurants;

  const DiscountedRestaurantsPage({
    super.key,
    required this.discountedRestaurants,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF6F00)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Discounted Restaurants",
          style: TextStyle(
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: discountedRestaurants.isEmpty
          ? const Center(
              child: Text(
                "No discounts available at the moment.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: discountedRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = discountedRestaurants[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantDetailPage(restaurant: restaurant),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.asset(
                                restaurant.imagePath,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.orange, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${restaurant.rating}",
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.local_offer,
                                            color: Colors.grey, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            restaurant.tags.join(', '),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer,
                                            color: Colors.grey, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant.deliveryTime,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (restaurant.freeDelivery)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 12),
                                            child: Text(
                                              "Free Delivery",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),

                        // Discount Badge
                        if (restaurant.discounts.isNotEmpty)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                restaurant.discounts.first, // Show first discount
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
