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
            height: 100, // গ্লো এবং বর্ডারের জন্য একটু জায়গা বাড়ানো হয়েছে
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

  // প্রফেশনাল নেভিগেশন আইটেম ডিজাইন (ProfilePage এর Color Dot এর মত)
  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 1 && !isLoggedIn) {
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
          // প্রোফাইল পেজের ডটের মতো সার্কুলার বর্ডার ও গ্লো
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12), // আইকনের চারপাশে সুন্দর স্পেস
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // কোনো সলিড ব্যাকগ্রাউন্ড নেই, শুধু বর্ডার এবং গ্লো
              border: isSelected
                  ? Border.all(color: accentColor, width: 2.5) // সিলেক্ট হলে থিম কালারের বর্ডার
                  : Border.all(color: Colors.transparent, width: 2.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 26,
              color: isSelected ? accentColor : Colors.white54,
            ),
          ),
          const SizedBox(height: 6),
          // টেক্সট এনিমেশন (সিলেক্ট হলে একটু বড় এবং বোল্ড হবে)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isSelected ? 13 : 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? accentColor : Colors.white54,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  // অথেন্টিকেশন বটম শিট
  void _showAuthSheet(BuildContext context, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AuthGatePage(); 
      },
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
