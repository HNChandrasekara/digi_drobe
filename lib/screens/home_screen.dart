import 'package:flutter/material.dart';
import 'home_content.dart';
import 'community_screen.dart';
import 'calendar_screen.dart';
import 'wardrobe_screen.dart';
import 'settings_screen.dart';
import '../widgets/digi_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(
        onTabChange: _onTabChange,
        onProfileTap: () {
          // Switch to Settings tab (index 4)
          _onTabChange(4);
        },
      ),
      const CommunityScreen(),
      const CalendarScreen(),
      const WardrobeScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: DigiBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabChange,
      ),
    );
  }
}
