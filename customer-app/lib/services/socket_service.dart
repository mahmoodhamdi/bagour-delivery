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

/// Stream provider for order status updates
final orderStatusStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.onOrderStatus;
});

/// Stream provider for driver location updates
final driverLocationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.onDriverLocation;
});

/// Stream provider for chat messages
final chatMessageStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.onChatMessage;
});

/// Socket service for real-time communication with the backend
class SocketService {
  IO.Socket? _socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // User ID for room management
  String? _userId;

  // Reconnection configuration
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 2);
  Timer? _reconnectTimer;

  // Event stream controllers
  final StreamController<Map<String, dynamic>> _orderNewController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderCancelledController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _driverAssignedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _driverLocationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderDeliveredController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Event streams
  Stream<Map<String, dynamic>> get onOrderNew => _orderNewController.stream;
  Stream<Map<String, dynamic>> get onOrderStatus => _orderStatusController.stream;
  Stream<Map<String, dynamic>> get onOrderCancelled => _orderCancelledController.stream;
  Stream<Map<String, dynamic>> get onDriverAssigned => _driverAssignedController.stream;
  Stream<Map<String, dynamic>> get onDriverLocation => _driverLocationController.stream;
  Stream<Map<String, dynamic>> get onOrderDelivered => _orderDeliveredController.stream;
  Stream<Map<String, dynamic>> get onChatMessage => _chatMessageController.stream;
  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;

  /// Initialize and connect to Socket.io server
  Future<void> connect(String userId) async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    _userId = userId;

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

      // Join user room
      if (_userId != null) {
        _socket!.emit('join:user', _userId);
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

    // Order events - listen for all backend event formats
    _socket!.on('order:new', (data) {
      if (data != null) {
        _orderNewController.add(_parseData(data));
      }
    });

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

    _socket!.on('order:cancelled', (data) {
      if (data != null) {
        _orderCancelledController.add(_parseData(data));
      }
    });

    _socket!.on('order:driver_assigned', (data) {
      if (data != null) {
        _driverAssignedController.add(_parseData(data));
      }
    });

    _socket!.on('order:driver_location', (data) {
      if (data != null) {
        _driverLocationController.add(_parseData(data));
      }
    });

    _socket!.on('order:delivered', (data) {
      if (data != null) {
        _orderDeliveredController.add(_parseData(data));
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
        if (_userId != null) {
          connect(_userId!);
        }
      },
    );
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
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    if (_userId != null) {
      await connect(_userId!);
    }
  }

  /// Disconnect from socket
  void disconnect() {
    _reconnectTimer?.cancel();
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
    _orderNewController.close();
    _orderStatusController.close();
    _orderCancelledController.close();
    _driverAssignedController.close();
    _driverLocationController.close();
    _orderDeliveredController.close();
    _chatMessageController.close();
    _notificationController.close();
    _connectionController.close();
  }
}
