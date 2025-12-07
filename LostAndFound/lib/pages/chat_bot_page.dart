import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const ChatbotApp());

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Support',
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        primaryColor: const Color(0xFF8C2F39),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C2F39)),
        useMaterial3: true,
      ),
      home: const ChatbotScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      isUser: false,
      text:
          "Hi! I'm here to help you find lost items. What are you looking for?",
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      isUser: true,
      text: "Was a black wallet found?",
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      isUser: false,
      text: "Let me check...",
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      isTyping: true,
    ),
    ChatMessage(
      isUser: false,
      text:
          "I found one item matching \"black wallet\". It was reported near the main library. Would you like to see the details?",
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      isUser: true,
      text: "Yes, please.",
      time: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final message = ChatMessage(
      isUser: true,
      text: _controller.text.trim(),
      time: DateTime.now(),
    );

    setState(() {
      _messages.removeWhere((m) => m.isTyping);
      _messages.add(message);
      _isTyping = true;
      _messages.add(
        ChatMessage(
          isUser: false,
          text: "Typing...",
          time: DateTime.now(),
          isTyping: true,
        ),
      );
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate bot response
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.isTyping);
          _messages.add(
            ChatMessage(
              isUser: false,
              text:
                  "Thanks for your message! Let me check our lost and found database.",
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chatbot Support',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!message.isUser) ...[
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: const NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuB1NkyUIDsLii5S5S3naRGIud_2aPn7iBKf68hr_dGvX8-ADlN-6TmAclfVTwEpTMK5LdC9u-s2TSRqTMkJ6wclgzbasLsPJz2YXnRVJ1iNIiZc6FXx68YzYcFDMGEQrJrMh-4XkYIaN-MmOyPUMLb4gTBu1x0a1A7XZxlrZTah-CBc0DUBygzc9_vRXejE_KoULVgYGHDQEpl9zueR6DQkicBj6iOlWx8uA4Ywyq1tmaGGKEAYPzM6JF29XHOrqgSYJBgZNnKDEQhq',
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: message.isUser
                                    ? const Color(0xFF8C2F39)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: message.isUser
                                      ? const Radius.circular(20)
                                      : const Radius.circular(4),
                                  bottomRight: message.isUser
                                      ? const Radius.circular(4)
                                      : const Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: message.isUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!message.isUser)
                                    Text(
                                      'Help Assistant',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      color: message.isUser
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (!message.isTyping) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(message.time),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: message.isUser
                                            ? Colors.white70
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (message.isUser) ...[
                            const SizedBox(width: 12),
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFF8C2F39),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input Area
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask about a lost item...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C2F39),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8C2F39).withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inMinutes < 1) return 'Just now';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final bool isUser;
  final String text;
  final DateTime time;
  final bool isTyping;

  ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.isTyping = false,
  });
}
