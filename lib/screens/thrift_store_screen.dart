import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/thrift_provider.dart';
import '../providers/cart_provider.dart';
import '../models/thrift_item.dart';
import '../models/cart_item.dart';
import '../utils/colors.dart';
import 'add_thrift_item_screen.dart';
import 'cart_screen.dart';

class ThriftStoreScreen extends StatefulWidget {
  const ThriftStoreScreen({super.key});

  @override
  State<ThriftStoreScreen> createState() => _ThriftStoreScreenState();
}

class _ThriftStoreScreenState extends State<ThriftStoreScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Thrift Store'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sell_rounded),
            tooltip: 'Sell Item',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddThriftItemScreen(),
                ),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMaroon,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(
            child: Consumer<ThriftProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = provider.items.where((item) {
                  return item.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      item.category.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                }).toList();

                if (items.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildThriftCard(items[index], isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search pre-loved items...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: isDark ? AppColors.cardDark : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildThriftCard(ThriftItem item, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _addToCart(item),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildItemImage(item),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMaroon,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '\$${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: AppColors.primaryMaroon,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seller: ${item.sellerName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.condition,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryMaroon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(ThriftItem item) async {
    final cartItem = CartItem(
      productId: 'thrift_${item.id}',
      title: item.title,
      brand: item.brand.isNotEmpty ? item.brand : item.category,
      imageUrl: item.imageUrl,
      imageDataUrl: item.imageDataUrl,
      price: item.price,
    );

    await context.read<CartProvider>().addItem(cartItem);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  Widget _buildItemImage(ThriftItem item) {
    final imageUrl = item.imageUrl;
    final imageDataUrl = item.imageDataUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildSavedImageFallback(imageDataUrl),
      );
    }

    return _buildSavedImageFallback(imageDataUrl);
  }

  Widget _buildSavedImageFallback(String? imageDataUrl) {
    if (imageDataUrl != null && imageDataUrl.isNotEmpty) {
      try {
        final base64Data = imageDataUrl.contains(',')
            ? imageDataUrl.split(',').last
            : imageDataUrl;
        return Image.memory(base64Decode(base64Data), fit: BoxFit.cover);
      } catch (_) {
        return _buildImagePlaceholder();
      }
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primaryMaroon.withValues(alpha: 0.1),
      child: const Icon(
        Icons.shopping_bag_outlined,
        size: 50,
        color: AppColors.primaryMaroon,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_rounded,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white54 : Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
