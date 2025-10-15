import 'package:flutter/material.dart';
import '../Services/api_service.dart';

class BookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late Map<String, dynamic> _booking;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

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

  bool _canCancel() {
    final status = (_booking['status'] ?? '').toString().toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }

  Future<void> _showCancelDialog() async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // makes it feel intentional
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final reasonText = reasonController.text.trim();
          final isReasonValid = reasonText.length >= 5;
          final errorText = reasonText.length < 5
              ? 'Reason must be at least 5 characters (${reasonText.length}/5)'
              : null;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🟠 Header icon and title
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined,
                        size: 32, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cancel Booking?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6F00),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Are you sure you want to cancel this booking?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 📝 Reason field
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason (Required)',
                      hintText: 'e.g., Change of plans',
                      labelStyle: const TextStyle(color: Color(0xFFFF6F00)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF6F00)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      errorText: errorText,
                      helperText: 'Minimum 5 characters required',
                      helperStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 8),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 12),

                  // 🟠 Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Color(0xFFFF6F00)),
                          ),
                          child: const Text(
                            'Keep Booking',
                            style: TextStyle(
                              color: Color(0xFFFF6F00),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isReasonValid
                                ? Colors.red
                                : Colors.red.shade200,
                            elevation: isReasonValid ? 3 : 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isReasonValid
                              ? () => Navigator.pop(context, true)
                              : null,
                          child: Text(
                            'Cancel Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (confirmed == true && mounted) {
      await _cancelBooking(reasonController.text.trim());
    }
  }

  Future<void> _cancelBooking(String reason) async {
    // Validate reason length
    if (reason.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cancellation reason must be at least 5 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _cancelling = true);
    try {
      final bookingId = (_booking['id'] ?? _booking['_id'] ?? '').toString();
      if (bookingId.isEmpty) {
        throw Exception('Booking ID not found');
      }

      final result = await ApiService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        debugPrint('✅ Booking cancelled successfully');
        setState(() {
          _booking['status'] = 'cancelled';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Build detailed error message
        String errorMessage =
            result['message'] ?? result['error'] ?? 'Failed to cancel booking';

        // Log error details to console
        debugPrint('❌ Booking cancellation failed:');
        debugPrint('  Error: ${result['error']}');
        debugPrint('  Message: ${result['message']}');
        if (result['details'] != null) {
          debugPrint('  Validation details: ${result['details']}');
        }
        if (result['requiredHours'] != null) {
          debugPrint('  Required hours: ${result['requiredHours']}');
        }
        if (result['hoursUntilBooking'] != null) {
          debugPrint('  Hours until booking: ${result['hoursUntilBooking']}');
        }

        // If we have additional details, append them
        if (result['requiredHours'] != null &&
            result['hoursUntilBooking'] != null) {
          final required = result['requiredHours'];
          final remaining = result['hoursUntilBooking'];
          errorMessage = '${result['error'] ?? errorMessage}\n'
              'Required: $required hours notice\n'
              'Time remaining: ${remaining.toStringAsFixed(1)} hours';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ Exception during booking cancellation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = (_booking['restaurant'] as Map<String, dynamic>?) ?? {};
    final table = (_booking['table'] as Map<String, dynamic>?) ?? {};
    final customerInfo =
        (_booking['customerInfo'] as Map<String, dynamic>?) ?? {};
    final status = (_booking['status'] ?? '').toString();
    final date = (_booking['date'] ?? '').toString();
    final time = (_booking['time'] ?? '').toString();
    final partySize = (_booking['partySize'] ?? '').toString();
    final duration = (_booking['duration'] ?? '').toString();
    final totalAmount = (_booking['totalAmount'] ?? 0).toString();
    final paymentStatus = (_booking['paymentStatus'] ?? '').toString();
    final specialRequests = (_booking['specialRequests'] ?? '').toString();
    final cover = (restaurant['coverImage'] ?? '').toString();
    final preOrderItems = (_booking['preOrderItems'] as List?) ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Restaurant header with image
            if (cover.isNotEmpty)
              Image.network(
                cover,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant,
                      size: 64, color: Colors.white),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child:
                    const Icon(Icons.restaurant, size: 64, color: Colors.white),
              ),

            // Status badge
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      restaurant['name']?.toString() ?? 'Unknown Restaurant',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _statusColor(status)),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Booking details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reservation Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6F00),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow(Icons.calendar_today, 'Date', date),
                  _detailRow(Icons.access_time, 'Time', time),
                  _detailRow(
                      Icons.event_seat,
                      'Table',
                      table['tableNumber']?.toString() ??
                          table['name']?.toString() ??
                          '-'),
                  _detailRow(Icons.people, 'Party Size', '$partySize guests'),
                  if (duration.isNotEmpty)
                    _detailRow(Icons.timer, 'Duration', '$duration minutes'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Customer info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6F00),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow(Icons.person, 'Name',
                      customerInfo['name']?.toString() ?? '-'),
                  _detailRow(Icons.phone, 'Phone',
                      customerInfo['phone']?.toString() ?? '-'),
                  _detailRow(Icons.email, 'Email',
                      customerInfo['email']?.toString() ?? '-'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Pre-order items
            if (preOrderItems.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pre-Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6F00),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...preOrderItems.map((item) {
                      final m = item as Map<String, dynamic>;
                      final name =
                          (m['name'] ?? m['menuItemId'] ?? '-').toString();
                      final qty = (m['quantity'] ?? '').toString();
                      final price = (m['price'] ?? 0).toString();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(name)),
                            Text('x$qty',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            Text('\$$price',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Payment info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6F00),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:',
                          style: TextStyle(fontSize: 16)),
                      Text(
                        '\$$totalAmount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment Status:'),
                      Text(
                        paymentStatus.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: paymentStatus.toLowerCase() == 'paid'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Special requests
            if (specialRequests.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Special Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6F00),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(specialRequests,
                        style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Cancel button
            if (_canCancel())
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _cancelling ? null : _showCancelDialog,
                  child: _cancelling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Cancel Booking',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
