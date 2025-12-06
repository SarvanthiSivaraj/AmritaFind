import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _itemTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  String _category = "Lost";
  String _location = "";

  // image picker fields
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _itemTypeController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() => _pickedImage = picked);
    } catch (e) {
      // you can show an error SnackBar if needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_pickedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _pickedImage = null);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // For demonstration: show selected image path (if any)
    final imgPath = _pickedImage?.path ?? "No image";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post submitted! Image: $imgPath")),
    );

    // TODO: upload the image + form fields to backend
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF8C2F39);
    const creamDark = Color(0xFFF5EDE8);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Item"),
        backgroundColor: maroon,
      ),
      backgroundColor: const Color(0xFFFDF8F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your Name"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Enter your name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              const Text("Category"),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _categoryButton(
                      label: "Lost Item",
                      value: "Lost",
                      selected: _category == "Lost",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _categoryButton(
                      label: "Found Item",
                      value: "Found",
                      selected: _category == "Found",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text("Item Type"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _itemTypeController,
                decoration: _inputDecoration("e.g. Wallet, Phone, ID Card"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              const Text("Description"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: _inputDecoration("Describe the item in detail..."),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              const Text("Location"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _location.isEmpty ? null : _location,
                items: const [
                  DropdownMenuItem(value: "AB1", child: Text("AB1")),
                  DropdownMenuItem(value: "AB2", child: Text("AB2")),
                  DropdownMenuItem(value: "AB3", child: Text("AB3")),
                  DropdownMenuItem(value: "Hostel", child: Text("Hostel")),
                  DropdownMenuItem(value: "Parking", child: Text("Parking")),
                  DropdownMenuItem(value: "Library", child: Text("Library")),
                  DropdownMenuItem(value: "Canteen", child: Text("Canteen")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                decoration: _inputDecoration("Select location"),
                onChanged: (v) => setState(() => _location = v ?? ""),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              const Text("Contact Number (Optional)"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Your phone number"),
              ),
              const SizedBox(height: 16),

              const Text("Upload Image"),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: creamDark,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    color: _pickedImage == null ? Colors.transparent : Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.file(
                              File(_pickedImage!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => _placeholder(maroon),
                            ),
                          ),
                        )
                      : _placeholder(maroon),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text("Post Item"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // small helper to keep the placeholder consistent
  Widget _placeholder(Color maroon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.camera_alt, size: 32, color: maroon),
        const SizedBox(height: 8),
        const Text("Tap to upload photo (todo)"),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF5EDE8), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF5EDE8), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8C2F39), width: 2),
      ),
    );
  }

  Widget _categoryButton({
    required String label,
    required String value,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8C2F39) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF8C2F39) : const Color(0xFFF5EDE8),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
