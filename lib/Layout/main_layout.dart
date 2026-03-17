import 'dart:ui';
import 'package:flutter/material.dart';
import 'premium_theme_controller.dart';
import '../Pages/home_feed_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeFeedPage(),
    const Center(child: Text("Discover", style: TextStyle(color: Colors.white, fontSize: 24))),
    const Center(child: Text("Inbox", style: TextStyle(color: Colors.white, fontSize: 24))),
    const Center(child: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.black, // Pure OLED Black
      extendBody: true,
      body: Row(
        children: [
          // ডেক্সটপের জন্য আইকন-বেসড সাইডবার (কোনো টেক্সট লোগো ছাড়া)
          if (!isMobile) _buildDesktopSidebar(),
          
          // মেইন কন্টেন্ট
          Expanded(
            child: Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
                // ডেক্সটপ টপবার
                if (!isMobile) _buildDesktopTopBar(),
              ],
            ),
          ),
        ],
      ),
      // মোবাইলের জন্য ফ্লোটিং গ্লাস বটম নেভিগেশন
      bottomNavigationBar: isMobile ? _buildMobileGlassNav() : null,
    );
  }

  // === মোবাইল গ্লাস নেভিগেশন ===
  Widget _buildMobileGlassNav() {
    return ValueListenableBuilder<Color>(
      valueListenable: PremiumTheme.accentColor,
      builder: (context, activeColor, child) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40), // iOS Pill Shape
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08), // Ultra subtle frosted glass
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navIcon(Icons.home_rounded, 0, activeColor),
                    _navIcon(Icons.explore_rounded, 1, activeColor),
                    // সেন্টার অ্যাকশন বাটন (টিকটকের প্লাস বাটনের মত)
                    _buildCenterActionButton(activeColor),
                    _navIcon(Icons.chat_bubble_rounded, 2, activeColor),
                    _navIcon(Icons.person_rounded, 3, activeColor),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // নেভিগেশন আইকন বিল্ডার
  Widget _navIcon(IconData icon, int index, Color activeColor) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: isSelected ? 30 : 26,
          color: isSelected ? activeColor : Colors.white54,
        ),
      ),
    );
  }

  // টিকটকের মত মাঝখানের স্পেশাল বাটন
  Widget _buildCenterActionButton(Color activeColor) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [activeColor, activeColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Icon(Icons.add, color: Colors.black, size: 30),
    );
  }

  // === ডেক্সটপ সাইডবার (শুধুমাত্র আইকন) ===
  Widget _buildDesktopSidebar() {
    return ValueListenableBuilder<Color>(
      valueListenable: PremiumTheme.accentColor,
      builder: (context, activeColor, child) {
        return Container(
          width: 80,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navIcon(Icons.home_rounded, 0, activeColor),
              const SizedBox(height: 32),
              _navIcon(Icons.explore_rounded, 1, activeColor),
              const SizedBox(height: 32),
              _navIcon(Icons.chat_bubble_rounded, 2, activeColor),
              const SizedBox(height: 32),
              _navIcon(Icons.person_rounded, 3, activeColor),
            ],
          ),
        );
      },
    );
  }

  // === ডেক্সটপ টপবার (এখানে ব্র্যান্ডিং থাকবে) ===
  Widget _buildDesktopTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "SKYTHOR", // টপ বারে লোগো টেক্সট 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 22, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: 1.5
                  ),
                ),
                ValueListenableBuilder<Color>(
                  valueListenable: PremiumTheme.accentColor,
                  builder: (context, activeColor, child) {
                     return Icon(Icons.search, color: activeColor);
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
