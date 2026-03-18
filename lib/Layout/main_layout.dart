import 'package:flutter/material.dart';
// আপনার থিম কন্ট্রোলারটি এখানে ইম্পোর্ট করবেন যদি দরকার হয়
// import 'premium_theme_controller.dart'; 

// আলাদা ফোল্ডার থেকে পেজগুলো ইম্পোর্ট করা হলো
import '../Pages/home_page.dart';
import '../Pages/explore_page.dart';
import '../Pages/profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 2; // ডিফল্টভাবে Profile পেজ দেখাবে

  // ইম্পোর্ট করা পেজগুলোর লিস্ট
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
      backgroundColor: const Color(0xFF1E1E1E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.palette, color: Colors.white),
                tooltip: "Theme Settings",
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
          ),
          const SizedBox(width: 16),
        ],
      ),

      endDrawer: Drawer(
        backgroundColor: Colors.grey[900],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Theme & Colors",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white24),

              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.white),
                title: const Text("Dark Mode", style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.white),
                title: const Text("Light Mode", style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Accent Colors",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    _buildColorDot(context, Colors.blue),
                    _buildColorDot(context, Colors.green),
                    _buildColorDot(context, Colors.redAccent),
                    _buildColorDot(context, Colors.purple),
                    _buildColorDot(context, Colors.orange),
                    _buildColorDot(context, Colors.teal),
                    _buildColorDot(context, Colors.pink),
                    _buildColorDot(context, Colors.yellow),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // _pages লিস্ট থেকে ইনডেক্স অনুযায়ী পেজ দেখাবে
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        // PremiumTheme.accentColor.value = color; // আনকমেন্ট করে নিবেন
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
