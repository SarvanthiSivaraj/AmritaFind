import 'package:flutter/material.dart';
import 'post_item_form_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';

/// COLORS SHARED
const Color kPrimary = Color(0xFF8C2F39);
const Color kPrimaryChat = Color(0xFF8D303B);
const Color kBackgroundLight = Color(0xFFFAF9F6);
const Color kBackgroundDark = Color(0xFF1E1415);

/// ================= HOME FEED =================

class HomePageFeed extends StatelessWidget {
  const HomePageFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardLight = const Color(0xFFFFFFFF);
    final cardDark = const Color(0xFF2A2122);
    final textPrimaryLight = const Color(0xFF333333);
    final textPrimaryDark = const Color(0xFFF2F2F2);
    final textSecondaryLight = const Color(0xFF757575);
    final textSecondaryDark = const Color(0xFFA09C9C);
    final chipLight = const Color(0xFFF0EBEA);
    final chipDark = const Color(0xFF3C3334);

    Color bgColor = isDark ? kBackgroundDark : kBackgroundLight;
    Color cardColor = isDark ? cardDark : cardLight;
    Color textPrimary = isDark ? textPrimaryDark : textPrimaryLight;
    Color textSecondary = isDark ? textSecondaryDark : textSecondaryLight;
    Color chipColor = isDark ? chipDark : chipLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.school, color: kPrimary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Lost & Found',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.person, color: kPrimary, size: 28),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PostItemFormPage()));
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search for 'water bottle', 'ID card'...",
                        hintStyle: TextStyle(color: textSecondary),
                      ),
                      style: TextStyle(color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: true,
                  primary: kPrimary,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                ),
                _FilterChip(
                  label: 'Lost',
                  selected: false,
                  primary: kPrimary,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                ),
                _FilterChip(
                  label: 'Found',
                  selected: false,
                  primary: kPrimary,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                ),
                _FilterChip.withIcon(
                  label: 'Location',
                  icon: Icons.expand_more,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                ),
                _FilterChip.withIcon(
                  label: 'Date',
                  icon: Icons.expand_more,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Cards (tap to open ChatPage)
          _ItemCard(
            title: 'Blue Water Bottle',
            statusText: 'FOUND',
            statusColorBg: Colors.green.shade100,
            statusColorText: Colors.green.shade700,
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCtbHje8XodJ39bsiJP6sMe2OeIbG6fmqzgVsRg4wEUEbBCPtUdhiSvBfXZhJ90t5TM-QRwL8gXByAzWBI2hQ6x8-1Zw4yXyAmuszB6qHJEk86dEP1i7aGkUEByY1VrNwa6ii-TTfsae8hM1cYteBVfPOZvRU6E5XsfwsZDH7zUYOlTpl1UTTtYR2BSKHK1MeWCHILoZN82kv54uCMNtZho7I36C2Cx8KhebJTq7s1_IksNaAf_QZ-Tx6T4Z_aso0w8P-5WbR5l5BhU',
            location: 'Found near AB1 entrance',
            time: 'Oct 26, 2:30 PM',
            buttonText: 'Chat with Finder',
            cardColor: cardColor,
            primary: kPrimary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onChatPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ChatPage()));
            },
          ),
          _ItemCard(
            title: 'Dell Laptop Charger',
            statusText: 'LOST',
            statusColorBg: Colors.red.shade100,
            statusColorText: Colors.red.shade700,
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBGnfrW4cBlo8roobNYq-sMBBuokYQtremQ7vhgJq3sQFz0oTIOLAzMDVVhWBYl3YFjv6E312WZ5yUwNngMJ98dLImIkVnyRGZoPBqjttj8oa_1Gk79t6RqjUOYozet2p3v1ekVmPFEpTd1XL289YyUjIJOUudbFQ0oTuzwNar41JP2jZRwTH2xAS8KSaG4TokgfzvsNlzpi76JwSCgpUNeuNWWJrYBVY2rez6qnFGBNG97RxuHM6xDnM-uzc3f89YnDahLUBkv_at4',
            location: 'Lost in Central Library, 3rd floor',
            time: 'Oct 26, 11:00 AM',
            buttonText: 'Chat with Owner',
            cardColor: cardColor,
            primary: kPrimary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onChatPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ChatPage()));
            },
          ),
          _ItemCard(
            title: 'Student ID Card',
            statusText: 'FOUND',
            statusColorBg: Colors.green.shade100,
            statusColorText: Colors.green.shade700,
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC0S-lgRPy0ijtWZ0y_9b5vmCRuvkqp3tIp0cgcuPMyEuJelS3XLpFp04jp5tY7oeGIaCV9EnKUFnFROziFrxUtXpWQ7rDlRz74BPU44RGjXEFeh5z4_exEuFUoevnZZ6I7MXgSDxOVfj-8HMAF3n3VaNEX1Ig_kf4aBT00e0lyMSSg4zfOeG1WNGyDHen3L_WslRUtlHPVrWx6Z5UN9NKTW55dabkTjPXrIP2VStSYxiFKvacxEl6u1nAmhSmeu-oIyy8JLkhZsgVP',
            location: 'Found in college main auditorium',
            time: 'Oct 25, 5:00 PM',
            buttonText: 'Chat with Finder',
            cardColor: cardColor,
            primary: kPrimary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onChatPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ChatPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final Color chipColor;
  final Color textPrimary;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.chipColor,
    required this.textPrimary,
    this.icon,
  });

  const _FilterChip.withIcon({
    required this.label,
    required this.chipColor,
    required this.textPrimary,
    required IconData this.icon,
  }) : selected = false,
       primary = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? primary : chipColor;
    final textColor = selected ? Colors.white : textPrimary;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, color: textColor, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusColorBg;
  final Color statusColorText;
  final String imageUrl;
  final String location;
  final String time;
  final String buttonText;
  final Color cardColor;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onChatPressed;

  const _ItemCard({
    required this.title,
    required this.statusText,
    required this.statusColorBg,
    required this.statusColorText,
    required this.imageUrl,
    required this.location,
    required this.time,
    required this.buttonText,
    required this.cardColor,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.onChatPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColorBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColorText,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onChatPressed,
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
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
}
