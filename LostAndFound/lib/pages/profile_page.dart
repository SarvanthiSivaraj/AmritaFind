import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
  Map<String, dynamic>? _profile;
  String _roll = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // -------------------- LOAD PROFILE --------------------
  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      setState(() {
        _loading = false;
        _profile = null;
      });
      return;
    }

    _roll = user.email!.split('@')[0].toUpperCase();
    final ref = FirebaseFirestore.instance.collection("users").doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      final data = {
        "name": _roll,
        "department": "CSE",
        "year": "1",
        "contact": "",
        "photo": "",
      };
      await ref.set(data);
      _profile = data;
    } else {
      _profile = snap.data();
    }

    setState(() => _loading = false);
  }

  // -------------------- LOGOUT --------------------
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  // -------------------- PICK PROFILE PIC --------------------
  Future<void> _pickProfilePic() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final user = FirebaseAuth.instance.currentUser!;
    final ref =
        FirebaseStorage.instance.ref("profile_pics/${user.uid}.jpg");

    if (kIsWeb) {
      Uint8List bytes = await img.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(img.path));
    }

    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"photo": url});

    _loadProfile();
  }

  // -------------------- EDIT PROFILE --------------------
  Future<void> _editProfile() async {
    final name = TextEditingController(text: _profile!["name"]);
    final dept = TextEditingController(text: _profile!["department"]);
    final year = TextEditingController(text: _profile!["year"]);
    final contact = TextEditingController(text: _profile!["contact"]);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: dept, decoration: const InputDecoration(labelText: "Department")),
              TextField(controller: year, decoration: const InputDecoration(labelText: "Year")),
              TextField(controller: contact, decoration: const InputDecoration(labelText: "Contact")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser!;
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .update({
                "name": name.text.trim(),
                "department": dept.text.trim(),
                "year": year.text.trim(),
                "contact": contact.text.trim(),
              });
              Navigator.pop(context);
              _loadProfile();
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // -------------------- MY POSTS --------------------
  Widget _myPosts() {
    final lost = FirebaseFirestore.instance
        .collection("lost_items")
        .where("userId", isEqualTo: _roll)
        .snapshots();

    final found = FirebaseFirestore.instance
        .collection("found_items")
        .where("userId", isEqualTo: _roll)
        .snapshots();

    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip([lost, found]),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const CircularProgressIndicator();
        }

        final lostDocs = snap.data![0].docs;
        final foundDocs = snap.data![1].docs;
        final all = [...lostDocs, ...foundDocs];

        if (all.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No posts yet"),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: all.length,
          itemBuilder: (_, i) {
            final doc = all[i];
            final data = doc.data() as Map<String, dynamic>;
            final isLost = lostDocs.contains(doc);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                title: Text(data["item_name"]),
                subtitle: Text(isLost ? "Lost Item" : "Found Item"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editPost(doc.id, isLost, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection(isLost ? "lost_items" : "found_items")
                            .doc(doc.id)
                            .delete();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------- EDIT POST --------------------
  Future<void> _editPost(
      String id, bool isLost, Map<String, dynamic> data) async {
    final name = TextEditingController(text: data["item_name"]);
    final desc = TextEditingController(text: data["description"]);
    final contact = TextEditingController(text: data["contact"]);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Post"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Item Name")),
            TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: contact, decoration: const InputDecoration(labelText: "Contact")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection(isLost ? "lost_items" : "found_items")
                  .doc(id)
                  .update({
                "item_name": name.text.trim(),
                "description": desc.text.trim(),
                "contact": contact.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // NOT LOGGED IN
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimary,
          leading: const BackButton(color: Colors.white),
          title: const Text("Profile", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text("Please login to view your profile")),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: (_profile!["photo"] ?? "").isEmpty
                      ? null
                      : NetworkImage(_profile!["photo"]),
                  child: (_profile!["photo"] ?? "").isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickProfilePic,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(_profile!["name"],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Department: ${_profile!["department"]}"),
            Text("Year: ${_profile!["year"]}"),
            Text("Roll Number: $_roll"),
            Text("Contact: ${_profile!["contact"]}"),
            const Divider(),
            const Text("My Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _myPosts(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
