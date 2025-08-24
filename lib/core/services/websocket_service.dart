// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// Project home: https://github.com/funnycups/petto
// Project introduction: https://www.cups.moe/archives/petto.html

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:synchronized/synchronized.dart';
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

/// ExAPI WebSocket implementation
class ExApiWebSocketService extends WebSocketService {
  final String _url;
  Function(dynamic)? onMessageReceived;
  
  ExApiWebSocketService(this._url, {this.onMessageReceived});
  
  @override
  String get url => _url;
  
  @override
  void handleMessage(dynamic message) async {
    try {
      final decoded = jsonDecode(message);
      await Logger.instance.writeLog('Received ExAPI message: $decoded');
      onMessageReceived?.call(decoded);
    } catch (e) {
      await Logger.instance.writeLog('Failed to decode ExAPI message: $e');
    }
  }
  
  /// Send speech message
  Future<void> sendSpeech(String modelNo, String text, int duration, {List<String>? choices}) async {
    final message = {
      "msg": 11000,
      "msgId": 1,
      "data": {
        "id": modelNo,
        "text": text,
        "duration": duration,
        if (choices != null) "choices": choices,
      }
    };
    await sendMessage(message);
  }
  
  /// Send action message
  Future<void> sendAction(String modelNo, String action) async {
    final message = {
      "msg": 13200,
      "msgId": 1,
      "data": {
        "id": modelNo,
        "type": 0,
        "mtn": action
      }
    };
    await sendMessage(message);
  }
}