import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SuggestedAccounts extends StatelessWidget {
  const SuggestedAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested accounts',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildAccountItem(
            name: 'john_doe',
            subtitle: 'John Doe',
            imageUrl: 'https://i.pravatar.cc/150?u=1',
          ),
          _buildAccountItem(
            name: 'travel_vlogs',
            subtitle: 'Traveler',
            imageUrl: 'https://i.pravatar.cc/150?u=2',
          ),
          _buildAccountItem(
            name: 'tech_guru',
            subtitle: 'Tech Master',
            imageUrl: 'https://i.pravatar.cc/150?u=3',
          ),
          _buildAccountItem(
            name: 'foodie_life',
            subtitle: 'Food Lover',
            imageUrl: 'https://i.pravatar.cc/150?u=4',
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              'See all',
              style: TextStyle(
                color: Color(0xFFFE2C55),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 32),
          const Text(
            'Discover',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('#flutter'),
              _buildTag('#dart'),
              _buildTag('#programming'),
              _buildTag('#tiktok_clone'),
              _buildTag('#mobile_dev'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem({
    required String name,
    required String subtitle,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 14,
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }
}
