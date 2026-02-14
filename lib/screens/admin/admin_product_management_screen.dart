import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AdminProductManagementScreen extends StatelessWidget {
  const AdminProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock data for products
    final List<Map<String, String>> products = [
      {'name': 'Designer Leather Handbag', 'price': '\$120', 'stock': '15'},
      {'name': 'Classic Blue Denim Jeans', 'price': '\$80', 'stock': '41'},
      {'name': 'Floral Summer Dress', 'price': '\$65', 'stock': '22'},
      {'name': 'White Casual Sneakers', 'price': '\$95', 'stock': '10'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // Open add product dialog
            },
          ),
        ],
      ),
      body: ListView.separated(
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
                color: isDark ? AppColors.dividerDark : Colors.grey.withOpacity(0.2),
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
                  child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Price: ${product['price']!} | Stock: ${product['stock']!}', 
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                  onPressed: () {
                    // Open edit product dialog
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  onPressed: () {
                    // Show delete confirmation
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
