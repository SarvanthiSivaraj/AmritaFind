import 'package:flutter/material.dart';
import 'home_page.dart';

/// ================= CHAT =================

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    _messageController.clear();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? kBackgroundDark : const Color(0xFFF8F6F6);
    final textMain = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final chipBg = kPrimaryChat.withOpacity(isDark ? 0.2 : 0.1);

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
                Container(
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
                            _Avatar(
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBBhokeDf4bff8-o7oVREbCQ-PC5iLsl4so6QJoMRghyWH8r3MpYJvDYY1C8L0UQ2XQyZMRkcZGV1S-whB69sJ-wF88d8PbpbcGSrcrqJvz4fXIEj8Z1NC7jrBjbIBNCRGsDPHZwNl8JPSNKBQaw58dsNEHcnylRb-Oz-QpQ2vGPWQVLC9QlucMRlxKt0R0ACVjwfzv1hrtpDiyYi3PsExmFTCHbSSIIqLWQ5lWTNCMuVqcbbkDm_y0sAbwYQlMsf3alZ4O12XcbHsm',
                              size: 40,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Aditya Sharma',
                                style: TextStyle(
                                  color: textMain,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
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
                                'Regarding: Blue Water Bottle',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.pink[50]
                                      : kPrimaryChat,
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
                ),

                // Chat body
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 12),

                        _ReceivedMessage(
                          name: 'Aditya Sharma',
                          avatarUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuA4Z7MFBa5jnkVlE2332ROrKY_dAtiN-gQwljNGVj37llgAfCKx3nYuNYNFgwGmtQZ9JnK20sVITBS4cGnqV8qxNf9rZdV6FBabCj0K6vA21nYEskIZSD-DA5nqZr7EXLwn7-TcYVBWom7fVk-0wfDF9o3kvoayZgVusmBjTv_pJYWysUDzPnc9wqncAMNV9zWXhLyJ5f7F2DwmsdybJHScRygfEo1eCtbtF4tUcdzT-rXy7mcIazcR9AQCv94-re15x6glsWkfqXkD',
                          message:
                              'Hey, I think I found your water bottle near the library. Is it a blue Milton one?',
                        ),

                        const SizedBox(height: 8),
                        const _SentMessage(
                          label: 'You',
                          message:
                              'Oh wow, yes! That\'s mine. Thank you so much for finding it! When and where can I meet you to get it?',
                        ),

                        const SizedBox(height: 8),
                        _ReceivedMessage(
                          name: 'Aditya Sharma',
                          avatarUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBcShYAA5EODr596-jsBcwHk1R5owr32QTLs4A4OcSeCglxG-kRNc-Xw6i4lDw2F8yVCtvGmAbSnH-jfFI_ABuFLdg5yXVljeSNYn6EE3vTqlfPr0XFHnN22Bi2d5NctTBVmFNcQgGL90CPIYT7QFYiS6eK0GeEss7w9p0DsHOOQomzn2onJk8F6E8ojR5Ao8unkoP5xmQG8ff2sMWw2X-iq8rPVmju75Ru56sD-0e1NfIkImvNVh-vH6vxtlS92UxQBoMk_0echMys',
                          message:
                              'No problem! I can meet you at the central library entrance in about 15 minutes. Does that work for you?',
                          showName: false,
                        ),

                        const SizedBox(height: 8),
                        const _SentMessage(
                          message:
                              'Perfect! See you there. I\'m wearing a green t-shirt.',
                          showLabel: false,
                        ),
                      ],
                    ),
                  ),
                ),

                // Composer
                Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: textSecondary),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF27272F)
                                : const Color(0xFFE4E4E7),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF3F3F46)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF3F3F46)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: kPrimaryChat),
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _Avatar({required this.imageUrl, this.size = 40, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ReceivedMessage extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String message;
  final bool showName;

  const _ReceivedMessage({
    required this.name,
    required this.avatarUrl,
    required this.message,
    this.showName = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final bubbleBg = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E5E5);
    final bubbleText = isDark ? Colors.white : const Color(0xFF18181B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Avatar(imageUrl: avatarUrl, size: 40),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showName)
                Text(
                  name,
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              if (showName) const SizedBox(height: 4),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SentMessage extends StatelessWidget {
  final String message;
  final String label;
  final bool showLabel;

  const _SentMessage({
    required this.message,
    this.label = 'You',
    this.showLabel = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[500]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showLabel)
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              if (showLabel) const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxWidth: 260),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
