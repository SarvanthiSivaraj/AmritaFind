import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'message.dart'; // Corrected import path
import 'package:lostandfound/services/chat_service.dart';

const Color kPrimaryChat = Color(0xFF8D303B);

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String itemContext;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.itemContext,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _receiverName = 'Loading...';
  String _receiverAvatarUrl = '';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchReceiverProfile();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchReceiverProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.receiverId)
          .get();
      if (mounted && doc.exists) {
        setState(() {
          _receiverName = doc.data()?['name'] ?? 'User';
          _receiverAvatarUrl = doc.data()?['photoUrl'] ?? '';
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(
        widget.receiverId,
        _messageController.text.trim(),
        widget.itemContext,
      );
      _messageController.clear();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF8F6F6);
    final textMain = Colors.black87;
    final chipBg = kPrimaryChat.withOpacity(0.1);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: bg,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top App Bar
                _buildAppBar(bg, textMain, chipBg),

                // Chat body
                Expanded(child: _buildMessageList()),

                // Composer
                _buildComposer(bg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(Color bg, Color textMain, Color chipBg) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg.withOpacity(0.95),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: 4,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 22,
                    color: textMain,
                  ),
                ),
                _isLoadingProfile
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      )
                    : _Avatar(imageUrl: _receiverAvatarUrl, size: 40),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _receiverName,
                    style: TextStyle(
                      color: textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.itemContext,
                    style: const TextStyle(
                      color: kPrimaryChat,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Message>>(
      stream: _chatService.getMessages(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Something went wrong...'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Say hello!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              _buildMessageItem(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildMessageItem(Message message) {
    final bool isCurrentUser = message.senderId == _auth.currentUser!.uid;
    return isCurrentUser
        ? _SentMessage(message: message.message)
        : _ReceivedMessage(
            name: _receiverName,
            avatarUrl: _receiverAvatarUrl,
            message: message.message,
          );
  }

  Widget _buildComposer(Color bg) {
    final textSecondary = Colors.grey[500]!;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: const Color(0xFFE4E4E7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: kPrimaryChat),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            width: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryChat,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              onPressed: _sendMessage,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _Avatar({required this.imageUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.person, size: size, color: Colors.grey),
            )
          : Icon(Icons.person, size: size, color: Colors.grey),
    );
  }
}

class _ReceivedMessage extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String message;

  const _ReceivedMessage({
    required this.name,
    required this.avatarUrl,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleBg = const Color(0xFFE5E5E5);
    final bubbleText = const Color(0xFF18181B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Avatar(imageUrl: avatarUrl, size: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 260),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(color: bubbleText, fontSize: 15),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SentMessage extends StatelessWidget {
  final String message;

  const _SentMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: kPrimaryChat,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
