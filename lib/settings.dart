import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

const _storage = FlutterSecureStorage();

Future<Map<String, dynamic>> readSettings() async {
  // final File file = File(_settingsFile);
  final data = await _storage.read(key: 'settings');
  if (data != null && data.isNotEmpty) {
    try{
      return jsonDecode(data);
    }catch(e){
      await _storage.delete(key: 'settings');
      return {};
    }
  }
  return {};
}

Future<void> saveSettings(String settings) async {
  await _storage.write(key: 'settings', value: settings);
}

Future<void> saveDefaultSettings() async {
  // final File file = File(_settingsFile);
  final data = await readSettings();
  if (data.isEmpty) {
    final Map<String, dynamic> defaultSettings = {
      'url': 'https://api.cups.moe/api/chat',
      'key': 'sk-key',
      'model': 'gpt-4o-mini',
      'name': S.current.settingName,
      'description': S.current.settingDescription,
      'model_no': '0',
      'cmd':
          '#powershell -ExecutionPolicy Bypass -File ${await loadAsset("scripts\\startmodel.ps1")}',
      'duration': '30',
      'hitokoto': 'https://v1.hitokoto.cn?encode=text&c=a&c=b&c=d&c=i&c=k',
      'user': S.current.settingUser,
      'question': S.current.settingQuestion,
      'response': S.current.settingResponse,
      'group': 'Tap,Taphead',
      'speech':
          '#powershell -ExecutionPolicy Bypass -File ${await loadAsset("scripts\\startserver.ps1")}',
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
      'window_info_getter': S.current.shell,
      'screen_info_cmd': "powershell -ExecutionPolicy Bypass -File ${await loadAsset("scripts\\getwindowname.ps1")}",
      'enable_logging': false
    };
    // await file.writeAsString(jsonEncode(defaultSettings));
    await saveSettings(jsonEncode(defaultSettings));
  }
}