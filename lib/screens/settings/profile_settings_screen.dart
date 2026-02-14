import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
<<<<<<< HEAD
=======
import '../../services/avatar_service.dart';
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
import '../../utils/colors.dart';
import '../../services/auth_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late AuthService _authService;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? 'User';
        _emailController.text = user.email ?? '';
        // Phone is not available in Firebase Auth by default
        _phoneController.text = '';
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update display name
        if (_nameController.text.isNotEmpty &&
            _nameController.text != user.displayName) {
          await user.updateDisplayName(_nameController.text);
        }

        // Refresh user data
        await user.reload();

        setState(() {
          _isEditing = false;
          _successMessage = 'Profile updated successfully!';
        });

        // Clear message after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _successMessage = '');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
=======
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildProfileAvatar(),
                    const SizedBox(height: 20),
                    if (_nameController.text.isNotEmpty)
                      Center(
                        child: Text(
                          _nameController.text,
<<<<<<< HEAD
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
=======
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    if (_successMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          _successMessage,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      enabled: false,
                      hint: 'Email cannot be changed',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      enabled: _isEditing,
                      hint: 'Optional',
                    ),
                    const SizedBox(height: 30),
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() => _isEditing = false);
                                      _loadUserData();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryMaroon,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Save',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isEditing = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMaroon,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildHeader(BuildContext context, bool isDark) {
=======
  Widget _buildHeader(BuildContext context) {
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
<<<<<<< HEAD
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A3A),
            ),
          ),
          Expanded(
=======
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A3A),
            ),
          ),
          const Expanded(
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
            child: Text(
              'Profile Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
<<<<<<< HEAD
                color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A3A),
=======
                color: Color(0xFF1A1A3A),
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
<<<<<<< HEAD
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryMaroon.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const ClipOval(
              child: Icon(
                Icons.person_rounded,
                size: 60,
                color: AppColors.primaryMaroon,
              ),
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndSaveAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryMaroon,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
=======
      child: FutureBuilder<Uint8List?>(
        future: AvatarService.loadAvatar(),
        builder: (context, snap) {
          final bytes = snap.data;
          return Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: bytes != null
                      ? Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: AppColors.primaryMaroon,
                        ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndSaveAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryMaroon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
      ),
    );
  }

  Future<void> _pickAndSaveAvatar() async {
<<<<<<< HEAD
    // Mock pick and save avatar since AvatarService is missing
=======
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null) return;
<<<<<<< HEAD
      // In a real app, we would save this to the AvatarService
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar selected (Mock mode)')),
      );
=======
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      await AvatarService.saveAvatar(Uint8List.fromList(bytes));
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? hint,
  }) {
<<<<<<< HEAD
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
=======
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
<<<<<<< HEAD
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
=======
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
<<<<<<< HEAD
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            prefixIcon: Icon(icon, color: AppColors.primaryMaroon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.dividerDark
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.dividerDark.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            filled: !enabled || isDark,
            fillColor: !enabled
                ? (isDark ? AppColors.surfaceDark : Colors.grey.withOpacity(0.05))
                : (isDark ? AppColors.cardDark : Colors.white),
=======
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryMaroon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            filled: !enabled,
            fillColor: !enabled ? Colors.grey.withOpacity(0.05) : Colors.white,
>>>>>>> 09c3eded5701c01428880b6acdeff424d436ba2e
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
