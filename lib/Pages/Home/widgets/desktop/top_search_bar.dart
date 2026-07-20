import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TopSearchBar extends StatelessWidget {
  const TopSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search accounts and videos',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          const Icon(
            CupertinoIcons.search,
            color: Colors.white54,
            size: 20,
          ),
        ],
      ),
    );
  }
}
