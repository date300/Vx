import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Core/constants.dart' as constants;
import '../../Layout/theme_provider.dart';
import '../Auth/auth_gate_page.dart';
import 'profile_provider.dart';
import '../Settings/settings_page.dart';
import '../../Core/config.dart';
import '../../Core/utils/format_util.dart';
import '../Home/widgets/video_viewer_page.dart';
import '../Home/models/video_data.dart';
import '../../Services/auth_service.dart';
import '../../Services/draft_service.dart';
import '../../widgets/vx_premium_refresher.dart';
import '../Upload/video_publish_screen.dart';
import 'edit_profile_page.dart';
import 'follow_list_page.dart';
import 'vx_studio_page.dart';
import '../Upload/widgets/vx_premium_loader.dart';
import '../Inbox/chat_detail_screen.dart';

class ProfilePage extends StatefulWidget {
  final String? username;
  const ProfilePage({super.key, this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _authToken = '';
  List<VideoDraft> _drafts = [];

  bool _isLoadingPublic = false;
  Map<String, dynamic>? _publicProfile;
  List<Map<String, dynamic>> _publicVideos = [];
  bool _isFollowing = false;
  bool _isFollowBack = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.username == null ? 4 : 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadDrafts() {
    setState(() {
      _drafts = DraftService.getDrafts();
    });
  }

  Future<void> _loadData() async {
    final isLoggedIn = await AuthService.checkIsLoggedIn();
    final token = await AuthService.getToken();
    _authToken = token ?? '';

    if (widget.username == null) {
      if (!isLoggedIn) {
        if (mounted) setState(() {}); // Trigger rebuild to show "Login Required" state
        return;
      }
      if (_authToken.isNotEmpty && mounted) {
        final provider = context.read<ProfileProvider>();
        await Future.wait([
          provider.fetchProfile(_authToken),
          provider.fetchMyVideos(_authToken),
        ]);
        _loadDrafts();
      }
    } else {
      await _loadPublicProfile();
    }
  }

  Future<void> _loadPublicProfile() async {
    if (mounted) setState(() => _isLoadingPublic = true);
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken.isNotEmpty) 'Authorization': 'Bearer $_authToken',
      };
      
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/user/profile/${widget.username}'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        _publicProfile = data['data'];
        _isFollowing = _publicProfile?['is_following'] == true;
        _isFollowBack = _publicProfile?['is_followed_by'] == true;
        
        final videoRes = await http.get(
          Uri.parse('${constants.baseUrl}/user/${widget.username}/videos'),
          headers: headers,
        );
        final videoData = jsonDecode(videoRes.body);
        if (videoRes.statusCode == 200 && videoData['status'] == true) {
          _publicVideos = List<Map<String, dynamic>>.from(videoData['data'] ?? []);
        }
      } else {
        _publicProfile = null;
      }
    } catch (e) {
      debugPrint("Error loading public profile: $e");
      _publicProfile = null;
    } finally {
      if (mounted) setState(() => _isLoadingPublic = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_publicProfile == null || _authToken.isEmpty) return;
    final wasFollowing = _isFollowing;
    setState(() => _isFollowing = !wasFollowing);

    try {
      final response = wasFollowing
          ? await http.delete(
              Uri.parse('${constants.baseUrl}/user/follow/${widget.username}'),
              headers: {'Authorization': 'Bearer $_authToken'},
            )
          : await http.post(
              Uri.parse('${constants.baseUrl}/user/follow/${widget.username}'),
              headers: {'Authorization': 'Bearer $_authToken'},
            );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        setState(() {
          _isFollowing = data['data']?['is_following'] == true;
          if (_publicProfile != null) _publicProfile!['followers'] = data['data']?['followers'];
        });
      } else {
        setState(() => _isFollowing = wasFollowing);
      }
    } catch (e) {
      setState(() => _isFollowing = wasFollowing);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1);
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);

    final profileProvider = context.watch<ProfileProvider>();
    final isSelf = widget.username == null;
    
    // Check login status for self profile
    if (isSelf) {
      return FutureBuilder<bool>(
        future: AuthService.checkIsLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && profileProvider.userProfile == null) {
            return Scaffold(
              backgroundColor: bgColor,
              body: const Center(child: VxPremiumLoader(color: Color(0xFFFE2C55))),
            );
          }
          
          final isLoggedIn = snapshot.data ?? false;
          if (!isLoggedIn) {
            return _buildLoginRequiredState(bgColor, titleColor);
          }
          
          final user = profileProvider.userProfile;
          if (profileProvider.isLoading && user == null) {
            return Scaffold(
              backgroundColor: bgColor,
              body: const Center(child: VxPremiumLoader(color: Color(0xFFFE2C55))),
            );
          }
          
          if (user == null) {
            return _buildErrorState(bgColor, titleColor, "Could not load profile", () => _loadData());
          }
          
          return _buildProfileContent(context, user, isSelf, isDark, bgColor, titleColor, subtitleColor, borderColor, cardColor, profileProvider);
        },
      );
    }

    // Public Profile Handling
    final user = _publicProfile;
    if (_isLoadingPublic && user == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: VxPremiumLoader(color: Color(0xFFFE2C55))),
      );
    }

    if (user == null) {
      return _buildErrorState(bgColor, titleColor, "User not found", () => _loadData());
    }

    return _buildProfileContent(context, user, isSelf, isDark, bgColor, titleColor, subtitleColor, borderColor, cardColor, profileProvider);
  }

  Widget _buildLoginRequiredState(Color bgColor, Color titleColor) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFFFE2C55).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.person_crop_circle_fill, color: Color(0xFFFE2C55), size: 80),
              ),
              const SizedBox(height: 30),
              Text(
                "Sign in to see your profile",
                textAlign: TextAlign.center,
                style: TextStyle(color: titleColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                "Your videos, likes, and drafts will appear here after you sign in.",
                textAlign: TextAlign.center,
                style: TextStyle(color: titleColor.withValues(alpha: 0.5), fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => showAuthPopup(context).then((_) => _loadData()),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFE2C55).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Center(
                    child: Text("Sign In / Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Color bgColor, Color titleColor, String message, VoidCallback onRetry) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.username != null ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
      ) : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.doc_text_search, color: titleColor.withValues(alpha: 0.2), size: 100),
              const SizedBox(height: 30),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                "The page you're looking for couldn't be loaded. Please try again or check your connection.",
                textAlign: TextAlign.center,
                style: TextStyle(color: titleColor.withValues(alpha: 0.4), fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  height: 54,
                  width: 160,
                  decoration: BoxDecoration(
                    color: titleColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: titleColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.refresh, color: titleColor, size: 20),
                      const SizedBox(width: 10),
                      Text("Retry", style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> user, bool isSelf, bool isDark, Color bgColor, Color titleColor, Color subtitleColor, Color borderColor, Color cardColor, ProfileProvider profileProvider) {
    return Scaffold(
      backgroundColor: bgColor,
      body: VxPremiumRefresher(
        onRefresh: _loadData,
        color: const Color(0xFFFE2C55),
        child: SafeArea(
          top: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // 1. COVER PHOTO
                          _buildCoverImage(borderColor, user['cover_url'], titleColor),

                          // 2. TOP BAR
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 0,
                            right: 0,
                            child: _buildTopBar(Colors.white, user['nickname'] ?? "Vx User", isSelf),
                          ),

                          // 3. PROFILE PICTURE (Overlapping)
                          Positioned(
                            bottom: -50,
                            child: _buildProfileImage(bgColor, user['avatar_url']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      
                      // 4. USERNAME & BIO
                      _buildUserInfo(user, titleColor, subtitleColor),
                      
                      const SizedBox(height: 30),
                      
                      // 5. MODERN STATS
                      _buildModernStats(titleColor, user),
                      
                      const SizedBox(height: 30),
                      
                      // 6. ACTION BUTTONS
                      _buildModernActionButtons(context, titleColor, isDark, isSelf),
                      
                      const SizedBox(height: 25),

                      // 6.5 VX STUDIO BANNER
                      if (isSelf) ...[
                        _buildVxStudioBanner(context, titleColor, cardColor),
                        const SizedBox(height: 25),
                      ],
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFFFE2C55),
                      indicatorWeight: 3,
                      labelColor: titleColor,
                      unselectedLabelColor: titleColor.withValues(alpha: 0.3),
                      tabs: [
                        const Tab(icon: Icon(CupertinoIcons.square_grid_2x2_fill, size: 22)),
                        const Tab(icon: Icon(CupertinoIcons.heart_fill, size: 22)),
                        if (isSelf) const Tab(icon: Icon(CupertinoIcons.lock_fill, size: 22)),
                        if (isSelf) const Tab(icon: Icon(CupertinoIcons.archivebox_fill, size: 22)),
                      ],
                    ),
                    bgColor: bgColor,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoGrid(isSelf ? profileProvider.myVideos : _publicVideos, user, titleColor),
                Center(child: Text("Liked Videos", style: TextStyle(color: titleColor.withValues(alpha: 0.4), fontWeight: FontWeight.w600))),
                if (isSelf) Center(child: Text("Private Videos", style: TextStyle(color: titleColor.withValues(alpha: 0.4), fontWeight: FontWeight.w600))),
                if (isSelf) _buildDraftsGrid(titleColor, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color titleColor, String name, bool isSelf) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isSelf)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10, width: 1),
              ),
              child: Icon(CupertinoIcons.person_add_solid, color: titleColor, size: 20),
            )
          else
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Icon(CupertinoIcons.back, color: titleColor, size: 20),
              ),
            ),
          Text(
            name,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: -0.5,
              shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15)],
            ),
          ),
          if (isSelf)
            GestureDetector(
              onTap: () => _showSettingsMenu(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Icon(CupertinoIcons.bars, color: titleColor, size: 22),
              ),
            )
          else
            GestureDetector(
              onTap: () => _showPublicExtraMenu(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Icon(CupertinoIcons.ellipsis_vertical, color: titleColor, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  void _showPublicExtraMenu(BuildContext context) {
    final isDark = _isDark(context);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 45, height: 5, decoration: BoxDecoration(color: titleColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 30),
              _buildMenuOption(
                icon: CupertinoIcons.flag_fill,
                title: "Report User",
                titleColor: titleColor,
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
              _buildMenuOption(
                icon: CupertinoIcons.slash_circle_fill,
                title: "Block User",
                titleColor: const Color(0xFFFE2C55),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirm();
                },
              ),
              _buildMenuOption(
                icon: CupertinoIcons.share,
                title: "Share Profile",
                titleColor: titleColor,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog() {
    final reasons = ["Spam", "Inappropriate content", "Harassment", "Fake account", "Other"];
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Report User"),
        message: const Text("Select a reason for reporting this user."),
        actions: reasons.map((r) => CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            if (_authToken.isEmpty) return;
            try {
              final targetId = _publicProfile?['id'];
              if (targetId != null) {
                await http.post(
                  Uri.parse('${constants.baseUrl}/user/report'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $_authToken',
                  },
                  body: jsonEncode({
                    'target_id': targetId,
                    'reason': r,
                    'type': 'user'
                  }),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User reported successfully"), backgroundColor: Color(0xFFFE2C55)),
                  );
                }
              }
            } catch (e) {
              debugPrint("Report error: $e");
            }
          },
          child: Text(r),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ),
    );
  }

  void _showBlockConfirm() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Block User?"),
        content: Text("They will no longer be able to find your profile, see your videos, or message you."),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              if (_authToken.isEmpty) return;
              try {
                final targetId = _publicProfile?['id'];
                if (targetId != null) {
                  await http.post(
                    Uri.parse('${constants.baseUrl}/user/block'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $_authToken',
                    },
                    body: jsonEncode({
                      'target_id': targetId
                    }),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User blocked"), backgroundColor: Colors.black),
                    );
                    Navigator.pop(context); // Go back as user is blocked
                  }
                }
              } catch (e) {
                debugPrint("Block error: $e");
              }
            },
            child: const Text("Block"),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic>? user, Color titleColor, Color subtitleColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user != null && user['username'] != null ? "@${user['username']}" : "@vx_user",
              style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.8),
            ),
            if (user?['is_verified'] == true) ...[
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF007AFF), size: 18),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (user != null && user['bio'] != null && user['bio'] != "")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Text(
              user['bio'],
              textAlign: TextAlign.center,
              style: TextStyle(color: titleColor.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        const SizedBox(height: 16),
        _buildSocialIcons(user, titleColor),
      ],
    );
  }

  Widget _buildModernStats(Color titleColor, Map<String, dynamic>? user) {
    final username = user != null ? user['username'] ?? "" : "";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: titleColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: titleColor.withValues(alpha: 0.05), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Following", FormatUtil.formatNumber(user?['following'] ?? 0), titleColor, username, false),
          _buildStatDivider(titleColor),
          _buildStatItem("Followers", FormatUtil.formatNumber(user?['followers'] ?? 0), titleColor, username, true),
          _buildStatDivider(titleColor),
          _buildStatItem("Likes", FormatUtil.formatNumber(user?['likes'] ?? 0), titleColor, "", false),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color titleColor, String username, bool isFollowers) {
    return GestureDetector(
      onTap: () {
        if (username.isNotEmpty && label != "Likes") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FollowListPage(
                username: username,
                title: label,
                isFollowers: isFollowers,
              ),
            ),
          );
        }
      },
      child: Column(
        children: [
          Text(value, style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: titleColor.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        ],
      ),
    );
  }

  Widget _buildStatDivider(Color titleColor) {
    return Container(
      height: 30,
      width: 1.5,
      color: titleColor.withValues(alpha: 0.06),
    );
  }

  Widget _buildModernActionButtons(BuildContext context, Color titleColor, bool isDark, bool isSelf) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (isSelf)
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage())),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFE2C55).withValues(alpha: 0.35), blurRadius: 15, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Center(
                    child: Text("Edit profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
              ),
            )
          else ...[
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: _toggleFollow,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: _isFollowing ? null : const LinearGradient(
                      colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: _isFollowing ? titleColor.withValues(alpha: 0.05) : null,
                    borderRadius: BorderRadius.circular(18),
                    border: _isFollowing ? Border.all(color: titleColor.withValues(alpha: 0.1)) : null,
                  ),
                  child: Center(
                    child: Text(
                      _isFollowing ? "Following" : (_isFollowBack ? "Follow Back" : "Follow"),
                      style: TextStyle(color: _isFollowing ? titleColor : Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            _buildAuxButton(
              CupertinoIcons.chat_bubble_fill, 
              titleColor,
              onTap: () {
                if (_publicProfile != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        userName: _publicProfile!['nickname'] ?? _publicProfile!['username'] ?? 'User',
                        avatar: _publicProfile!['avatar_url'] ?? '',
                        targetId: _publicProfile!['id'] ?? 0,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          if (isSelf) ...[
            const SizedBox(width: 14),
            _buildAuxButton(CupertinoIcons.bookmark_fill, titleColor),
            const SizedBox(width: 14),
            _buildAuxButton(CupertinoIcons.share_up, titleColor),
          ],
        ],
      ),
    );
  }

  Widget _buildAuxButton(IconData icon, Color titleColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: titleColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: titleColor.withValues(alpha: 0.08), width: 1),
        ),
        child: Icon(icon, color: titleColor, size: 22),
      ),
    );
  }

  Widget _buildCoverImage(Color borderColor, String? url, Color titleColor) {
    final hasUrl = url != null && url.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: titleColor.withValues(alpha: 0.05),
        image: hasUrl ? DecorationImage(image: CachedNetworkImageProvider(url), fit: BoxFit.cover) : null,
      ),
      child: !hasUrl ? Center(child: Icon(CupertinoIcons.photo, color: titleColor.withValues(alpha: 0.1), size: 40)) : null,
    );
  }

  Widget _buildProfileImage(Color bgColor, String? url) {
    final hasUrl = url != null && url.isNotEmpty;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withValues(alpha: 0.1),
        border: Border.all(color: bgColor, width: 6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        image: hasUrl ? DecorationImage(image: CachedNetworkImageProvider(url), fit: BoxFit.cover) : null,
      ),
      child: !hasUrl ? const Icon(CupertinoIcons.person_alt, color: Colors.grey, size: 50) : null,
    );
  }

  Widget _buildVxStudioBanner(BuildContext context, Color titleColor, Color cardColor) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VxStudioPage())),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [const Color(0xFFFE2C55).withValues(alpha: 0.12), const Color(0xFFAF52DE).withValues(alpha: 0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: titleColor.withValues(alpha: 0.06), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFAF52DE), Color(0xFF5856D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFAF52DE).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(CupertinoIcons.flame_fill, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Vx Creator Studio", style: TextStyle(color: titleColor, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text("Track your viral growth & analytics", style: TextStyle(color: titleColor.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: titleColor.withValues(alpha: 0.3), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(List<Map<String, dynamic>> videos, Map<String, dynamic>? user, Color titleColor) {
    if (videos.isEmpty) return Center(child: Text("No videos yet", style: TextStyle(color: titleColor.withValues(alpha: 0.3), fontSize: 15, fontWeight: FontWeight.w700)));

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4.5,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final videoMap = videos[index];
        final video = VideoData.fromJson(videoMap);
        final thumbUrl = video.thumbnailUrl;

        return GestureDetector(
          onTap: () {
            final videoDataList = videos.map((v) => VideoData.fromJson(v)).toList();
            Navigator.push(context, MaterialPageRoute(builder: (context) => VideoViewerPage(videos: videoDataList, initialIndex: index, feedKey: 'profile_${user?['username']}')));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              color: titleColor.withValues(alpha: 0.05),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: thumbUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.white.withValues(alpha: 0.05)),
                      errorWidget: (_, __, ___) => const Center(child: Icon(CupertinoIcons.play_circle, color: Colors.white24, size: 35)),
                    )
                  else
                    const Center(child: Icon(CupertinoIcons.play_circle, color: Colors.white24, size: 35)),
                  
                  // View count overlay
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          FormatUtil.formatNumber(video.views),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraftsGrid(Color titleColor, bool isDark) {
    if (_drafts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.archivebox, color: titleColor.withValues(alpha: 0.2), size: 50),
            const SizedBox(height: 16),
            Text("No drafts found", style: TextStyle(color: titleColor.withValues(alpha: 0.3), fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4.5,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: _drafts.length,
      itemBuilder: (context, index) {
        final draft = _drafts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPublishScreen(
                  videoPath: draft.videoPath,
                  draft: draft,
                ),
              ),
            ).then((_) => _loadDrafts());
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: titleColor.withValues(alpha: 0.05),
                child: const Center(child: Icon(CupertinoIcons.play_circle, color: Colors.white24, size: 35)),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  draft.caption.isNotEmpty ? draft.caption : "Draft",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () async {
                    await DraftService.deleteDraft(draft.id);
                    _loadDrafts();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsMenu(BuildContext context) {
    final isDark = _isDark(context);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 45, height: 5, decoration: BoxDecoration(color: titleColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 30),
              _buildMenuOption(icon: CupertinoIcons.settings, title: "Settings & Privacy", titleColor: titleColor, onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              }),
              _buildMenuOption(icon: CupertinoIcons.chart_bar_square, title: "Creator Tools", titleColor: titleColor, onTap: () => Navigator.pop(context)),
              _buildMenuOption(icon: CupertinoIcons.qrcode, title: "My QR Code", titleColor: titleColor, onTap: () => Navigator.pop(context)),
              _buildMenuOption(icon: CupertinoIcons.share, title: "Share Profile", titleColor: titleColor, onTap: () => Navigator.pop(context)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({required IconData icon, required String title, required Color titleColor, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: titleColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: titleColor, size: 22),
      ),
      title: Text(title, style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
      trailing: Icon(CupertinoIcons.chevron_right, color: titleColor.withValues(alpha: 0.2), size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSocialIcons(Map<String, dynamic>? user, Color titleColor) {
    if (user == null) return const SizedBox.shrink();
    final instagram = user['instagram_url'] as String?;
    final youtube = user['youtube_url'] as String?;
    final facebook = user['facebook_url'] as String?;
    if ((instagram == null || instagram.isEmpty) && (youtube == null || youtube.isEmpty) && (facebook == null || facebook.isEmpty)) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (instagram != null && instagram.isNotEmpty) _socialIcon(const FaIcon(FontAwesomeIcons.instagram), instagram, titleColor),
        if (youtube != null && youtube.isNotEmpty) _socialIcon(const FaIcon(FontAwesomeIcons.youtube), youtube, titleColor),
        if (facebook != null && facebook.isNotEmpty) _socialIcon(const FaIcon(FontAwesomeIcons.facebook), facebook, titleColor),
      ],
    );
  }

  Widget _socialIcon(Widget iconWidget, String url, Color color) {
    return IconButton(
      icon: Opacity(opacity: 0.7, child: IconTheme(data: IconThemeData(color: color, size: 20), child: iconWidget)),
      onPressed: () => _launchURL(url),
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) debugPrint("Could not launch $urlString");
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;
  _SliverTabBarDelegate(this.tabBar, {required this.bgColor});
  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: bgColor, child: tabBar);
  @override bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
