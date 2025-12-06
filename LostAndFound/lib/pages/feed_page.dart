import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class FeedPage extends StatefulWidget {
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Post> posts = [];
  String category = "All";
  String location = "All";
  String search = "";

  @override
  void initState() {
    super.initState();
    loadSampleData();
  }

  void loadSampleData() {
    posts = [
      Post(
        id: "1",
        userName: "Rahul",
        category: "Lost",
        itemType: "Wallet",
        description: "Black leather wallet lost near AB1",
        location: "AB1",
        contactNumber: "9876543210",
        imageUrl: "",
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
      Post(
        id: "2",
        userName: "Anita",
        category: "Found",
        itemType: "ID Card",
        description: "Found ID card of someone named Kiran",
        location: "Library",
        imageUrl: "",
        contactNumber: null,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF8C2F39)),
                  border: InputBorder.none,
                  hintText: "Search items...",
                ),
                onChanged: (v) => setState(() => search = v),
              ),
            ),

            SizedBox(height: 14),

            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, i) {
                  return PostCard(
                    post: posts[i],
                    onChat: () {},
                    onContact: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Call: ${posts[i].contactNumber}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
