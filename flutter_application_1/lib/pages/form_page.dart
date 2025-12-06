import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
final _formKey = GlobalKey<FormState>();
final _nameCtl = TextEditingController();
final _productCtl = TextEditingController();
final _locationCtl = TextEditingController();
final _contactCtl = TextEditingController();
final _descriptionCtl = TextEditingController();
String _category = '';
DateTime? _selectedDate;
String _type = 'lost';
File? _pickedImage;
final ImagePicker _picker = ImagePicker();


Future<void> _pickImage() async {
final file = await _picker.pickImage(source: ImageSource.gallery);
if (file != null) setState(() => _pickedImage = File(file.path));
}


Future<void> _pickDate() async {
final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), lastDate: DateTime.now().add(const Duration(days: 365)));
if (picked != null) setState(() => _selectedDate = picked);
}


void _submit() {
if (_formKey.currentState?.validate() ?? false) {
// For demo: simply pop. In a real app you would save to backend.
Navigator.pop(context);
}
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    body: SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Post Item',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Fill in the details',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // type
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _type = 'lost'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _type == 'lost' ? Colors.red : Colors.grey[200],
                              foregroundColor: _type == 'lost' ? Colors.white : Colors.black,
                            ),
                            child: const Text('I Lost Something'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _type = 'found'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _type == 'found' ? Colors.green : Colors.grey[200],
                              foregroundColor: _type == 'found' ? Colors.white : Colors.black,
                            ),
                            child: const Text('I Found Something'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Photo',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          if (_pickedImage != null)
                            Stack(
                              children: [
                                Image.file(
                                  _pickedImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () => setState(() => _pickedImage = null),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFF0F3F7),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameCtl,
                            decoration: const InputDecoration(labelText: 'Your Name'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _productCtl,
                            decoration: const InputDecoration(labelText: 'Item Name'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter item name' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _category.isEmpty ? null : _category,
                            items: const [
                              DropdownMenuItem(value: 'electronics', child: Text('Electronics')),
                              DropdownMenuItem(value: 'documents', child: Text('Documents')),
                              DropdownMenuItem(value: 'accessories', child: Text('Accessories')),
                              DropdownMenuItem(value: 'books', child: Text('Books')),
                              DropdownMenuItem(value: 'clothing', child: Text('Clothing')),
                              DropdownMenuItem(value: 'other', child: Text('Other')),
                            ],
                            onChanged: (v) => setState(() => _category = v ?? ''),
                            decoration: const InputDecoration(labelText: 'Category'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Choose category' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _locationCtl,
                            decoration: const InputDecoration(labelText: 'Location'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter location' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    hintText: _selectedDate == null
                                        ? 'Select date'
                                        : _selectedDate!.toLocal().toString().split(' ')[0],
                                  ),
                                  onTap: _pickDate,
                                  validator: (v) => (_selectedDate == null) ? 'Choose date' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _contactCtl,
                                  decoration: const InputDecoration(labelText: 'Contact Number'),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Enter contact' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionCtl,
                            decoration: const InputDecoration(labelText: 'Description'),
                            maxLines: 4,
                            validator: (v) => (v == null || v.isEmpty) ? 'Add description' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Post Item',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}