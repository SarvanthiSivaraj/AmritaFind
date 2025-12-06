import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _itemTypeController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Post submitted! (hook API later)")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF8C2F39);
    const creamDark = Color(0xFFF5EDE8);

    return Scaffold(
      appBar: AppBar(title: Text("Report Item"), backgroundColor: maroon),
      backgroundColor: Color(0xFFFDF8F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Name"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Enter your name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Text("Category"),
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

              Text("Item Type"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _itemTypeController,
                decoration: _inputDecoration("e.g. Wallet, Phone, ID Card"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Text("Description"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: _inputDecoration("Describe the item in detail..."),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Text("Location"),
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

              Text("Contact Number (Optional)"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Your phone number"),
              ),
              const SizedBox(height: 16),

              Text("Upload Image"),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: creamDark,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.camera_alt, size: 32, color: maroon),
                    SizedBox(height: 8),
                    Text("Tap to upload photo (todo)"),
                  ],
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFF5EDE8), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFF5EDE8), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF8C2F39), width: 2),
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
          color: selected ? Color(0xFF8C2F39) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Color(0xFF8C2F39) : Color(0xFFF5EDE8),
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
