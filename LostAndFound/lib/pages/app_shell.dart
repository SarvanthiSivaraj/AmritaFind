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

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final selected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              padding: selected
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                  : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFDE8EF) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? const Color(0xFFBE1250) : Colors.grey,
                size: selected ? 22 : 20,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 260),
              style: TextStyle(
                fontSize: 12,
                color: selected ? const Color(0xFFBE1250) : Colors.grey,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      // CUSTOM BOTTOM NAV
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildNavItem(icon: Icons.home, label: '', index: 0),
                  _buildNavItem(icon: Icons.support_agent,label: '', index: 1),

                  // center item keeps same size, but styled like others
                  _buildNavItem(icon: Icons.chat_bubble, label: '', index: 2),

                  _buildNavItem(icon: Icons.person, label: '', index: 3),
                ],
              ),
              const SizedBox(height: 8),
              // small center handle / indicator
              Center(
                child: Container(
                  width: 120,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
