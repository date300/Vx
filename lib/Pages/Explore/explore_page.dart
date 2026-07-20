import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Core/constants.dart' as constants;
import '../Home/models/video_data.dart';
import '../Home/widgets/video_viewer_page.dart';
import '../../widgets/vx_premium_refresher.dart';
import 'search_page.dart';

// Top-level function for isolate parsing
Map<String, dynamic> parseExploreData(String responseBody) {
  return jsonDecode(responseBody);
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<dynamic> _trendingVideos = [];
  List<dynamic> _hashtags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrendingData();
  }

  Future<void> _fetchTrendingData() async {
    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/explore/trending'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = await compute(parseExploreData, response.body);
        setState(() {
          _trendingVideos = data['videos'] ?? [];
          _hashtags = data['hashtags'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP SEARCH BAR (NAVIGATES TO SEARCH PAGE)
            _buildSearchBar(),

            Expanded(
              child: _isLoading ? _buildShimmerLoading() : VxPremiumRefresher(
                onRefresh: _fetchTrendingData,
                child: _buildMainExploreView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainExploreView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. MODERN CATEGORY CAROUSEL
        _buildCategoryCarousel(),

        const SizedBox(height: 10),

        // 2. PREMIUM TRENDING BANNER
        _buildTrendingBanner(),

        const SizedBox(height: 10),

        // 3. SECTION HEADER
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Discover Trends",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),

        // 4. MODERN TRENDING SECTIONS
        for (var tag in _hashtags)
          _buildTrendingSection(tag["name"], "${tag["total_videos"]} videos"),
        
        const SizedBox(height: 100), 
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            children: [
              Icon(CupertinoIcons.search, color: Colors.white54, size: 20),
              SizedBox(width: 10),
              Text(
                "Search content...",
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCarousel() {
    final categories = ["For You", "Trending", "Gaming", "Music", "Tech", "Dance", "Food", "Fashion"];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFE2C55) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150, height: 20, color: Colors.white),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(3, (index) => 
                    Container(width: 100, height: 140, margin: const EdgeInsets.only(right: 10), color: Colors.white)
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=1000&auto=format&fit=crop"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.9),
              Colors.black.withValues(alpha: 0.2),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFE2C55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "FEATURED",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Viral Challenges 2024",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const Text(
              "Join the millions creating viral hits today.",
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(String hashtag, String views) {
    final filteredVideos = _trendingVideos.map((v) => VideoData.fromJson(v)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text("#", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hashtag,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.3),
                    ),
                    Text(
                      "Trending now • $views",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.right_chevron, color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredVideos.length,
            itemBuilder: (context, index) {
              final video = filteredVideos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoViewerPage(
                        videos: filteredVideos,
                        initialIndex: index,
                        feedKey: 'explore_$hashtag',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (video.images != null && video.images!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: video.images![0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.white.withValues(alpha: 0.05)),
                            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white24),
                          )
                        else
                          const Center(child: Icon(Icons.play_circle_outline, color: Colors.white24, size: 40)),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                "1.2K",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 4)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
