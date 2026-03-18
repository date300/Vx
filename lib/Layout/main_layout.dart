import 'dart:ui';
import 'package:flutter/cupertino.dart'; // iOS স্টাইল আইকনের জন্য
import 'package:flutter/material.dart';

// আপনার প্রজেক্টের পাথ অনুযায়ী ইম্পোর্টগুলো
import '../Pages/profile_page.dart';
import '../Pages/home_feed_page.dart';
import 'premium_theme_controller.dart';
// import '../Pages/Auth/auth_gate_page.dart'; // যখন আপনার AuthGatePage তৈরি হয়ে যাবে, তখন এটি আনকমেন্ট করবেন

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

  // ব্যবহারকারী লগইন করা আছে কি না, তা ট্র্যাক করার জন্য একটি ডামি ভ্যারিয়েবল।
  // ভবিষ্যতে এখানে আপনার Firebase বা Auth লজিক বসাবেন।
  bool isLoggedIn = false; 

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
        // প্রোফাইল বাটনে ক্লিক হলে (index 1) চেক করুন
        if (index == 1) {
          if (!isLoggedIn) {
            // ইউজার লগইন না থাকলে বটম শিট দেখান এবং রিটার্ন করুন
            _showPremiumAuthSheet(context, accentColor);
            return; // এখানেই থেমে যাবে, পেজ চেঞ্জ হবে না
          }
        }

        // অন্য কোনো ট্যাব হলে বা ইউজার লগইন থাকলে পেজ চেঞ্জ হবে
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

  // অথেন্টিকেশন বটম শিট দেখানোর ফাংশন
  void _showPremiumAuthSheet(BuildContext context, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // গ্লাসমর্ফিজম ইফেক্টের জন্য ট্রান্সপারেন্ট
      builder: (context) {
        
        // এখানে আপনি চাইলে আপনার নিজস্ব "AuthGatePage()" রিটার্ন করতে পারেন।
        // আপাতত একটি সুন্দর ডেমো শিট ডিজাইন করে দিলাম:
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              height: 400, // শিটের উচ্চতা
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ড্র্যাগ হ্যান্ডেল
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // আইকন
                  Icon(CupertinoIcons.lock_shield_fill, size: 60, color: accentColor),
                  const SizedBox(height: 20),
                  
                  // টেক্সট
                  const Text(
                    "Authentication Required",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Please log in to access your profile and premium features.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // লগইন বাটন
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        // এখানে লগইন লজিক বসবে। আপাতত শিটটি বন্ধ করে দিচ্ছি।
                        Navigator.pop(context);
                        
                        // টেস্টিংয়ের জন্য লগইন স্ট্যাটাস পরিবর্তন করে প্রোফাইল পেজে নিয়ে যাওয়ার ডেমো:
                        /*
                        setState(() {
                          isLoggedIn = true;
                          _currentIndex = 1;
                        });
                        */
                      },
                      child: const Text(
                        "Log In Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
