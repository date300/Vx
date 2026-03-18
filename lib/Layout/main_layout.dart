import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// আপনার তৈরি করা আগের ফাইলটি ইম্পোর্ট করুন
import '../Pages/Auth/auth_gate_page.dart';

// পেজগুলোর ইম্পোর্ট (আপনার ফাইলের লোকেশন অনুযায়ী)
import '../Pages/home_page.dart';
import '../Pages/explore_page.dart';
import '../Pages/profile_page.dart';

// টেস্টিংয়ের জন্য একটি ডামি AuthService (পরে আপনার আসল লজিক দিয়ে রিপ্লেস করে নিবেন)
class AuthService {
  static bool isLoggedIn = false; // এটি true করলে প্রোফাইল পেজে যাওয়া যাবে
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // শুরুতে 'Home' (0) ইনডেক্স সিলেক্ট থাকবে
  int _selectedIndex = 0;

  // নেভিগেশন পেজগুলোর লিস্ট
  final List<Widget> _pages = const [
    HomeFeedPage(),
    ExplorePage(),
    ProfilePage(),
  ];

  // এই ফাংশনটি প্রতিটি ট্যাপ নিয়ন্ত্রণ করবে
  void _onItemTapped(int index) {
    // ১. প্রথমে যে ট্যাবে ক্লিক করা হয়েছে, সেই পেজটি ওপেন করার জন্য ইনডেক্স সেট করে দিচ্ছি
    setState(() {
      _selectedIndex = index;
    });

    // ২. এরপর চেক করছি, যদি প্রোফাইল পেজ (ইনডেক্স ২) হয় এবং ইউজার লগ-ইন না থাকে
    if (index == 2 && AuthService.isLoggedIn == false) {
      // তাহলে প্রোফাইল পেজের উপরে পপ-আপটি ওপেন হবে
      showAuthPopup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // প্রিমিয়াম ব্ল্যাক থিম
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // প্রিমিয়াম iOS স্টাইল Glassmorphic Bottom Navigation
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0), // হাই-কোয়ালিটি ব্লার
          child: SafeArea(
            bottom: true,
            child: Container(
              height: 65, // একটি নির্দিষ্ট হাইট দিলে দেখতে ভালো লাগে
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // স্বচ্ছ ব্যাকগ্রাউন্ড
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1), // উপরে খুবই হালকা একটি বর্ডার
                    width: 0.5,
                  ),
                ),
              ),
              child: Theme(
                // ট্যাপ করার সময় যে রিং ইফেক্ট হয়, সেটা বন্ধ করার জন্য (iOS এ রিং হয় না)
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white.withOpacity(0.4),
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped, // আমাদের ঠিক করা লজিক ফাংশন
                  items: const [
                    BottomNavigationBarItem(
                      // আনসিলেক্ট অবস্থায় আউটলাইন Cupertino আইকন
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(CupertinoIcons.house, size: 24),
                      ),
                      // সিলেক্ট অবস্থায় সলিড Cupertino আইকন
                      activeIcon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(CupertinoIcons.house_fill, size: 24),
                      ),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(CupertinoIcons.search, size: 24),
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(CupertinoIcons.search, size: 24), 
                      ),
                      label: "Discover",
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(CupertinoIcons.person, size: 24),
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(CupertinoIcons.person_fill, size: 24),
                      ),
                      label: "Profile",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
