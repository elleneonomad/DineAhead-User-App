import 'package:flutter/material.dart';
import '../authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _userName = 'User';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName') ?? '';
    final lastName = prefs.getString('lastName') ?? '';
    final email = prefs.getString('userEmail') ?? '';

    setState(() {
      _userName =
          [firstName, lastName].where((v) => v.isNotEmpty).join(' ').trim();
      if (_userName.isEmpty) _userName = 'User';
      _userEmail = email;
      _isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF6F00);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(
            color: orange,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: orange),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: orange))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 🟠 User Header
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: orange.withOpacity(0.9),
                          child: Text(
                            _userName.isNotEmpty
                                ? _userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_userName,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat')),
                              if (_userEmail.isNotEmpty)
                                Text(
                                  _userEmail,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Montserrat'),
                                ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  "View profile",
                                  style: TextStyle(
                                      color: orange,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🟠 Promo Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Save on your next dine-in booking!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Explore offers →",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.local_offer,
                            color: Colors.white, size: 36),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🟠 Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Quick Access",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3.2,
                          children: [
                            _quickButton(Icons.receipt_long, "Orders", () {}),
                            _quickButton(
                                Icons.favorite_border, "Favourites", () {}),
                            _quickButton(Icons.payment, "Payments", () {}),
                            _quickButton(
                                Icons.location_on_outlined, "Addresses", () {}),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🟠 Perks Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Perks for You",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat')),
                        const SizedBox(height: 12),
                        _perksTile(
                            Icons.workspace_premium, "Become a pro", () {}),
                        _perksTile(Icons.card_giftcard, "Vouchers", () {}),
                        _perksTile(Icons.emoji_events, "Rewards", () {}),
                        _perksTile(Icons.group_add, "Invite friends", () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Divider(thickness: 1, color: Colors.grey),

                  // 🟠 Logout Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        "Log out",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- Styled Buttons and Tiles (no logic changed) ---
  static Widget _quickButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.orange.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6F00)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              )),
        ],
      ),
    );
  }

  static Widget _perksTile(IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shadowColor: Colors.orange.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF6F00)),
        title: Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              fontFamily: 'Montserrat',
            )),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
