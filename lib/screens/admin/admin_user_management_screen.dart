import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock data for users
    final List<Map<String, String>> users = [
      {'name': 'Hirushie', 'email': 'hirushie9@gmail.com', 'role': 'Admin'},
      {'name': 'John Doe', 'email': 'john@example.com', 'role': 'User'},
      {'name': 'Jane Smith', 'email': 'jane@example.com', 'role': 'User'},
      {'name': 'Bob Wilson', 'email': 'bob@example.com', 'role': 'User'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryMaroon.withOpacity(0.1),
                  child: Text(user['name']![0], style: const TextStyle(color: AppColors.primaryMaroon)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(user['email']!, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['role'] == 'Admin' 
                        ? Colors.red.withOpacity(0.1) 
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user['role']!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: user['role'] == 'Admin' ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                  onPressed: () {
                    // Show management options (Change role, Delete, etc.)
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
