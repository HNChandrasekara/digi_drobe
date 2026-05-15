import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/thrift_item.dart';
import '../providers/thrift_provider.dart';
import '../utils/colors.dart';

class AddThriftItemScreen extends StatefulWidget {
  const AddThriftItemScreen({super.key});

  @override
  State<AddThriftItemScreen> createState() => _AddThriftItemScreenState();
}

class _AddThriftItemScreenState extends State<AddThriftItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Tops';
  String _selectedCondition = 'Used - Good';

  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Outerwear',
    'Dresses',
    'Footwear',
    'Accessories',
  ];

  final List<String> _conditions = [
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Fair',
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

  Future<void> _saveThriftItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image for your item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      final extension = _selectedImageExt ?? 'jpg';
      final fileName = 'thrift_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('thrift_images/$fileName');
      
      final metadata = SettableMetadata(contentType: 'image/$extension');
      final TaskSnapshot snapshot = await ref.putData(_selectedImageBytes!, metadata);
      imageUrl = await snapshot.ref.getDownloadURL();

      final user = FirebaseAuth.instance.currentUser;
      final newItem = ThriftItem(
        id: '',
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        sellerId: user?.uid ?? 'unknown',
        sellerName: user?.displayName ?? 'Anonymous',
        condition: _selectedCondition,
        addedAt: DateTime.now(),
      );

      if (mounted) {
        await context.read<ThriftProvider>().addItem(newItem);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item listed in Thrift Store!'), backgroundColor: AppColors.primaryMaroon),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Sell Item')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _selectedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.add_a_photo_outlined, size: 50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildField('Item Title', _titleController, isDark),
                    const SizedBox(height: 16),
                    _buildField('Price (\$)', _priceController, isDark, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildDropdown('Category', _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v!), isDark),
                    const SizedBox(height: 16),
                    _buildDropdown('Condition', _conditions, _selectedCondition, (v) => setState(() => _selectedCondition = v!), isDark),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveThriftItem,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryMaroon, foregroundColor: Colors.white),
                        child: const Text('List Item', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool isDark, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.cardDark : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String current, Function(String?) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: current,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.cardDark : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
