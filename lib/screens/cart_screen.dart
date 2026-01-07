import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(child: Text('Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
