import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;

    final url = dotenv.env['BASE_URL']
            ?.replaceAll('/api', '') ??
        'http://127.0.0.1:5000';

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('🔌 Socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔌 Socket disconnected');
    });

    _socket!.onError((error) {
      debugPrint('🔌 Socket error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
  }

  // Customer joins order tracking room
  void trackOrder(String orderId) {
    _socket?.emit('track:order', orderId);
    debugPrint('📍 Tracking order: $orderId');
  }

  // Listen for location updates
  void onLocationUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('location:update', (data) {
      debugPrint('📍 Location update: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for status updates
  void onStatusUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('status:update', (data) {
      debugPrint('📦 Status update: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Rider sends location
  void sendRiderLocation({
    required String orderId,
    required String riderId,
    required double lat,
    required double lng,
  }) {
    _socket?.emit('rider:location', {
      'orderId': orderId,
      'riderId': riderId,
      'lat': lat,
      'lng': lng,
    });
  }

  // Update order status
  void updateOrderStatus(String orderId, String status) {
    _socket?.emit('order:status', {
      'orderId': orderId,
      'status': status,
    });
  }

  void off(String event) {
    _socket?.off(event);
  }
}