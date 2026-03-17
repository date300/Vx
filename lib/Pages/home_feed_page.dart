import 'package:flutter/material.dart';
import '../Layout/premium_theme_controller.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // ব্যাকগ্রাউন্ড ইমেজ বা ভিডিও (এখানে আপাতত কালার প্লেসহোল্ডার)
            Container(
              color: index % 2 == 0 ? const Color(0xFF0F0F0F) : const Color(0xFF141414),
              child: Image.network(
                "https://source.unsplash.com/random/800x1200?nature,dark", // Placeholder
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            
            // প্রিমিয়াম গ্রেডিয়েন্ট ওভারলে (টেক্সট রিডেবিলিটির জন্য)
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
            
            // ডান দিকের অ্যাকশন বাটনগুলো
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
            
            // নিচের ক্যাপশন এবং ইনফো
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
        );
      },
    );
  }

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
