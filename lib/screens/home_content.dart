import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/feature_card.dart';
import '../widgets/product_card.dart';

class HomeContent extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeContent({super.key, required this.onTabChange});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _showFeed = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const CustomHeader(userName: 'Hirushie'),
          const DigiSearchBar(),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Favourite Virtual Wardrobe',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showFeed = !_showFeed),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.systemGray6,
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
              child: _showFeed ? _buildProductFeed() : _buildFeatureNavigation(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductFeed() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final items = [
          {'title': 'White Top', 'url': 'https://images.unsplash.com/photo-1598554747436-c92900c73229?auto=format&fit=crop&q=80&w=400'},
          {'title': 'Maroon Heels', 'url': 'https://images.unsplash.com/photo-1596702994291-944ccc40866b?auto=format&fit=crop&q=80&w=400'},
          {'title': 'Designer Bag', 'url': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&q=80&w=400'},
          {'title': 'Aesthetic Jeans', 'url': 'https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?auto=format&fit=crop&q=80&w=400'},
        ];
        return ProductCard(
          title: items[index]['title']!,
          imageUrl: items[index]['url']!,
        );
      },
    );
  }

  Widget _buildFeatureNavigation() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        FeatureCard(
          title: 'My Cart',
          subtitle: 'View and checkout your items',
          icon: Icons.shopping_cart_rounded,
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
          onTap: () {},
        ),
        FeatureCard(
          title: 'Thrift Store',
          subtitle: 'Buy and sell pre-loved items',
          icon: Icons.store_rounded,
          onTap: () {},
        ),
        FeatureCard(
          title: 'App Goals',
          subtitle: 'What we aim to achieve',
          icon: Icons.flag_rounded,
          onTap: () {},
        ),
        _buildStylemateCard(),
      ],
    );
  }

  Widget _buildStylemateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
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
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
