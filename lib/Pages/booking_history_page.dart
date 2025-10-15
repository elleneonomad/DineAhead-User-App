import 'package:flutter/material.dart';
import '../Services/api_service.dart';
import 'booking_detail_page.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  bool _loading = false;
  List<dynamic> _bookings = [];
  String? _status;
  String? _upcomingSelection;

  final Color themeColor = const Color(0xFFFF6F00);

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.redAccent;
      case 'completed':
        return Colors.blue;
      case 'no-show':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _upcomingSelection = 'all';
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      bool? upcoming;
      if (_upcomingSelection == 'true') upcoming = true;
      if (_upcomingSelection == 'false') upcoming = false;

      final list = await ApiService.getBookings(
        status: _status,
        upcoming: upcoming,
      );
      setState(() => _bookings = list);
    } catch (e) {
      debugPrint('Failed to load bookings: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  Widget _bookingCard(Map<String, dynamic> b) {
    final restaurant = (b['restaurant'] as Map<String, dynamic>?) ?? {};
    final table = (b['table'] as Map<String, dynamic>?) ?? {};
    final status = (b['status'] ?? '').toString();
    final date = (b['date'] ?? '').toString();
    final time = (b['time'] ?? '').toString();
    final partySize = (b['partySize'] ?? '').toString();
    final totalAmount = (b['totalAmount'] ?? 0).toString();
    final paymentStatus = (b['paymentStatus'] ?? '').toString();
    final cover = (restaurant['coverImage'] ?? '').toString();
    final preOrderItems = (b['preOrderItems'] as List?) ?? const [];

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailPage(booking: b),
          ),
        );
        if (result == true) _fetch();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: cover.isNotEmpty
                  ? Image.network(cover,
                      width: 70, height: 70, fit: BoxFit.cover)
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.orange.shade50,
                      alignment: Alignment.center,
                      child: const Icon(Icons.restaurant, color: Colors.orange),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Name + Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (restaurant['name'] ?? 'Unknown Restaurant')
                              .toString(),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        '$date • $time',
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: Colors.black87),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.event_seat,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        'Table ${table['tableNumber'] ?? table['name'] ?? '-'} • Party $partySize',
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: Colors.black87),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        'Total: \$$totalAmount • $paymentStatus',
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: Colors.black87),
                      ),
                    ],
                  ),

                  if (preOrderItems.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: preOrderItems.map<Widget>((pi) {
                        final m = pi as Map<String, dynamic>;
                        final name =
                            (m['name'] ?? m['menuItemId'] ?? '-').toString();
                        final qty = (m['quantity'] ?? '').toString();
                        return Chip(
                          label: Text('$name x$qty'),
                          backgroundColor: Colors.orange.shade50,
                          labelStyle: const TextStyle(
                            color: Color(0xFFFF6F00),
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text(
          'Booking History',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters row
            Row(
              children: [
                Expanded(
                  child: _styledDropdown<String?>(
                    label: "Status",
                    value: _status,
                    items: const [
                      DropdownMenuItem<String?>(
                          value: null, child: Text('All statuses')),
                      DropdownMenuItem<String?>(
                          value: 'pending', child: Text('Pending')),
                      DropdownMenuItem<String?>(
                          value: 'confirmed', child: Text('Confirmed')),
                      DropdownMenuItem<String?>(
                          value: 'rejected', child: Text('Rejected')),
                      DropdownMenuItem<String?>(
                          value: 'cancelled', child: Text('Cancelled')),
                      DropdownMenuItem<String?>(
                          value: 'completed', child: Text('Completed')),
                      DropdownMenuItem<String?>(
                          value: 'no-show', child: Text('No-show')),
                    ],
                    onChanged: (v) {
                      setState(() => _status = v);
                      _fetch();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _styledDropdown<String>(
                    label: "Time",
                    value: _upcomingSelection,
                    items: const [
                      DropdownMenuItem<String>(
                          value: 'all', child: Text('All')),
                      DropdownMenuItem<String>(
                          value: 'true', child: Text('Upcoming')),
                      DropdownMenuItem<String>(
                          value: 'false', child: Text('Past')),
                    ],
                    onChanged: (v) {
                      setState(() => _upcomingSelection = v);
                      _fetch();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loading ? null : _fetch,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Booking list
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6F00),
                      ),
                    )
                  : _bookings.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/empty.png',
                                width: 160, height: 160),
                            const SizedBox(height: 12),
                            const Text(
                              'No bookings found',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          color: themeColor,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _bookings.length,
                            itemBuilder: (context, i) =>
                                _bookingCard(_bookings[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
