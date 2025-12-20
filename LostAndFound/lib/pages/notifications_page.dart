import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';

const Color kPrimary = Color(0xFFBE1250);
const Color kPrimaryDark = Color(0xFF8F0D3B);
const Color kPrimaryLight = Color(0xFFFDE8EF);
const Color kBackgroundLight = Color(0xFFF9FAFB);
const Color kSurfaceLight = Colors.white;
const Color kTextMain = Color(0xFF1F2937);
const Color kTextMuted = Color(0xFF6B7280);

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<void> _onNotificationTapped(
    BuildContext context,
    DocumentSnapshot notificationDoc,
  ) async {
    final data = notificationDoc.data() as Map<String, dynamic>;

    // Mark as read in Firestore
    if (data['isRead'] == false) {
      await notificationDoc.reference.update({'isRead': true});
    }

    // Fetch the found item's data to show it
    final foundItemId = data['foundItemId'];
    final foundItemDoc = await FirebaseFirestore.instance
        .collection('found_items')
        .doc(foundItemId)
        .get();

    if (!foundItemDoc.exists || !context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "The matched item could not be found. It may have been deleted.",
          ),
        ),
      );
      return;
    }

    final foundData = foundItemDoc.data()!;
    final posterUid = foundData['uid'] as String?;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final canChat = posterUid != null && posterUid != currentUserId;

    // Show a custom dialog that matches the desired UI
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: kPrimary,
                          size: 30,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Matched Item Found",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Is this the item you lost?",
                    style: TextStyle(color: kTextMuted),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foundData['item_name'] ?? 'No name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                foundData['description'] ?? '',
                                style: const TextStyle(color: kTextMuted),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                foundData['location'] ?? 'Unknown location',
                                style: const TextStyle(
                                  color: kPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: canChat
                        ? () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  receiverId: posterUid!,
                                  itemContext:
                                      "Regarding: ${foundData['item_name'] ?? 'Item'}",
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text(
                      "Chat with Finder",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifications")),
        body: const Center(child: Text("Please log in to see notifications.")),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundLight,

      // HEADER
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        
      ),

      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: user.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No notifications yet."));
              }

              final notifications = snapshot.data!.docs;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Today",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ...notifications.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isRead = data['isRead'] ?? false;
                    // compute simple time label
                    String timeLabel = '';
                    final ts = data['timestamp'];
                    if (ts is Timestamp) {
                      final diff = DateTime.now().difference(ts.toDate());
                      if (diff.inMinutes < 60) {
                        timeLabel = '${diff.inMinutes} min ago';
                      } else if (diff.inHours < 24) {
                        timeLabel = '${diff.inHours} hrs ago';
                      } else {
                        timeLabel = '${diff.inDays} days ago';
                      }
                    } else {
                      timeLabel = data['time'] ?? '';
                    }

                    return _notificationCard(
                      unread: !isRead,
                      icon: isRead ? Icons.notifications_off_outlined : Icons.notifications_active,
                      title: data['title'] ?? 'Notification',
                      body: data['body'] ?? '',
                      time: timeLabel,
                      onTap: () => _onNotificationTapped(context, doc),
                    );
                  }).toList(),

                  const SizedBox(height: 120),
                ],
              );
            },
          ),
        ],
      ),

      
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required String title,
    required String body,
    required String time,
    required VoidCallback onTap,
    bool unread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (unread)
            Container(
              width: 4,
              height: 70,
              decoration: const BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(8),
                ),
              ),
            ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSurfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: unread ? kPrimaryLight : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: kPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
