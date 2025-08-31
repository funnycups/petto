// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:convert';
import 'dart:math';
import 'package:openai_dart/openai_dart.dart';
import '../config/settings_manager.dart';
import '../utils/logger.dart';
import 'screenshot_service.dart';
import '../../generated/l10n.dart';
import 'weather_service.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  static AiService get instance => _instance;

  AiService._internal();

  Future<String?> sendChatRequest(
      List<ChatCompletionMessage> requestMessages) async {
    try {
      final settings = await SettingsManager.instance.readSettings();
      final url = settings['url'] ?? '';
      final key = settings['key'] ?? '';
      final model = settings['model'] ?? '';
      final name = settings['name'] ?? '';
      final description = settings['description'] ?? '';
      final user = settings['user'] ?? '';
      final response = settings['response'] ?? '';
      final question = settings['question'] ?? '';
      final enableScreenshot = settings['enable_screenshot'] ?? false;

      // Add custom response if configured
      if (response.isNotEmpty) {
        requestMessages.insert(
            0, ChatCompletionMessage.assistant(content: response));
      }

      // Add custom question if configured
      if (question.isNotEmpty) {
        requestMessages.insert(
            0,
            ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(question)));
      }

      // Add context information
      await _addContextMessages(requestMessages, enableScreenshot);

      // Add system prompt
      final userCall = user.isNotEmpty ? S.current.userCall(user) : '';
      final cleanDescription = description.replaceAll('\r\n', '\n');
      requestMessages.insert(
          0,
          ChatCompletionMessage.system(
              content:
                  S.current.systemPrompt(name, userCall, cleanDescription)));

      // Create OpenAI client and send request
      final client = OpenAIClient(
        apiKey: key,
        baseUrl: url,
      );

      final aiResponse = await client.createChatCompletion(
          request: CreateChatCompletionRequest(
              model: ChatCompletionModel.modelId(model),
              messages: requestMessages,
              temperature: 1.5));

      // Screenshot cleanup is now handled internally by the screenshot service

      final responseContent = aiResponse.choices.first.message.content;
      await Logger.instance.writeLog(
          'OpenAI API response: ${aiResponse.choices.first.message.role} - '
          '${responseContent?.substring(0, min(responseContent.length, 100))}...');

      return responseContent;
    } catch (e) {
      await Logger.instance.writeLog('OpenAI API request failed: $e. '
          'Request messages: ${jsonEncode(requestMessages.map((m) => m.toJson()).toList())}');
      return S.current.modelError;
    }
  }

  Future<void> _addContextMessages(
      List<ChatCompletionMessage> messages, bool enableScreenshot) async {
    // Add time context
    DateTime now = DateTime.now();
    var hour = now.hour;
    var minute = now.minute;
    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    String period = _getTimePeriod(hour);

    // Add screenshot if enabled
    if (enableScreenshot) {
      final screenshotData = await ScreenshotService.instance.takeScreenshot();

      if (screenshotData != null) {
        String screenshotInfo = S.current.windowInfoScreenshot;
        String base64Image = base64Encode(screenshotData);

        messages.insert(
            0,
            ChatCompletionMessage.user(
                content: ChatCompletionMessageContentParts([
              ChatCompletionMessageContentPart.text(text: screenshotInfo),
              ChatCompletionMessageContentPart.image(
                  imageUrl: ChatCompletionMessageImageUrl(
                      url: 'data:image/png;base64,$base64Image'))
            ])));
      }
    }

    // Add weather and context
    var weather = await WeatherService.instance.getWeather();
    messages.insert(
        0,
        ChatCompletionMessage.system(
            content: S.current.modelWeather(
                WeatherService.getSeason(DateTime.now()),
                period,
                formattedTime,
                weather)));
  }

  String _getTimePeriod(int hour) {
    if (hour >= 20 || hour < 1) {
      return S.current.night;
    } else if (hour >= 1 && hour < 6) {
      return S.current.dawn;
    } else if (hour >= 6 && hour < 10) {
      return S.current.morning;
    } else if (hour >= 10 && hour < 12) {
      return S.current.forenoon;
    } else if (hour >= 12 && hour < 14) {
      return S.current.noon;
    } else if (hour >= 14 && hour < 18) {
      return S.current.afternoon;
    } else {
      return S.current.evening;
    }
  }
}
