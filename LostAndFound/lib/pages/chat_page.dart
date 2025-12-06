import 'package:flutter/material.dart';

class Chat {
  final String id;
  final String otherName;
  final List<Message> messages;

  Chat({required this.id, required this.otherName, required this.messages});
}

class Message {
  final String content;
  final bool isMe;
  final DateTime time;

  Message({required this.content, required this.isMe, required this.time});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Chat> chats = [];

  @override
  void initState() {
    super.initState();
    _loadDummyChats();
  }

  void _loadDummyChats() {
    chats = [
      Chat(
        id: "1",
        otherName: "Rahul",
        messages: [
          Message(
            content: "Hi, is this your wallet?",
            isMe: false,
            time: DateTime.now().subtract(Duration(minutes: 20)),
          ),
          Message(
            content: "Yes! Where can I collect it?",
            isMe: true,
            time: DateTime.now().subtract(Duration(minutes: 18)),
          ),
        ],
      ),
      Chat(
        id: "2",
        otherName: "Anita",
        messages: [
          Message(
            content: "I found an ID card with your name.",
            isMe: false,
            time: DateTime.now().subtract(Duration(hours: 2)),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Your Chats",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8C2F39),
              ),
            ),
          ),
          Expanded(
            child: chats.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final last = chat.messages.isNotEmpty
                          ? chat.messages.last
                          : null;
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(chat: chat),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Color(0xFFFDF8F5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFF8C2F39),
                                child: Text(
                                  chat.otherName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chat.otherName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      last?.content ?? "No messages yet",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.chat_bubble_outline, size: 60, color: Color(0xFFF5EDE8)),
            SizedBox(height: 16),
            Text(
              "No conversations yet",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              "Start chatting with item owners or finders!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final Chat chat;

  const ChatDetailPage({required this.chat, super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      widget.chat.messages.add(
        Message(content: text, isMe: true, time: DateTime.now()),
      );
    });
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF8C2F39);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: maroon,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                widget.chat.otherName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.chat.otherName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Color(0xFFFDF8F5),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.chat.messages.length,
                itemBuilder: (context, index) {
                  final msg = widget.chat.messages[index];
                  return Align(
                    alignment: msg.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isMe ? maroon : Colors.white,
                        borderRadius: BorderRadius.circular(18).copyWith(
                          bottomRight: msg.isMe
                              ? Radius.circular(4)
                              : Radius.circular(18),
                          bottomLeft: msg.isMe
                              ? Radius.circular(18)
                              : Radius.circular(4),
                        ),
                        boxShadow: [
                          if (!msg.isMe)
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(
                          color: msg.isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF5EDE8))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Color(0xFFF5EDE8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: maroon),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: maroon,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
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
