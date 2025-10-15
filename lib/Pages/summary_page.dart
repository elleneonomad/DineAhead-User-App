import 'package:flutter/material.dart';
import '../Models/table_model.dart';
import '../Models/cart.dart';
import '../Models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/api_service.dart';
import '../Models/cart.dart';

class SummaryPage extends StatefulWidget {
  final TableModel? reservedTable;
  final String? restaurantId;
  final String? tableId;
  final String? date;
  final String? time;
  final int? duration;
  final int? partySize;
  final String? name;
  final String? phone;
  final String? email;
  final String? specialRequests;

  const SummaryPage({
    super.key,
    this.reservedTable,
    this.restaurantId,
    this.tableId,
    this.date,
    this.time,
    this.duration,
    this.partySize,
    this.name,
    this.phone,
    this.email,
    this.specialRequests,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _submitting = false;
  String? _error;

  Future<void> _confirmBooking() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (widget.restaurantId == null ||
          widget.tableId == null ||
          widget.date == null ||
          widget.time == null ||
          widget.partySize == null ||
          widget.name == null ||
          widget.phone == null ||
          widget.email == null) {
        throw Exception('Missing booking details');
      }

      final minSpend = widget.reservedTable?.minSpending ?? 0;
      final preOrderTotal = Cart.items.fold(
        0.0,
        (sum, ci) => sum + (ci.item.price * ci.quantity),
      );

      if (minSpend > 0 && preOrderTotal < minSpend) {
        throw Exception(
          'This table requires a minimum spending of \$${minSpend.toStringAsFixed(2)}. '
          'Your total is \$${preOrderTotal.toStringAsFixed(2)}.',
        );
      }

      final preOrder = Cart.items
          .map((ci) => {
                'menuItemId': ci.item.id,
                'quantity': ci.quantity,
              })
          .toList();

      final res = await ApiService.createBooking(
        restaurantId: widget.restaurantId!,
        tableId: widget.tableId!,
        date: widget.date!,
        time: widget.time!,
        duration: widget.duration,
        partySize: widget.partySize!,
        name: widget.name!,
        phone: widget.phone!,
        email: widget.email!,
        specialRequests: widget.specialRequests ?? '',
        preOrder: preOrder,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        // 🧹 clear cart after booking
        Cart.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully ✅'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        final err = res['error'] ?? res['message'] ?? 'Booking failed';
        setState(() => _error = err);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Cart.items;
    final total = Cart.total;
    const orange = Color(0xFFFF6F00);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: const Text(
          "Booking Summary",
          style: TextStyle(
            color: orange,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: orange),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🟠 Table Info
          if (widget.reservedTable != null)
            _sectionCard(
              title: "Table Details",
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      widget.reservedTable!.name,
                      style: const TextStyle(
                          color: orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text("Table ${widget.reservedTable!.name}",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    "Seats: ${widget.reservedTable!.seatLevelName} • ${widget.reservedTable!.locationTypeName}",
                  ),
                  trailing: Icon(
                    widget.reservedTable!.isActive
                        ? Icons.event_busy
                        : Icons.event_seat,
                    color: widget.reservedTable!.isActive
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),

          // 🟠 Booking Info
          if (widget.restaurantId != null)
            _sectionCard(
              title: "Booking Details",
              children: [
                _detailTile(Icons.event, '${widget.date} at ${widget.time}',
                    'Party size: ${widget.partySize ?? '-'}'),
                const SizedBox(height: 8),
                _detailTile(Icons.person, widget.name ?? '-',
                    '${widget.phone ?? ''} • ${widget.email ?? ''}'),
                if ((widget.specialRequests ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailTile(Icons.note_alt_outlined, 'Special requests',
                      widget.specialRequests!),
                ],
              ],
            ),

          // 🟠 Food Order
          if (cartItems.isNotEmpty ||
              (widget.reservedTable?.minSpending ?? 0) > 0)
            _sectionCard(
              title: "Food Order",
              action: (widget.reservedTable?.minSpending ?? 0) > 0
                  ? _minSpendTag(total)
                  : null,
              children: [
                ...cartItems.map((cartItem) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cartItem.item.imageUrl,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                        title: Text(cartItem.item.name),
                        subtitle: Text(
                          "Qty: ${cartItem.quantity} • \$${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}",
                        ),
                      ),
                    )),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("\$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: orange)),
                  ],
                ),
                if ((widget.reservedTable?.minSpending ?? 0) > 0 &&
                    total < widget.reservedTable!.minSpending!)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Need \$${(widget.reservedTable!.minSpending! - total).toStringAsFixed(2)} more to meet minimum spending.',
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!,
                  style: const TextStyle(color: Colors.redAccent)),
            ),

          // 🟠 Confirm Button
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: _submitting ? null : _confirmBooking,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text("Confirm Booking",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    List<Widget> children = const [],
    Widget? action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F00))),
            if (action != null) action,
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _detailTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6F00)),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
        ),
      ],
    );
  }

  Widget _minSpendTag(double total) {
    final minSpend = widget.reservedTable?.minSpending ?? 0;
    final met = total >= minSpend;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: met ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: met ? Colors.green : Colors.red),
      ),
      child: Text(
        'Min \$${minSpend.toStringAsFixed(2)}',
        style: TextStyle(
          color: met ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
