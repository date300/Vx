import 'dart:ui';
import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart';

// আপনার প্রজেক্টের পাথ অনুযায়ী ইম্পোর্টগুলো ঠিক আছে কি না দেখে নিন
import '../Pages/profile_page.dart';
import '../Pages/home_feed_page.dart';
import '../Pages/Auth/auth_gate_page.dart'; // পাথটি চেক করুন
import 'premium_theme_controller.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // আপনার পেজগুলোর লিস্ট
  final List<Widget> _pages = [
    const HomeFeedPage(),
    const ProfilePage(),
  ];

  // এই ভ্যারিয়েবলটি আপনার আসল লগইন লজিকের সাথে কানেক্ট করবেন
  bool isLoggedIn = false; 

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
            height: 90,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
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

  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 1 && !isLoggedIn) {
          // যদি প্রোফাইল বাটনে ক্লিক হয় এবং লগইন না থাকে
          _showAuthSheet(context, accentColor);
          return; 
        }

        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

  // এই ফাংশনটি দিয়ে অথেন্টিকেশন শিট কল হবে
  void _showAuthSheet(BuildContext context, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // এখানে আপনার AuthGatePage কল করা হয়েছে
        // আপনি যদি চান লগইন হওয়ার পর অটো প্রোফাইল পেজে নিয়ে যাক, 
        // তবে AuthGatePage থেকে ডাটা রিটার্ন করতে পারেন।
        return const AuthGatePage(); 
      },
    ).then((value) {
      // লগইন শিট বন্ধ হওয়ার পর যদি সাকসেসফুল লগইন হয় (value true হলে)
      // তখন ইউজারকে প্রোফাইল পেজে নিয়ে যাবে।
      if (value == true) {
        setState(() {
          isLoggedIn = true;
          _currentIndex = 1; 
        });
      }
    });
  }
}
