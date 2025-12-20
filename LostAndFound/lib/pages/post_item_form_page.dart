import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimary = Color(0xFFBF0C4F);
const Color kBackgroundLight = Color(0xFFFAF9F6);

class PostItemFormPage extends StatefulWidget {
  final String? docId;
  final String? collection;
  final Map<String, dynamic>? existingData;

  const PostItemFormPage({
    super.key,
    this.docId,
    this.collection,
    this.existingData,
  });

  @override
  State<PostItemFormPage> createState() => _PostItemFormPageState();
}

class _PostItemFormPageState extends State<PostItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool get isEdit => widget.docId != null;

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

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    if (isEdit && widget.existingData != null) {
      final data = widget.existingData!;

      _status = data["status"] ?? "Lost";
      _location = data["location"];
      _itemNameController.text = data["item_name"] ?? "";
      _descriptionController.text = data["description"] ?? "";
      _contactController.text = data["contact"] ?? "";
      _secretQuestionController.text = data["secret_question"] ?? "";
      _uploadedUrls = List<String>.from(data["imageUrls"] ?? []);
    }
  }

  // ---------------- USER ID ----------------
  String _extractUserIdFromEmail(String email) {
    return email.split('@')[0].toUpperCase();
  }

  // ---------------- PICK IMAGES ----------------
  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images == null) return;

    if (images.length + _selectedImages.length + _uploadedUrls.length > 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Max 5 images allowed")));
      return;
    }

    setState(() {
      _selectedImages.addAll(images);
    });
  }

  // ---------------- UPLOAD NEW IMAGES ----------------
  Future<void> _uploadImages() async {
    // --- Cloudinary Setup ---
    // IMPORTANT: Replace with your details from your Cloudinary dashboard.
    final cloudinary = CloudinaryPublic(
      'doysqcrok', // <-- Paste your Cloud Name here
      'amritafind_uploads', // <-- Paste your Upload Preset name here
      cache: false,
    );

    for (final img in _selectedImages) {
      try {
        final response = await cloudinary.uploadFile(
          kIsWeb
              ? CloudinaryFile.fromBytesData(
                  await img.readAsBytes(),
                  identifier: img.name,
                )
              : CloudinaryFile.fromFile(
                  img.path,
                  resourceType: CloudinaryResourceType.Image,
                ),
        );

        if (response.secureUrl.isNotEmpty) {
          _uploadedUrls.add(response.secureUrl);
        } else {
          // The request was successful, but the URL is unexpectedly empty.
          debugPrint(
            'Failed to upload ${img.name}. Secure URL was empty in the response.',
          );
        }
      } catch (e) {
        debugPrint('Error uploading image to Cloudinary: $e');
        // Optionally, show an error to the user
      }
    }
  }

  // ---------------- SAVE / UPDATE ----------------
  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    final rollNumber = _extractUserIdFromEmail(user.email!);
    final collectionName = _status == 'Lost' ? 'lost_items' : 'found_items';

    final data = {
      "item_name": _itemNameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "location": _location ?? "",
      "contact": _contactController.text.trim(),
      "secret_question": _secretQuestionController.text.trim(),
      "status": _status,
      "imageUrls": _uploadedUrls,
    };

    if (isEdit) {
      await FirebaseFirestore.instance
          .collection(widget.collection!)
          .doc(widget.docId)
          .update(data);
    } else {
      await FirebaseFirestore.instance.collection(collectionName).add({
        ...data,
        "userId": rollNumber,
        "uid": user.uid,
        "email": user.email,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: Text(
          isEdit ? "Edit Post" : "Post Lost / Found",
          style: const TextStyle(color: Colors.white),
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
                "Upload Images (Max 5)",
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

              if (_uploadedUrls.isNotEmpty || _selectedImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._uploadedUrls.map((url) {
                        final safeUrl = (url ?? '').toString();
                        final Widget widgetImg = safeUrl.isNotEmpty
                            ? Image.network(safeUrl, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              );

                        return _imageTile(
                          widgetImg,
                          onRemove: () {
                            setState(() => _uploadedUrls.remove(url));
                          },
                        );
                      }),
                      ..._selectedImages.map(
                        (img) => _imageTile(
                          kIsWeb
                              ? Image.network(img.path, fit: BoxFit.cover)
                              : Image.file(File(img.path), fit: BoxFit.cover),
                          onRemove: () {
                            setState(() => _selectedImages.remove(img));
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _statusButton("Lost"),
                  const SizedBox(width: 10),
                  _statusButton("Found"),
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
                              SnackBar(
                                content: Text(
                                  isEdit
                                      ? "Post updated successfully!"
                                      : "Item posted successfully!",
                                ),
                              ),
                            );

                            Navigator.pop(context);
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? "Update" : "Submit",
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _imageTile(Widget img, {required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          width: 120,
          child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.red,
            child: InkWell(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusButton(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: isEdit ? null : () => setState(() => _status = label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _status == label ? kPrimary : Colors.grey[300],
          foregroundColor: _status == label ? Colors.white : Colors.black,
        ),
        child: Text(label),
      ),
    );
  }

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
          DropdownMenuItem(value: "Auditorium", child: Text("Auditorium")),
          DropdownMenuItem(value: "Lib", child: Text("Lib")),
          DropdownMenuItem(value: "Canteen", child: Text("Canteen")),
        ],
        onChanged: (v) => setState(() => _location = v),
      ),
    );
  }
}
