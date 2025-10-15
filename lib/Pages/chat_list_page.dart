import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/firebase_chat.dart';
import 'chat-page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String _search = '';
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('uid');
    debugPrint('ChatList: loaded currentUserId=$id');
    setState(() => _currentUserId = id);
  }

  void _onSearchChanged(String query) {
    setState(() => _search = query.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // light background for modern look
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
      ),
      body: (_currentUserId == null)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search chats...",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),
                // Chat list
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseChatService.threadsStream(_currentUserId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        debugPrint('ChatList stream error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data?.docs ?? [];
                      debugPrint('ChatList: fetched ${docs.length} thread(s) for userId=$_currentUserId');
                      final uid = _currentUserId;
                      final filtered = docs.where((d) {
                        final data = d.data();
                        final name = (data['merchantName'] ?? data['userName'] ?? '').toString().toLowerCase();
                        return _search.isEmpty || name.contains(_search);
                      }).toList();

                      if (filtered.isEmpty) {
                        debugPrint('ChatList: no conversations after filter (search="$_search").');
                        return const Center(child: Text('No conversations yet'));
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
              final doc = filtered[index];
              final data = doc.data();
              final participants = List<String>.from(data['participants'] ?? []);
              final otherId = participants.firstWhere((p) => p != uid, orElse: () => '');
              final otherName = (otherId == data['userId']) ? (data['userName'] ?? '') : (data['merchantName'] ?? '');
              final otherAvatar = (otherId == data['userId']) ? (data['userAvatar'] ?? '') : (data['merchantAvatar'] ?? '');
              final lastMessage = (data['lastMessage'] ?? '').toString();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (otherAvatar is String && otherAvatar.startsWith('http'))
                        ? NetworkImage(otherAvatar)
                        : null,
                    child: (otherAvatar is String && otherAvatar.startsWith('http'))
                        ? null
                        : const Icon(Icons.person),
                    radius: 25,
                  ),
                  title: Text(
                    otherName.toString().isEmpty ? 'Chat' : otherName.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          threadId: doc.id,
                          participants: participants,
                          otherDisplayName: otherName.toString(),
                          otherAvatarUrl: otherAvatar.toString(),
                        ),
                      ),
                    );
                  },
                ),
              );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
