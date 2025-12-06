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
        primaryColor: const Color(0xFF8C2F39),
        scaffoldBackgroundColor: const Color(0xFFFDF8F5),
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
    const maroon = Color(0xFF8C2F39);

    // show FAB only on Home/Feed
    final bool showFab = currentIndex == 0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: maroon,
          elevation: 6,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Lost & Found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Amrita Campus",
                    style: TextStyle(color: Color(0xFFF2D6D8), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: pages[currentIndex],

      // Only provide FAB when showFab is true
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showFab
          ? SizedBox(
              height: 48,
              width: 48,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddPostPage()),
                  );
                },
                backgroundColor: maroon,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            )
          : null,

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        // only show notch when FAB is present
        shape: showFab ? const CircularNotchedRectangle() : null,
        notchMargin: showFab ? 8 : 0,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home,
                        color: currentIndex == 0 ? maroon : Colors.grey,
                      ),
                      onPressed: () => setState(() => currentIndex = 0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chat,
                        color: currentIndex == 1 ? maroon : Colors.grey,
                      ),
                      onPressed: () => setState(() => currentIndex = 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.smart_toy,
                        color: currentIndex == 2 ? maroon : Colors.grey,
                      ),
                      onPressed: () => setState(() => currentIndex = 2),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person,
                        color: currentIndex == 3 ? maroon : Colors.grey,
                      ),
                      onPressed: () => setState(() => currentIndex = 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
