import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/firebase_chat.dart';

class ChatPage extends StatefulWidget {
  final String threadId;
  final List<String> participants;
  final String? otherDisplayName;
  final String? otherAvatarUrl;

  const ChatPage({super.key, required this.threadId, required this.participants, this.otherDisplayName, this.otherAvatarUrl});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String? _myId;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _myId == null) return;
    await FirebaseChatService.sendMessage(
      threadId: widget.threadId,
      text: text,
      senderId: _myId!,
      participants: widget.participants,
    );
    _controller.clear();
  }

  @override
  void initState() {
    super.initState();
    _loadMyId();
  }

  Future<void> _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('uid');
    setState(() => _myId = id);
    if (id != null) {
      await FirebaseChatService.markThreadRead(widget.threadId, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherName = widget.otherDisplayName ?? 'Chat';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          otherName,
          style: const TextStyle(
            color: Color(0xFFFF6F00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
      ),
      body: Column(
        children: [
          // Restaurant image (not in app bar)
          // Container(
          //   width: double.infinity,
          //   height: 180,
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage(widget.restaurant.imagePath),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),

          // Chat messages
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseChatService.messagesStream(widget.threadId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs; // newest first due to orderBy desc
                final uid = _myId;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final isUser = data['senderId'] == uid;
                    final text = (data['text'] ?? '').toString();

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFFFF6F00) : const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 16),
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: const BoxDecoration(
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
                      filled: true,
                      fillColor: const Color.fromARGB(255, 249, 215, 193),
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
