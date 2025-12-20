import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:async/async.dart';

import 'login_page.dart';
import 'edit_profile_page.dart';
import 'post_item_form_page.dart';

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
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ---------------- LOAD PROFILE ----------------
  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      setState(() {
        _profile = null;
        _loading = false;
      });
      return;
    }

    _roll = user.email!.split('@')[0].toUpperCase();

    final ref = FirebaseFirestore.instance.collection("users").doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        "name": _roll,
        "department": "CSE",
        "year": "1",
        "contact": "",
        "photoUrl": "",
      });
      _profile = {
        "name": _roll,
        "department": "CSE",
        "year": "1",
        "contact": "",
        "photoUrl": "",
      };
    } else {
      _profile = snap.data();
    }

    setState(() => _loading = false);
  }

  // ---------------- UPLOAD PROFILE PICTURE ----------------
  Future<void> _changeProfilePicture() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compress image slightly
    );
    if (image == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final cloudinary = CloudinaryPublic(
        'doysqcrok',
        'amritafind_uploads',
        cache: false,
      );

      final response = await cloudinary.uploadFile(
        kIsWeb
            ? CloudinaryFile.fromBytesData(
                await image.readAsBytes(),
                identifier: image.name,
              )
            : CloudinaryFile.fromFile(
                image.path,
                resourceType: CloudinaryResourceType.Image,
              ),
      );

      if (response.secureUrl.isNotEmpty) {
        final newPhotoUrl = response.secureUrl;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"photoUrl": newPhotoUrl});
          await _loadProfile(); // Refresh profile data
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image upload failed. Please try again."),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred during upload.")),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    setState(() => _profile = null);
  }

  // ---------------- MY POSTS ----------------
  Widget _myPosts() {
    final lostStream = FirebaseFirestore.instance
        .collection("lost_items")
        .where("userId", isEqualTo: _roll)
        .snapshots();

    final foundStream = FirebaseFirestore.instance
        .collection("found_items")
        .where("userId", isEqualTo: _roll)
        .snapshots();

    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip([lostStream, foundStream]),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final lostDocs = snap.data![0].docs;
        final foundDocs = snap.data![1].docs;
        final allDocs = [...lostDocs, ...foundDocs];

        if (allDocs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No posts yet"),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allDocs.length,
          itemBuilder: (_, i) {
            final doc = allDocs[i];
            final data = doc.data() as Map<String, dynamic>;
            final isLost = lostDocs.contains(doc);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                title: Text(data["item_name"] ?? "Item"),
                subtitle: Text(isLost ? "Lost Item" : "Found Item"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✏️ EDIT POST
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostItemFormPage(
                              docId: doc.id,
                              collection: isLost ? "lost_items" : "found_items",
                              existingData: data,
                            ),
                          ),
                        );
                      },
                    ),
                    // 🗑 DELETE POST
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ---------- NOT LOGGED IN ----------
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimary,
          title: const Text("Profile", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () async {
              final ok = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
              if (ok == true) _loadProfile();
            },
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    // ---------- LOGGED IN ----------
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        actions: [
          // ✏️ EDIT PROFILE
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(profile: _profile!),
                ),
              );
              _loadProfile();
            },
          ),
          // 🚪 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // AVATAR with upload functionality
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (_profile!["photoUrl"] ?? "").isEmpty
                      ? null
                      : NetworkImage(_profile!["photoUrl"]),
                  child: (_profile!["photoUrl"] ?? "").isEmpty
                      ? const Icon(Icons.person, size: 50, color: kPrimary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _changeProfilePicture,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: kPrimary, size: 22),
                    ),
                  ),
                ),
                if (_isUploadingPhoto)
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.black45,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              _profile!["name"],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Department: ${_profile!["department"]}"),
            Text("Year: ${_profile!["year"]}"),
            Text("Roll Number: $_roll"),
            Text("Phone: ${_profile!["contact"]}"),

            const Divider(),
            const Text(
              "My Posts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _myPosts(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
