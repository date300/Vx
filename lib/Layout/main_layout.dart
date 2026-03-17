import 'dart:ui';
import 'package:flutter/cupertino.dart'; // iOS স্টাইল আইকনের জন্য
import 'package:flutter/material.dart';
import '../Pages/profile_page.dart';
import '../Pages/home_feed_page.dart';
import 'premium_theme_controller.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

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
          extendBody: true, // এটি নেভিগেশন বারের নিচে কন্টেন্ট পাঠাতে সাহায্য করে (ব্লার ইফেক্টের জন্য জরুরি)
          body: _pages[_currentIndex],
          
          // কাস্টম iOS স্টাইল নেভিগেশন বার
          bottomNavigationBar: Container(
            height: 90,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                // ১. ব্লার ইফেক্ট (Glassmorphism)
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
                
                // ২. নেভিগেশন আইকনস
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  // কাস্টম আইটেম বিল্ডার (Premium Touch)
  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // আইকন এনিমেশন বা গ্লো ইফেক্ট
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              boxShadow: isSelected ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ] : [],
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? accentColor : Colors.grey.withOpacity(0.6),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? accentColor : Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
