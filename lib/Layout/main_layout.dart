import 'dart:ui';
import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart';

import '../Pages/profile_page.dart';
import '../Pages/home_feed_page.dart';
import '../Pages/Auth/auth_gate_page.dart'; 
import 'premium_theme_controller.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool isLoggedIn = false; 

  final List<Widget> _pages = [
    const HomeFeedPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: PremiumTheme.accentColor,
      builder: (context, accentColor, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true, 
          body: _pages[_currentIndex],
          bottomNavigationBar: Container(
            height: 100,
            color: Colors.transparent,
            child: Stack(
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, CupertinoIcons.house_fill, "Home", accentColor),
                      _buildNavItem(1, CupertinoIcons.person_fill, "Profile", accentColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 1 && !isLoggedIn) {
          _showAuthSheet(context, accentColor);
          return; 
        }
        setState(() => _currentIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? accentColor : Colors.transparent, 
                width: 2.5
              ),
              boxShadow: isSelected ? [
                BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)
              ] : [],
            ),
            child: Icon(icon, size: 26, color: isSelected ? accentColor : Colors.white54),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isSelected ? 13 : 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? accentColor : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthSheet(BuildContext context, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AuthGatePage(), // এখান থেকে const সরানো হয়েছে যদি প্রয়োজন হয়
    ).then((value) {
      if (value == true) {
        setState(() {
          isLoggedIn = true;
          _currentIndex = 1;
        });
      }
    });
  }
}
