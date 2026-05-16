import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/user_provider.dart';
import '../models/wardrobe_item.dart';
import 'wardrobe_item_detail_screen.dart';
import 'add_clothing_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late final TextEditingController _searchCtrl;

  static const List<String> _fixedCategories = [
    'All',
    'Tops',
    'Bottoms',
    'Outerwear',
    'Dresses',
    'Footwear',
    'Accessories',
    'Knitwear',
    'Activewear',
    'Swimwear',
  ];

  // Category icon map
  static const Map<String, IconData> _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Tops': Icons.dry_cleaning_rounded,
    'Bottoms': Icons.straighten_rounded,
    'Outerwear': Icons.wb_cloudy_rounded,
    'Dresses': Icons.accessibility_new_rounded,
    'Footwear': Icons.directions_walk_rounded,
    'Accessories': Icons.watch_rounded,
    'Knitwear': Icons.stroller_rounded, // Best fit for knitwear/sweaters
    'Activewear': Icons.fitness_center_rounded,
    'Swimwear': Icons.pool_rounded,
  };

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = context.watch<UserProvider>().displayName;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      floatingActionButton: _buildFAB(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark, userName),
            _buildStatsBar(context, isDark),
            _buildSearchBar(isDark),
            _buildCategoryTabs(isDark),
            const SizedBox(height: 8),
            Expanded(child: _buildGrid(context, isDark)),
          ],
        ),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddClothingScreen()),
        );
      },
      backgroundColor: AppColors.primaryMaroon,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Item',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark, String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Wardrobe',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Welcome back, $userName',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Sort / Filter icon (decorative for now)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 22,
              color: AppColors.primaryMaroon,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats bar ────────────────────────────────────────────────────────────────
  Widget _buildStatsBar(BuildContext context, bool isDark) {
    return Consumer<WardrobeProvider>(
      builder: (context, provider, _) {
        final total = provider.items.length;
        final cats = provider.categories.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              _statChip('$total', 'items', isDark),
              const SizedBox(width: 10),
              _statChip('$cats', 'categories', isDark),
              const SizedBox(width: 10),
              if (_selectedCategory != 'All')
                _statChip(
                  '${provider.countByCategory(_selectedCategory)}',
                  _selectedCategory.toLowerCase(),
                  isDark,
                  highlighted: true,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(
    String value,
    String label,
    bool isDark, {
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primaryMaroon
            : (isDark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: highlighted || isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: highlighted
                    ? Colors.white
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
              ),
            ),
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: highlighted
                    ? Colors.white70
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search clothes, brands...',
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.cardDark : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Category tabs ─────────────────────────────────────────────────────────────
  Widget _buildCategoryTabs(bool isDark) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _fixedCategories.length,
        itemBuilder: (context, i) {
          final cat = _fixedCategories[i];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryMaroon
                    : (isDark ? AppColors.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(22),
                boxShadow: selected || isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categoryIcons[cat] ?? Icons.category_rounded,
                    size: 15,
                    color: selected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Grid ─────────────────────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context, bool isDark) {
    return Consumer<WardrobeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMaroon),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppColors.primaryMaroon,
                ),
                const SizedBox(height: 12),
                Text(
                  'Could not load wardrobe',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final items = provider.search(
          _searchQuery,
          category: _selectedCategory,
        );

        if (items.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildWardrobeCard(context, items[index], isDark, provider);
          },
        );
      },
    );
  }

  // ── Wardrobe card ─────────────────────────────────────────────────────────────
  Widget _buildWardrobeCard(
    BuildContext context,
    WardrobeItem item,
    bool isDark,
    WardrobeProvider provider,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WardrobeItemDetailScreen(item: item)),
      ),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
              SizedBox(height: 4),
              Text(
                'Remove',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Remove Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text('Remove "${item.title}" from wardrobe?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) async {
          try {
            await provider.deleteItem(item.id);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background
                      Container(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.systemGray6,
                      ),
                      // Image
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.primaryMaroon,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 36,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.systemGray,
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Icon(
                            Icons.checkroom_rounded,
                            size: 44,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.systemGray,
                          ),
                        ),
                      // Category badge top-left
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info area
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.brand.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.brand,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    final isFiltered = _searchQuery.isNotEmpty || _selectedCategory != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.search_off_rounded : Icons.checkroom_rounded,
                size: 48,
                color: AppColors.primaryMaroon,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No matching items' : 'Your wardrobe is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try a different search or category'
                  : 'Tap the button below to add your first item',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddClothingScreen()),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add First Item',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
