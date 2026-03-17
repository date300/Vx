import 'package:flutter/material.dart';
import '../Pages/profile_page.dart';
import '../Pages/home_feed_page.dart'; // এই ফাইলটি আপনার থাকতে হবে
import 'premium_theme_controller.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // পেজগুলোর লিস্ট
  final List<Widget> _pages = [
    const HomeFeedPage(), // হোম পেজ (ইন্ডেক্স ০)
    const ProfilePage(),  // প্রোফাইল পেজ (ইন্ডেক্স ১)
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: PremiumTheme.accentColor,
      builder: (context, accentColor, child) {
        return Scaffold(
          backgroundColor: Colors.black, // মেইন ব্যাকগ্রাউন্ড
          body: _pages[_currentIndex], // এখানে বর্তমান পেজটি লোড হবে
          
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index; // ক্লিক করলে ইন্ডেক্স পাল্টে যাবে
              });
            },
            backgroundColor: Colors.grey[900],
            selectedItemColor: accentColor,
            unselectedItemColor: Colors.white54,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}

