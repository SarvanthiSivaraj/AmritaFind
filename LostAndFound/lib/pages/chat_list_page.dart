import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/pages/chat_page.dart';
import 'package:lostandfound/services/chat_service.dart';

const Color kPrimary = Color(0xFF8C2F39);
const Color kBackgroundLight = Color(0xFFFAF9F6);

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 1,
        title: const Text("My Chats", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimary),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "You have no active chats.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final chatRooms = snapshot.data!;

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return _ChatListItem(chatRoomData: chatRoom);
            },
          );
        },
      ),
    );
  }
}

class _ChatListItem extends StatefulWidget {
  final Map<String, dynamic> chatRoomData;
  const _ChatListItem({required this.chatRoomData});

  @override
  State<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<_ChatListItem> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String otherUserId = '';
  Map<String, dynamic>? otherUser;

  @override
  void initState() {
    super.initState();
    final List<dynamic> users = widget.chatRoomData['users'];
    otherUserId = users.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isNotEmpty) {
      _fetchOtherUserData();
    }
  }

  Future<void> _fetchOtherUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();
      if (mounted && doc.exists) {
        setState(() => otherUser = doc.data());
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final difference = now.difference(dt);

    if (difference.inDays == 0 && now.day == dt.day) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1 ||
        (difference.inHours < 48 && now.day != dt.day)) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (otherUser == null) {
      return const ListTile(
        leading: CircleAvatar(radius: 28, child: SizedBox()),
        title: Text("Loading..."),
      );
    }

    final String name = otherUser?['name'] ?? 'User';
    final String photoUrl = otherUser?['photoUrl'] ?? '';
    final String lastMessage = widget.chatRoomData['lastMessage'] ?? '';
    final String itemContext = widget.chatRoomData['itemContext'] ?? '';
    final Timestamp? timestamp = widget.chatRoomData['lastMessageTimestamp'];
    final time = timestamp != null ? _formatTimestamp(timestamp) : '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatPage(receiverId: otherUserId, itemContext: itemContext),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 28, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
