import 'package:flutter/material.dart';
import 'pages/feed_page.dart';
import 'pages/chat_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/profile_page.dart';
import 'pages/add_post_page.dart';

void main() {
  runApp(LostFoundApp());
}

class LostFoundApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Lost & Found - Amrita",
      theme: ThemeData(
        fontFamily: "Poppins",
        primaryColor: Color(0xFF8C2F39),
        scaffoldBackgroundColor: Color(0xFFFDF8F5),
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final pages = [FeedPage(), ChatPage(), ChatBotPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF8C2F39),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPostPage()),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Color(0xFF8C2F39),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: "Assistant",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
