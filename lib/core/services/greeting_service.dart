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

import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import '../config/settings_manager.dart';
import '../utils/logger.dart';
import './websocket_service.dart';
import './speech_service.dart';
import './ai_service.dart';
import '../../generated/l10n.dart';

class GreetingService {
  static final GreetingService _instance = GreetingService._internal();
  static GreetingService get instance => _instance;
  
  GreetingService._internal();
  
  ExApiWebSocketService? _exApiService;
  
  /// Send hitokoto greeting
  Future<void> sendHitokoto(String hitokotoUrl) async {
    if (hitokotoUrl.isEmpty) {
      return;
    }
    
    try {
      var response = await http.get(Uri.parse(hitokotoUrl));
      if (response.statusCode == 200) {
        await _sendSpeechMessage(response.body, null);
      } else {
        await Logger.instance.writeLog(
          'Hitokoto request failed with status: ${response.statusCode}, body: ${response.body}'
        );
      }
    } catch (e) {
      await Logger.instance.writeLog('Hitokoto request error: $e');
    }
  }
  
  /// Send AI-generated greeting
  Future<void> sendModelGreeting({String prompt = ''}) async {
    String question = prompt.isEmpty ? S.current.modelGreeting : prompt;
    
    final userMessage = [
      ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(question)
      )
    ];
    
    var response = await AiService.instance.sendChatRequest(userMessage);
    if (response != null) {
      await _sendSpeechMessage(response, null);
    }
  }
  
  /// Send time-based greeting
  Future<void> sendTimeGreeting() async {
    DateTime now = DateTime.now();
    var hour = now.hour;
    var minute = now.minute;
    String formattedTime = 
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    
    String question;
    List<String>? choices;
    
    if (hour >= 23 || hour < 1) {
      question = S.current.timeSleep(formattedTime);
      choices = [S.current.goodNight];
    } else if (hour >= 1 && hour < 6) {
      question = S.current.timeDawn(formattedTime);
    } else if (hour >= 6 && hour < 8) {
      question = S.current.timeMorning(formattedTime);
    } else if (hour >= 8 && hour < 11) {
      question = S.current.timeForenoon(formattedTime);
    } else if (hour >= 11 && hour < 13) {
      question = S.current.timeNoon(formattedTime);
    } else if (hour >= 13 && hour < 18) {
      question = S.current.timeAfternoon(formattedTime);
    } else if (hour >= 18 && hour < 19) {
      question = S.current.timeEvening(formattedTime);
    } else if (hour >= 19 && hour < 23) {
      question = S.current.timeNight(formattedTime);
    } else {
      question = S.current.timeUnknown(formattedTime);
    }
    
    await _sendSpeechMessage(question, choices);
  }
  
  /// Send action animation through WebSocket
  Future<void> sendAction() async {
    final settings = await SettingsManager.instance.readSettings();
    String modelNo = settings['model_no'] ?? '';
    String group = settings['group'] ?? '';
    
    if (group.isNotEmpty) {
      var groups = group.split(",");
      Random r = Random();
      String selectedGroup = groups[r.nextInt(groups.length)];
      
      await _ensureExApiService();
      await _exApiService!.sendAction(modelNo, selectedGroup);
    }
  }
  
  /// Send speech message through WebSocket
  Future<void> _sendSpeechMessage(String message, List<String>? choices) async {
    await Logger.instance.writeLog(
      'sendSpeechMessage called with message: $message, choices: $choices'
    );
    
    final settings = await SettingsManager.instance.readSettings();
    String modelNo = settings['model_no'] ?? '';
    
    String messageText = message.toString().trim();
    final duration = (await SpeechService.instance.textToSpeech(messageText)) ?? 3000;
    
    await _ensureExApiService();
    
    // Set up message handler for choices
    if (choices != null) {
      _exApiService!.onMessageReceived = (message) {
        if (message['data'] == 0) {
          sendSpeechMessage(S.current.goodNight, null);
        }
      };
    }
    
    await _exApiService!.sendSpeech(modelNo, messageText, duration, choices: choices);
    
    // Wait for speech duration
    await Future.delayed(Duration(milliseconds: duration));
    await _exApiService!.close();
    _exApiService = null;
  }
  
  // Public method for external use
  Future<void> sendSpeechMessage(String message, List<String>? choices) async {
    await _sendSpeechMessage(message, choices);
  }
  
  /// Ensure ExAPI WebSocket service is created
  Future<void> _ensureExApiService() async {
    if (_exApiService == null) {
      final settings = await SettingsManager.instance.readSettings();
      String url = settings['exapi'] ?? '';
      
      if (url.isEmpty) {
        await Logger.instance.writeLog('ExAPI URL is empty');
        throw Exception('ExAPI URL not configured');
      }
      
      _exApiService = ExApiWebSocketService(url);
      await _exApiService!.connect();
    }
  }
}