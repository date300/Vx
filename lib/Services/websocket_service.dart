import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Core/config.dart';

enum WSEventType {
  likeUpdate,
  commentUpdate,
  followUpdate,
  notification,
  chatMessage,
}

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _eventController = StreamController.broadcast();
  bool _isConnected = false;

  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  bool get isConnected => _isConnected;

  void connect(String token) {
    if (_isConnected) return;

    // Fixed WebSocket URL construction
    final wsUrl = ApiConfig.rootUrl.replaceFirst('http', 'ws') + '/api/v1/ws?token=$token';
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _eventController.add(data);
        },
        onDone: () {
          _isConnected = false;
          _reconnect(token);
        },
        onError: (error) {
          _isConnected = false;
          _reconnect(token);
        },
      );
    } catch (e) {
      _isConnected = false;
      _reconnect(token);
    }
  }

  void _reconnect(String token) {
    Future.delayed(const Duration(seconds: 5), () => connect(token));
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }
}

final webSocketService = WebSocketService();
