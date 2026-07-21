import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/theme_provider.dart';
import 'studio_provider.dart';

class VxStudioPage extends StatefulWidget {
  const VxStudioPage({super.key});

  @override
  State<VxStudioPage> createState() => _VxStudioPageState();
}

class _VxStudioPageState extends State<VxStudioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudioProvider>().fetchAnalytics();
    });
  }

  bool _isDark(BuildContext context) {
    final mode = context.read<ThemeProvider>().themeMode;
    if (mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  String _formatNumber(dynamic number) {
    if (number == null) return "0";
    if (number is String) return number;
    int value = 0;
    if (number is int) value = number;
    if (number is double) value = number.toInt();

    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final studioProvider = context.watch<StudioProvider>();

    final bgColor = isDark ? Colors.black : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: titleColor, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Vx Studio",
          style: TextStyle(
              color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: titleColor),
            onPressed: () => studioProvider.fetchAnalytics(),
          ),
        ],
      ),
      body: studioProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : studioProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Error: ${studioProvider.error}",
                          style: TextStyle(color: titleColor)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => studioProvider.fetchAnalytics(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => studioProvider.fetchAnalytics(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Analytics Overview ──
                        _buildSectionHeader("Analytics (Last 7 days)", titleColor),
                        const SizedBox(height: 12),
                        if (studioProvider.analytics != null)
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.6,
                            children: [
                              _buildAnalyticsCard(
                                "Video Views",
                                _formatNumber(studioProvider
                                    .analytics!.overview['views']?['value']),
                                studioProvider.analytics!.overview['views']
                                        ?['trend'] ??
                                    "0%",
                                Colors.blueAccent,
                                cardColor,
                                titleColor,
                              ),
                              _buildAnalyticsCard(
                                "Profile Visits",
                                _formatNumber(studioProvider
                                    .analytics!.overview['profile_visits']?['value']),
                                studioProvider.analytics!.overview['profile_visits']
                                        ?['trend'] ??
                                    "0%",
                                Colors.pinkAccent,
                                cardColor,
                                titleColor,
                              ),
                              _buildAnalyticsCard(
                                "Followers",
                                _formatNumber(studioProvider
                                    .analytics!.overview['followers']?['value']),
                                studioProvider.analytics!.overview['followers']
                                        ?['trend'] ??
                                    "0%",
                                Colors.orangeAccent,
                                cardColor,
                                titleColor,
                              ),
                              _buildAnalyticsCard(
                                "Likes",
                                _formatNumber(studioProvider
                                    .analytics!.overview['likes']?['value']),
                                studioProvider.analytics!.overview['likes']
                                        ?['trend'] ??
                                    "0%",
                                Colors.redAccent,
                                cardColor,
                                titleColor,
                              ),
                            ],
                          ),

                        const SizedBox(height: 32),

                        // ── Performance Chart ──
                        _buildSectionHeader("Performance (Views)", titleColor),
                        const SizedBox(height: 12),
                        _buildHistoryChart(studioProvider.analytics?.dailyStats ?? [], Colors.blueAccent, cardColor, titleColor),

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
                ),
    );
  }

  Widget _buildSectionHeader(String title, Color titleColor) {
    return Text(
      title,
      style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHistoryChart(List<dynamic> stats, Color color, Color cardColor, Color titleColor) {
    if (stats.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text("No data available", style: TextStyle(color: titleColor.withValues(alpha: 0.5)))),
      );
    }

    final List<double> values = stats.map((s) => (s['views'] as num).toDouble()).toList();
    
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: LineChartPainter(values, color, titleColor.withValues(alpha: 0.1)),
      ),
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

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color gridColor;

  LineChartPainter(this.values, this.color, this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final double stepX = size.width / (values.length - 1);
    
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((values[i] - minVal) / range * size.height * 0.8 + size.height * 0.1);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      if (i == values.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    // Draw Grid Lines (simple)
    final gridPaint = Paint()..color = gridColor..strokeWidth = 1;
    for(int i=0; i<=4; i++) {
      double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    
    // Draw points
    final pointPaint = Paint()..color = color..style = PaintingStyle.fill;
    for (int i = 0; i < values.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((values[i] - minVal) / range * size.height * 0.8 + size.height * 0.1);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
