import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/feature_card.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../providers/wardrobe_provider.dart';
import 'style_bot_screen.dart';
import 'virtual_fitting_room_screen.dart';
import 'goals_screen.dart';
import 'thrift_store_screen.dart';

class HomeContent extends StatefulWidget {
  final Function(int) onTabChange;
  final VoidCallback? onProfileTap;

  const HomeContent({super.key, required this.onTabChange, this.onProfileTap});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _showFeed = true;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = context.watch<UserProvider>().displayName;

    return SafeArea(
      child: Column(
        children: [
          CustomHeader(userName: userName, onProfileTap: widget.onProfileTap),
          DigiSearchBar(onChanged: (q) => setState(() => _searchQuery = q)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Your Favourite Virtual Wardrobe',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showFeed = !_showFeed),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : AppColors.systemGray6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _showFeed ? Icons.grid_view_rounded : Icons.list_rounded,
                      size: 20,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _searchQuery.trim().isNotEmpty || !_showFeed
                  ? _buildFeatureNavigation()
                  : _buildStyleDashboard(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleDashboard(bool isDark) {
    return Consumer2<WardrobeProvider, CartProvider>(
      builder: (context, wardrobe, cart, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            _buildStyleHero(isDark),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    '${wardrobe.items.length}',
                    'Closet pieces',
                    Icons.checkroom_rounded,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    '${cart.itemCount}',
                    'In cart',
                    Icons.shopping_bag_rounded,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildQuickActions(isDark),
            const SizedBox(height: 18),
            _buildOutfitPrompts(isDark),
          ],
        );
      },
    );
  }

  Widget _buildStyleHero(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Style Mood',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Soft layers, clean lines',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _MoodChip(label: 'campus'),
                    _MoodChip(label: 'coffee run'),
                    _MoodChip(label: 'easy glam'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 92,
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.primaryMaroon.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 18,
                  child: Icon(
                    Icons.dry_cleaning_rounded,
                    size: 44,
                    color: AppColors.primaryMaroon.withValues(alpha: 0.9),
                  ),
                ),
                Positioned(
                  bottom: 26,
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 28,
                    color: AppColors.accentMaroon.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    String value,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryMaroon, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            'Wardrobe',
            Icons.checkroom_rounded,
            isDark,
            () => widget.onTabChange(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickAction(
            'Stylemate',
            Icons.psychology_rounded,
            isDark,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StyleBotScreen()),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickAction(
            'Thrift',
            Icons.store_rounded,
            isDark,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ThriftStoreScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickAction(
    String label,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryMaroon, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitPrompts(bool isDark) {
    final prompts = [
      ('White tee', 'wide-leg denim', Icons.wb_sunny_rounded),
      ('Soft sweater', 'mini skirt', Icons.cloud_rounded),
      ('Linen shirt', 'tailored pants', Icons.auto_awesome_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wear Today',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...prompts.map(
          (prompt) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(prompt.$3, color: AppColors.primaryMaroon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${prompt.$1} + ${prompt.$2}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureNavigation() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        FeatureCard(
          title: 'My Wardrobe',
          subtitle: 'View and organize your clothes',
          icon: Icons.checkroom_rounded,
          onTap: () => widget.onTabChange(3),
        ),
        FeatureCard(
          title: 'Community',
          subtitle: 'Join style channels and stories',
          icon: Icons.people_rounded,
          onTap: () => widget.onTabChange(1),
        ),
        FeatureCard(
          title: 'Virtual Fitting Room',
          subtitle: 'Try on clothes digitally',
          icon: Icons.accessibility_new_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VirtualFittingRoomScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Thrift Store',
          subtitle: 'Buy and sell pre-loved items',
          icon: Icons.store_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThriftStoreScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'App Goals',
          subtitle: 'What we aim to achieve',
          icon: Icons.flag_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoalsScreen()),
            );
          },
        ),
        _buildStylemateCard(),
      ],
    );
  }

  Widget _buildStylemateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StyleBotScreen()),
          );
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryMaroon, AppColors.accentMaroon],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMaroon.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STYLEMATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'AI Stylist Assistant',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;

  const _MoodChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryMaroon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryMaroon,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
