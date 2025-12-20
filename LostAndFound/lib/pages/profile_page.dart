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
import 'onboarding_screen.dart';

const Color kPrimary = Color(0xFFBF0C4F);
const Color kSecondary = Color(0xFFD81B60);
const Color kBackgroundLight = Color(0xFFF9FAFB);
const Color kSurfaceLight = Colors.white;
const Color kBorderLight = Color(0xFFE5E7EB);
const Color kTextLight = Color(0xFF1F2937);

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
    final image =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
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
            : CloudinaryFile.fromFile(image.path),
      );

      if (response.secureUrl.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"photoUrl": response.secureUrl});
          await _loadProfile();
        }
      }
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
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        final lostDocs = snap.data![0].docs;
        final foundDocs = snap.data![1].docs;
        final allDocs = [...lostDocs, ...foundDocs];

        if (allDocs.isEmpty) {
          return _emptyPostsUI();
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
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(data["item_name"] ?? "Item"),
                subtitle: Text(isLost ? "Lost Item" : "Found Item"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

    if (_profile == null) {
      return Scaffold(
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
            child: const Text("Login"),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved header
            Container(
              height: 90,
              decoration: const BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
            ),

            // Profile card
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage:
                                  (_profile!["photoUrl"] ?? "").isEmpty
                                      ? null
                                      : NetworkImage(_profile!["photoUrl"]),
                              child: (_profile!["photoUrl"] ?? "").isEmpty
                                  ? const Icon(Icons.person,
                                      size: 56, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _changeProfilePicture,
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: kPrimary,
                                  child: Icon(Icons.camera_alt,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Text(
                          (_profile!['name'] ?? 'User').toString(),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          (_profile!['department'] ?? '').toString(),
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 16),
                        _infoRow("Department", (_profile!['department'] ?? '').toString()),
                        _infoRow("Year", (_profile!['year'] ?? '').toString()),
                        _infoRow("Roll Number", _roll),
                        _infoRow("Phone", (_profile!['contact'] ?? '').toString()),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.history, color: kPrimary),
                      SizedBox(width: 6),
                      Text(
                        "My Posts",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _myPosts(),

                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.help_outline, color: kPrimary),
                      title: const Text('How to use the app'),
                      subtitle: const Text('Onboarding and walkthrough'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => OnboardingScreen()),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _emptyPostsUI() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: kSurfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderLight),
        ),
        child: Column(
          children: const [
            Icon(Icons.post_add, size: 40, color: kPrimary),
            SizedBox(height: 10),
            Text("No posts yet",
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(
              "Items you report as lost or found will appear here.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
