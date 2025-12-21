import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:async/async.dart';

import 'login_page.dart';
import 'edit_profile_page.dart';
import 'post_item_form_page.dart';
import 'onboarding_screen.dart';

// --- Theme Constants ---
const Color kPrimary = Color(0xFFBF0C4F);
const Color kBackground = Color(0xFFF8F9FD);
const Color kSurface = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A1A);
const Color kTextSecondary = Color(0xFF757575);
const Color kFoundGreen = Color(0xFF00BFA5);
const Color kInputFill = Color(0xFFF3F4F6);

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
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes. This ensures the profile page
    // automatically updates when a user logs in or out from anywhere in the app.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed to prevent memory leaks.
    _authSubscription?.cancel();
    super.dispose();
  }

  // ---------------- LOGIC ----------------
  Future<void> _loadProfile() async {
    // Set loading state at the beginning of a profile load.
    if (mounted) setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      // If user is logged out, clear the profile and stop loading.
      if (!mounted) return;
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

    // Stop loading once profile data is fetched.
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _changeProfilePicture() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    setState(() => _profile = null);
  }

  // ---------------- UI BUILD ----------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return _buildLoginState();
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildInfoGrid(),
            const SizedBox(height: 24),
            _buildMenuSection(),
            const SizedBox(height: 24),
            _buildMyPostsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Login Placeholder ---
  Widget _buildLoginState() {
    return Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              "Login to view profile",
              style: TextStyle(color: kTextSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                final ok = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (ok == true) _loadProfile();
              },
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header: Avatar + Name + Edit ---
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: (_profile!["photoUrl"] ?? "").isEmpty
                    ? null
                    : NetworkImage(_profile!["photoUrl"]),
                child: _isUploadingPhoto
                    ? const CircularProgressIndicator(color: kPrimary)
                    : ((_profile!["photoUrl"] ?? "").isEmpty
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[400],
                            )
                          : null),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _changeProfilePicture,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          (_profile!['name'] ?? 'User').toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Roll No: $_roll",
          style: const TextStyle(
            fontSize: 14,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfilePage(profile: _profile!),
              ),
            );
            _loadProfile();
          },
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text("Edit Profile"),
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: const BorderSide(color: kPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // --- Info Grid: Dept, Year, Phone ---
  Widget _buildInfoGrid() {
    return Row(
      children: [
        _buildInfoCard(
          label: "Department",
          value: _profile!['department'] ?? 'N/A',
          icon: Icons.school_outlined,
        ),
        const SizedBox(width: 12),
        _buildInfoCard(
          label: "Year",
          value: _profile!['year'] ?? 'N/A',
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(width: 12),
        _buildInfoCard(
          label: "Phone",
          value: _profile!['contact'] ?? '--',
          icon: Icons.phone_outlined,
        ),
      ],
    );
  }

  // --- FIXED INFO CARD WIDGET ---
  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimary.withOpacity(0.8), size: 24),
            const SizedBox(height: 8),
            // Use FittedBox to scale text down if it's too long, preventing ellipsis
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: kTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // --- Menu: Help/Onboarding ---
  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kInputFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.help_outline_rounded, color: kTextPrimary),
        ),
        title: const Text(
          "How to use App",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          "Onboarding & Walkthrough",
          style: TextStyle(fontSize: 12, color: kTextSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: kTextSecondary,
        ),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => OnboardingScreen())),
      ),
    );
  }

  // --- My Posts Section ---
  Widget _buildMyPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Activities",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildPostsStream(),
      ],
    );
  }

  Widget _buildPostsStream() {
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
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());

        final lostDocs = snap.data![0].docs;
        final foundDocs = snap.data![1].docs;
        final allDocs = [...lostDocs, ...foundDocs];

        allDocs.sort((a, b) {
          final t1 = (a.data() as Map)['timestamp'];
          final t2 = (b.data() as Map)['timestamp'];
          if (t1 == null || t2 == null) return 0;
          return (t2 as Timestamp).compareTo(t1 as Timestamp);
        });

        if (allDocs.isEmpty) return _emptyPostsUI();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allDocs.length,
          itemBuilder: (_, i) {
            final doc = allDocs[i];
            final data = doc.data() as Map<String, dynamic>;
            final isLost = lostDocs.contains(doc);
            return _ModernPostCard(
              data: data,
              isLost: isLost,
              onEdit: () async {
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
              onDelete: () async {
                await FirebaseFirestore.instance
                    .collection(isLost ? "lost_items" : "found_items")
                    .doc(doc.id)
                    .delete();
              },
            );
          },
        );
      },
    );
  }

  Widget _emptyPostsUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            "No posts yet",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper: Modern Post Card ---
class _ModernPostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLost;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModernPostCard({
    required this.data,
    required this.isLost,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final List imgs = data['imageUrls'] ?? [];
    final String? firstImg = imgs.isNotEmpty ? imgs.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: firstImg != null
                    ? Image.network(firstImg, fit: BoxFit.cover)
                    : Icon(
                        isLost ? Icons.search_off : Icons.check_circle_outline,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLost
                              ? kPrimary.withOpacity(0.1)
                              : kFoundGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isLost ? "LOST" : "FOUND",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isLost ? kPrimary : kFoundGreen,
                          ),
                        ),
                      ),

                      // Edit/Delete Menu
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: kTextSecondary,
                          ),
                          onSelected: (val) {
                            if (val == 'edit') onEdit();
                            if (val == 'delete') _confirmDelete(context);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Item Name
                  Text(
                    data["item_name"] ?? "Unknown Item",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    data["description"] ?? "No description",
                    style: const TextStyle(fontSize: 12, color: kTextSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to remove this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
