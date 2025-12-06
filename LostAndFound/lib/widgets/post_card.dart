import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onChat;
  final VoidCallback? onContact;

  const PostCard({
    required this.post,
    required this.onChat,
    this.onContact,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF8C2F39),
              child: Text(
                post.userName[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              post.userName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(timeAgo(post.createdAt)),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: post.category == "Lost"
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.category,
                style: TextStyle(
                  color: post.category == "Lost" ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Container(
            height: 160,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFF5EDE8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag, size: 70, color: Color(0xFF8C2F39)),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.itemType,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C2F39),
                  ),
                ),
                SizedBox(height: 6),
                Text(post.description, style: TextStyle(color: Colors.black87)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF8C2F39)),
                    SizedBox(width: 6),
                    Text(post.location),
                  ],
                ),
              ],
            ),
          ),

          Row(
            children: [
              if (post.contactNumber != null)
                Expanded(
                  child: TextButton.icon(
                    onPressed: onContact,
                    icon: Icon(Icons.phone, color: Colors.black87),
                    label: Text(
                      "Contact",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onChat,
                  icon: Icon(Icons.chat, color: Colors.white),
                  label: Text("Chat", style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF8C2F39),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
}
