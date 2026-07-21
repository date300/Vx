import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Core/constants.dart' as constants;
import 'auth_service.dart';
import 'websocket_service.dart';

enum NotificationType { like, comment, reply, follow, mention }

class VxNotification {
  final int id;
  final String actorName;
  final String actorAvatar;
  final String content;
  final String type; // like, comment, follow, system
  final DateTime createdAt;
  bool isRead;

  VxNotification({
    required this.id,
    required this.actorName,
    required this.actorAvatar,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory VxNotification.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] ?? {};
    return VxNotification(
      id: json['id'] ?? 0,
      actorName: actor['nickname'] ?? actor['username'] ?? 'User',
      actorAvatar: actor['avatar_url'] ?? '',
      content: json['message'] ?? '',
      type: json['type'] ?? 'system',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
}

class NotificationService extends ChangeNotifier {
  List<VxNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _wsSub;

  NotificationService() {
    _listenToWS();
  }

  void _listenToWS() {
    _wsSub = webSocketService.eventStream.listen((event) {
      if (event['type'] == 'notification') {
        final payload = event['payload'];
        if (payload != null) {
          addNotification(VxNotification.fromJson(payload));
        }
      }
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  List<VxNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/inbox/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        _notifications = list.map((n) => VxNotification.fromJson(n)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/inbox/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _unreadCount = data['unread_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching unread count: $e");
    }
  }

  void addNotification(VxNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      // We might need a MarkAsRead API in InboxApi if not already there
      // For now, local update
      for (var n in _notifications) {
        n.isRead = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
       debugPrint("Error marking as read: $e");
    }
  }

  // Keep loadMockNotifications for testing purposes if needed
  void loadMockNotifications() {
    _notifications = [
      VxNotification(
        id: 1,
        actorName: "janesmith",
        actorAvatar: "https://i.pravatar.cc/150?u=jane",
        content: "liked your video",
        type: "like",
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      VxNotification(
        id: 2,
        actorName: "alex_dev",
        actorAvatar: "https://i.pravatar.cc/150?u=alex",
        content: "replied to your comment: 'Nice work! 🚀'",
        type: "comment",
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      VxNotification(
        id: 3,
        actorName: "fitness_guru",
        actorAvatar: "https://i.pravatar.cc/150?u=fit",
        content: "commented: 'Wow, this is amazing! 🔥'",
        type: "comment",
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      VxNotification(
        id: 4,
        actorName: "travel_vlogger",
        actorAvatar: "https://i.pravatar.cc/150?u=travel",
        content: "started following you",
        type: "follow",
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
    _unreadCount = _notifications.length;
    notifyListeners();
  }
}

final notificationService = NotificationService();
