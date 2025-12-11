import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kPrimary = Color(0xFF8C2F39);
const Color kBackgroundLight = Color(0xFFFAF9F6);

// Default avatar for everyone
const String defaultAvatar =
    "https://i.postimg.cc/3R1V1V1t/default-avatar.png";

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
      // Default profile creation
      final map = {
        "name": user.email?.split("@")[0] ?? "Student",
        "department": "CSE",
        "year": "1",
        "rollNumber": "00000",
        "contact": "",
        "avatarUrl": defaultAvatar,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(map);

      setState(() {
        _data = map;
        _loading = false;
      });
      return;
    }

    setState(() {
      _data = doc.data()!;
      _loading = false;
    });
  }

  Future<void> _openEdit() async {
    if (_data == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: _data!["name"],
          department: _data!["department"],
          year: _data!["year"],
          roll: _data!["rollNumber"],
          contact: _data!["contact"],
          avatar: _data!["avatarUrl"] ?? defaultAvatar,
        ),
      ),
    );

    if (result != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update(result);

        setState(() {
          _data!.addAll(result);
        });
      }
    }
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
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        title: const Text("My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _openEdit,
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),

            /// Avatar
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(_data!["avatarUrl"] ?? defaultAvatar),
            ),

            const SizedBox(height: 20),

            /// Name
            Text(
              _data!["name"],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text("Department: ${_data!["department"]}",
                style: const TextStyle(fontSize: 16)),
            Text("Year: ${_data!["year"]}",
                style: const TextStyle(fontSize: 16)),
            Text("Roll Number: ${_data!["rollNumber"]}",
                style: const TextStyle(fontSize: 16)),
            Text("Contact: ${_data!["contact"]}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////
/// EDIT PROFILE SCREEN
///////////////////////////////////////////////////////

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String department;
  final String year;
  final String roll;
  final String contact;
  final String avatar;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.department,
    required this.year,
    required this.roll,
    required this.contact,
    required this.avatar,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _name;
  late TextEditingController _dept;
  late TextEditingController _year;
  late TextEditingController _roll;
  late TextEditingController _contact;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _dept = TextEditingController(text: widget.department);
    _year = TextEditingController(text: widget.year);
    _roll = TextEditingController(text: widget.roll);
    _contact = TextEditingController(text: widget.contact);
  }

  @override
  void dispose() {
    _name.dispose();
    _dept.dispose();
    _year.dispose();
    _roll.dispose();
    _contact.dispose();
    super.dispose();
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
        title: const Text("Edit Profile",
            style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.avatar),
            ),

            const SizedBox(height: 20),

            _input("Full Name", _name),
            _input("Department", _dept),
            _input("Year", _year),
            _input("Roll Number", _roll),
            _input("Contact", _contact),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                onPressed: _save,
                child: const Text("Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
