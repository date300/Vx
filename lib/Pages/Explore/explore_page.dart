import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Services/native_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  // Mock Data for Categories & Trending
  final List<String> _categories = ["For You", "Trending", "Gaming", "Music", "Tech", "Dance", "Food", "Fashion"];
  
  final List<Map<String, String>> _trendingItems = [
    {"title": "#SummerVibes", "views": "1.2B"},
    {"title": "#FlutterDev", "views": "850M"},
    {"title": "#VxRevolution", "views": "500M"},
    {"title": "#NativePerformance", "views": "320M"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP SEARCH BAR
            _buildSearchBar(),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // 2. CATEGORY CAROUSEL
                  _buildCategoryCarousel(),

                  // 3. TRENDING BANNER (Simulated)
                  _buildTrendingBanner(),

                  // 4. TRENDING HASHTAGS SECTIONS
                  for (var trending in _trendingItems)
                    _buildTrendingSection(trending["title"]!, trending["views"]!),
                  
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search content...",
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(CupertinoIcons.search, color: Colors.white54, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCarousel() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: index == 0 ? Colors.white : Colors.white54,
                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Trending Now",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Discover the most viral videos on Vx",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(String hashtag, String views) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hashtag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Trending hashtag • $views views", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(CupertinoIcons.right_chevron, color: Colors.white54, size: 16),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage("https://picsum.photos/200/300"),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
