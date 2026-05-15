import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class AdminProductManagementScreen extends StatelessWidget {
  const AdminProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productService = ProductService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showProductDialog(context, null, productService),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProductsStream(),
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
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
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
                                    size: 24),
                              ),
                            )
                          : const Icon(Icons.image_not_supported_rounded,
                              color: Colors.grey, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                              '\$${product.price.toStringAsFixed(2)} | Stock: ${product.stock ?? '–'}',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 20, color: Colors.grey),
                      onPressed: () => _showProductDialog(
                          context, product, productService),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 20, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(
                          context, product, productService),
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

  void _showProductDialog(BuildContext context, Product? existing,
      ProductService service) {
    final titleC =
        TextEditingController(text: existing?.title ?? '');
    final priceC = TextEditingController(
        text: existing != null ? '${existing.price}' : '');
    final descC =
        TextEditingController(text: existing?.description ?? '');
    final catC =
        TextEditingController(text: existing?.category ?? '');
    final brandC =
        TextEditingController(text: existing?.brand ?? '');
    final imgC =
        TextEditingController(text: existing?.imageUrl ?? '');
    final stockC = TextEditingController(
        text: existing?.stock != null ? '${existing!.stock}' : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(existing == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(titleC, 'Title'),
              _dialogField(priceC, 'Price', isNum: true),
              _dialogField(descC, 'Description', maxLines: 3),
              _dialogField(catC, 'Category'),
              _dialogField(brandC, 'Brand'),
              _dialogField(imgC, 'Image URL'),
              _dialogField(stockC, 'Stock', isNum: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white),
            onPressed: () async {
              final product = Product(
                id: existing?.id ?? '',
                title: titleC.text.trim(),
                price: double.tryParse(priceC.text.trim()) ?? 0,
                description: descC.text.trim(),
                category: catC.text.trim(),
                brand: brandC.text.trim(),
                imageUrl: imgC.text.trim().isEmpty
                    ? null
                    : imgC.text.trim(),
                stock: int.tryParse(stockC.text.trim()),
              );
              if (existing == null) {
                await service.addProduct(product);
              } else {
                await service.updateProduct(product);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label,
      {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, Product product, ProductService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () async {
              await service.deleteProduct(product.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
