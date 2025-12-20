import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';

const Color kPrimary = Color(0xFFBF0C4F);

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

    // Show a dialog with the found item's details
    showDialog(
      context: context,
      builder: (context) {
        final foundData = foundItemDoc.data()!;
        final posterUid = foundData['uid'] as String?;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final canChat = posterUid != null && posterUid != currentUserId;

        return AlertDialog(
          title: const Text("Matched Item Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  foundData['item_name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(foundData['description'] ?? 'No description.'),
                const SizedBox(height: 8),
                Text("Location: ${foundData['location'] ?? 'N/A'}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
            if (canChat)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        receiverId: posterUid!,
                        itemContext:
                            "Regarding: ${foundData['item_name'] ?? 'Item'}",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Chat with Poster",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
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
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: kPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool isRead = data['isRead'] ?? false;

              return ListTile(
                tileColor: isRead ? null : kPrimary.withOpacity(0.08),
                leading: Icon(
                  isRead
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active,
                  color: kPrimary,
                ),
                title: Text(
                  data['title'] ?? 'Notification',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data['body'] ?? ''),
                onTap: () => _onNotificationTapped(context, doc),
              );
            },
          );
        },
      ),
    );
  }
}
