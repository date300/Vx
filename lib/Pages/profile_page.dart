import 'package:flutter/material.dart';
import '../Layout/premium_theme_controller.dart'; // আপনার থিম কন্ট্রোলারের পাথ ঠিক করে নেবেন

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // MainLayout এর ব্যাকগ্রাউন্ড বজায় রাখার জন্য
      
      // প্রোফাইল পেজের উপরের অ্যাপবার
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // মেনু বাটন (ডান দিকে)
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  // ডান দিকের সাইডবার ওপেন করবে
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      // ডান দিকের সাইডবার (End Drawer)
      endDrawer: Drawer(
        backgroundColor: Colors.grey[900], // ড্রয়ারের ব্যাকগ্রাউন্ড কালার
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
              
              // থিম মোড অপশন (যদি আপনার আলাদা ডার্ক/লাইট মোড লজিক থাকে)
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.white),
                title: const Text("Dark Mode", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // এখানে ডার্ক মোডের লজিক দিন
                  Navigator.pop(context); // সিলেক্ট করার পর ড্রয়ার বন্ধ করতে
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.white),
                title: const Text("Light Mode", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // এখানে লাইট মোডের লজিক দিন
                  Navigator.pop(context);
                },
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
              
              // এক্সেন্ট কালার পিকার
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
      
      // প্রোফাইল পেজের মেইন বডি
      body: const Center(
        child: Text(
          "Profile Page Content",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }

  // একটি ছোট উইজেট ফাংশন কালার ডট বানানোর জন্য
  Widget _buildColorDot(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        // আপনার PremiumTheme এর accentColor চেঞ্জ করে দেবে
        PremiumTheme.accentColor.value = color;
        // আপনি চাইলে ক্লিক করার পর ড্রয়ার বন্ধ করার জন্য নিচের লাইন অ্যাড করতে পারেন
        // Navigator.pop(context);
      },
      child: ValueListenableBuilder<Color>(
        valueListenable: PremiumTheme.accentColor,
        builder: (context, activeColor, child) {
          bool isSelected = activeColor == color;
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)]
                  : null,
            ),
          );
        },
      ),
    );
  }
}
