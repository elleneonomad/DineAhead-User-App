import 'package:flutter/material.dart';
import '../Models/table_model.dart';
import 'summary_page.dart';

class TableDetailPage extends StatelessWidget {
  final TableModel table;

  const TableDetailPage({super.key, required this.table});

  void _showReserveDialog(BuildContext context, TableModel table) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Reserve Table ${table.tableNumber}",
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
    final reviews = [
      {
        "reviewer": "Jackson Wang",
        "comment": "Tasty and serve exactly on time",
        "rating": 4.0
      },
      {
        "reviewer": "Jackson Wang",
        "comment": "Tasty and serve exactly on time",
        "rating": 4.0
      },
      {
        "reviewer": "Jackson Wang",
        "comment": "Tasty and serve exactly on time",
        "rating": 4.0
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
        title: Row(
          children: [
            Text(
              "Table ${table.tableNumber}",
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image carousel
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: (table.imageUrl != null && table.imageUrl!.isNotEmpty)
                ? Image.asset(
                    table.imageUrl![0],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text("No Image"),
                  ),
          ),
          const SizedBox(height: 16),

          // Table info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${table.locationType} • Seats: ${table.seats}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                table.isBooked ? "Booked" : "Available",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: table.isBooked ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text("Minimum Spend: \$${table.minSpend ?? 0}",
              style: const TextStyle(color: Colors.black54)),
          if (table.note != null && table.note!.isNotEmpty)
            Text("Note: ${table.note!}",
                style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),

          // Example static extra info
          const Text("Available from: 1:00 PM - 3:00 PM",
              style: TextStyle(color: Colors.black54)),
          const Text("Duration: 2 hours",
              style: TextStyle(color: Colors.black54)),
          const Text("Parking: Free", style: TextStyle(color: Colors.black54)),
          const Text("Free Cancellation Within 2 Hours",
              style: TextStyle(color: Colors.black54)),
          const Text("Deposit 50% Free One Starter",
              style: TextStyle(color: Colors.black54)),

          const SizedBox(height: 20),

          // Reviews Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Customer Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("(${reviews.length} reviews)",
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ...reviews.map((r) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(r["reviewer"] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Review: ${r["comment"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text((r["rating"] as double).toStringAsFixed(1)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 80), // spacing for button
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6F00),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed:
              table.isBooked ? null : () => _showReserveDialog(context, table),
          child: const Text(
            "Book Table",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
