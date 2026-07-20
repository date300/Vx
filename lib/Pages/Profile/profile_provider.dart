import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Core/constants.dart' as constants;

class ProfileProvider with ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _myVideos = [];
  bool _isLoadingVideos = false;

  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> get myVideos => _myVideos;
  bool get isLoadingVideos => _isLoadingVideos;

  bool get isUploadingAvatar => _isUploadingAvatar;
  bool get isUploadingCover => _isUploadingCover;

  Future<void> fetchProfile(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          _userProfile = data['data'];
        } else {
          _errorMessage = data['message'] ?? 'Failed to load profile';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String token,
    required String nickname,
    required String username,
    required String bio,
    String instagramUrl = "",
    String youtubeUrl = "",
    String facebookUrl = "",
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${constants.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "nickname": nickname,
          "username": username,
          "bio": bio,
          "instagram_url": instagramUrl,
          "youtube_url": youtubeUrl,
          "facebook_url": facebookUrl,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        _userProfile = data['data'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── নিজের ভিডিও লিস্ট আনা (Profile page grid এর জন্য, এখন আর mock না) ──
  Future<void> fetchMyVideos(String token) async {
    _isLoadingVideos = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/user/videos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          _myVideos = List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
    } catch (e) {
      // ভিডিও লোড ফেল করলেও প্রোফাইল দেখাতে থাকবে, তাই এখানে silently fail করছি
      // চাইলে _errorMessage সেট করে UI তে দেখাতে পারো
    } finally {
      _isLoadingVideos = false;
      notifyListeners();
    }
  }

  // ── প্রোফাইল/কভার ছবি আপলোড ──
  Future<bool> uploadAvatar(String token, File file) async {
    _isUploadingAvatar = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${constants.baseUrl}/user/profile/avatar');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        updateLocalProfile({'avatar_url': data['data']['avatar_url']});
        return true;
      }
      _errorMessage = data['message'] ?? 'Failed to upload avatar';
      return false;
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      return false;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<bool> uploadCover(String token, File file) async {
    _isUploadingCover = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${constants.baseUrl}/user/profile/cover');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        updateLocalProfile({'cover_url': data['data']['cover_url']});
        return true;
      }
      _errorMessage = data['message'] ?? 'Failed to upload cover';
      return false;
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      return false;
    } finally {
      _isUploadingCover = false;
      notifyListeners();
    }
  }

  // Real-time update method (can be called after editing profile)
  void updateLocalProfile(Map<String, dynamic> newData) {
    if (_userProfile != null) {
      _userProfile!.addAll(newData);
      notifyListeners();
    }
  }
}
