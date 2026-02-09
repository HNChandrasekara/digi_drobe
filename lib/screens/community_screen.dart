import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../widgets/search_bar.dart';
import 'chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _searchQuery = '';

  bool _matchesSearch(String text) {
    if (_searchQuery.isEmpty) return true;
    return text.toLowerCase().contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(userName: 'Hirushie'),
              DigiSearchBar(
                onChanged: (query) {
                  setState(() => _searchQuery = query.toLowerCase());
                },
              ),

              const SizedBox(height: 20),

              // Stories Section
              if (_matchesSearch('stories'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Stories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              if (_matchesSearch('stories')) _buildStoriesList(isDark),

              const SizedBox(height: 20),

              // Channels Section
              if (_matchesSearch('channels'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Channels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              if (_matchesSearch('channels'))
                _buildChannelItem(context, isDark: isDark, isNavigable: true),
              if (_matchesSearch('channels')) _buildChannelItem(context, isDark: isDark),
              if (_matchesSearch('channels')) _buildChannelItem(context, isDark: isDark),

              const SizedBox(height: 20),

              // Recommended Communities Section
              if (_matchesSearch('recommended') ||
                  _matchesSearch('communities'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Recommended Communities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              if (_matchesSearch('recommended') ||
                  _matchesSearch('communities'))
                _buildChannelItem(context, isDark: isDark),
              if (_matchesSearch('recommended') ||
                  _matchesSearch('communities'))
                _buildChannelItem(context, isDark: isDark),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesList(bool isDark) {
    final stories = ['', '', '', '', ''];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.cardDark : AppColors.systemGray6,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primaryMaroon,
                size: 35,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelItem(BuildContext context,
      {required bool isDark, bool isNavigable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: isNavigable
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(
                    channelName: 'Daily Outfit Inspirations (OOTD)',
                  ),
                ),
              )
            : null,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark
                : const Color(0xFFD9D9D9).withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: isDark
                ? Border.all(color: AppColors.dividerDark, width: 0.5)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Daily Outfit Inspirations (OOTD)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMaroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
