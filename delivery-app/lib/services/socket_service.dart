import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

class SocketService {
  IO.Socket? _socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Event stream controllers
  final StreamController<Map<String, dynamic>> _orderAvailableController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderCancelledController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Event streams
  Stream<Map<String, dynamic>> get onOrderAvailable => _orderAvailableController.stream;
  Stream<Map<String, dynamic>> get onOrderStatus => _orderStatusController.stream;
  Stream<Map<String, dynamic>> get onOrderCancelled => _orderCancelledController.stream;
  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;

  /// Initialize and connect to Socket.io server
  Future<void> connect(String driverId) async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token == null) {
        throw Exception('لا يوجد رمز وصول');
      }

      _socket = IO.io(
        AppConstants.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': 'Bearer $token'})
            .setExtraHeaders({'authorization': 'Bearer $token'})
            .build(),
      );

      _setupEventListeners(driverId);
      _socket!.connect();
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: ${e.toString()}');
    }
  }

  /// Setup socket event listeners
  void _setupEventListeners(String driverId) {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      _connectionController.add(true);

      // Join driver room
      _socket!.emit('join:driver', {'driverId': driverId});

      // Join drivers online pool
      _socket!.emit('driver:online', {'driverId': driverId});
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      _connectionController.add(false);
    });

    // Order events
    _socket!.on('order:available', (data) {
      if (data != null) {
        _orderAvailableController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('order:status', (data) {
      if (data != null) {
        _orderStatusController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('order:cancelled', (data) {
      if (data != null) {
        _orderCancelledController.add(Map<String, dynamic>.from(data));
      }
    });

    // Notification events
    _socket!.on('notification', (data) {
      if (data != null) {
        _notificationController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('notification:new', (data) {
      if (data != null) {
        _notificationController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Emit driver online status
  void setDriverOnline(String driverId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('driver:online', {'driverId': driverId});
    }
  }

  /// Emit driver offline status
  void setDriverOffline(String driverId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('driver:offline', {'driverId': driverId});
    }
  }

  /// Update driver location during delivery
  void updateDriverLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('driver:location', {
        'orderId': orderId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Subscribe to specific order updates
  void subscribeToOrder(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('order:subscribe', {'orderId': orderId});
    }
  }

  /// Unsubscribe from order updates
  void unsubscribeFromOrder(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('order:unsubscribe', {'orderId': orderId});
    }
  }

  /// Emit custom event
  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    }
  }

  /// Listen to custom event
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Remove custom event listener
  void off(String event) {
    _socket?.off(event);
  }

  /// Reconnect to socket
  Future<void> reconnect(String driverId) async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect(driverId);
  }

  /// Disconnect from socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _orderAvailableController.close();
    _orderStatusController.close();
    _orderCancelledController.close();
    _notificationController.close();
    _connectionController.close();
  }
}
