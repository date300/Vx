import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ShareOption {
  final dynamic icon;
  final String  label;
  final Color   bgColor;
  final bool    isFa;
  const ShareOption({
    required this.icon, required this.label,
    required this.bgColor, this.isFa = true,
  });
}

class ShareSheet extends StatelessWidget {
  final String? videoUrl;
  final VoidCallback? onMore;
  const ShareSheet({super.key, this.videoUrl, this.onMore});

  static const _options = [
    ShareOption(icon: Icons.link_rounded,         label: "Copy Link",   bgColor: Color(0xFF333333), isFa: false),
    ShareOption(icon: FontAwesomeIcons.whatsapp,  label: "WhatsApp",    bgColor: Color(0xFF25D366)),
    ShareOption(icon: FontAwesomeIcons.telegram,  label: "Telegram",    bgColor: Color(0xFF0088CC)),
    ShareOption(icon: FontAwesomeIcons.facebook,  label: "Facebook",    bgColor: Color(0xFF1877F2)),
    ShareOption(icon: FontAwesomeIcons.instagram, label: "Instagram",   bgColor: Color(0xFFE1306C)),
    ShareOption(icon: FontAwesomeIcons.xTwitter,  label: "X (Twitter)", bgColor: Color(0xFF000000)),
    ShareOption(icon: Icons.more_horiz_rounded,   label: "More",        bgColor: Color(0xFF444444), isFa: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Share to", style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemBuilder: (_, i) {
                final opt = _options[i];
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    if (opt.label == "More" && onMore != null) {
                      onMore!();
                    } else if (opt.label == "Copy Link") {
                      if (videoUrl != null) {
                        await Clipboard.setData(ClipboardData(text: videoUrl!));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Link copied to clipboard! 🔗"),
                            duration: Duration(milliseconds: 900),
                            backgroundColor: Colors.pinkAccent,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      }
                    } else {
                      if (videoUrl != null) {
                        await Share.share('Check out this video on Vx: $videoUrl');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Shared via ${opt.label} ?"),
                          duration: const Duration(milliseconds: 900),
                          backgroundColor: opt.bgColor == const Color(0xFF333333)
                              ? Colors.pinkAccent : opt.bgColor,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          color: opt.bgColor, shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: opt.bgColor.withValues(alpha: 0.4), blurRadius: 10),
                          ],
                        ),
                        child: Center(
                          child: opt.isFa
                              ? FaIcon(opt.icon as FaIconData, color: Colors.white, size: 24)
                              : Icon(opt.icon  as IconData, color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(opt.label, style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
