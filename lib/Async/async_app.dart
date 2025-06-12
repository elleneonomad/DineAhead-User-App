import 'package:flutter/material.dart';
import '../Pages/account-page.dart';
import '../Pages/home-page.dart';
import '../Pages/search-page.dart';
import '../Pages/chat-page.dart';
import '../Pages/grocery-page.dart';
import '../authentication/login.dart'; // Add this

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

    // Trigger navigation after delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
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
                image: AssetImage('assets/images/dinengo-logo.png'),
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
    GroceryPage(),
    SearchPage(),
    ChatPage(restaurantName: 'Sushi World'),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFF6F00),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_grocery_store), label: 'Grocery'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
