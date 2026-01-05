import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';

/// Provider for the socket service
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

/// Socket connection state provider
final socketConnectionProvider = StreamProvider<bool>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.onConnectionChange;
});

/// Stream provider for available orders
final orderAvailableStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.onOrderAvailable;
});

/// Stream provider for order status updates
final orderStatusStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.onOrderStatus;
});

/// Stream provider for chat messages
final chatMessageStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.onChatMessage;
});

/// Socket service for real-time communication with the backend
/// Handles driver-specific events including location updates and order management
class SocketService {
  IO.Socket? _socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Driver ID for room management
  String? _driverId;

  // Online status
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  // Reconnection configuration
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 2);
  Timer? _reconnectTimer;

  // Location update timer
  Timer? _locationUpdateTimer;
  static const Duration _locationUpdateInterval = Duration(seconds: 10);

  // Event stream controllers
  final StreamController<Map<String, dynamic>> _orderAvailableController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderCancelledController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderAssignedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _onlineStatusController =
      StreamController<bool>.broadcast();

  // Event streams
  Stream<Map<String, dynamic>> get onOrderAvailable => _orderAvailableController.stream;
  Stream<Map<String, dynamic>> get onOrderStatus => _orderStatusController.stream;
  Stream<Map<String, dynamic>> get onOrderCancelled => _orderCancelledController.stream;
  Stream<Map<String, dynamic>> get onOrderAssigned => _orderAssignedController.stream;
  Stream<Map<String, dynamic>> get onChatMessage => _chatMessageController.stream;
  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;
  Stream<bool> get onOnlineStatusChange => _onlineStatusController.stream;

  /// Initialize and connect to Socket.io server
  Future<void> connect(String driverId) async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    _driverId = driverId;

    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token == null) {
        throw Exception('No access token available');
      }

      _socket = IO.io(
        AppConstants.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .setExtraHeaders({'authorization': 'Bearer $token'})
            .enableReconnection()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(_reconnectDelay.inMilliseconds)
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  /// Setup socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);

      // Join driver room
      if (_driverId != null) {
        _socket!.emit('join:driver', _driverId);
      }

      // Restore online status if was previously online
      if (_isOnline && _driverId != null) {
        setDriverOnline();
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectionController.add(false);
      _attemptReconnect();
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      _connectionController.add(false);
      _attemptReconnect();
    });

    _socket!.onError((error) {
      // Log error but don't disconnect
      print('Socket error: $error');
    });

    // Order events - available orders for drivers
    _socket!.on('order:available', (data) {
      if (data != null) {
        _orderAvailableController.add(_parseData(data));
      }
    });

    _socket!.on('driver:available_order', (data) {
      if (data != null) {
        _orderAvailableController.add(_parseData(data));
      }
    });

    // New order assigned to this driver
    _socket!.on('order:new', (data) {
      if (data != null) {
        _orderAssignedController.add(_parseData(data));
      }
    });

    _socket!.on('order:assigned', (data) {
      if (data != null) {
        _orderAssignedController.add(_parseData(data));
      }
    });

    // Order status updates
    _socket!.on('order:status', (data) {
      if (data != null) {
        _orderStatusController.add(_parseData(data));
      }
    });

    _socket!.on('order:status_updated', (data) {
      if (data != null) {
        _orderStatusController.add(_parseData(data));
      }
    });

    // Order cancellation
    _socket!.on('order:cancelled', (data) {
      if (data != null) {
        _orderCancelledController.add(_parseData(data));
      }
    });

    // Chat events
    _socket!.on('chat:message', (data) {
      if (data != null) {
        _chatMessageController.add(_parseData(data));
      }
    });

    _socket!.on('chat:new_message', (data) {
      if (data != null) {
        _chatMessageController.add(_parseData(data));
      }
    });

    // Notification events
    _socket!.on('notification', (data) {
      if (data != null) {
        _notificationController.add(_parseData(data));
      }
    });

    _socket!.on('notification:new', (data) {
      if (data != null) {
        _notificationController.add(_parseData(data));
      }
    });

    // Driver status confirmation
    _socket!.on('driver:status', (data) {
      if (data != null) {
        final parsedData = _parseData(data);
        if (parsedData['driverId'] == _driverId) {
          _isOnline = parsedData['status'] == 'online';
          _onlineStatusController.add(_isOnline);
        }
      }
    });
  }

  /// Parse incoming data to Map
  Map<String, dynamic> _parseData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'data': data};
  }

  /// Attempt to reconnect with exponential backoff
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: _reconnectDelay.inSeconds * (_reconnectAttempts + 1)),
      () {
        _reconnectAttempts++;
        if (_driverId != null) {
          connect(_driverId!);
        }
      },
    );
  }

  /// Set driver online and join online drivers pool
  void setDriverOnline({double? latitude, double? longitude}) {
    if (_socket != null && _socket!.connected) {
      final data = <String, dynamic>{};
      if (latitude != null && longitude != null) {
        data['location'] = {'lat': latitude, 'lng': longitude};
      }
      _socket!.emit('driver:online', data.isEmpty ? null : data);
      _isOnline = true;
      _onlineStatusController.add(true);
    }
  }

  /// Set driver offline and leave online drivers pool
  void setDriverOffline() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('driver:offline');
      _isOnline = false;
      _onlineStatusController.add(false);
      _stopLocationUpdates();
    }
  }

  /// Update driver location during active delivery
  void updateDriverLocation({
    String? orderId,
    required double latitude,
    required double longitude,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('driver:location', {
        if (orderId != null) 'orderId': orderId,
        'location': {
          'lat': latitude,
          'lng': longitude,
        },
      });
    }
  }

  /// Start periodic location updates for active delivery
  void startLocationUpdates({
    required String orderId,
    required Future<Map<String, double>?> Function() getLocation,
  }) {
    _stopLocationUpdates();
    _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (_) async {
      final location = await getLocation();
      if (location != null && _isConnected) {
        updateDriverLocation(
          orderId: orderId,
          latitude: location['latitude']!,
          longitude: location['longitude']!,
        );
      }
    });
  }

  /// Stop periodic location updates
  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Subscribe to a specific order's updates
  void subscribeToOrder(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('order:subscribe', orderId);
    }
  }

  /// Unsubscribe from order updates
  void unsubscribeFromOrder(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('order:unsubscribe', orderId);
    }
  }

  /// Accept an available order
  void acceptOrder(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('order:accept', {'orderId': orderId});
    }
  }

  /// Reject an available order
  void rejectOrder(String orderId, {String? reason}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('order:reject', {
        'orderId': orderId,
        if (reason != null) 'reason': reason,
      });
    }
  }

  /// Join a chat room
  void joinChatRoom(String chatId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:join', chatId);
    }
  }

  /// Leave a chat room
  void leaveChatRoom(String chatId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:leave', chatId);
    }
  }

  /// Send a chat message
  void sendChatMessage({
    required String chatId,
    required String message,
    String? messageType,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:send_message', {
        'chatId': chatId,
        'message': message,
        'messageType': messageType ?? 'text',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Mark chat messages as read
  void markChatAsRead(String chatId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:mark_read', chatId);
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
  Future<void> reconnect() async {
    final wasOnline = _isOnline;
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    if (_driverId != null) {
      await connect(_driverId!);
      if (wasOnline) {
        setDriverOnline();
      }
    }
  }

  /// Disconnect from socket
  void disconnect() {
    _reconnectTimer?.cancel();
    _stopLocationUpdates();
    if (_socket != null) {
      // Notify offline before disconnecting
      if (_isOnline) {
        _socket!.emit('driver:offline');
      }
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _isOnline = false;
      _connectionController.add(false);
      _onlineStatusController.add(false);
    }
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _orderAvailableController.close();
    _orderStatusController.close();
    _orderCancelledController.close();
    _orderAssignedController.close();
    _chatMessageController.close();
    _notificationController.close();
    _connectionController.close();
    _onlineStatusController.close();
  }
}
