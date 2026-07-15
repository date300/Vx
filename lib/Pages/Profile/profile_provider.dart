import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Api/Profile/profile_api.dart';

class ProfileProvider with ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ProfileApi.getProfile(token);
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

  // Real-time update method (can be called after editing profile)
  void updateLocalProfile(Map<String, dynamic> newData) {
    if (_userProfile != null) {
      _userProfile!.addAll(newData);
      notifyListeners();
    }
  }
}
