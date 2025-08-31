// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:async';
import 'dart:convert';
import '../utils/logger.dart';
import 'websocket_service.dart';

/// Kage WebSocket implementation
class KageWebSocketService extends WebSocketService {
  final String _url;
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};

  KageWebSocketService(this._url);

  /// Test if Kage WebSocket service is accessible
  /// Returns true if Kage is running and accessible, false otherwise
  static Future<bool> isKageAccessible(String kageApiUrl) async {
    try {
      await Logger.instance.writeLog('Testing Kage WebSocket at: $kageApiUrl');
      final kageService = KageWebSocketService(kageApiUrl);
      await kageService.connect();

      final version = await kageService.getVersion().timeout(
            Duration(seconds: 2),
            onTimeout: () => throw TimeoutException('Cannot reach Kage'),
          );

      await kageService.close();
      await Logger.instance.writeLog('Kage is running, version: $version');
      return true;
    } catch (e) {
      await Logger.instance.writeLog('Kage not accessible: $e');
      return false;
    }
  }

  @override
  String get url => _url;

  @override
  void handleMessage(dynamic message) async {
    try {
      final decoded = jsonDecode(message);
      await Logger.instance.writeLog('Received Kage message: $decoded');

      // Handle response with requestId
      if (decoded['requestId'] != null) {
        final requestId = decoded['requestId'] as String;
        if (_pendingRequests.containsKey(requestId)) {
          _pendingRequests[requestId]!.complete(decoded);
          _pendingRequests.remove(requestId);
        }
      }
    } catch (e) {
      await Logger.instance.writeLog('Failed to decode Kage message: $e');
    }
  }

  /// Send request and wait for response
  Future<Map<String, dynamic>> sendRequest(
      String action, Map<String, dynamic> params) async {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final request = {
      "action": action,
      "params": params,
      "requestId": requestId
    };

    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;

    await sendMessage(request);

    // Set timeout for request
    return completer.future.timeout(
      Duration(seconds: 10),
      onTimeout: () {
        _pendingRequests.remove(requestId);
        throw TimeoutException('Kage request timed out');
      },
    );
  }

  /// Show text message (replacement for EXAPI sendSpeech)
  Future<void> showTextMessage(String message, int duration) async {
    await sendRequest(
        "showTextMessage", {"message": message, "duration": duration});
  }

  /// Trigger motion (replacement for EXAPI sendAction)
  Future<void> triggerMotion(String motionName) async {
    await sendRequest("triggerMotion", {"motionName": motionName});
  }

  /// Change model path
  Future<void> setModelPath(String path) async {
    await sendRequest("setModelPath", {"path": path});
  }

  /// Get motion list
  Future<List<String>> getMotions() async {
    final response = await sendRequest("getMotions", {});
    if (response['success'] == true && response['data'] != null) {
      return List<String>.from(response['data']['motions'] ?? []);
    }
    return [];
  }

  /// Get expression list
  Future<List<String>> getExpressions() async {
    final response = await sendRequest("getExpressions", {});
    if (response['success'] == true && response['data'] != null) {
      return List<String>.from(response['data']['expressions'] ?? []);
    }
    return [];
  }

  /// Set expression
  Future<void> setExpression(String expressionName) async {
    await sendRequest("setExpression", {"expressionName": expressionName});
  }

  /// Clear expression
  Future<void> clearExpression() async {
    await sendRequest("clearExpression", {});
  }

  /// Set model size
  Future<void> setModelSize(int width, int height) async {
    await sendRequest("setModelSize", {"width": width, "height": height});
  }

  /// Set model position
  Future<void> setModelPosition(int x, int y) async {
    await sendRequest("setModelPosition", {"x": x, "y": y});
  }

  /// Get version information
  Future<Map<String, dynamic>> getVersion() async {
    final response = await sendRequest("getVersion", {});
    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    }
    return {};
  }

  /// Exit Kage application
  Future<void> exitApp() async {
    await sendRequest("exitApp", {});
  }

  /// Restart Kage application
  Future<void> restartApp() async {
    await sendRequest("restartApp", {});
  }
}
