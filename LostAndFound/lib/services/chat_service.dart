import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lostandfound/pages/message.dart'; // Corrected import path

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get message stream for a chat room
  Stream<List<Message>> getMessages(String receiverId) {
    final String currentUserId = _auth.currentUser!.uid;
    final String chatRoomId = _getChatRoomId(currentUserId, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromMap(doc.data()))
              .toList();
        });
  }

  /// Get all chat rooms for the current user
  Stream<List<Map<String, dynamic>>> getChatRooms() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['chatRoomId'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Send a message
  Future<void> sendMessage(
    String receiverId,
    String message,
    String itemContext,
  ) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    final String chatRoomId = _getChatRoomId(currentUserId, receiverId);

    // Add new message to the messages subcollection
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    // Update the chat room metadata (for chat lists, etc.)
    await _firestore.collection('chats').doc(chatRoomId).set({
      'users': [currentUserId, receiverId],
      'lastMessage': message,
      'lastMessageTimestamp': timestamp,
      'itemContext': itemContext,
    }, SetOptions(merge: true));
  }

  /// Helper to generate a consistent chat room ID
  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Sort ensures the ID is the same regardless of who starts the chat
    return ids.join('_');
  }
}
