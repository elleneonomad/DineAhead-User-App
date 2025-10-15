import 'package:dinengo/Pages/cart_page.dart';
import 'package:dinengo/Pages/fav_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'location_picker_page.dart';
import '../Models/restaurants.dart';
import 'restaurant_details_page.dart';
import 'filtered_restaurant_page.dart';
import 'discounted_restaurant_page.dart';
import 'search-page.dart';
import '../Services/api_service.dart';
import '../Models/cuisine.dart';
import '../Providers/fav_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Restaurant> _filteredRestaurants = [];
  String _selectedFilter = 'None';
  bool isLoadingRestaurants = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  void _fetchRestaurants() async {
    try {
      final data = await ApiService.getRestaurants();
      setState(() {
        _filteredRestaurants = data.take(2).toList(); // show 2 restaurants
        isLoadingRestaurants = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching restaurants: $e");
      setState(() => isLoadingRestaurants = false);
    }
  }

  void _sortRestaurants() {
    setState(() {
      if (_selectedFilter == 'Price: High to Low') {
        _filteredRestaurants
            .sort((a, b) => b.averageMenuPrice.compareTo(a.averageMenuPrice));
      } else if (_selectedFilter == 'Price: Low to High') {
        _filteredRestaurants
            .sort((a, b) => a.averageMenuPrice.compareTo(b.averageMenuPrice));
      } else if (_selectedFilter == 'Rating') {
        _filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
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
      default:
        return 'Popular Restaurants';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.05),
      body: CustomScrollView(
        slivers: [
          /// Header
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Welcome to DineAhead",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CartPage()),
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

          /// Sticky Search
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              height: 70,
              child: _StickySearchBar(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
              ),
            ),
          ),

          /// Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _buildBannerPromo(),
                  const SizedBox(height: 10),

                  /// Food Types (Cuisines)
                  const _buildFoodTypesSection(),
                  const SizedBox(height: 20),

                  /// Restaurant Section
                  KeyedSubtree(
                    key: _restaurantSectionKey,
                    child: Column(
                      children: [
                        /// Title + Filter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _getRestaurantSectionTitle(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.filter_list, color: primaryColor),
                            const SizedBox(width: 4),
                            Flexible(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedFilter,
                                items: [
                                  'None',
                                  'Price: High to Low',
                                  'Price: Low to High',
                                  'Rating',
                                ].map((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: const TextStyle(fontSize: 12)),
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
                                underline: const SizedBox(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Restaurants
                        if (isLoadingRestaurants)
                          const Center(child: CircularProgressIndicator())
                        else if (_filteredRestaurants.isEmpty)
                          const Center(child: Text("No restaurants available"))
                        else
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
                                    child: _restaurantCard(restaurant),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _restaurantCard(Restaurant restaurant) {
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
                child: Image.network(
                  restaurant.cover,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text("${restaurant.rating}",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restaurant.tags.join(', '),
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(restaurant.deliveryTime,
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

/// Sticky Search Bar
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

/// Sliver Header Delegate
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

/// Banner Promo
class _buildBannerPromo extends StatelessWidget {
  const _buildBannerPromo();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
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
                const Text("DineAhead",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6F00))),
                const Text("Enjoy your food",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Text("With us",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ElevatedButton(
                  onPressed: () {
                    Scrollable.ensureVisible(
                      _restaurantSectionKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Book now",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
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

/// Cuisine Section (Static)
class _buildFoodTypesSection extends StatelessWidget {
  const _buildFoodTypesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6F00);

    // ✅ Static cuisine data
    final List<Map<String, String>> cuisines = [
      {
        'name': 'Khmer',
        'image':
            'https://thumbs.dreamstime.com/b/cambodian-food-called-beef-lok-lak-traditional-khmer-food-isolated-transparent-background-317891964.jpg',
      },
      {
        'name': 'Japanese',
        'image':
            'https://thumbs.dreamstime.com/b/sushi-rolls-salmon-cucumber-wasabi-served-wooden-board-lime-slices-isolated-transparent-background-png-ai-generated-362748982.jpg',
      },
      {
        'name': 'Korean',
        'image':
            'https://i.pinimg.com/736x/4a/67/9d/4a679d2976c77250b251feaa05c58a09.jpg',
      },
      {
        'name': 'Chinese',
        'image':
            'https://windhorsetour.com/wp-content/uploads/tranditional-chinese-food-shaomai.jpg',
      },
      {
        'name': 'Vietnamese',
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMI5MKYCuEUpp6d5BS3lryR6PSLxZOUlGbPQ&s',
      },
      {
        'name': 'Indian',
        'image':
            'https://static.vecteezy.com/system/resources/previews/046/342/821/non_2x/vegetable-thai-food-isolated-on-transparent-background-free-png.png',
      },
      {
        'name': 'Mexican',
        'image':
            'https://static.vecteezy.com/system/resources/previews/025/229/670/non_2x/tasty-taco-salad-isolated-on-transparent-background-png.png',
      },
    ];

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: cuisines.map((cuisine) {
            return GestureDetector(
              onTap: () => debugPrint("Tapped ${cuisine['name']}"),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(cuisine['image']!),
                      child: null,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 80,
                      child: Text(
                        cuisine['name']!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
