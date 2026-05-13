import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../utils/colors.dart';

class _ModelItem {
  final String name;
  final String url;
  final IconData icon;

  const _ModelItem({required this.name, required this.url, required this.icon});
}

class VirtualFittingRoomScreen extends StatefulWidget {
  const VirtualFittingRoomScreen({super.key});

  @override
  State<VirtualFittingRoomScreen> createState() =>
      _VirtualFittingRoomScreenState();
}

class _VirtualFittingRoomScreenState extends State<VirtualFittingRoomScreen> {
  int _selectedIndex = 0;

  final List<_ModelItem> _models = [
    const _ModelItem(
      name: 'AI Female',
      url: 'https://threejs.org/examples/models/gltf/Xbot.glb',
      icon: Icons.face_3_rounded,
    ),
    const _ModelItem(
      name: 'AI Male',
      url: 'https://threejs.org/examples/models/gltf/Soldier.glb',
      icon: Icons.face_6_rounded,
    ),
    const _ModelItem(
      name: 'Dresses',
      url: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      icon: Icons.dry_cleaning_rounded,
    ),
    const _ModelItem(
      name: 'Bottoms',
      url: 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
      icon: Icons.straighten_rounded,
    ),
    const _ModelItem(
      name: 'Footwear',
      url: 'https://modelviewer.dev/shared-assets/models/DamagedHelmet.glb',
      icon: Icons.ice_skating_rounded,
    ),
    const _ModelItem(
      name: 'Outerwear',
      url: 'https://modelviewer.dev/shared-assets/models/Horse.glb',
      icon: Icons.shield_rounded,
    ),
  ];

  void _addCustomModel() {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.textSecondaryDark.withOpacity(0.4)
                        : AppColors.systemGray2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add 3D Model',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Paste a .glb or .gltf model URL',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Model Name',
                    hintText: 'e.g. Summer Dress',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppColors.primaryMaroon, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'Model URL',
                    hintText: 'https://example.com/model.glb',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppColors.primaryMaroon, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final url = urlController.text.trim();
                      final name = nameController.text.trim();
                      if (url.isNotEmpty) {
                        setState(() {
                          _models.add(_ModelItem(
                            name: name.isEmpty ? 'Custom Model' : name,
                            url: url,
                            icon: Icons.view_in_ar_rounded,
                          ));
                          _selectedIndex = _models.length - 1;
                        });
                        Navigator.pop(ctx);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add Model',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMaroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentModel = _models[_selectedIndex];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Virtual Fitting Room'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'Interactive 3D Prototype',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Rotate, zoom, and explore items in 3D to see how they look from every angle.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          // ── 3D Viewer ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  ModelViewer(
                    key: ValueKey(currentModel.url),
                    backgroundColor: Colors.transparent,
                    src: currentModel.url,
                    alt: 'A 3D model of ${currentModel.name}',
                    ar: true,
                    autoRotate: true,
                    disableZoom: false,
                    cameraControls: true,
                  ),
                  // Model name badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMaroon.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(currentModel.icon,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            currentModel.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Model Selector Row ──
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _models.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final model = _models[index];
                        final isSelected = index == _selectedIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 88,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryMaroon
                                  : (isDark
                                      ? AppColors.cardDark
                                      : AppColors.systemGray6),
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.accentMaroon, width: 2)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryMaroon
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  model.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                  size: 26,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  model.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ── Add Button ──
                  GestureDetector(
                    onTap: _addCustomModel,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryMaroon,
                            AppColors.accentMaroon,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryMaroon.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
