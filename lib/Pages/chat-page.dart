import 'package:flutter/material.dart';
import 'package:dinengo/Pages/chat_list_page.dart';
import '../Mock_Data/mock_message.dart';
import '../Models/message_model.dart';

class ChatPage extends StatefulWidget {
  final String restaurantName;

  const ChatPage({super.key, required this.restaurantName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      mockChats[widget.restaurantName] ??= [];
      mockChats[widget.restaurantName]!.add(
        ChatMessage(text: text.trim(), isUser: true, time: DateTime.now()),
      );

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          mockChats[widget.restaurantName]!.add(
            ChatMessage(
              text: "Thank you for your message! 😊",
              isUser: false,
              time: DateTime.now(),
            ),
          );
        });
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = mockChats[widget.restaurantName] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F00),
        elevation: 1,
        title: Text(widget.restaurantName,
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChatListPage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isUser = message.isUser;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFFF6F00)
                          : const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Color.fromARGB(255, 249, 215, 193),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _sendMessage(_controller.text),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6F00),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
