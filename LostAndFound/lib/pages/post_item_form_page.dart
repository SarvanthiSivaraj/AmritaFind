import 'dart:io';
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

  // -------------------------
  // IMAGE PICKER VARIABLES
  // -------------------------
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<String> _uploadedUrls = [];

  // PICK MULTIPLE IMAGES
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images == null) return;

    if (images.length + _selectedImages.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Max 5 images allowed")),
      );
      return;
    }

    setState(() {
      _selectedImages.addAll(images.map((e) => File(e.path)));
    });
  }

  // UPLOAD IMAGES TO FIREBASE STORAGE
  Future<void> _uploadImages() async {
    _uploadedUrls.clear();

    for (File img in _selectedImages) {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance
          .ref()
          .child("lost_found_images/$fileName");

      await ref.putFile(img);
      final url = await ref.getDownloadURL();
      _uploadedUrls.add(url);
    }
  }

  // SAVE POST TO FIRESTORE
  Future<void> _saveToFirestore() async {
    final collection = _status == "Lost" ? "lost_items" : "found_items";

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection(collection).add({
      "userId": user.uid,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text("Post Lost/Found", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // -------------------------
              // IMAGE PICKER UI
              // -------------------------
              Text("Upload Images (Max 5):",
                  style: TextStyle(fontWeight: FontWeight.bold)),

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
                      Icon(Icons.add_a_photo_outlined, size: 40, color: kPrimary),
                      SizedBox(height: 10),
                      Text("Tap to select images"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Preview selected images
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_selectedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Remove image button
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
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // -------------------------
              // LOST / FOUND Buttons
              // -------------------------
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _status = "Lost"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _status == "Lost" ? kPrimary : Colors.grey[300],
                        foregroundColor: _status == "Lost" ? Colors.white : Colors.black,
                      ),
                      child: const Text("Lost"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _status = "Found"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _status == "Found" ? kPrimary : Colors.grey[300],
                        foregroundColor: _status == "Found" ? Colors.white : Colors.black,
                      ),
                      child: const Text("Found"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // -------------------------
              // FORM FIELDS
              // -------------------------
              _buildField("Item Name", _itemNameController),
              _buildField("Description", _descriptionController, maxLines: 3),
              _buildLocationDropdown(),
              _buildField("Contact Number", _contactController),
              _buildField("Secret Question", _secretQuestionController),

              const SizedBox(height: 30),

              // -------------------------
              // SUBMIT BUTTON
              // -------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    // Upload images first
                    await _uploadImages();

                    // Save post to Firestore
                    await _saveToFirestore();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Item posted successfully!")),
                    );

                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1}) {
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
