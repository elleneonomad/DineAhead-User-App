import 'package:dinengo/Pages/restaurant_details_page.dart';
import 'package:flutter/material.dart';
import '../Mock_Data/mock_message.dart';
import 'chat-page.dart';
import '../Models/restaurants.dart';

class ChatListPage extends StatelessWidget {
  // final Restaurant restaurant;
  const ChatListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final restaurants = mockChats.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFFFF6F00),
      ),
      body: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final name = restaurants[index];
          final lastMessage = mockChats[name]!.last;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF6F00),
              child: Text(name[0]),
            ),
            title: Text(name),
            subtitle: Text(lastMessage.text,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatPage(restaurantName: name)),
              );
            },
          );
        },
      ),
    );
  }
}
