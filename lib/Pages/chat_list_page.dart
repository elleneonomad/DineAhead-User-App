import 'package:flutter/material.dart';
import '../Models/restaurants.dart';
import 'chat-page.dart';
import '../Mock_Data/mock_restaurants.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Restaurant> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    filteredRestaurants =
        mockRestaurants.where((r) => r.chatHistory.isNotEmpty).toList();
  }

  void _onSearchChanged(String query) {
    final results = mockRestaurants.where((r) {
      final hasChats = r.chatHistory.isNotEmpty;
      final matchesQuery = r.name.toLowerCase().contains(query.toLowerCase());
      return hasChats && matchesQuery;
    }).toList();

    setState(() {
      filteredRestaurants = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // light background for modern look
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            "Messages",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search chats...",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = filteredRestaurants[index];
          final lastMessage = restaurant.chatHistory.last;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(restaurant.imagePath),
                radius: 25,
              ),
              title: Text(
                restaurant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                lastMessage.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(restaurant: restaurant),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
