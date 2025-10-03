import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import '../Models/cart.dart';
import '../Models/table_model.dart';
import 'table_detail_page.dart';
import 'cart_page.dart';
import 'chat-page.dart';
import 'menu_page.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with TickerProviderStateMixin {
  late TabController _tableTabController;
  String _currentView = "table"; // default view

  @override
  void initState() {
    super.initState();
    _tableTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tableTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
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
            Text(
              widget.restaurant.tags.join(", "),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      body: _currentView == "table"
          ? _buildTableTabbedView()
          : MenuPage(restaurant: widget.restaurant),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _currentView == "table"
                      ? const Color(0xFFFF6F00)
                      : Colors.grey[200],
                  foregroundColor:
                      _currentView == "table" ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() => _currentView = "table");
                },
                child: const Text("Table"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _currentView == "menu"
                      ? const Color(0xFFFF6F00)
                      : Colors.grey[200],
                  foregroundColor:
                      _currentView == "menu" ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() => _currentView = "menu");
                },
                child: const Text("Menu"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // TABLE VIEW
  // =====================
  Widget _buildTableTabbedView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(child: _buildRestaurantHeader()),
        SliverToBoxAdapter(child: _buildPromotionsSection()),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tableTabController,
              indicatorColor: const Color(0xFFFF6F00),
              labelColor: const Color(0xFFFF6F00),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Indoor'),
                Tab(text: 'Outdoor'),
                Tab(text: 'Room'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tableTabController,
        children: [
          _buildTableList('Indoor'),
          _buildTableList('Outdoor'),
          _buildTableList('Private'),
        ],
      ),
    );
  }

  Widget _buildTableList(String category) {
    final tables = widget.restaurant.tables
        .where((t) => t.locationType.toLowerCase() == category.toLowerCase())
        .toList();

    if (tables.isEmpty) {
      return const Center(child: Text("No tables available."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TableDetailPage(table: table),
              ),
            );
            if (result == "menu" && mounted) {
              setState(() => _currentView = "menu");
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: table.imageUrl != null
                  ? DecorationImage(
                      image: AssetImage(table.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
              color: Colors.grey[200],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Table ${table.tableNumber} • Seats: ${table.seats}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Status: ${table.isBooked ? "Booked" : "Available"}",
                      style: TextStyle(
                        color: table.isBooked ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantHeader() {
    final restaurant = widget.restaurant;
    return Padding(
      padding: const EdgeInsets.all(16),
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
                      builder: (_) => ChatPage(restaurant: restaurant),
                    ),
                  );
                },
                icon: const Icon(Icons.message, size: 18),
                label: const Text("Message"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '[${restaurant.tags.join(", ")}] • Price Range ${restaurant.priceLevel}',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.percent, color: Color(0xFFFF6F00)),
              SizedBox(width: 6),
              Text(
                "Promotions",
                style: TextStyle(
                  color: Color(0xFFFF6F00),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              _promoChip("Up to 60% off"),
              _promoChip("Free Dessert"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _promoChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.orange.shade50,
      labelStyle: const TextStyle(color: Color(0xFFFF6F00)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// Sliver delegate for pinned tabs
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
