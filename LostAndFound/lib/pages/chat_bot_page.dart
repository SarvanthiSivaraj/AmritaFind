import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lostandfound/services/ai_service.dart';

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
          "Hi! I'm the AmritaFind assistant. How can I help you with lost and found items today?",
      time: DateTime.now(),
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final AiService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = AiService(
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      model: 'gemini-2.5-flash',
    );
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

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(
        isUser: true,
        text: userText,
        time: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        isUser: false,
        text: '',
        time: DateTime.now(),
        isTyping: true,
      ));
    });

    _scrollToBottom();

    try {
      const systemPrompt =
          'You are the LostAndFound assistant for a university lost-and-found app. '
          'Respond concisely and helpfully only about lost and found items.';

      final response =
          await _aiService.sendMessage('$systemPrompt\nUser: $userText');

      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(ChatMessage(
          isUser: false,
          text: response,
          time: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(ChatMessage(
          isUser: false,
          text: 'Error: ${e.toString()}',
          time: DateTime.now(),
        ));
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
  elevation: 2,
  shadowColor: Colors.black12,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
  ),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFBF0C4F), size: 20),
    onPressed: () => Navigator.pop(context),
  ),
  titleSpacing: 0,
  title: Row(
    children: [
      const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFBF0C4F),
        child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 10),
      // THIS WIDGET FIXES THE OVERFLOW
      Expanded( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Keeps column compact
          children: const [
            Text(
              'AmritaFind Assistant',
              overflow: TextOverflow.ellipsis, // Adds '...' if name is too long
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Online',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
  
),
      body: Column(
        children: [
          // CHAT LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                if (message.isTyping) return const SizedBox.shrink();

                return _ChatBubble(message: message);
              },
            ),
          ),

          // TYPING INDICATOR (ALWAYS ABOVE INPUT)
          if (_messages.any((m) => m.isTyping))
            const _AssistantTypingIndicator(),

          // INPUT BAR (ALWAYS VISIBLE)
          _ChatInputBar(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

////////////////////////////////////////////////////////////
/// MODELS
////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////
/// CHAT BUBBLE
////////////////////////////////////////////////////////////

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFFBF0C4F)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// INPUT BAR
////////////////////////////////////////////////////////////

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F6F6),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Ask about a lost item...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFBF0C4F),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ASSISTANT TYPING INDICATOR
////////////////////////////////////////////////////////////

class _AssistantTypingIndicator extends StatelessWidget {
  const _AssistantTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFBF0C4F),
            child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final dots = (_controller.value * 3).floor() + 1;
        return Text(
          'Typing${'.' * dots}',
          style: const TextStyle(color: Colors.grey),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
