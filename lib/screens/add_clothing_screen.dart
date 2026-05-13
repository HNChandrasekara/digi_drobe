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
  ];

  Uint8List? _selectedImageBytes;
  String? _selectedImageExt;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
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
      // 1. Try to upload image to Firebase Storage (optional — won't block save)
      String? imageUrl;
      if (_selectedImageBytes != null) {
        try {
          final extension = _selectedImageExt ?? 'jpg';
          final fileName =
              'wardrobe_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final storage = FirebaseStorage.instanceFor(
            bucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
          );
          final ref = storage.ref().child('wardrobe_images/$fileName');
          
          // Added SettableMetadata to help Firebase identify the file type
          final metadata = SettableMetadata(
            contentType: 'image/$extension',
            customMetadata: {'picked-extension': extension},
          );

          final uploadTask = await ref.putData(_selectedImageBytes!, metadata);
          imageUrl = await uploadTask.ref.getDownloadURL();
        } catch (storageError) {
          // Storage upload failed — save item without image and warn user
          debugPrint('DEBUG: Storage upload failed details: $storageError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image upload failed: ${storageError.toString().contains('unknown') ? 'Connection/Permission error' : storageError}',
                ),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }

      // 2. Save item to user's Firestore wardrobe sub-collection
      //    Always runs regardless of whether image upload succeeded
      final newItem = WardrobeItem(
        id: '',
        title: _titleController.text.trim(),
        category: _selectedCategory,
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl, // null if upload failed — that's fine
        addedAt: DateTime.now(),
      );

      if (mounted) {
        await context.read<WardrobeProvider>().addItem(newItem);
      }

      if (mounted) {
        Navigator.pop(context);
        // Only show success if storage also worked (no pending orange snackbar)
        if (imageUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Item added to your wardrobe!'),
              backgroundColor: AppColors.primaryMaroon,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      // Firestore write itself failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save item: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
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
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Add to Wardrobe',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                        color: AppColors.primaryMaroon),
                    const SizedBox(height: 16),
                    Text(
                      'Saving your piece...',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Image picker ──────────────────────────────────────
                      GestureDetector(
                        onTap: _pickImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.systemGray6,
                            borderRadius: BorderRadius.circular(24),
                            border: _selectedImageBytes == null
                                ? Border.all(
                                    color: AppColors.primaryMaroon
                                        .withOpacity(0.3),
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  )
                                : null,
                            boxShadow: _selectedImageBytes != null && !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    )
                                  ]
                                : null,
                          ),
                          child: _selectedImageBytes != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.memory(
                                        _selectedImageBytes!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    // Edit overlay
                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.65),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_rounded,
                                                color: Colors.white, size: 14),
                                            SizedBox(width: 6),
                                            Text(
                                              'Change Photo',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryMaroon
                                            .withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 30,
                                        color: AppColors.primaryMaroon,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Add a Photo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryMaroon,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to upload from your gallery',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Clothing Name ─────────────────────────────────────
                      _fieldLabel('Clothing Name', isDark),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration(
                            isDark, 'e.g. Favourite Denim Jacket'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a name'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // ── Category ──────────────────────────────────────────
                      _fieldLabel('Category', isDark),
                      const SizedBox(height: 8),
                      // Horizontal chip row
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemCount: _categories.length,
                          itemBuilder: (_, i) {
                            final cat = _categories[i];
                            final selected = cat == _selectedCategory;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryMaroon
                                      : (isDark
                                          ? AppColors.cardDark
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryMaroon
                                        : (isDark
                                            ? AppColors.dividerDark
                                            : Colors.black.withOpacity(0.1)),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Brand ─────────────────────────────────────────────
                      _fieldLabel('Brand (Optional)', isDark),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _brandController,
                        decoration:
                            _inputDecoration(isDark, "e.g. Levi's, Zara"),
                      ),
                      const SizedBox(height: 24),

                      // ── Description ───────────────────────────────────────
                      _fieldLabel('Notes (Optional)', isDark),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          isDark,
                          'Size, condition, when you wear it...',
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Save button ───────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _saveClothingItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMaroon,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save to Wardrobe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDark ? AppColors.cardDark : Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.dividerDark
              : Colors.black.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            const BorderSide(color: AppColors.primaryMaroon, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}
