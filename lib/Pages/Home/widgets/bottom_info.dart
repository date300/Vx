import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Profile/profile_page.dart';
import '../models/video_data.dart';

class BottomInfo extends StatelessWidget {
  final VideoData    data;
  final bool         isFollowing;
  final bool         expanded;
  final VoidCallback onToggleCaption;
  final VoidCallback onFollow;

  const BottomInfo({
    super.key,
    required this.data,
    required this.isFollowing,
    required this.expanded,
    required this.onToggleCaption,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Premium Username Row
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(username: data.username),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small Avatar (Instagram Style)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: ClipOval(
                  child: data.avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: data.avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white10),
                          errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white, size: 20),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              Text(
                '@${data.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.verified, color: Colors.blueAccent, size: 16),
              ),
              if (!isFollowing)
                GestureDetector(
                  onTap: onFollow,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Follow",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Gradient Caption
        GestureDetector(
          onTap: onToggleCaption,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topLeft,
            child: Text(
              data.caption,
              maxLines: expanded ? 10 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 1)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
