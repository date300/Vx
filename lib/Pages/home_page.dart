import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../Layout/premium_theme_controller.dart'; // আপনার থিম কন্ট্রোলার

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // কিছু ডেমো ভিডিও (আপনি পরে এপিআই থেকে ডেটা আনবেন)
  final List<String> videoUrls = [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // For You ডিফল্ট
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ১. মূল ভিডিও ফিড (TabBarView দিয়ে Following এবং For You আলাদা করা)
          TabBarView(
            controller: _tabController,
            children: [
              _buildVideoFeed(), // Following Feed
              _buildVideoFeed(), // For You Feed
            ],
          ),

          // ২. উপরের নেভিগেশন (Following, For You, Search)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.live_tv, color: Colors.white, size: 28), // বাম দিকের আইকন
                  
                  // মাঝখানের ট্যাব
                  SizedBox(
                    width: 220,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      tabs: const [
                        Tab(text: "Following"),
                        Tab(text: "For You"),
                      ],
                    ),
                  ),
                  
                  // ডান দিকের সার্চ আইকন
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 30),
                    onPressed: () {
                      // এখানে আপনার Search Page এ যাওয়ার কোড লিখবেন
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // আপনার দেওয়া PageView.builder
  Widget _buildVideoFeed() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videoUrls.length,
      itemBuilder: (context, index) {
        return FeedVideoItem(
          videoUrl: videoUrls[index],
          index: index,
        );
      },
    );
  }
}

// প্রতিটি ভিডিওর জন্য আলাদা Widget (যাতে ভিডিও প্লে/পজ স্মুথলি হয়)
class FeedVideoItem extends StatefulWidget {
  final String videoUrl;
  final int index;

  const FeedVideoItem({super.key, required this.videoUrl, required this.index});

  @override
  State<FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<FeedVideoItem> {
  late VideoPlayerController _videoController;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true); // ভিডিও রিপিট হওয়ার জন্য
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay, // স্ক্রিনে ট্যাপ করলে ভিডিও প্লে/পজ হবে
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ১. ব্যাকগ্রাউন্ড ভিডিও (আপনার ইমেজের বদলে)
          Container(
            color: widget.index % 2 == 0 ? const Color(0xFF0F0F0F) : const Color(0xFF141414),
            child: _videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),

          // প্লে/পজ আইকন (যখন পজ থাকবে)
          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow_rounded, size: 80, color: Colors.white54),
            ),
          
          // ২. প্রিমিয়াম গ্রেডিয়েন্ট ওভারলে
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          
          // ৩. ডান দিকের অ্যাকশন বাটনগুলো (আপনার দেওয়া কোড অনুযায়ী)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildFeedAction(Icons.favorite_rounded, "45K"),
                const SizedBox(height: 24),
                _buildFeedAction(Icons.chat_bubble_rounded, "1.2K"),
                const SizedBox(height: 24),
                _buildFeedAction(Icons.share_rounded, "Share"),
              ],
            ),
          ),
          
          // ৪. নিচের ক্যাপশন এবং ইনফো (আপনার দেওয়া কোড অনুযায়ী)
          Positioned(
            left: 24,
            bottom: 120,
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<Color>(
                  valueListenable: PremiumTheme.accentColor,
                  builder: (context, activeColor, child) {
                     return Text("@Sohan_Dev", 
                       style: TextStyle(color: activeColor, fontSize: 18, fontWeight: FontWeight.bold));
                  }
                ),
                const SizedBox(height: 8),
                const Text("Building the ultimate premium UI. This feels like a billion-dollar app! #Flutter #UIUX", 
                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // আপনার দেওয়া অ্যাকশন বাটন উইজেট
  Widget _buildFeedAction(IconData icon, String text) {
    return Column(
      children: [
        ValueListenableBuilder<Color>(
          valueListenable: PremiumTheme.accentColor,
          builder: (context, activeColor, child) {
             return Icon(icon, color: Colors.white, size: 36);
          }
        ),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
