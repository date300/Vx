import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../Core/constants.dart' as constants;
import '../../Layout/theme_provider.dart';
import 'profile_page.dart';

class FollowListPage extends StatefulWidget {
  final String username;
  final String title; // "Followers" or "Following"
  final bool isFollowers;

  const FollowListPage({
    super.key,
    required this.username,
    required this.title,
    required this.isFollowers,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future<void> _fetchList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final headers = {'Content-Type': 'application/json'};
      final response = widget.isFollowers
          ? await http.get(Uri.parse('${constants.baseUrl}/user/${widget.username}/followers'), headers: headers)
          : await http.get(Uri.parse('${constants.baseUrl}/user/${widget.username}/following'), headers: headers);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        setState(() {
          _users = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load list';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
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
    final isDark = _isDark(context);
    final bgColor = isDark ? Colors.black : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: titleColor.withValues(alpha: 0.6))))
              : _users.isEmpty
                  ? Center(child: Text("No users found", style: TextStyle(color: titleColor.withValues(alpha: 0.6))))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['avatar_url'] != null && user['avatar_url'].isNotEmpty
                                ? NetworkImage(user['avatar_url'])
                                : null,
                            child: user['avatar_url'] == null || user['avatar_url'].isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            user['nickname'] ?? user['username'] ?? "User",
                            style: TextStyle(color: titleColor, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "@${user['username'] ?? ""}",
                            style: TextStyle(color: titleColor.withValues(alpha: 0.54)),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(username: user['username']),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
