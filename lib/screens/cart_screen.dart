import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    // Mock cart items
    final items = [
      {
        'title': 'White Polo Shirt',
        'price': '\$45.00',
        'url':
            'https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&q=80&w=400',
        'isAsset': false,
      },
      {
        'title': 'Maroon Heels',
        'price': '\$89.00',
        'url':
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&q=80&w=400',
        'isAsset': false,
      },
      {
        'title': 'Designer Bag',
        'price': '\$120.00',
        'url':
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&q=80&w=400',
        'isAsset': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(userName: 'Hirushie'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                children: [
                  Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildCartList(items)),
            _buildCheckoutFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Your cart is empty'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 30),
      itemBuilder: (context, index) {
        final item = items[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: item['isAsset'] == true
                      ? AssetImage(item['url']! as String) as ImageProvider
                      : NetworkImage(item['url']! as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    item['title']! as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['price']! as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.black.withOpacity(0.7),
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckoutFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              Text(
                '\$254.00',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
