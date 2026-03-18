import 'package:flutter/material.dart';

// প্রোজেক্টের নামের ঝামেলা এড়াতে সরাসরি পাথ ব্যবহার করা হলো
import '../Pages/home_page.dart';
import '../Pages/explore_page.dart';
import '../Pages/profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // অ্যাপ ওপেন হলে ডিফল্টভাবে Home (Index 0) দেখাবে
  int _selectedIndex = 0;

  // পেজগুলোর লিস্ট
  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const ProfilePage(),
  ];

  final List<String> _pageTitles = [
    "Home",
    "Explore",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // ডার্ক প্রিমিয়াম ব্যাকগ্রাউন্ড

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.palette_outlined, color: Colors.white),
                tooltip: "Theme Settings",
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
          ),
          const SizedBox(width: 12),
        ],
      ),

      // থিম সেটিংস ড্রয়ার
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Text(
                  "Appearance",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white10, thickness: 1),
              
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded, color: Colors.blueAccent),
                title: const Text("Dark Theme", style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.check_circle, color: Colors.blueAccent, size: 20),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_rounded, color: Colors.white54),
                title: const Text("Light Theme", style: TextStyle(color: Colors.white54)),
                onTap: () => Navigator.pop(context),
              ),

              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text("Vx Premium v1.0", style: TextStyle(color: Colors.white24, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),

      // IndexedStack ব্যবহার করা হয়েছে যাতে পেজ সুইচ করলে আগের পেজের ডেটা বা স্ক্রল পজিশন ঠিক থাকে
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white38,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home_filled, color: Colors.blueAccent),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore, color: Colors.blueAccent),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: Colors.blueAccent),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
