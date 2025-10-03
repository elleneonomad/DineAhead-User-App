import 'package:flutter/material.dart';
import '../Models/table_model.dart';
import '../Models/cart.dart';
import '../Models/cart_item_model.dart';

class SummaryPage extends StatelessWidget {
  final TableModel? reservedTable;

  const SummaryPage({super.key, this.reservedTable});

  @override
  Widget build(BuildContext context) {
    final cartItems = Cart.items;
    final total = Cart.total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Booking Summary",
          style: TextStyle(
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ Table info
          if (reservedTable != null) ...[
            const Text("Table Details",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F00))),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    reservedTable!.tableNumber,
                    style: const TextStyle(color: Color(0xFFFF6F00)),
                  ),
                ),
                title: Text("Table ${reservedTable!.tableNumber}"),
                subtitle: Text(
                  "Seats: ${reservedTable!.seats} • ${reservedTable!.locationType}",
                ),
                trailing: Icon(
                  reservedTable!.isBooked ? Icons.event_busy : Icons.event_seat,
                  color: reservedTable!.isBooked ? Colors.red : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ✅ Food order info
          if (cartItems.isNotEmpty) ...[
            const Text("Food Order",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F00))),
            const SizedBox(height: 8),
            ...cartItems.map((cartItem) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      cartItem.item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(cartItem.item.name),
                  subtitle: Text(
                    "Qty: ${cartItem.quantity} • \$${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}",
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6F00))),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ✅ Confirmation button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reservation confirmed ✅")),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("Confirm Booking",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}
