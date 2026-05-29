import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final String _baseUrl = "https://app.easysarvice.com"; // আপনার বেজ ইউআরএল
  
  List<dynamic> _categories = []; 
  final Set<int> _selectedCategoryIds = {}; 
  bool _isPageLoading = true;
  bool _isSubmitLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories(); 
  }

  // 🎯 ব্যাকএন্ড থেকে ক্যাটাগরি লিস্ট লোড (GET /api/v1/user/categories)
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse("$_baseUrl/api/v1/user/categories"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // আপনার গো ব্যাকএন্ড থেকে আসা "data" কী (Key) রিড করা হচ্ছে
          _categories = data['data'] ?? []; 
          _isPageLoading = false;
        });
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      setState(() => _isPageLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 🎯 প্রোফাইল এবং পছন্দ সাবমিট করা (POST /api/v1/user/onboard)
  Future<void> _submitProfile() async {
    final nickname = _nicknameController.text.trim();
    final username = _usernameController.text.trim();

    // ব্যাকএন্ড ভ্যালিডেশন রুলস অ্যাপে চেক করা
    if (nickname.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nickname must be at least 2 characters!")));
      return;
    }
    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username must be at least 3 characters!")));
      return;
    }
    if (_selectedCategoryIds.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least 3 categories! 🎯")));
      return;
    }

    setState(() => _isSubmitLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse("$_baseUrl/api/v1/user/onboard"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "nickname": nickname,
          "username": username,
          "category_ids": _selectedCategoryIds.toList(), // আপনার গো স্ট্রাক্টের matching key
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile setup completed successfully! 🚀")));
        Navigator.pushReplacementNamed(context, '/home'); 
      } else {
        // ব্যাকএন্ড থেকে আসা এরর মেসেজ (যেমন: Username already taken!) দেখাবে
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to save profile")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isPageLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Setup Profile", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Complete your TikTok style identity", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                    const SizedBox(height: 24),
                    
                    // নিকনেম ইনপুট ফিল্ড
                    TextField(
                      controller: _nicknameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter Nickname (e.g. Sohan)",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ইউজারনেম ইনপুট ফিল্ড
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter Unique Username (e.g. sohan_dev)",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text("Select at least 3 interests:", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    
                    // ডাইনামিক ক্যাটাগরি চিপস
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((category) {
                        int id = category['ID'] ?? 0; // GORM ডিফল্ট আইডি uppercase ID দেয়
                        String name = category['Name'] ?? '';
                        final isSelected = _selectedCategoryIds.contains(id);
                        
                        return FilterChip(
                          label: Text(name, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategoryIds.add(id);
                              } else {
                                _selectedCategoryIds.remove(id);
                              }
                            });
                          },
                          selectedColor: Colors.pinkAccent,
                          backgroundColor: const Color(0xFF1E1E1E),
                          checkmarkColor: Colors.black,
                        );
                      }).toList(),
                    ),
                    
                    const Spacer(),
                    
                    // সাবমিট বাটন
                    ElevatedButton(
                      onPressed: _isSubmitLoading ? null : _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isSubmitLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Complete Setup", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

