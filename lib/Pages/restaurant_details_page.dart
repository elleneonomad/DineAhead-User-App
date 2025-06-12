import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import '../Models/cart.dart';
import 'cart_page.dart';
import 'chat-page.dart';
import 'food_detail_page.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<MenuItem> _searchResults = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _searchQuery = query;
        _searchResults = widget.restaurant.menu.where((item) {
          return item.name.toLowerCase().contains(query) ||
              (item.description?.toLowerCase() ?? '').contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6), // fixed color
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          iconTheme: const IconThemeData(
            color: Color(0xFFFF6F00),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.restaurant.name,
                style: const TextStyle(
                  color: Color(0xFFFF6F00),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.restaurant.tags.join(', '),
                style: const TextStyle(
                  color: Color(0xFFFF6F00),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
            ),
          ],
        ),
        body: _isSearching ? _buildSearchResults() : _buildTabbedView(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onTap: () {
                setState(() {
                  _isSearching = true;
                  _searchQuery = '';
                  _searchResults = widget.restaurant.menu;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _searchResults = widget.restaurant.menu;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_isSearching)
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                _searchController.clear();
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                });
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFFF6F00), fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuList(String category) {
    final items = widget.restaurant.menu
        .where((item) =>
            (item.category?.toLowerCase() ?? '') == (category?.toLowerCase() ?? '') &&
(item.name.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();

    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FoodDetailPage(item: item),
              ),
            );
          },
          child: _menuItemCard(context, item),
        );
      },
    );
  }

  Widget _menuItemCard(BuildContext context, MenuItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description ?? 'No description',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.all(8),
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      Cart.addItem(item);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    final restaurant = widget.restaurant;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              restaurant.imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(restaurantName: restaurant.name),
                    ),
                  );
                },
                icon: const Icon(Icons.message, size: 18),
                label: const Text("Message"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
  '${restaurant.tags ?? ''} • ${restaurant.deliveryTime ?? ''} • ${restaurant.priceLevel ?? ''}',
  style: const TextStyle(color: Colors.grey, fontSize: 14),
),

          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                restaurant.freeDelivery ? Icons.check_circle : Icons.cancel,
                color: restaurant.freeDelivery ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                restaurant.freeDelivery ? 'Free Delivery' : 'Delivery not free',
                style: TextStyle(
                  color: restaurant.freeDelivery ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (restaurant.discounts.isNotEmpty) ...[
            const Text(
              '🔥 Promotions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: restaurant.discounts
                  .map((d) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          d,
                          style: const TextStyle(color: Colors.deepOrange),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabbedView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(child: _buildRestaurantHeader()),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.deepOrange,
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Popular Menu'),
                Tab(text: 'Discount'),
                Tab(text: 'Beverages'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenuList('popular'),
          _buildMenuList('discount'),
          _buildMenuList('beverage'),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(child: Text('No matching menu items found.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodDetailPage(item: item),
                          ),
                        );
                      },
                      child: _menuItemCard(context, item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
