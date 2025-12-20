import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

const Color kPrimary = Color(0xFFBF0C4F);

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController name, dept, year, phone;
  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.profile["name"]);
    dept = TextEditingController(text: widget.profile["department"]);
    year = TextEditingController(text: widget.profile["year"]);
    phone = TextEditingController(text: widget.profile["contact"]);
    photoUrl = widget.profile["photo"] ?? "";
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (photoUrl.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Remove Photo",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: source);
    if (img == null) return;

    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseStorage.instance.ref("profile_pics/${user.uid}.jpg");

    if (kIsWeb) {
      Uint8List bytes = await img.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(img.path));
    }

    photoUrl = await ref.getDownloadURL();
    setState(() {});
  }

  Future<void> _removePhoto() async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseStorage.instance.ref("profile_pics/${user.uid}.jpg");
    try {
      await ref.delete();
    } catch (_) {}
    setState(() => photoUrl = "");
  }

  Future<void> _save() async {
    if (!RegExp(r'^[1-5]$').hasMatch(year.text) ||
        !RegExp(r'^[0-9]{10}$').hasMatch(phone.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid year or phone")));
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "name": name.text.trim(),
      "department": dept.text.trim(),
      "year": year.text.trim(),
      "contact": phone.text.trim(),
      "photo": photoUrl,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.pink.shade100,
                  backgroundImage: photoUrl.isEmpty
                      ? null
                      : NetworkImage(photoUrl),
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 50, color: kPrimary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: kPrimary,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: _showImageOptions,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _field("Name", name),
            _field("Department", dept),
            _field("Year (1–5)", year, isNumber: true),
            _field("Phone Number", phone, isNumber: true),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                onPressed: _save,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
