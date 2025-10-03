import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import '../Models/cart.dart';
import 'cart_page.dart';
import 'food_detail_page.dart';

class MenuPage extends StatefulWidget {
  final Restaurant restaurant;

  const MenuPage({super.key, required this.restaurant});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  late TabController _menuTabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  bool _isSearching = false;
  List<MenuItem> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _menuTabController = TabController(length: 3, vsync: this);

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _searchQuery = query;
        _searchResults = widget.restaurant.menu.where((item) {
          return item.name.toLowerCase().contains(query) ||
              (item.description?.toLowerCase() ?? '')
                  .contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _menuTabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isSearching ? _buildSearchResults() : _buildMenuTabbedView();
  }

  // =====================
  // MENU VIEW
  // =====================
  Widget _buildMenuTabbedView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _menuTabController,
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
        controller: _menuTabController,
        children: [
          _buildMenuList('popular'),
          _buildMenuList('discount'),
          _buildMenuList('beverage'),
        ],
      ),
    );
  }

  // =====================
  // SEARCH BAR
  // =====================
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

  // =====================
  // MENU LIST
  // =====================
  Widget _buildMenuList(String category) {
    final items = widget.restaurant.menu
        .where((item) =>
            (item.category?.toLowerCase() ?? '') == category.toLowerCase() &&
            (item.name.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();

    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // ✅ two per row
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75, // control height/width ratio
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isBigger = index % 3 == 0; // every 3rd card is bigger

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FoodDetailPage(item: item),
              ),
            );
          },
          child: _menuItemGridCard(context, item, isBigger),
        );
      },
    );
  }

  Widget _menuItemGridCard(BuildContext context, MenuItem item, bool isBigger) {
    return Container(
      height: isBigger ? 260 : 220, // ✅ make one a bit bigger
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                item.description ?? 'No description',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.all(6),
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      Cart.addItem(item);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================
  // SEARCH RESULTS
  // =====================
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
                        child: _menuItemGridCard(context, item, false));
                  },
                ),
        ),
      ],
    );
  }
}

// Sliver delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
