import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChatService {
  static final _db = FirebaseFirestore.instance;

  // Stream all threads that include current userId
  static Stream<QuerySnapshot<Map<String, dynamic>>> threadsStream(String currentUserId) {
    if (currentUserId.isEmpty) return const Stream.empty();
    return _db
        .collection('threads')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Get or create a thread between two users (by your app's IDs)
  static Future<DocumentReference<Map<String, dynamic>>> getOrCreateThread({
    required String userId,
    required String merchantId,
    String? userName,
    String? merchantName,
    String? userAvatar,
    String? merchantAvatar,
  }) async {
    // Try to find existing
    final q = await _db
        .collection('threads')
        .where('participants', arrayContains: userId)
        .get();

    for (final doc in q.docs) {
      final p = List<String>.from(doc.data()['participants'] ?? []);
      if (p.contains(merchantId)) return doc.reference;
    }

    // Create
    final ref = await _db.collection('threads').add({
      'participants': [userId, merchantId],
      'userId': userId,
      'merchantId': merchantId,
      'userName': userName ?? '',
      'merchantName': merchantName ?? '',
      'userAvatar': userAvatar ?? '',
      'merchantAvatar': merchantAvatar ?? '',
      'lastMessage': '',
      'lastSenderId': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'unread': {userId: 0, merchantId: 0},
    });
    return ref;
  }

  // Stream messages inside a thread
  static Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String threadId) {
    return _db
        .collection('threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Send a text message with your app's senderId
  static Future<void> sendMessage({
    required String threadId,
    required String text,
    required String senderId,
    required List<String> participants,
  }) async {
    if (senderId.isEmpty) return;
    final threadRef = _db.collection('threads').doc(threadId);
    final msgRef = threadRef.collection('messages').doc();

    await _db.runTransaction((txn) async {
      // READS must happen before WRITES in a transaction
      final snap = await txn.get(threadRef);
      final data = snap.data() ?? {};
      final unread = Map<String, dynamic>.from(data['unread'] ?? {});
      for (final p in participants) {
        unread[p] = (p == senderId) ? 0 : ((unread[p] ?? 0) as int) + 1;
      }

      // Now perform WRITES
      txn.set(msgRef, {
        'senderId': senderId,
        'text': text.trim(),
        'type': 'text',
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': [senderId],
      });

      txn.update(threadRef, {
        'lastMessage': text.trim(),
        'lastSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': unread,
      });
    });
  }

  static Future<void> markThreadRead(String threadId, String userId) async {
    if (userId.isEmpty) return;
    final ref = _db.collection('threads').doc(threadId);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() ?? {};
      final unread = Map<String, dynamic>.from(data['unread'] ?? {});
      unread[userId] = 0;
      txn.update(ref, {'unread': unread});
    });
  }
}
