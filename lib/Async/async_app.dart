import 'package:dinengo/Pages/booking_history_page.dart';
import 'package:dinengo/Pages/chat_list_page.dart';
import 'package:flutter/material.dart';
import '../Pages/account-page.dart';
import '../Pages/home-page.dart';
import '../Pages/search-page.dart';
import '../Pages/chat-page.dart';
import '../authentication/login.dart'; // Add this
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/auth_service.dart';

Widget asyncApp() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Attempt token refresh while showing splash, then navigate
    _attemptRefreshAndNavigate();
  }

  Future<void> _attemptRefreshAndNavigate() async {
    try {
      // Keep splash visible for a moment
      await Future.delayed(const Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      final storedRefresh = prefs.getString('refreshToken');

      if (storedRefresh != null && storedRefresh.isNotEmpty) {
        final res = await AuthService.refreshToken(refreshToken: storedRefresh);

        if (res['success'] == true) {
          final tokens = (res['tokens'] ?? {}) as Map<String, dynamic>;
          final idToken = (tokens['idToken'] ?? '') as String;
          final newRefresh = (tokens['refreshToken'] ?? '') as String;
          final expiresInStr = tokens['expiresIn']?.toString() ?? '0';
          final expiresIn = int.tryParse(expiresInStr) ?? 0;
          final expiresAtMs = DateTime.now()
              .add(Duration(seconds: expiresIn))
              .millisecondsSinceEpoch;

          // Persist refreshed tokens (keep legacy 'token' for API service)
          await prefs.setString('token', idToken);
          await prefs.setString('idToken', idToken);
          await prefs.setString('refreshToken', newRefresh);
          await prefs.setInt('tokenExpiresAt', expiresAtMs);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainApp()),
          );
          return;
        }
      }
    } catch (_) {
      // ignore and fall through to login
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: const Image(
                image: AssetImage('assets/images/dineahead-logo.png'),
                width: 200,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                color: Color(0xFFFF6F00),
                backgroundColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    BookingHistoryPage(),
    SearchPage(),
    ChatListPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // ✅ white background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // ✅ ensure it stays white
          selectedItemColor: const Color(0xFFFF6F00),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0, // remove extra shadow from material
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Montserrat'),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
