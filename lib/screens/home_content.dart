import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/feature_card.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/user_provider.dart';
import 'style_bot_screen.dart';
import 'product_details_screen.dart';
import 'virtual_fitting_room_screen.dart';
import 'coming_soon_screen.dart';

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
          DigiSearchBar(
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
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
                      _showFeed
                          ? Icons.grid_view_rounded
                          : Icons.list_rounded,
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
              child: _showFeed
                  ? _buildProductFeed(isDark)
                  : _buildFeatureNavigation(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductFeed(bool isDark) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(
            child: Text(
              'Error loading products: ${provider.error}',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          );
        }
        final items = provider.search(_searchQuery);
        if (items.isEmpty) {
          return Center(
            child: Text(
              'No items found',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailsScreen(product: product),
                  ),
                );
              },
              child: ProductCard(
                title: product.title,
                imageUrl: product.imageUrl ?? '',
              ),
            );
          },
        );
      },
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
              MaterialPageRoute(builder: (context) => const VirtualFittingRoomScreen()),
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
                builder: (context) => const ComingSoonScreen(
                  title: 'Thrift Store',
                  subtitle: 'Get ready to buy and sell pre-loved fashion pieces with other style enthusiasts.',
                  icon: Icons.store_rounded,
                ),
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
              MaterialPageRoute(
                builder: (context) => const ComingSoonScreen(
                  title: 'App Goals',
                  subtitle: 'We are working on bringing sustainable fashion goals tracking here. Check back later!',
                  icon: Icons.flag_rounded,
                ),
              ),
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
                color: AppColors.primaryMaroon.withOpacity(0.3),
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
