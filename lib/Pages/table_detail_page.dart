import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/table_model.dart';
import '../Models/restaurants.dart';
import '../Models/cart.dart';
import '../Services/api_service.dart';
import 'summary_page.dart';
import 'restaurant_details_page.dart';

class TableDetailPage extends StatefulWidget {
  final TableModel table;
  final Restaurant restaurant;

  const TableDetailPage(
      {super.key, required this.table, required this.restaurant});

  @override
  State<TableDetailPage> createState() => _TableDetailPageState();
}

class _TableDetailPageState extends State<TableDetailPage> {
  DateTime _selectedDate = DateTime.now();
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  String? _selectedSlot;
  int _partySize = 2;
  int _currentImageIndex = 0;
  PageController _pageController = PageController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillCustomer();
    _fetchSlots();
    // Set default party size up to capacity
    final cap =
        widget.table.capacity ?? int.tryParse(widget.table.seatLevelName) ?? 2;
    _partySize = cap > 0 ? (cap >= 2 ? 2 : 1) : 2;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _prefillCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getString('firstName') ?? '';
    final last = prefs.getString('lastName') ?? '';
    final email = prefs.getString('userEmail') ?? '';
    final phone = prefs.getString('phone') ?? '';
    setState(() {
      _nameController.text =
          [first, last].where((s) => s.isNotEmpty).join(' ').trim();
      _emailController.text = email;
      _phoneController.text = phone;
    });
  }

  String _formatDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _fetchSlots() async {
    setState(() {
      _loadingSlots = true;
      _availableSlots = [];
      _selectedSlot = null;
    });
    try {
      final dateStr = _formatDate(_selectedDate);
      final res = await ApiService.getAvailableTimeSlots(
        tableId: widget.table.id,
        date: dateStr,
        // omit duration to let backend default to table.maxBookingDuration
        duration: null,
      );
      final slots =
          (res['availableSlots'] as List?)?.map((e) => e.toString()).toList() ??
              [];
      setState(() {
        _availableSlots = slots;
        _loadingSlots = false;
      });
      if (slots.isEmpty) {
        final msg = res['message']?.toString() ?? 'No available slots';
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      setState(() => _loadingSlots = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load slots: $e')));
      }
    }
  }

  bool _canBook() {
    if (_selectedSlot == null) return false;
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) return false;

    // Check minSpending policy
    final minSpend = widget.table.minSpending ?? 0;
    if (minSpend > 0) {
      final preOrderTotal = Cart.items
          .where((ci) => ci.item.restaurantId == widget.restaurant.id)
          .fold(0.0, (sum, ci) => sum + (ci.item.price * ci.quantity));
      if (preOrderTotal < minSpend) return false;
    }
    return true;
  }

  Future<void> _goToSummary() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot')));
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please provide your name, phone and email')));
      return;
    }

    final dateStr = _formatDate(_selectedDate);
    final duration =
        widget.table.maxBookingDuration; // let backend default if null

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryPage(
          reservedTable: widget.table,
          restaurantId: widget.restaurant.id,
          tableId: widget.table.id,
          date: dateStr,
          time: _selectedSlot!,
          duration: duration,
          partySize: _partySize,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          specialRequests: _noteController.text.trim(),
        ),
      ),
    );
  }

  void _showReserveDialog(BuildContext context, TableModel table) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Reserve Table ${table.name}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6F00),
            ),
          ),
          content: const Text(
            "Do you want to reserve this table only, or also pre-order food?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SummaryPage(reservedTable: table),
                  ),
                );
              },
              child: const Text(
                "Book Table Only",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, "menu");
              },
              child: const Text("Book & Pre-Order Food"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final table = widget.table;
    final cap = table.capacity ?? int.tryParse(table.seatLevelName) ?? 0;
    // Reviews removed per request

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "Table ${table.name}",
              style: const TextStyle(
                color: Color(0xFFFF6F00),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            const Text(
              "4.5",
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image carousel
          SizedBox(
            height: 200,
            child: table.images.isNotEmpty
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: table.images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              table.images[index],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text("Failed to load image", style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFFFF6F00),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Show indicators only if there are multiple images
                      if (table.images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              table.images.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Show image counter in top-right corner if multiple images
                      if (table.images.length > 1)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${table.images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("No Image", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Table info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${table.locationTypeName} • Seats: ${table.seatLevelName}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                table.isActive ? "Active" : "Inactive",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: table.isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Show minimum spending requirement
          if ((table.minSpending ?? 0) > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF6F00), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFFFF6F00), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Minimum Spending: \$${table.minSpending!.toStringAsFixed(2)} (Pre-order required)",
                      style: const TextStyle(
                        color: Color(0xFFFF6F00),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (table.description.isNotEmpty)
            Text("Note: ${table.description}",
                style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),

          // Date picker and available time slots
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 18, color: Color(0xFFFF6F00)),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                    await _fetchSlots();
                  }
                },
                child: Text(_formatDate(_selectedDate),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadingSlots ? null : _fetchSlots,
                icon: const Icon(Icons.refresh, color: Color(0xFFFF6F00)),
                tooltip: 'Reload slots',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loadingSlots)
            const Center(child: CircularProgressIndicator())
          else if (_availableSlots.isEmpty)
            const Text('No available time slots for the selected date',
                style: TextStyle(color: Colors.black54))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) {
                final selected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedSlot = slot);
                  },
                  selectedColor: const Color(0xFFFF6F00),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),
          // Party size selector
          Row(
            children: [
              const Text('Party size:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _partySize,
                items: [
                  for (int i = 1; i <= (cap > 0 ? cap : 12); i++)
                    DropdownMenuItem(value: i, child: Text(i.toString()))
                ],
                onChanged: (v) => setState(() => _partySize = v ?? _partySize),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Customer info
          const Text('Your info',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _noteController,
            decoration:
                const InputDecoration(labelText: 'Special requests (optional)'),
          ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                // Open Restaurant details on top (so back goes to this page)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailPage(
                      restaurant: widget.restaurant,
                      initialView: 'menu',
                    ),
                  ),
                ).then((_) {
                  if (mounted)
                    setState(() {}); // refresh to reflect updated Cart
                });
              },
              icon: const Icon(Icons.restaurant_menu, color: Color(0xFFFF6F00)),
              label: const Text('Pre-Order Menu',
                  style: TextStyle(color: Color(0xFFFF6F00))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6F00)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // Show pre-ordered items for this restaurant
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final preOrderItems = Cart.items
                  .where((ci) => ci.item.restaurantId == widget.restaurant.id)
                  .toList();
              final preOrderTotal = preOrderItems.fold(
                  0.0, (sum, ci) => sum + (ci.item.price * ci.quantity));
              final minSpend = table.minSpending ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pre-Order Items',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      if (minSpend > 0)
                        Text(
                          '\$${preOrderTotal.toStringAsFixed(2)} / \$${minSpend.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: preOrderTotal >= minSpend
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (preOrderItems.isEmpty && minSpend > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This table requires \$${minSpend.toStringAsFixed(2)} minimum spending. Please pre-order menu items.',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (preOrderItems.isEmpty)
                    const Text('No items added yet',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ...preOrderItems.map((ci) {
                    final img = ci.item.imageUrl;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: (img.startsWith('http'))
                                ? Image.network(img,
                                    width: 48, height: 48, fit: BoxFit.cover)
                                : Image.asset(img,
                                    width: 48, height: 48, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ci.item.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                    '\$${ci.item.price.toStringAsFixed(2)} each',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          // Quantity controls
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 20),
                                color: const Color(0xFFFF6F00),
                                onPressed: () {
                                  setState(() {
                                    if (ci.quantity > 1) {
                                      ci.quantity--;
                                    } else {
                                      Cart.removeItem(ci.item);
                                    }
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  ci.quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 20),
                                color: const Color(0xFFFF6F00),
                                onPressed: () {
                                  setState(() {
                                    ci.quantity++;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    Cart.removeItem(ci.item);
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '\$${(ci.item.price * ci.quantity).toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6F00)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),

          const SizedBox(height: 12),
          const Text("Parking: Free", style: TextStyle(color: Colors.black54)),
          const Text("Free Cancellation Within 2 Hours",
              style: TextStyle(color: Colors.black54)),
          const Text("Deposit 50% Free One Starter",
              style: TextStyle(color: Colors.black54)),

          const SizedBox(height: 20),

          // Reviews removed per request
          const SizedBox(height: 80), // spacing for button
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_canBook() && (widget.table.minSpending ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Add \$${((widget.table.minSpending ?? 0) - Cart.items.where((ci) => ci.item.restaurantId == widget.restaurant.id).fold(0.0, (sum, ci) => sum + (ci.item.price * ci.quantity))).toStringAsFixed(2)} more to pre-order',
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              onPressed: _canBook() ? _goToSummary : null,
              child: Text(
                "Book Table",
                style: TextStyle(
                  color: _canBook() ? Colors.white : Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
