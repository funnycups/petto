// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:async';
import 'dart:convert';
import '../../core/utils/logger.dart';
import 'websocket_service.dart';

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
  Future<void> sendSpeech(String modelNo, String text, int duration,
      {List<String>? choices}) async {
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
      "data": {"id": modelNo, "type": 0, "mtn": action}
    };
    await sendMessage(message);
  }
}
