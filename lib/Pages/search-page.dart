import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import '../Services/api_service.dart';
import 'restaurant_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  List<Restaurant> _results = [];
  List<String> _cuisineOptions = [];
  String? _selectedCuisine;
  String? _selectedPriceRange;

  final Color themeColor = const Color(0xFFFF6F00);

  @override
  void initState() {
    super.initState();
    _loadCuisines();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        _performSearch('');
      }
    });
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCuisines() async {
    try {
      final cuisines = await ApiService.getCuisines();
      setState(() {
        _cuisineOptions = cuisines.map((c) => c.name).toList();
      });
    } catch (_) {}
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    setState(() => _loading = true);
    try {
      final list = await ApiService.getRestaurants(
        cuisine: _selectedCuisine,
        priceRange: _selectedPriceRange,
        search: trimmed.isEmpty ? null : trimmed,
      );
      setState(() {
        _results = list;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _restaurantCard(Restaurant restaurant) {
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: restaurant.cover.isNotEmpty
                  ? Image.network(
                      restaurant.cover,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.orange.shade50,
                      child: const Icon(Icons.restaurant, color: Colors.orange),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFF6F00), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${restaurant.rating}",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.tags.join(', '),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.priceLevel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.orange),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontFamily: 'Montserrat', color: Colors.grey, fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text(
          "Search Restaurants",
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search bar
            TextField(
              controller: _searchController,
              onSubmitted: (query) => _performSearch(query),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search for restaurants...",
                hintStyle: const TextStyle(fontFamily: 'Montserrat'),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6F00)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 14),

            // 🎯 Filters
            Row(
              children: [
                Expanded(
                  child: _styledDropdown<String>(
                    label: "Cuisine",
                    value: _selectedCuisine,
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('All cuisines')),
                      ..._cuisineOptions.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedCuisine = v);
                      _performSearch(_searchController.text);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _styledDropdown<String>(
                    label: "Price Range",
                    value: _selectedPriceRange,
                    items: const [
                      DropdownMenuItem<String>(
                          value: null, child: Text('All prices')),
                      DropdownMenuItem<String>(
                          value: 'budget', child: Text('Budget')),
                      DropdownMenuItem<String>(
                          value: 'mid-range', child: Text('Mid-range')),
                      DropdownMenuItem<String>(
                          value: 'fine-dining', child: Text('Fine-dining')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedPriceRange = v);
                      _performSearch(_searchController.text);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📋 Results
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6F00),
                      ),
                    )
                  : _results.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/empty.png',
                                width: 150, height: 150),
                            const SizedBox(height: 16),
                            const Text(
                              "No restaurants found",
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) =>
                              _restaurantCard(_results[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
