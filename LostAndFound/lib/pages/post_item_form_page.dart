import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';

class PostItemFormPage extends StatefulWidget {
  const PostItemFormPage({super.key});

  @override
  State<PostItemFormPage> createState() => _PostItemFormPageState();
}

class _PostItemFormPageState extends State<PostItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _status = 'Lost';
  String? _location;

  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _secretQuestionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<String> _uploadedUrls = [];

  bool _isSubmitting = false;

  // ----------------------------------
  // EXTRACT USER ID FROM EMAIL
  // ----------------------------------
  String _extractUserIdFromEmail(String email) {
    return email.split('@')[0].toUpperCase();
  }

  // ----------------------------------
  // PICK IMAGES
  // ----------------------------------
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images == null) return;

    if (images.length + _selectedImages.length > 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Max 5 images allowed")));
      return;
    }

    setState(() {
      _selectedImages.addAll(images);
    });
  }

  // ----------------------------------
  // UPLOAD IMAGES (WEB + MOBILE SAFE)
  // ----------------------------------
  Future<void> _uploadImages() async {
    _uploadedUrls.clear();

    for (final img in _selectedImages) {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${img.name}";
      final ref = FirebaseStorage.instance.ref().child(
        "lost_found_images/$fileName",
      );

      if (kIsWeb) {
        final Uint8List bytes = await img.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(img.path));
      }

      final url = await ref.getDownloadURL();
      _uploadedUrls.add(url);
    }
  }

  // ----------------------------------
  // SAVE TO FIRESTORE (CORRECT userId)
  // ----------------------------------
  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw Exception("User not logged in");
    }

    final rollNumber = _extractUserIdFromEmail(user.email!);
    final collection = _status == "Lost" ? "lost_items" : "found_items";

    await FirebaseFirestore.instance.collection(collection).add({
      "userId": rollNumber, // ✅ IMPORTANT
      "uid": user.uid, // ✅ EVEN MORE IMPORTANT for chat
      "email": user.email,
      "item_name": _itemNameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "location": _location ?? "",
      "contact": _contactController.text.trim(),
      "secret_question": _secretQuestionController.text.trim(),
      "status": _status,
      "imageUrls": _uploadedUrls,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // ----------------------------------
  // UI
  // ----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text(
          "Post Lost/Found",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload Images (Max 5):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: kPrimary,
                      ),
                      SizedBox(height: 10),
                      Text("Tap to select images"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final img = _selectedImages[index];
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? Image.network(img.path, fit: BoxFit.cover)
                                  : Image.file(
                                      File(img.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _status = "Lost"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _status == "Lost"
                            ? kPrimary
                            : Colors.grey[300],
                        foregroundColor: _status == "Lost"
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: const Text("Lost"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _status = "Found"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _status == "Found"
                            ? kPrimary
                            : Colors.grey[300],
                        foregroundColor: _status == "Found"
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: const Text("Found"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildField("Item Name", _itemNameController),
              _buildField("Description", _descriptionController, maxLines: 3),
              _buildLocationDropdown(),
              _buildField("Contact Number", _contactController),
              _buildField("Secret Question", _secretQuestionController),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isSubmitting = true);

                          try {
                            if (_selectedImages.isNotEmpty) {
                              await _uploadImages();
                            }
                            await _saveToFirestore();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Item posted successfully!"),
                              ),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Submission failed: $e")),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------
  // HELPERS
  // ----------------------------------
  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _location,
        decoration: InputDecoration(
          labelText: "Location",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: const [
          DropdownMenuItem(value: "AB1", child: Text("AB1")),
          DropdownMenuItem(value: "AB2", child: Text("AB2")),
          DropdownMenuItem(value: "AB3", child: Text("AB3")),
          DropdownMenuItem(value: "Hostel", child: Text("Hostel")),
          DropdownMenuItem(value: "Parking", child: Text("Parking")),
          DropdownMenuItem(value: "Other", child: Text("Other")),
        ],
        onChanged: (v) => setState(() => _location = v),
      ),
    );
  }
}
