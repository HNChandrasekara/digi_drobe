import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/threejs_viewer.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: imageUrl received on detail page: ${product.imageUrl}');
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.backgroundLight,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.systemGray6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base Image
                    product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.systemGray,
                                size: 80,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.systemGray,
                              size: 80,
                            ),
                          ),

                    // 3D View Overlay Button
                    if (product.model3dUrl != null &&
                        product.model3dUrl!.isNotEmpty)
                      Positioned(
                        bottom: 40,
                        right: 20,
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 5,
                                      width: 40,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Expanded(
                                      child: ThreeJsViewer(
                                        src: product.model3dUrl!,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          backgroundColor: AppColors.primaryMaroon,
                          icon: const Icon(
                            Icons.view_in_ar_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'View in 3D',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 28,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                      Text(
                        'Rs.${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMaroon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Brand: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        product.brand,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        debugPrint(
                          'DEBUG: Add to Cart button tapped for: ${product.title}',
                        );
                        try {
                          final cart = context.read<CartProvider>();
                          final cartItem = CartItem(
                            productId: product.id,
                            title: product.title,
                            brand: product.brand,
                            imageUrl: product.imageUrl,
                            price: product.price,
                            quantity: 1,
                          );

                          debugPrint(
                            'DEBUG: Created CartItem: ${cartItem.title} (ID: ${cartItem.productId})',
                          );

                          // Show a loading indicator if needed, but let's just proceed for now
                          await cart.addItem(cartItem);
                          debugPrint(
                            'DEBUG: Successfully added to CartProvider',
                          );

                          if (context.mounted) {
                            debugPrint(
                              'DEBUG: Showing SnackBar and navigating...',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart successfully'),
                                backgroundColor: AppColors.primaryMaroon,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            ).then(
                              (_) => debugPrint(
                                'DEBUG: Navigation to CartScreen completed',
                              ),
                            );
                          }
                        } catch (e, stack) {
                          debugPrint('DEBUG: ERROR adding to cart: $e');
                          debugPrint('DEBUG: STACKTRACE: $stack');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add to cart: $e'),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
