import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Api/Studio/studio_api.dart';
import '../../Services/auth_service.dart';

class StudioAnalytics {
  final Map<String, dynamic> overview;
  final List<dynamic> dailyStats;

  StudioAnalytics({required this.overview, required this.dailyStats});

  factory StudioAnalytics.fromJson(Map<String, dynamic> json) {
    return StudioAnalytics(
      overview: json['overview'] ?? {},
      dailyStats: json['daily_stats'] ?? [],
    );
  }
}

class StudioProvider extends ChangeNotifier {
  StudioAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;

  StudioAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        _error = "Unauthorized";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await StudioApi.getAnalytics(token);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        _analytics = StudioAnalytics.fromJson(data['data']);
      } else {
        _error = data['message'] ?? "Failed to load analytics";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
