import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import '../Models/table_model.dart';
import '../Services/api_service.dart';
import '../Models/cart.dart';
import 'table_detail_page.dart';
import 'chat-page.dart';
import '../Services/firebase_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final String? initialView; // 'table' or 'menu'

  const RestaurantDetailPage(
      {super.key, required this.restaurant, this.initialView});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with TickerProviderStateMixin {
  late TabController _tableTabController;
  String _currentView = "table";

  List<TableModel> _tables = [];
  List<_MenuItemData> _menu = [];
  bool _loadingDetails = true;

  @override
  void initState() {
    super.initState();
    _tableTabController = TabController(length: 3, vsync: this);

    // Set initial view if provided
    if (widget.initialView != null &&
        (widget.initialView == 'menu' || widget.initialView == 'table')) {
      _currentView = widget.initialView!;
    }

    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await ApiService.getRestaurantDetails(widget.restaurant.id);
      final tables =
          (res['tables'] as List?)?.whereType<dynamic>().toList() ?? [];
      final menu = (res['menu'] as List?)?.whereType<dynamic>().toList() ?? [];

      setState(() {
        _tables = tables
            .map<TableModel>(
                (t) => TableModel.fromJson(t as Map<String, dynamic>))
            .toList();
        _menu = menu
            .map<_MenuItemData>(
                (m) => _MenuItemData.fromJson(m as Map<String, dynamic>))
            .toList();
        _loadingDetails = false;
      });
    } catch (e) {
      setState(() {
        _tables = [];
        _menu = [];
        _loadingDetails = false;
      });
    }
  }

  @override
  void dispose() {
    _tableTabController.dispose();
    super.dispose();
  }

  void _showRestaurantInfo() {
    final restaurant = widget.restaurant;

    // Debug logging
    debugPrint('=== Restaurant Info ===');
    debugPrint('Address: ${restaurant.address}');
    debugPrint('Location: ${restaurant.location}');
    debugPrint('Business Hours: ${restaurant.businessHours}');
    debugPrint('Policies: ${restaurant.policies}');
    debugPrint('Payment: ${restaurant.payment}');
    debugPrint('Parking: ${restaurant.parking}');
    debugPrint('Cancellation: ${restaurant.cancellation}');
    debugPrint('Social Media: ${restaurant.socialMedia}');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6F00),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Restaurant Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address & Location
                      if (restaurant.address.isNotEmpty ||
                          restaurant.location.isNotEmpty) ...[
                        _infoSection(
                          'Location',
                          Icons.location_on,
                          [
                            if (restaurant.address.isNotEmpty)
                              _infoItem('Address', restaurant.address),
                            if (restaurant.location['googleMapsLink'] != null &&
                                restaurant.location['googleMapsLink']
                                    .toString()
                                    .isNotEmpty)
                              _buildGoogleMapsLink(restaurant
                                  .location['googleMapsLink']
                                  .toString()),
                          ],
                        ),
                        const Divider(height: 24),
                      ],

                      // Business Hours
                      if (restaurant.businessHours != null) ...[
                        _infoSection(
                          'Business Hours',
                          Icons.access_time,
                          _buildBusinessHours(restaurant.businessHours!),
                        ),
                        const Divider(height: 24),
                      ],

                      // Policies
                      if (restaurant.policies != null) ...[
                        _infoSection(
                          'Policies',
                          Icons.policy,
                          [
                            if (restaurant.policies!['petFriendly'] == true)
                              _infoItem('', '🐕 Pet Friendly', isTag: true),
                            if (restaurant.policies!['smokingArea'] == true)
                              _infoItem('', '🚬 Smoking Area', isTag: true),
                            if (restaurant.policies!['outdoorSeating'] == true)
                              _infoItem('', '🌳 Outdoor Seating', isTag: true),
                          ],
                        ),
                        const Divider(height: 24),
                      ],

                      // Payment Methods
                      if (restaurant.payment != null) ...[
                        _infoSection(
                          'Payment Methods',
                          Icons.payment,
                          [
                            if (restaurant.payment!['cash'] == true)
                              _infoItem('', '💵 Cash', isTag: true),
                            if (restaurant.payment!['creditCard'] == true)
                              _infoItem('', '💳 Credit Card', isTag: true),
                            if (restaurant.payment!['mobilePayment'] == true)
                              _infoItem('', '📱 Mobile Payment', isTag: true),
                          ],
                        ),
                        const Divider(height: 24),
                      ],

                      // Parking
                      if (restaurant.parking != null) ...[
                        _infoSection(
                          'Parking',
                          Icons.local_parking,
                          [
                            if (restaurant.parking!['available'] == true)
                              _infoItem(
                                  'Available',
                                  restaurant.parking!['type']?.toString() ??
                                      'Yes'),
                            if (restaurant.parking!['feeApplies'] == true)
                              _infoItem('Fee', 'Parking fee applies')
                            else if (restaurant.parking!['available'] == true)
                              _infoItem('Fee', 'Free parking'),
                          ],
                        ),
                        const Divider(height: 24),
                      ],

                      // Cancellation Policy
                      if (restaurant.cancellation != null) ...[
                        _infoSection(
                          'Cancellation Policy',
                          Icons.cancel,
                          [
                            if (restaurant.cancellation!['allowFreeCancel'] ==
                                true)
                              _infoItem(
                                'Free Cancellation',
                                'Up to ${restaurant.cancellation!['cancelBeforeHours']} hour(s) before booking',
                              )
                            else
                              _infoItem('Cancellation', 'Not allowed'),
                          ],
                        ),
                        const Divider(height: 24),
                      ],

                      // Social Media
                      if (restaurant.socialMedia != null) ...[
                        _infoSection(
                          'Social Media',
                          Icons.share,
                          [
                            if ((restaurant.socialMedia!['facebookUrl'] ?? '')
                                .toString()
                                .isNotEmpty)
                              _infoItem(
                                  'Facebook',
                                  restaurant.socialMedia!['facebookUrl']
                                      .toString()),
                            if ((restaurant.socialMedia!['instagramUrl'] ?? '')
                                .toString()
                                .isNotEmpty)
                              _infoItem(
                                  'Instagram',
                                  restaurant.socialMedia!['instagramUrl']
                                      .toString()),
                            if ((restaurant.socialMedia!['websiteUrl'] ?? '')
                                .toString()
                                .isNotEmpty)
                              _infoItem(
                                  'Website',
                                  restaurant.socialMedia!['websiteUrl']
                                      .toString()),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoSection(String title, IconData icon, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFFF6F00)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6F00),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _infoItem(String label, String value, {bool isTag = false}) {
    if (isTag) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Chip(
          label: Text(value),
          backgroundColor: Colors.orange.shade50,
          labelStyle: const TextStyle(color: Color(0xFFFF6F00)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapsLink(String link) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          // Open Google Maps link
          debugPrint('Opening Google Maps: $link');
          // You can use url_launcher package here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Maps: $link'),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  // Copy to clipboard if needed
                },
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'View on Google Maps',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 14, color: Colors.blue.shade700),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBusinessHours(Map<String, dynamic> hours) {
    final List<Widget> widgets = [];
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    for (final day in days) {
      if (hours[day] != null && hours[day] is Map) {
        final data = hours[day] as Map<String, dynamic>;
        final isOpen = data['isOpen'] == true;
        final open = data['open']?.toString() ?? '';
        final close = data['close']?.toString() ?? '';
        final dayName = day[0].toUpperCase() + day.substring(1);

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  isOpen ? '$open - $close' : 'Closed',
                  style: TextStyle(
                    color: isOpen ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
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
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
      ),
      body: _currentView == "table"
          ? _loadingDetails
              ? const Center(child: CircularProgressIndicator())
              : _buildTableTabbedView()
          : (_loadingDetails
              ? const Center(child: CircularProgressIndicator())
              : _buildMenuListView()),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
                Tab(text: 'Private'),
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
    final tables = _tables
        .where((t) =>
            t.locationTypeName.toLowerCase() == category.toLowerCase() &&
            t.isAvailable) // Filter only available tables
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
                builder: (_) => TableDetailPage(
                  table: table,
                  restaurant: widget.restaurant,
                ),
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
              image: table.images != null && table.images!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(table.images![0]),
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
                color: Colors.black.withOpacity(0.2),
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
                      "Table ${table.name} • Seats: ${table.seatLevelName ?? '-'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Status: Available",
                      style: TextStyle(
                        color: Colors.green,
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
            child: Image.network(
              restaurant.cover,
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
                onPressed: () => _showRestaurantInfo(),
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text("Info"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6F00),
                  side: const BorderSide(color: Color(0xFFFF6F00)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    // Use app userId from SharedPreferences (no FirebaseAuth UID)
                    final prefs = await SharedPreferences.getInstance();
                    final uid = prefs.getString('uid');
                    final merchantUid = restaurant.merchantId;
                    if (uid == null ||
                        uid.isEmpty ||
                        merchantUid == null ||
                        merchantUid.isEmpty) {
                      debugPrint(
                          'Cannot start chat: userId=$uid merchantUid=$merchantUid');
                      return;
                    }

                    // Optional: load user display name from prefs
                    final userName = [
                      prefs.getString('firstName') ?? '',
                      prefs.getString('lastName') ?? ''
                    ].where((s) => s.isNotEmpty).join(' ').trim();

                    final threadRef =
                        await FirebaseChatService.getOrCreateThread(
                      userId: uid,
                      merchantId: merchantUid,
                      userName: userName.isEmpty ? null : userName,
                      merchantName: restaurant.name,
                      merchantAvatar: restaurant.cover,
                    );

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          threadId: threadRef.id,
                          participants: [uid, merchantUid],
                          otherDisplayName: restaurant.name,
                          otherAvatarUrl: restaurant.cover,
                        ),
                      ),
                    );
                  } catch (e) {
                    debugPrint('Failed to open chat: $e');
                  }
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

  // =====================
  // MENU (no tabs, from details endpoint)
  // =====================
  Widget _buildMenuListView() {
    // Filter only available menu items
    final availableMenu = _menu.where((item) => item.isAvailable).toList();
    
    if (availableMenu.isEmpty) {
      return const Center(child: Text('No menu available.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: availableMenu.length,
      itemBuilder: (context, index) {
        final item = availableMenu[index];
        final image = (item.images.isNotEmpty) ? item.images.first : null;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: image != null
                ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)
                : null,
            color: Colors.grey[200],
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price != null
                            ? '\$${item.price!.toStringAsFixed(2)}'
                            : '-',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          // Convert lightweight menu item into MenuItem for Cart
                          final img = image ?? '';
                          final menuItem = MenuItem(
                            id: item.id,
                            name: item.name,
                            imageUrl: img,
                            price: item.price ?? 0.0,
                            description: item.description,
                            category: item.category,
                            restaurantId: widget.restaurant.id,
                            restaurantName: widget.restaurant.name,
                            customizations: null,
                          );
                          Cart.addItem(menuItem);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to pre-order')),
                          );
                        },
                        icon: const Icon(Icons.add_circle,
                            color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _MenuItemData {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? category;
  final List<String> images;
  final bool isAvailable;

  _MenuItemData({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.category,
    required this.images,
    this.isAvailable = true, // Default to true for backward compatibility
  });

  factory _MenuItemData.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] is List)
        ? List<String>.from((json['images'] as List).map((e) => e.toString()))
        : <String>[];
    final priceVal = json['price'];
    final price = priceVal is num
        ? priceVal.toDouble()
        : double.tryParse(priceVal?.toString() ?? '');
    // Check both isAvailable and is_available fields, default to true if neither exists
    final isAvailable = json.containsKey('isAvailable')
        ? (json['isAvailable'] == true)
        : json.containsKey('is_available')
            ? (json['is_available'] == true)
            : true;
    return _MenuItemData(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: price,
      category: json['category']?.toString(),
      images: images,
      isAvailable: isAvailable,
    );
  }
}
