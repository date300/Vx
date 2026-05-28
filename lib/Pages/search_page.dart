import 'package:flutter/material.dart';

// ================================================================
//  SEARCH PAGE
// ================================================================
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _recentSearches = ["#nature", "@wild_lens", "butterfly", "animation", "#scifi"];
  bool _isSearching = false;
  String _query = "";

  final List<_TrendingItem> _trending = [
    _TrendingItem("#nature", "128.4K videos", "Trending in Nature", Colors.greenAccent),
    _TrendingItem("#butterfly", "89.2K videos", "Wildlife", Colors.orangeAccent),
    _TrendingItem("#animation", "245K videos", "Trending in Art", Colors.purpleAccent),
    _TrendingItem("#scifi", "430K videos", "Movies & TV", Colors.cyanAccent),
    _TrendingItem("#joyride", "312K videos", "Adventure", Colors.redAccent),
    _TrendingItem("#blender", "196K videos", "3D Art", Colors.blueAccent),
    _TrendingItem("#wildlife", "876K videos", "Nature", Colors.tealAccent),
    _TrendingItem("#car", "267K videos", "Auto", Colors.amberAccent),
  ];

  final List<_SearchResult> _mockResults = [
    _SearchResult("@nature_vibes", "Nature Vibes", "12.4M followers", "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4", true),
    _SearchResult("@wild_lens", "Wild Lens", "8.7M followers", "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4", true),
    _SearchResult("@animation_hub", "Animation Hub", "24.5M followers", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", true),
    _SearchResult("@scifi_world", "SciFi World", "43M followers", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4", true),
    _SearchResult("@blender_art", "Blender Art", "19.6M followers", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", true),
    _SearchResult("@adrenaline_rush", "Adrenaline Rush", "31.2M followers", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", true),
    _SearchResult("@fire_starter", "Fire Starter", "9.8M followers", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", true),
    _SearchResult("@fun_factory", "Fun Factory", "7.6M followers", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", true),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _query = query.trim();
      _isSearching = true;
      if (!_recentSearches.contains(query.trim())) {
        _recentSearches.insert(0, query.trim());
        if (_recentSearches.length > 10) _recentSearches.removeLast();
      }
    });
    _focusNode.unfocus();
  }

  void _clearRecent() => setState(() => _recentSearches.clear());

  void _removeRecent(String item) => setState(() => _recentSearches.remove(item));

  List<_SearchResult> get _filteredResults {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _mockResults.where((r) {
      return r.username.toLowerCase().contains(q) ||
             r.displayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _focusNode,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              textInputAction: TextInputAction.search,
                              onSubmitted: _onSearch,
                              onChanged: (v) {
                                if (v.isEmpty && _isSearching) {
                                  setState(() => _isSearching = false);
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "Search videos, users, hashtags...",
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _isSearching = false;
                                  _query = "";
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _onSearch(_searchCtrl.text),
                    child: const Text("Search", style: TextStyle(
                      color: Colors.pinkAccent, fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Body content
            Expanded(
              child: _isSearching && _query.isNotEmpty
                  ? _buildResults(results)
                  : _buildDiscover(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscover() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                const Text("Recent", style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: _clearRecent,
                  child: const Text("Clear all", style: TextStyle(
                    color: Colors.pinkAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          ..._recentSearches.map((s) => ListTile(
            dense: true,
            leading: const Icon(Icons.history_rounded, color: Colors.white54, size: 22),
            title: Text(s, style: const TextStyle(color: Colors.white, fontSize: 14)),
            trailing: GestureDetector(
              onTap: () => _removeRecent(s),
              child: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
            ),
            onTap: () {
              _searchCtrl.text = s;
              _onSearch(s);
            },
          )),
          const Divider(color: Colors.white10, height: 1),
        ],

        // Trending
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text("Trending", style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _trending.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final t = _trending[i];
            return GestureDetector(
              onTap: () {
                _searchCtrl.text = t.tag;
                _onSearch(t.tag);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text("${i + 1}", style: TextStyle(
                          color: t.color, fontSize: 14, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.tag, style: const TextStyle(
                            color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(t.subtitle, style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(t.count, style: const TextStyle(
                      color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Suggested users
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text("Suggested for you", style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mockResults.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final u = _mockResults[i];
              return _UserCard(user: u);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults(List<_SearchResult> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            Text('No results for "$_query"', style: const TextStyle(
              color: Colors.white54, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text("Try different keywords or hashtags", style: TextStyle(
              color: Colors.white30, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        return ListTile(
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.pinkAccent.withOpacity(0.7), Colors.deepPurpleAccent.withOpacity(0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(r.username.length > 1 ? r.username[1].toUpperCase() : "U",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          title: Text(r.displayName, style: const TextStyle(
            color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
          subtitle: Text("${r.username}  ·  ${r.followers}", style: const TextStyle(
            color: Colors.white54, fontSize: 12.5)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text("Follow", style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          onTap: () {},
        );
      },
    );
  }
}

// ================================================================
//  SEARCH MODELS
// ================================================================
class _TrendingItem {
  final String tag;
  final String count;
  final String subtitle;
  final Color color;
  _TrendingItem(this.tag, this.count, this.subtitle, this.color);
}

class _SearchResult {
  final String username;
  final String displayName;
  final String followers;
  final String videoUrl;
  final bool isVerified;
  _SearchResult(this.username, this.displayName, this.followers, this.videoUrl, this.isVerified);
}

class _UserCard extends StatelessWidget {
  final _SearchResult user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.pinkAccent.withOpacity(0.7), Colors.deepPurpleAccent.withOpacity(0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(user.username.length > 1 ? user.username[1].toUpperCase() : "U",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            ),
          ),
          const SizedBox(height: 10),
          Text(user.displayName, style: const TextStyle(
            color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(user.username, style: const TextStyle(
            color: Colors.white54, fontSize: 11.5),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(user.followers, style: const TextStyle(
            color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text("Follow", style: TextStyle(
              color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
