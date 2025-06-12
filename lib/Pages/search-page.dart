import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import '../Mock_Data/mock_restaurants.dart';
import 'restaurant_details_page.dart';
import 'food_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchMode = 'restaurant'; // 'restaurant' or 'menu'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Triggers rebuild on any text change
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _searchResults =
      mockRestaurants; // Can be List<Restaurant> or List<Map>

  List<String> _recentSearches = [];

  bool isMenuSearch = false;

  void _performSearch(String query, {bool saveToRecent = false}) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _searchResults = mockRestaurants;
        isMenuSearch = false;
      } else {
        if (saveToRecent && !_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches = _recentSearches.sublist(0, 5);
          }
        }

        if (_searchMode == 'menu') {
          final menuMatches = <Map<String, dynamic>>[];
          for (var restaurant in mockRestaurants) {
            for (var item in restaurant.menu) {
              if (item.name.toLowerCase().contains(lowerQuery)) {
                menuMatches.add({
                  'menuItem': item,
                  'restaurant': restaurant,
                });
              }
            }
          }
          _searchResults = menuMatches;
          isMenuSearch = true;
        } else {
          _searchResults = mockRestaurants.where((restaurant) {
            return restaurant.name.toLowerCase().contains(lowerQuery);
          }).toList();
          isMenuSearch = false;
        }
      }
    });
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "Recent Searches",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Wrap(
          spacing: 8,
          children: _recentSearches.map((query) {
            return ActionChip(
              label: Text(query),
              onPressed: () {
                _searchController.text = query;
                _performSearch(query);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _menuItemCard(Map<String, dynamic> data) {
    final menuItem = data['menuItem'];
    final restaurant = data['restaurant'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: ListTile(
        title: Text(menuItem.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Restaurant: ${restaurant.name}"),
            Text("Price: \$${menuItem.price.toStringAsFixed(2)}"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _performSearch(menuItem.name, saveToRecent: true);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodDetailPage(item: menuItem),
            ),
          );
        },
      ),
    );
  }

  Widget _restaurantCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        _performSearch(restaurant.name,
            saveToRecent: true); // Add restaurant to recent

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailPage(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                restaurant.imagePath,
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
                  Text(restaurant.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFF6F00), size: 16),
                      const SizedBox(width: 4),
                      Text("${restaurant.rating}",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(restaurant.tags.join(', '),
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(restaurant.deliveryTime,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6F00);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (query) {
                // Live preview, no saving to recent
                _performSearch(query, saveToRecent: false);
              },
              onSubmitted: (query) {
                _performSearch(query,
                    saveToRecent: true); // Save only on submit
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText: "Search for restaurants and menus",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Restaurants"),
                  selected: _searchMode == 'restaurant',
                  onSelected: (_) {
                    setState(() {
                      _searchMode = 'restaurant';
                      _performSearch(
                          _searchController.text); // Re-perform search
                    });
                  },
                  selectedColor: primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _searchMode == 'restaurant'
                        ? primaryColor
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Menus"),
                  selected: _searchMode == 'menu',
                  onSelected: (_) {
                    setState(() {
                      _searchMode = 'menu';
                      _performSearch(
                          _searchController.text); // Re-perform search
                    });
                  },
                  selectedColor: primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _searchMode == 'menu' ? primaryColor : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildRecentSearches()
                  : _searchResults.isEmpty
                      ? const Center(child: Text("No results found"))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            if (isMenuSearch) {
                              return _menuItemCard(_searchResults[index]);
                            } else {
                              return _restaurantCard(_searchResults[index]);
                            }
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
