import 'package:flutter/material.dart';
import 'home_content.dart';
import 'community_screen.dart';
import 'calendar_screen.dart';
import 'cart_screen.dart';
import 'auth/login_screen.dart';
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
      HomeContent(onTabChange: _onTabChange),
      const CommunityScreen(),
      const CalendarScreen(),
      const CartScreen(),
      const LoginScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: DigiBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabChange,
      ),
    );
  }
}
