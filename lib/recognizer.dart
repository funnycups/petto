import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:dart_openai/dart_openai.dart';
import 'settings.dart';

class Recognizer {
  final _record = AudioRecorder();
  Stream<Uint8List>? _stream;
  late dynamic _webSocket;
  late Function(String) onResult;
  late bool _flow;

  Future<void> stop() async {
    if(!await(_record.isRecording())){
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
        var settings = await readSettings();
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
    if(await _record.isRecording()){
      return;
    }
    _flow = flow;
    if (!await _record.hasPermission()) {
      onResult('没有录音权限');
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
        // print('录音数据: ${data.length} bytes');
        await _webSocket.sink.add(Uint8List.fromList(data));
      }, onDone: () async {
        // print('done');
      });
      _webSocket.stream.listen((message) {
        var response = json.decode(message);
        // print('收到服务器响应: $response');

        if (response['result'] != null) {
          // print('识别结果: ${response['result']}');
          // result = response['result'];
          onResult(response['result']);
        }
      }, onDone: () {
        // print('WebSocket 连接关闭');
      });
    } else {
      await _record.start(const RecordConfig(), path: 'tmp.mp4');
    }
  }
}
