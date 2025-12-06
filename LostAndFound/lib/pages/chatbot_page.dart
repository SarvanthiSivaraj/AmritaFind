import 'package:flutter/material.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<_BotMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hello! I'm FindBot, your campus assistant.\n\n"
      "I can help you search for lost or found items.\n"
      "Try asking:\n"
      "• Was a wallet found?\n"
      "• Any lost ID cards?\n"
      "• Show AB1 posts\n"
      "• Recent items",
    );
  }

  void _addBotMessage(String text) {
    _messages.add(_BotMessage(text: text, isBot: true));
  }

  void _addUserMessage(String text) {
    _messages.add(_BotMessage(text: text, isBot: false));
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _addUserMessage(text);
      _controller.clear();

      _addBotMessage(
        "You asked: \"$text\"\n\n"
        "(Hook this to your /api/chatbot endpoint later.)",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF8C2F39);

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: maroon,
            child: Row(
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.smart_toy, color: Colors.white),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FindBot Assistant",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Ask me about lost & found items",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFFDF8F5),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final align = msg.isBot
                      ? Alignment.centerLeft
                      : Alignment.centerRight;
                  final bg = msg.isBot
                      ? const LinearGradient(
                          colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                        )
                      : const LinearGradient(colors: [maroon, maroon]);
                  return Align(
                    alignment: align,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        gradient: bg,
                        borderRadius: BorderRadius.circular(18).copyWith(
                          bottomLeft: msg.isBot
                              ? const Radius.circular(4)
                              : const Radius.circular(18),
                          bottomRight: msg.isBot
                              ? const Radius.circular(18)
                              : const Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF5EDE8))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about lost items...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFF5EDE8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: maroon),
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: maroon,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _handleSend,
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

class _BotMessage {
  final String text;
  final bool isBot;

  _BotMessage({required this.text, required this.isBot});
}
