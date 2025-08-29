// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../generated/l10n.dart';
import 'constants.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  static SettingsManager get instance => _instance;

  SettingsManager._internal();

  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _cachedSettings;

  Future<Map<String, dynamic>> readSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    final data = await _storage.read(key: Constants.settingsKey);
    if (data != null && data.isNotEmpty) {
      try {
        _cachedSettings = jsonDecode(data);
        return _cachedSettings!;
      } catch (e) {
        await _storage.delete(key: Constants.settingsKey);
        return {};
      }
    }
    return {};
  }

  Future<void> saveSettings(String settings) async {
    _cachedSettings = null; // Clear cache
    await _storage.write(key: Constants.settingsKey, value: settings);
  }

  Future<void> saveDefaultSettings() async {
    final data = await readSettings();
    if (data.isEmpty) {
      final Map<String, dynamic> defaultSettings = {
        'url': 'https://api.cups.moe/api/chat',
        'key': 'sk-key',
        'model': 'gpt-4o-mini',
        'name': S.current.settingName,
        'description': S.current.settingDescription,
        'model_no': '0',
        // DEPRECATED: LLM startup command is no longer supported
        'cmd':
            '', // Was: '#powershell -ExecutionPolicy Bypass -File ${await PlatformUtils.loadAsset("scripts\\startmodel.ps1")}',
        'duration': '30',
        'hitokoto': 'https://v1.hitokoto.cn?encode=text&c=a&c=b&c=d&c=i&c=k',
        'user': S.current.settingUser,
        'question': S.current.settingQuestion,
        'response': S.current.settingResponse,
        'group': 'Tap,Taphead',
        // DEPRECATED: ASR startup command is no longer supported
        'speech':
            '', // Was: '#powershell -ExecutionPolicy Bypass -File ${await PlatformUtils.loadAsset("scripts\\startserver.ps1")}',
        'recognition_url': 'wss://api.cups.moe/api/asr/',
        'flow': false,
        'keywords': S.current.settingKeywords,
        'whisper': 'https://api.openai.com',
        'whisper_key': 'sk-key',
        'whisper_model': 'whisper-1',
        'tts': '',
        'tts_key': '',
        'tts_model': 'tts-1',
        'tts_voice': S.current.settingTTSVoice,
        'exapi': 'ws://127.0.0.1:10086/api',
        'hide': false,
        'enable_screenshot': false, // New setting for screenshot
        'enable_logging': false,
        'check_update': true,
        'text_display_duration': 3000 // Default 3 seconds
      };
      await saveSettings(jsonEncode(defaultSettings));
    }
  }
}
