import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:synchronized/synchronized.dart';
import 'dart:async';
import '../../core/utils/logger.dart';

/// Generic WebSocket service for handling various protocols
/// Can be extended for ExAPI, Kage, or other WebSocket protocols
abstract class WebSocketService {
  WebSocketChannel? _channel;
  final _wsLock = Lock();
  StreamSubscription? _subscription;

  String get url;

  /// Connect to WebSocket server
  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await Logger.instance.writeLog('Connected to WebSocket: $url');

      _subscription = _channel!.stream.listen(
        (data) => handleMessage(data),
        onError: (error) => handleError(error),
        onDone: () => handleClose(),
      );
    } catch (e) {
      await Logger.instance.writeLog('Failed to connect to WebSocket: $e');
      throw e;
    }
  }

  /// Send message through WebSocket
  Future<void> sendMessage(dynamic message) async {
    await _wsLock.synchronized(() async {
      if (_channel == null) {
        await connect();
      }

      final jsonMessage = message is String ? message : jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      await Logger.instance.writeLog('Sent WebSocket message: $jsonMessage');
    });
  }

  /// Handle incoming messages - to be implemented by subclasses
  void handleMessage(dynamic message);

  /// Handle errors
  void handleError(dynamic error) async {
    await Logger.instance.writeLog('WebSocket error: $error');
  }

  /// Handle connection close
  void handleClose() async {
    await Logger.instance.writeLog('WebSocket connection closed');
  }

  /// Close WebSocket connection
  Future<void> close() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }
}
