import 'dart:ui'; // ব্লার ইফেক্টের জন্য এটি যোগ করা হয়েছে
import 'package:flutter/material.dart';

import '../Pages/home_page.dart';
import '../Pages/explore_page.dart';
import '../Pages/profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeFeedPage(),
    ExplorePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true দেওয়ার কারণে পেজের কন্টেন্ট (ভিডিও/ছবি) নেভিগেশন বারের নিচ পর্যন্ত যাবে
      extendBody: true, 
      backgroundColor: Colors.black, // আইওএস স্টাইল ডার্ক মোডের জন্য পিওর ব্ল্যাক

      // টপ বার (AppBar) পুরোপুরি বাদ দেওয়া হয়েছে

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // প্রিমিয়াম iOS স্টাইল Glassmorphic Bottom Navigation
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0), // হাই-কোয়ালিটি ব্লার ইফেক্ট
          child: Container(
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
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    // আনসিলেক্ট অবস্থায় আউটলাইন আইকন
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.home_outlined, size: 26),
                    ),
                    // সিলেক্ট অবস্থায় সলিড আইকন (iOS স্ট্যান্ডার্ড)
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.home_rounded, size: 26),
                    ),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.search_rounded, size: 26), 
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      // সিলেক্ট হলে আইকন কিছুটা বড় ও উজ্জ্বল দেখাবে
                      child: Icon(Icons.search_rounded, size: 28, color: Colors.white), 
                    ),
                    label: "Discover",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.person_outline_rounded, size: 26),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.person_rounded, size: 26),
                    ),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
