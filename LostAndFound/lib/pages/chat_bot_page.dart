import 'package:flutter/material.dart';
import 'dart:async';
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
  // AI Service for the backend, initialized in initState.
  late final AiService _aiService;

  @override
  void initState() {
    super.initState();
    // Initialize the AiService to call Google Gemini directly.
    // The API key is loaded from the .env file.
    _aiService = AiService(
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      model: 'gemini-2.5-flash',
    );
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

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessageText = _controller.text.trim();
    final message = ChatMessage(
      isUser: true,
      text: userMessageText,
      time: DateTime.now(),
    );

    setState(() {
      // Add user message and a temporary typing indicator
      _messages.add(message);
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

    // Get bot response from our backend proxy
    try {
      // Add a check for the API key before making the call
      if (_aiService.apiKey.isEmpty) {
        throw Exception(
          'API Key is missing. Is GEMINI_API_KEY set in your .env file?',
        );
      }

      // Construct the full prompt with system instructions for the chatbot.
      const systemPrompt =
          'You are the LostAndFound assistant for a university lost-and-found app. '
          'Only respond with helpful, concise information related to lost and found items, reports, locations, and recovery steps for this app. '
          'Do NOT provide unrelated information, personal opinions, or external links. Keep style consistent with short helpful messages.';

      final fullPrompt = '$systemPrompt\n\nUser: $userMessageText\nAssistant:';

      final botResponse = await _aiService.sendMessage(fullPrompt);
      if (mounted) {
        setState(() {
          // Remove typing indicator and add bot's response
          _messages.removeWhere((m) => m.isTyping);
          _messages.add(
            ChatMessage(isUser: false, text: botResponse, time: DateTime.now()),
          );
        });
      }
    } catch (e, s) {
      // Log the full error and stack trace to the debug console for more details.
      print('--- ERROR SENDING MESSAGE ---');
      print('Exception: $e');
      print('Stack Trace: $s');
      print('-----------------------------');

      if (mounted) {
        // Display the specific error message in the chat UI for better debugging.
        String displayError = e.toString();
        // Clean up the exception text for better readability in the UI.
        if (displayError.startsWith('Exception: ')) {
          displayError = displayError.substring('Exception: '.length);
        }
        // Provide a more helpful message for Gemini API errors.
        if (displayError.contains('Status: 400')) {
          displayError =
              'Bad request (400). Please check your GEMINI_API_KEY. It might be invalid or missing billing information on your Google Cloud account.';
        } else if (displayError.contains('Status: 404')) {
          displayError =
              'Model not found (404). Ensure the model name is correct and the "Generative Language API" is enabled in your Google Cloud project.';
        } else if (displayError.contains('Status: 429')) {
          displayError =
              'Too many requests (429). You have exceeded your API quota. Please wait and try again later, or check your Google Cloud billing status.';
        }

        setState(() {
          // Remove typing indicator and show an error message
          _messages.removeWhere((m) => m.isTyping);
          _messages.add(
            ChatMessage(
              isUser: false,
              text: 'Error: $displayError',
              time: DateTime.now(),
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
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
      body: Padding(
        // This padding pushes the entire body up to avoid the main app's
        // floating navigation bar.
        // Calculation:
        // 72px (nav bar container height)
        // 14px (nav bar bottom padding from AppShell)
        // 18px (FAB overhang from nav bar)
        //  8px (extra visual gap for better UI)
        // ---
        // 112px total padding needed.
        padding: const EdgeInsets.only(bottom: 112),
        child: Column(
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
                                      ? const Color(0xFFBF0C4F)
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
                                backgroundColor: Color(0xFFBF0C4F),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                        maxHeight: 160, // ❗ TextField can grow up to 6–7 lines
                      ),
                      child: Container(
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
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: 6, // ❗ Multiline enabled and visible
                          decoration: InputDecoration(
                            hintText: 'Ask about a lost item...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
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
                        color: const Color(0xFFBF0C4F),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBF0C4F).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
