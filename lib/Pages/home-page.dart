import 'package:dinengo/Pages/cart_page.dart';
import 'package:dinengo/Pages/fav_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'location_picker_page.dart'; // Import for location picker if used
import '../Models/restaurants.dart';
import '../Mock_Data/mock_restaurants.dart';
import 'restaurant_details_page.dart';
import 'filtered_restaurant_page.dart';
import 'search-page.dart';
// import 'cart_page.dart';
import '../Providers/fav_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final ScrollController _scrollController = ScrollController();
final GlobalKey _restaurantSectionKey = GlobalKey();

class _HomePageState extends State<HomePage> {
  final Color primaryColor = const Color(0xFFFF6F00);
  String _locationName = 'idk';
  List<Restaurant> _filteredRestaurants = mockRestaurants;

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = mockRestaurants;
  }

  void _filterFreeDeliveryRestaurants() {
    setState(() {
      _selectedFilter = 'Free Delivery';
      _filteredRestaurants =
          mockRestaurants.where((r) => r.freeDelivery == true).toList();
    });
  }

  void _searchRestaurants(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = mockRestaurants;
      } else {
        _filteredRestaurants = mockRestaurants.where((restaurant) {
          final nameMatch = restaurant.name.toLowerCase().contains(lowerQuery);
          final menuMatch = restaurant.menu.any(
            (item) => item.name.toLowerCase().contains(lowerQuery),
          );
          return nameMatch || menuMatch;
        }).toList();
      }
    });
  }

  // Uncomment to use location picker page
  // void _pickLocation() async {
  //   final selectedLocation = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => LocationPickerPage()),
  //   );
  //   if (selectedLocation != null && mounted) {
  //     setState(() {
  //       _locationName = selectedLocation;
  //     });
  //   }
  // }

  String _selectedFilter = 'None';

  void _sortRestaurants() {
    setState(() {
      if (_selectedFilter == 'Free Delivery') {
        _filteredRestaurants =
            mockRestaurants.where((r) => r.freeDelivery == true).toList();
      } else if (_selectedFilter == 'Price: High to Low') {
        _filteredRestaurants = List.from(mockRestaurants)
          ..sort((a, b) => b.averageMenuPrice.compareTo(a.averageMenuPrice));
      } else if (_selectedFilter == 'Price: Low to High') {
        _filteredRestaurants = List.from(mockRestaurants)
          ..sort((a, b) => a.averageMenuPrice.compareTo(b.averageMenuPrice));
      } else if (_selectedFilter == 'Rating') {
        _filteredRestaurants = List.from(mockRestaurants)
          ..sort((a, b) => b.rating.compareTo(a.rating));
      } else {
        _filteredRestaurants = mockRestaurants;
      }
    });
  }

  String _getRestaurantSectionTitle() {
    switch (_selectedFilter) {
      case 'Rating':
        return 'Top Rated Restaurants';
      case 'Price: High to Low':
        return 'Expensive Restaurants';
      case 'Price: Low to High':
        return 'Budget Restaurants';
      case 'Free Delivery':
        return 'Free Delivery Restaurants';
      default:
        return 'Popular Restaurants';
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor.withOpacity(0.05),
        body: CustomScrollView(slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              height: 100,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: 80, // Leave space for SafeArea + content
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 80,
                          child: InkWell(
                            // onTap: _pickLocation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Current Location",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: primaryColor, size: 18),
                                      const SizedBox(width: 4),
                                      Text(_locationName,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_outline),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => FavoritePage()),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CartPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              child: _StickySearchBar(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchPage()));
                },
              ),
              height: 70,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Promo
                  _buildBannerPromo(),

                  const SizedBox(height: 20),

                  // Categories
                  _buildCategorySection(),

                  const SizedBox(height: 10),

                  Divider(color: Colors.grey.shade500, thickness: 1),
                  const SizedBox(height: 10),

                  // Food types
                  _buildFoodTypesSection(),

                  const SizedBox(height: 20),

                  // Promotions Row 1

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _promoCard(
                          "Unlimited free delivery",
                          Colors.purple.shade100,
                          onTap: () {
                            final freeDeliveryRestaurants = mockRestaurants
                                .where((r) => r.freeDelivery == true)
                                .toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FilteredRestaurantsPage(
                                  title: "Free Delivery Restaurants",
                                  filteredRestaurants: freeDeliveryRestaurants,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _promoCard(
                          "Buy 1, get 1 free",
                          Colors.orange.shade100,
                          onTap: () {
                            // Example: You can add your own logic here
                            final bogoRestaurants = mockRestaurants
                                .where((r) => r.tags.contains("BOGO"))
                                .toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FilteredRestaurantsPage(
                                  title: "Buy 1 Get 1 Free",
                                  filteredRestaurants: bogoRestaurants,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

// Popular Restaurants and Filter
                  KeyedSubtree(
                    key: _restaurantSectionKey,
                    child: Column(
                      children: [
                        // Title and Filter Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getRestaurantSectionTitle(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 20),
                            Icon(Icons.filter_list, color: primaryColor),
                            DropdownButton<String>(
                              value: _selectedFilter,
                              items: [
                                'None',
                                'Price: High to Low',
                                'Price: Low to High',
                                'Rating',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFilter = value;
                                    _sortRestaurants();
                                  });
                                }
                              },
                              underline: SizedBox(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Restaurant Cards
                        Column(
                          children: _filteredRestaurants.map((restaurant) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RestaurantDetailPage(
                                            restaurant: restaurant),
                                      ),
                                    );
                                  },
                                  child: _restaurantCard(
                                    imagePath: restaurant.imagePath,
                                    name: restaurant.name,
                                    rating: restaurant.rating,
                                    category: restaurant.tags.join(', '),
                                    deliveryTime: restaurant.deliveryTime,
                                    restaurant: restaurant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Limited time deal
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: primaryColor),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Save 25% - Hurry! Limited time offers",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const Text("26:17",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  // Promo card widget
  Widget _promoCard(String text, Color bgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _restaurantCard({
    required String imagePath,
    required String name,
    required double rating,
    required String category,
    required String deliveryTime,
    required Restaurant restaurant, // NEW
  }) {
    return Consumer<FavoriteManager>(
      builder: (context, favoriteManager, _) {
        final isFav = favoriteManager.isFavorite(restaurant);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text("$rating",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text(category,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(deliveryTime,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  favoriteManager.toggleFavorite(restaurant);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StickySearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _StickySearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: "Search for restaurants and groceries",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyLocationHeader extends StatelessWidget {
  final String locationName;
  final VoidCallback onFavoritesTap;
  final VoidCallback onCartTap;

  const _StickyLocationHeader({
    required this.locationName,
    required this.onFavoritesTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6F00);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Current Location",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.location_on, color: primaryColor, size: 18),
                  const SizedBox(width: 4),
                  Text(locationName,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                  onTap: onFavoritesTap, child: Icon(Icons.favorite_outline)),
              const SizedBox(width: 16),
              GestureDetector(
                  onTap: onCartTap, child: Icon(Icons.shopping_cart_outlined)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _SliverHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class _buildBannerPromo extends StatelessWidget {
  const _buildBannerPromo();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow
        children: [
          // Main white banner
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(right: 100, left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DineNGo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFFFF6F00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enjoy your food with us',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Scrollable.ensureVisible(
                      _restaurantSectionKey.currentContext!,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Order now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Positioned image that pops out of the banner
          Positioned(
            right: -20,
            top: -20,
            bottom: -20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/pizza.png',
                height: 160,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _buildCategorySection extends StatelessWidget {
  const _buildCategorySection();

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6F00);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryIcon('Offers', 'assets/images/percentage.png', primaryColor),
          _categoryIcon(
              'New Restaurant', 'assets/images/restaurant.png', primaryColor),
          _categoryIcon('Pick Up', 'assets/images/pickup.png', primaryColor),
          _categoryIcon('Voucher', 'assets/images/voucher.png', primaryColor),
          _categoryIcon('Top Restaurant', 'assets/images/top_restaurant.png',
              primaryColor),
        ],
      ),
    );
  }
}

// Category icon widget
Widget _categoryIcon(String label, String imagePath, Color color) {
  return Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: color.withOpacity(0.07),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    ),
  );
}

class _buildFoodTypesSection extends StatelessWidget {
  const _buildFoodTypesSection();

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6F00);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _foodType('Drinks', 'assets/images/drink.png', primaryColor),
          _foodType('Asian', 'assets/images/asianfood.png', primaryColor),
          _foodType('Pastry', 'assets/images/pastry.png', primaryColor),
          _foodType('Ice Cream', 'assets/images/icecream.png', primaryColor),
          _foodType('Pizza', 'assets/images/pizza.png', primaryColor),
        ],
      ),
    );
  }
}

// Food type widget
Widget _foodType(String label, String imagePath, Color color) {
  return Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.asset(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    ),
  );
}
