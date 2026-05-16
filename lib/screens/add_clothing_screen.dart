import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';
import '../utils/colors.dart';
import '../firebase_options.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Tops';
  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Outerwear',
    'Dresses',
    'Footwear',
    'Accessories',
    'Knitwear',
    'Activewear',
    'Swimwear',
  ];

  Uint8List? _selectedImageBytes;
  String? _selectedImageExt;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes;
        _selectedImageExt = result.files.first.extension;
      });
    }
  }

  Future<void> _saveClothingItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImageBytes != null) {
        try {
          final extension = _selectedImageExt ?? 'jpg';
          final fileName =
              'wardrobe_${DateTime.now().millisecondsSinceEpoch}.$extension';

          final storage = FirebaseStorage.instance;
          final ref = storage.ref().child('wardrobe_images/$fileName');

          final metadata = SettableMetadata(contentType: 'image/$extension');

          final TaskSnapshot snapshot = await ref.putData(
            _selectedImageBytes!,
            metadata,
          );
          imageUrl = await snapshot.ref.getDownloadURL();
          debugPrint('DEBUG: Image uploaded successfully: $imageUrl');
        } catch (storageError) {
          debugPrint('DEBUG: Storage upload failed: $storageError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image upload failed: ${storageError.toString()}',
                ),
                backgroundColor: Colors.orange.shade700,
              ),
            );
          }
        }
      }

      final newItem = WardrobeItem(
        id: '',
        title: _titleController.text.trim(),
        category: _selectedCategory,
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        addedAt: DateTime.now(),
      );

      if (mounted) {
        await context.read<WardrobeProvider>().addItem(newItem);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item added to your wardrobe!'),
            backgroundColor: AppColors.primaryMaroon,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save item: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Add to Wardrobe',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryMaroon,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Image Upload Placeholder ──────────────────────────
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : const Color(0xFFEDEEF3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _selectedImageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 48,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tap to upload a photo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Clothing Name ─────────────────────────────────────
                      _fieldLabel('Clothing Name', isDark),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration(
                          isDark,
                          'e.g. Favorite Denim Jack...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a name'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // ── Category ──────────────────────────────────────────
                      _fieldLabel('Category', isDark),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedCategory = newValue);
                          }
                        },
                        decoration: _inputDecoration(isDark, ''),
                        icon: const Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 30,
                        ),
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : Colors.white,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Brand ─────────────────────────────────────────────
                      _fieldLabel('Brand (Optional)', isDark),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _brandController,
                        decoration: _inputDecoration(isDark, "e.g. Levi's"),
                      ),
                      const SizedBox(height: 24),

                      // ── Description ───────────────────────────────────────
                      _fieldLabel('Description', isDark),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          isDark,
                          'Add more details about this item...',
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Save Button ───────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _saveClothingItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMaroon,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save to Wardrobe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _fieldLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      filled: true,
      fillColor: isDark ? AppColors.cardDark : const Color(0xFFF2F3F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryMaroon,
          width: 1.5,
        ),
      ),
    );
  }
}
