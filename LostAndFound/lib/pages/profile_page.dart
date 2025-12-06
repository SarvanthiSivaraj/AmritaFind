import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF8C2F39);

    final int postsCount = 0;
    final int foundCount = 0;
    final int lostCount = 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [maroon, Color(0xFFA64D55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.person, size: 46, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "Guest User",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "guest@amrita.edu",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statCard("Posts", postsCount.toString()),
                const SizedBox(width: 24),
                _statCard("Found", foundCount.toString()),
                const SizedBox(width: 24),
                _statCard("Lost", lostCount.toString()),
              ],
            ),
            const SizedBox(height: 32),

            // Actions
            Column(
              children: [
                _profileButton(
                  icon: Icons.settings,
                  label: "Settings",
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _profileButton(
                  icon: Icons.notifications,
                  label: "Notifications",
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _profileButton(
                  icon: Icons.info_outline,
                  label: "About App",
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8C2F39),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _profileButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF8C2F39)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF555555)),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
