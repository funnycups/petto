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

import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:dart_openai/dart_openai.dart';
import '../config/settings_manager.dart';
import '../utils/logger.dart';

class Recognizer {
  final _record = AudioRecorder();
  Stream<Uint8List>? _stream;
  late dynamic _webSocket;
  late Function(String) onResult;
  late bool _flow;

  Future<void> stop() async {
    if (!await _record.isRecording()) {
      return;
    }
    
    if (_flow) {
      await _record.cancel();
      await _webSocket.sink.add('end'.codeUnits);
      await _webSocket.sink.close();
    } else {
      final path = await _record.stop();
      if (path == null) {
        return;
      } else {
        var file = File(path);
        var settings = await SettingsManager.instance.readSettings();
        OpenAI.baseUrl = settings['whisper'] ?? 'https://api.openai.com';
        OpenAI.apiKey = settings['whisper_key'] ?? '';
        OpenAIAudioModel transcription = 
            await OpenAI.instance.audio.createTranscription(
          file: file,
          model: settings['whisper_model'] ?? 'whisper-1',
          responseFormat: OpenAIAudioResponseFormat.json,
        );
        if (transcription.text.isNotEmpty) {
          onResult(transcription.text);
        }
        file.delete();
      }
    }
  }

  Future<void> start(String url, bool flow) async {
    if (await _record.isRecording()) {
      return;
    }
    
    _flow = flow;
    if (!await _record.hasPermission()) {
      onResult('No recording permission');
      return;
    }
    
    if (flow) {
      _webSocket = WebSocketChannel.connect(Uri.parse(url));
      _stream = await _record.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ));
      
      _stream?.listen((data) async {
        // Recording data: ${data.length} bytes
        await _webSocket.sink.add(Uint8List.fromList(data));
      }, onDone: () async {
        // Recording done
      });
      
      _webSocket.stream.listen((message) async {
        var response = json.decode(message);
        // Received server response
        await Logger.instance.writeLog('Recognition server response: $response');
        
        if (response['result'] != null) {
          // Recognition result
          onResult(response['result']);
        }
      }, onDone: () {
        // WebSocket connection closed
        Logger.instance.writeLog('Recognition WebSocket closed');
      });
    } else {
      await _record.start(const RecordConfig(), path: 'tmp.mp4');
    }
  }
}