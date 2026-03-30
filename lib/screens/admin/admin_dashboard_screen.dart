import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/user_provider.dart';
import 'admin_user_management_screen.dart';
import 'admin_product_management_screen.dart';
import '../../services/user_profile_service.dart';
import '../../services/product_service.dart';

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
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(bool isDark) {
    return StreamBuilder<List>(
      stream: UserProfileService().getAllUsersStream(),
      builder: (context, userSnap) {
        return StreamBuilder<List>(
          stream: ProductService().getProductsStream(),
          builder: (context, productSnap) {
            final userCount = userSnap.data?.length ?? 0;
            final productCount = productSnap.data?.length ?? 0;
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total Users', '$userCount',
                    Icons.person, Colors.blue, isDark),
                _buildStatCard('Products', '$productCount',
                    Icons.shopping_bag, Colors.green, isDark),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget destination,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => destination)),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color:
                              isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
