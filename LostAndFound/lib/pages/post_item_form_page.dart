import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/ai_service.dart';

// --- Theme Constants ---
const Color kPrimary = Color(0xFFBF0C4F);
const Color kPrimaryLight = Color(0xFFFCE4EC);
const Color kBackground = Color(0xFFF8F9FD);
const Color kSurface = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A1A);
const Color kTextSecondary = Color(0xFF757575);
const Color kInputFill = Color(0xFFF3F4F6);

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
      _uploadedUrls = List<String>.from(data["imageUrls"] ?? []);
    }
  }

  // ---------------- LOGIC (UNCHANGED) ----------------
  String _extractUserIdFromEmail(String email) {
    return email.split('@')[0].toUpperCase();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    if (images.length + _selectedImages.length + _uploadedUrls.length > 5) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Max 5 images allowed"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _selectedImages.addAll(images);
    });
  }

  Future<void> _uploadImages() async {
    final cloudinary = CloudinaryPublic(
      'doysqcrok',
      'amritafind_uploads',
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
        }
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }
    }
  }

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
      "status": _status,
      "imageUrls": _uploadedUrls,
    };

    // Strictly sanitize data for AI (Allow-list approach) to ensure no images/timestamps pass through
    final aiData = {
      "item_name": data["item_name"],
      "description": data["description"],
      "location": data["location"],
      "status": data["status"],
    };

    if (isEdit) {
      await FirebaseFirestore.instance
          .collection(widget.collection!)
          .doc(widget.docId)
          .update(data);
    } else {
      final newDocRef = await FirebaseFirestore.instance
          .collection(collectionName)
          .add({
            ...data,
            "userId": rollNumber,
            "uid": user.uid,
            "email": user.email,
            "timestamp": FieldValue.serverTimestamp(),
          });

      if (_status == 'Lost') {
        await _runAiMatching(aiData, newDocRef.id, user.uid);
      } else {
        await _runFoundItemMatching(aiData, newDocRef.id);
      }
    }
  }

  Future<void> _runAiMatching(
    Map<String, dynamic> lostItemData,
    String lostItemId,
    String userId,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) return;
    final aiService = AiService(apiKey: apiKey);

    final foundItemsSnapshot = await FirebaseFirestore.instance
        .collection("found_items")
        .get();
    final foundItems = foundItemsSnapshot.docs;

    if (foundItems.isEmpty) return;

    for (final foundDoc in foundItems) {
      final foundItemData = foundDoc.data();

      // Strictly sanitize comparison data
      final cleanFoundData = {
        "item_name": foundItemData["item_name"] ?? "",
        "description": foundItemData["description"] ?? "",
        "location": foundItemData["location"] ?? "",
      };

      try {
        final isMatch = await aiService.isMatch(lostItemData, cleanFoundData);
        if (isMatch) {
          await _createMatchNotification(
            userId: userId,
            lostItemName: lostItemData['item_name'],
            lostItemId: lostItemId,
            foundItemId: foundDoc.id,
          );
        }
      } catch (e) {
        debugPrint("Error in AI matching (Lost): $e");
      }
    }
  }

  Future<void> _runFoundItemMatching(
    Map<String, dynamic> foundItemData,
    String foundItemId,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) return;
    final aiService = AiService(apiKey: apiKey);

    final lostItemsSnapshot = await FirebaseFirestore.instance
        .collection("lost_items")
        .get();
    final lostItems = lostItemsSnapshot.docs;

    if (lostItems.isEmpty) return;

    for (final lostDoc in lostItems) {
      final lostItemData = lostDoc.data();

      // Strictly sanitize comparison data
      final cleanLostData = {
        "item_name": lostItemData["item_name"] ?? "",
        "description": lostItemData["description"] ?? "",
        "location": lostItemData["location"] ?? "",
      };

      try {
        final isMatch = await aiService.isMatch(cleanLostData, foundItemData);
        if (isMatch && lostItemData['uid'] != null) {
          await _createMatchNotification(
            userId: lostItemData['uid'],
            lostItemName: lostItemData['item_name'] ?? 'Unknown Item',
            lostItemId: lostDoc.id,
            foundItemId: foundItemId,
          );
        }
      } catch (e) {
        debugPrint("Error in AI matching (Found): $e");
      }
    }
  }

  Future<void> _createMatchNotification({
    required String userId,
    required String lostItemName,
    required String lostItemId,
    required String foundItemId,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': 'Potential Match Found!',
      'body': "We think we found a match for your lost item: '$lostItemName'.",
      'lostItemId': lostItemId,
      'foundItemId': foundItemId,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          isEdit ? "Edit Details" : "Create Post",
          style: const TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Image Picker Section ---
                      _buildSectionTitle("Photos"),
                      const SizedBox(height: 12),
                      _buildImagePickerArea(),

                      const SizedBox(height: 24),

                      // --- Status Toggle ---
                      _buildSectionTitle("Status"),
                      const SizedBox(height: 12),
                      _buildModernToggle(),

                      const SizedBox(height: 24),

                      // --- Details Section ---
                      _buildSectionTitle("Item Details"),
                      const SizedBox(height: 16),

                      _ModernTextField(
                        controller: _itemNameController,
                        label: "Item Name",
                        hint: "e.g., Blue Dell Laptop",
                        icon: Icons.shopping_bag_outlined,
                      ),

                      const SizedBox(height: 16),

                      _ModernTextField(
                        controller: _descriptionController,
                        label: "Description",
                        hint:
                            "Provide details like color, brand, or unique marks...",
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      _buildModernDropdown(),

                      const SizedBox(height: 16),

                      _ModernTextField(
                        controller: _contactController,
                        label: "Contact Number",
                        hint: "+91 9876543210",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 24), // Bottom padding
                    ],
                  ),
                ),
              ),

              // --- Bottom Button ---
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildImagePickerArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_uploadedUrls.isEmpty && _selectedImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: kPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Upload Item Photos",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Max 5 images. Tap to browse.",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                // Add button in list
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.add, color: kPrimary, size: 30),
                  ),
                ),
                ..._uploadedUrls.map(
                  (url) => _buildImageTile(
                    url: url,
                    isWebImage: true,
                    onRemove: () => setState(() => _uploadedUrls.remove(url)),
                  ),
                ),
                ..._selectedImages.map(
                  (img) => _buildImageTile(
                    file: img,
                    isWebImage: false,
                    onRemove: () => setState(() => _selectedImages.remove(img)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageTile({
    String? url,
    XFile? file,
    required bool isWebImage,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 110,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              fit: BoxFit.cover,
              image: isWebImage
                  ? NetworkImage(url!) as ImageProvider
                  : (kIsWeb
                        ? NetworkImage(file!.path)
                        : FileImage(File(file!.path)) as ImageProvider),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernToggle() {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kInputFill, // The light grey background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildToggleOption("Lost", _status == "Lost"),
          _buildToggleOption("Found", _status == "Found"),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: isEdit ? null : () => setState(() => _status = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            // Active: Filled with Primary Color. Inactive: Transparent.
            color: isSelected ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : kTextSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDropdown() {
    return DropdownButtonFormField<String>(
      value: _location,
      style: const TextStyle(color: kTextPrimary, fontSize: 15),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: "Location",
        prefixIcon: const Icon(
          Icons.place_outlined,
          color: kTextSecondary,
          size: 22,
        ),
        filled: true,
        fillColor: kInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "AB1", child: Text("AB1")),
        DropdownMenuItem(value: "AB2", child: Text("AB2")),
        DropdownMenuItem(value: "AB3", child: Text("AB3")),
        DropdownMenuItem(value: "Hostel", child: Text("Hostel")),
        DropdownMenuItem(value: "Parking", child: Text("Parking")),
        DropdownMenuItem(value: "Auditorium", child: Text("Auditorium")),
        DropdownMenuItem(value: "Lib", child: Text("Library")),
        DropdownMenuItem(value: "Canteen", child: Text("Canteen")),
      ],
      onChanged: (v) => setState(() => _location = v),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    isEdit ? "Update Post" : "Submit Post",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      if (_selectedImages.isNotEmpty) await _uploadImages();
      await _saveToFirestore();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? "Post updated!" : "Item posted successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

// --- Reusable Modern Text Field ---
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? helperText;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: kTextPrimary),
      validator: (v) => v == null || v.isEmpty ? "$label is required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        labelStyle: const TextStyle(color: kTextSecondary),
        prefixIcon: Icon(icon, color: kTextSecondary, size: 22),
        filled: true,
        fillColor: kInputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}
