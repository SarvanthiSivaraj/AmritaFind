import 'package:flutter/material.dart';
import 'package:lostandfound/pages/home_page.dart';
import 'package:lostandfound/pages/chat_bot_page.dart';
import 'package:lostandfound/pages/chat_list_page.dart';
import 'package:lostandfound/pages/profile_page.dart';
import 'package:lostandfound/pages/login_page.dart' as login;
import 'package:lostandfound/pages/onboarding_screen.dart';
import 'package:lostandfound/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kNavPrimary = Color(0xFFBE1250);
const Color kNavBg = Colors.white;

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
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => OnboardingScreen()));
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

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool selected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? kNavPrimary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            scale: selected ? 1.15 : 1.0,
            child: Icon(
              icon,
              size: 22,
              color: selected ? kNavPrimary : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      // CUSTOM BOTTOM NAV
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          height: 72,
          decoration: BoxDecoration(
            color: kNavBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(icon: Icons.home_rounded, index: 0),
              _buildNavItem(icon: Icons.support_agent_rounded, index: 1),
              _buildNavItem(icon: Icons.chat_bubble_rounded, index: 2),
              _buildNavItem(icon: Icons.person_rounded, index: 3),
            ],
          ),
        ),
      ),
    );
  }
}
