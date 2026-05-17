import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../utils/colors.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../firebase_options.dart';

class AdminProductManagementScreen extends StatefulWidget {
  const AdminProductManagementScreen({super.key});

  @override
  State<AdminProductManagementScreen> createState() =>
      _AdminProductManagementScreenState();
}

class _AdminProductManagementScreenState
    extends State<AdminProductManagementScreen> {
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showProductDialog(context, null),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No products. Tap + to add one.',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            );
          }
          final products = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.dividerDark
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_rounded,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.grey,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)} | Stock: ${product.stock ?? '–'}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () => _showProductDialog(context, product),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _confirmDelete(context, product),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDialog(BuildContext context, Product? existing) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    final priceC = TextEditingController(
      text: existing != null ? '${existing.price}' : '',
    );
    final descC = TextEditingController(text: existing?.description ?? '');
    final catC = TextEditingController(text: existing?.category ?? '');
    final brandC = TextEditingController(text: existing?.brand ?? '');
    final stockC = TextEditingController(
      text: existing?.stock != null ? '${existing!.stock}' : '',
    );

    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Product' : 'Edit Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        debugPrint('DEBUG: Selected image path: ${image.path}');
                        setDialogState(() {
                          selectedImageBytes = bytes;
                          selectedImageName = image.name;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: selectedImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                selectedImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : existing?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                existing!.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 32),
                                SizedBox(height: 4),
                                Text(
                                  'Select Product Image',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                    ),
                  ),
                  _dialogField(titleC, 'Title'),
                  _dialogField(priceC, 'Price', isNum: true),
                  _dialogField(descC, 'Description', maxLines: 3),
                  _dialogField(catC, 'Category'),
                  _dialogField(brandC, 'Brand'),
                  _dialogField(stockC, 'Stock', isNum: true),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMaroon,
                  foregroundColor: Colors.white,
                ),
                onPressed: isUploading
                    ? null
                    : () async {
                        setDialogState(() => isUploading = true);
                        try {
                          String? finalImageUrl = existing?.imageUrl;

                          if (selectedImageBytes != null) {
                            final ext =
                                selectedImageName?.split('.').last ?? 'jpg';
                            final fileName =
                                'product_${DateTime.now().millisecondsSinceEpoch}.$ext';

                            final storage = FirebaseStorage.instanceFor(
                              bucket:
                                  'gs://digidrobe-f0de3.firebasestorage.app',
                            );
                            final ref = storage.ref().child(
                              'product_images/$fileName',
                            );

                            await ref.putData(
                              selectedImageBytes!,
                              SettableMetadata(contentType: 'image/$ext'),
                            );
                            finalImageUrl = await ref.getDownloadURL();
                            debugPrint(
                              'DEBUG: Uploaded image URL: $finalImageUrl',
                            );
                          }

                          final product = Product(
                            id: existing?.id ?? '',
                            title: titleC.text.trim(),
                            price: double.tryParse(priceC.text.trim()) ?? 0,
                            description: descC.text.trim(),
                            category: catC.text.trim(),
                            brand: brandC.text.trim(),
                            imageUrl: finalImageUrl,
                            stock: int.tryParse(stockC.text.trim()),
                          );

                          debugPrint(
                            'DEBUG: Saving product data: ${product.toJson()}',
                          );

                          if (existing == null) {
                            await _productService.addProduct(product);
                          } else {
                            await _productService.updateProduct(product);
                          }
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          debugPrint('DEBUG: Error saving product: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } finally {
                          setDialogState(() => isUploading = false);
                        }
                      },
                child: isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(existing == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogField(
    TextEditingController c,
    String label, {
    bool isNum = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _productService.deleteProduct(product.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
