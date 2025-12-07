import 'package:flutter/material.dart';
import 'home_page.dart';

/// ================= POST ITEM FORM =================

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

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _secretQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Light theme only
    final surfaceLight = const Color(0xFFFFFFFF);
    final textPrimaryLight = const Color(0xFF333333);
    final textSecondaryLight = const Color(0xFF888888);
    final borderLight = const Color(0xFFEAEAEA);

    final bg = kBackgroundLight;
    final surface = surfaceLight;
    final textPrimary = textPrimaryLight;
    final textSecondary = textSecondaryLight;
    final borderColor = borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              decoration: BoxDecoration(
                color: surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back, color: textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Post a Lost or Found Item',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Content + sticky button
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image upload
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_a_photo_outlined,
                                size: 36,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Upload a Photo',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to open your camera or gallery',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Segmented Lost / Found
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SegmentButton(
                                      label: 'I Lost an Item',
                                      selected: _status == 'Lost',
                                      primary: kPrimary,
                                      textSecondary: textSecondary,
                                      onTap: () {
                                        setState(() {
                                          _status = 'Lost';
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: _SegmentButton(
                                      label: 'I Found an Item',
                                      selected: _status == 'Found',
                                      primary: kPrimary,
                                      textSecondary: textSecondary,
                                      onTap: () {
                                        setState(() {
                                          _status = 'Found';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            _LabeledField(
                              label: 'Item Name',
                              textPrimary: textPrimary,
                              child: TextFormField(
                                controller: _itemNameController,
                                style: TextStyle(color: textPrimary),
                                decoration: _inputDecoration(
                                  'e.g., Black Water Bottle',
                                  textSecondary,
                                  borderColor,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter the item name';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            _LabeledField(
                              label: 'Description',
                              textPrimary: textPrimary,
                              child: TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                style: TextStyle(color: textPrimary),
                                decoration: _inputDecoration(
                                  'Add details like brand, color, or any identifying marks...',
                                  textSecondary,
                                  borderColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            _LabeledField(
                              label: 'Location',
                              textPrimary: textPrimary,
                              child: DropdownButtonFormField<String>(
                                value: _location,
                                items: const [
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text('Select a location'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AB1',
                                    child: Text('AB1'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AB2',
                                    child: Text('AB2'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AB3',
                                    child: Text('AB3'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Hostel',
                                    child: Text('Hostel'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Parking',
                                    child: Text('Parking'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Other',
                                    child: Text('Other'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _location = value;
                                  });
                                },
                                style: TextStyle(color: textPrimary),
                                decoration: _inputDecoration(
                                  'Select a location',
                                  textSecondary,
                                  borderColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(child: Divider(color: borderColor)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    'OPTIONAL',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: borderColor)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _LabeledField(
                              label: 'Contact Number',
                              textPrimary: textPrimary,
                              child: TextFormField(
                                controller: _contactController,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(color: textPrimary),
                                decoration: _inputDecoration(
                                  'Your phone number',
                                  textSecondary,
                                  borderColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            _LabeledField(
                              label: 'Secret Question',
                              textPrimary: textPrimary,
                              child: TextFormField(
                                controller: _secretQuestionController,
                                style: TextStyle(color: textPrimary),
                                decoration: _inputDecoration(
                                  "e.g., What's the laptop's sticker?",
                                  textSecondary,
                                  borderColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky submit
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: kPrimary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Submit',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    Color hintColor,
    Color borderColor,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.primary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? primary : Colors.transparent;
    final textColor = selected ? Colors.white : textSecondary;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        elevation: selected ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final Color textPrimary;

  const _LabeledField({
    required this.label,
    required this.child,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
