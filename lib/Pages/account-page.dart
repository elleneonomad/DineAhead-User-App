import 'package:flutter/material.dart';
import '../authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text("Account",
            style: TextStyle(
                color: Color(0xFFFF6F00), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFFF6F00),
                    child: Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Jack",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to profile
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text("View profile",
                            style: TextStyle(
                                color: Color(0xFFFF6F00),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Promo Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F00),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Save on your future orders with Dinengo!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                        SizedBox(height: 6),
                        Text("Learn more →",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Icon(Icons.local_offer, color: Colors.white, size: 32),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Access Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3.2,
                children: [
                  _quickButton(Icons.receipt_long, "Orders", () {}),
                  _quickButton(Icons.favorite_border, "Favourites", () {}),
                  _quickButton(Icons.payment, "Payments", () {}),
                  _quickButton(Icons.location_on_outlined, "Addresses", () {}),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Perks Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Perks for you",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 12),
                  _perksTile(Icons.workspace_premium, "Become a pro", () {}),
                  _perksTile(Icons.card_giftcard, "Vouchers", () {}),
                  _perksTile(Icons.emoji_events, "Panda rewards", () {}),
                  _perksTile(Icons.group_add, "Invite friends", () {}),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Divider(),

            // Logout Button
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: TextButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Log out",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFF6F00)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _perksTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Icon(icon, color: Color(0xFFFF6F00)),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
