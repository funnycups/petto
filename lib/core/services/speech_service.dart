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

import 'dart:io';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:dart_openai/dart_openai.dart';
import '../config/settings_manager.dart';
import '../utils/logger.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  static SpeechService get instance => _instance;
  
  SpeechService._internal();
  
  /// Text-to-speech conversion
  /// Returns duration in milliseconds if TTS is configured, null otherwise
  Future<int?> textToSpeech(String text) async {
    try {
      final settings = await SettingsManager.instance.readSettings();
      final tts = settings['tts'];
      final ttsKey = settings['tts_key'];
      final ttsModel = settings['tts_model'];
      final ttsVoice = settings['tts_voice'];
      
      if (tts != null && tts.isNotEmpty && 
          ttsKey != null && ttsKey.isNotEmpty && 
          ttsModel != null && ttsModel.isNotEmpty && 
          ttsVoice != null && ttsVoice.isNotEmpty) {
        
        OpenAI.baseUrl = tts;
        OpenAI.apiKey = ttsKey;
        
        File speechFile = await OpenAI.instance.audio.createSpeech(
          model: ttsModel,
          input: text,
          voice: ttsVoice,
          responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
          outputDirectory: Directory.current
        );
        
        // Play the audio file
        final soloud = SoLoud.instance;
        await soloud.init();
        final source = await soloud.loadFile(speechFile.path);
        await speechFile.delete();
        final duration = soloud.getLength(source);
        soloud.play(source);
        
        await Logger.instance.writeLog(
          'TTS completed for text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...'
        );
        
        return duration.inMilliseconds;
      }
    } catch (e) {
      await Logger.instance.writeLog('TTS failed: $e');
    }
    
    return null;
  }
}