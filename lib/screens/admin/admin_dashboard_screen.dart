import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'admin_user_management_screen.dart';
import 'admin_product_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatGrid(isDark),
            const SizedBox(height: 30),
            const Text(
              'Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              context,
              'User Management',
              'View and manage app users',
              Icons.people_alt_rounded,
              const AdminUserManagementScreen(),
              isDark,
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              context,
              'Product Management',
              'Manage your clothing catalog',
              Icons.inventory_2_rounded,
              const AdminProductManagementScreen(),
              isDark,
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              context,
              'Analytics',
              'View sales and usage data',
              Icons.analytics_rounded,
              null, // Placeholder
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Users', '1,234', Icons.person, Colors.blue, isDark),
        _buildStatCard('Active Now', '56', Icons.bolt, Colors.orange, isDark),
        _buildStatCard('Total Products', '456', Icons.shopping_bag, Colors.green, isDark),
        _buildStatCard('Total Revenue', '\$12k', Icons.attach_money, Colors.purple, isDark),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget? destination,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: destination != null
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination))
          : null,
      child: Container(
        padding: const EdgeInsets.all(20),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryMaroon),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
