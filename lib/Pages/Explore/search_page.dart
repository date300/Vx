import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _recentSearches = ["Trending", "Fashion", "Gaming", "Music", "Tech"];

  @override
  void initState() {
    super.initState();
    // Request focus when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildSearchHistoryView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(CupertinoIcons.back, color: Colors.white),
            ),
          ),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search content...",
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
                  prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white54, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                    icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.white54, size: 20),
                    onPressed: () => _searchController.clear(),
                  ) : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() {}),
                onSubmitted: (v) {
                  if (v.isNotEmpty && !_recentSearches.contains(v)) {
                    setState(() => _recentSearches.insert(0, v));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistoryView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Searches",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _recentSearches.clear()),
                child: const Text(
                  "Clear all",
                  style: TextStyle(color: Color(0xFFFE2C55)),
                ),
              ),
          ],
        ),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "No recent searches",
              style: TextStyle(color: Colors.white54),
            ),
          )
        else
          Wrap(
            spacing: 10,
            children: _recentSearches.map((s) => Chip(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)),
              onDeleted: () => setState(() => _recentSearches.remove(s)),
              deleteIconColor: Colors.white54,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            )).toList(),
          ),
        const SizedBox(height: 30),
        const Text(
          "Trending for you",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _buildTrendingItem("Technology", "1.2M posts", "Trending in Tech"),
        _buildTrendingItem("Gaming", "850K posts", "Trending in Games"),
        _buildTrendingItem("Music", "2.5M posts", "Trending in Music"),
        _buildTrendingItem("Fashion", "400K posts", "Trending in Lifestyle"),
      ],
    );
  }

  Widget _buildTrendingItem(String title, String subtitle, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.ellipsis, color: Colors.white54, size: 16),
        ],
      ),
    );
  }
}
