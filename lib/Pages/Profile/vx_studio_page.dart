import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/theme_provider.dart';

class VxStudioPage extends StatelessWidget {
  const VxStudioPage({super.key});

  bool _isDark(BuildContext context) {
    final mode = context.read<ThemeProvider>().themeMode;
    if (mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final isDark = _isDark(context);

    final bgColor = isDark ? Colors.black : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Vx Studio",
          style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Analytics Overview ──
            _buildSectionHeader("Analytics (Last 7 days)", titleColor),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildAnalyticsCard("Video Views", "1.2M", "+12%", Colors.blueAccent, cardColor, titleColor),
                _buildAnalyticsCard("Profile Visits", "45.8K", "+5.4%", Colors.pinkAccent, cardColor, titleColor),
                _buildAnalyticsCard("Followers", "12.8K", "+8%", Colors.orangeAccent, cardColor, titleColor),
                _buildAnalyticsCard("Likes", "893K", "+2.1%", Colors.redAccent, cardColor, titleColor),
              ],
            ),

            const SizedBox(height: 32),

            // ── Creator Tools ──
            _buildSectionHeader("Creator Tools", titleColor),
            const SizedBox(height: 12),
            _buildToolItem(CupertinoIcons.graph_circle, "Creator Portal", "Tips and guides for growth", titleColor, cardColor),
            _buildToolItem(CupertinoIcons.speaker_2, "Promote", "Boost your video views", titleColor, cardColor),
            _buildToolItem(CupertinoIcons.money_dollar_circle, "Monetization", "Check your earnings", titleColor, cardColor),
            _buildToolItem(CupertinoIcons.shield_lefthalf_fill, "Copyright Check", "Verify your content", titleColor, cardColor),

            const SizedBox(height: 32),

            // ── Support ──
            _buildSectionHeader("Support", titleColor),
            const SizedBox(height: 12),
            _buildToolItem(CupertinoIcons.question_circle, "Help Center", "Find answers to your questions", titleColor, cardColor),
            _buildToolItem(CupertinoIcons.chat_bubble_2, "Feedback", "Tell us what you think", titleColor, cardColor),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color titleColor) {
    return Text(
      title,
      style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAnalyticsCard(String label, String value, String trend, Color trendColor, Color cardColor, Color titleColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: titleColor.withValues(alpha: 0.5), fontSize: 13)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(trend, style: TextStyle(color: trendColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem(IconData icon, String title, String subtitle, Color titleColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: titleColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: titleColor, size: 24),
        ),
        title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: titleColor.withValues(alpha: 0.5), fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: titleColor.withValues(alpha: 0.2), size: 14),
        onTap: () {},
      ),
    );
  }
}
