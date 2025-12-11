import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';

const Color kPrimary = Color(0xFF8C2F39);
const Color kBackgroundLight = Color(0xFFFAF9F6);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
        _data = null;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      final profile = {
        "name": user.email?.split("@")[0] ?? "Student",
        "department": "CSE",
        "year": "1",
        "rollNumber": "00000",
        "contact": "",
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(profile);

      setState(() {
        _data = profile;
        _loading = false;
      });

      return;
    }

    setState(() {
      _data = doc.data();
      _loading = false;
    });
  }

  Future<void> _openEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: _data!["name"],
          department: _data!["department"],
          year: _data!["year"],
          roll: _data!["rollNumber"],
          contact: _data!["contact"],
        ),
      ),
    );

    if (result == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update(result);

    setState(() {
      _data!.addAll(result);
    });
  }

  /// -------------------------------
  /// LOAD USER POSTS (Lost + Found)
  /// -------------------------------
  Widget _buildMyPosts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final lostStream = FirebaseFirestore.instance
        .collection("lost_items")
        .where("userId", isEqualTo: uid)
        .snapshots();

    final foundStream = FirebaseFirestore.instance
        .collection("found_items")
        .where("userId", isEqualTo: uid)
        .snapshots();

    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip([lostStream, foundStream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: kPrimary),
          );
        }

        final lostDocs = snapshot.data![0].docs;
        final foundDocs = snapshot.data![1].docs;

        final allPosts = [...lostDocs, ...foundDocs];

        if (allPosts.isEmpty) {
          return const Text(
            "No posts yet.",
            style: TextStyle(fontSize: 16),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allPosts.length,
          itemBuilder: (context, i) {
            final doc = allPosts[i];
            final data = doc.data() as Map<String, dynamic>;

            final bool isLost = lostDocs.contains(doc);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: ListTile(
                title: Text(data["item_name"] ?? "Item"),
                subtitle: Text(isLost ? "Lost Item" : "Found Item"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection(isLost ? "lost_items" : "found_items")
                        .doc(doc.id)
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Post deleted")),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: kBackgroundLight,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimary,
          leading: BackButton(color: Colors.white),
          title:
              const Text("My Profile", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text("Please log in"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        leading: BackButton(color: Colors.white),
        title: const Text("My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _openEdit,
          )
        ],
      ),

      /// BODY
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),

            /// 🔹 BLANK AVATAR CIRCLE
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.shade100,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              _data!["name"],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Text("Department: ${_data!["department"]}"),
            Text("Year: ${_data!["year"]}"),
            Text("Roll Number: ${_data!["rollNumber"]}"),
            Text("Contact: ${_data!["contact"]}"),

            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade400),

            const SizedBox(height: 10),
            const Text(
              "My Posts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            _buildMyPosts(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////
///                EDIT PROFILE (NO AVATAR)
///////////////////////////////////////////////////////////////////////

class EditProfileScreen extends StatefulWidget {
  final String name, department, year, roll, contact;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.department,
    required this.year,
    required this.roll,
    required this.contact,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _name, _dept, _year, _roll, _contact;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _dept = TextEditingController(text: widget.department);
    _year = TextEditingController(text: widget.year);
    _roll = TextEditingController(text: widget.roll);
    _contact = TextEditingController(text: widget.contact);
  }

  void _save() {
    Navigator.pop(context, {
      "name": _name.text.trim(),
      "department": _dept.text.trim(),
      "year": _year.text.trim(),
      "rollNumber": _roll.text.trim(),
      "contact": _contact.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        leading: BackButton(color: Colors.white),
        title:
            const Text("Edit Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔹 SAME BLANK AVATAR
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.shade100,
              ),
            ),

            const SizedBox(height: 20),

            _field("Full Name", _name),
            _field("Department", _dept),
            _field("Year", _year),
            _field("Roll Number", _roll),
            _field("Contact", _contact),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                onPressed: _save,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
