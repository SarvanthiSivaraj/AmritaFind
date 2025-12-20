import 'package:flutter/material.dart';
import 'package:lostandfound/pages/home_page.dart';
import 'package:lostandfound/pages/chat_bot_page.dart';
import 'package:lostandfound/pages/chat_list_page.dart';
import 'package:lostandfound/pages/profile_page.dart';
import 'package:lostandfound/pages/login_page.dart' as login;
import 'package:lostandfound/pages/onboarding_screen.dart';
import 'package:lostandfound/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePageFeed(),
    ChatbotScreen(),
    ChatListPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _maybeShowOnboardingOnFirstLaunch();
  }

  Future<void> _maybeShowOnboardingOnFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getBool('onboarding_shown_on_launch') ?? false;
      if (!shown) {
        await prefs.setBool('onboarding_shown_on_launch', true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnboardingScreen()));
        });
      }
    } catch (_) {
      // ignore
    }
  }

  void _onTap(int index) async {
    // Chats (2) and Profile (3) require login
    if ((index == 2 || index == 3) && !AuthService.isLoggedIn) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const login.LoginScreen()),
      );
      if (ok != true) return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFFBF0C4F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        onTap: _onTap,
      ),
    );
  }
}
