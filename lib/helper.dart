import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:process_run/shell.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'settings.dart';
import 'model.dart';

Timer? _currentTimer;
List<String> _pid = [];

const String _logFileName = 'error.log';
bool _logFileInitialized = false;

Future<void> _initLogging() async {
  if (!_logFileInitialized) {
    final settings = await readSettings();
    final bool enableLogging = settings['enable_logging'] ?? false;
    if (enableLogging) {
      final logFile = File(p.join(Directory.current.path, _logFileName));
      if (await logFile.exists()) {
        try {
          await logFile.delete();
        } catch (e) {
          // print('Failed to delete old log file: $e');
        }
      }
    }
    _logFileInitialized = true;
  }
}

Future<void> writeLog(String logContent) async {
  await _initLogging();
  final settings = await readSettings();
  final bool enableLogging = settings['enable_logging'] ?? false;

  if (!enableLogging) {
    return;
  }

  final logFile = File(p.join(Directory.current.path, _logFileName));
  final timestamp = DateTime.now().toIso8601String();
  final logEntry = '$timestamp - $logContent\n';

  try {
    await logFile.writeAsString(logEntry, mode: FileMode.append, flush: true);
  } catch (e) {
    // print('Failed to write to log file: $e');
  }
}

String decode(String str) {
  return utf8.decode(base64.decode(str.replaceAll(RegExp(r'\s+'), '')));
}

Future<String> runCmd(String command) async {
  var shell = Shell();
  List<ProcessResult> result;
  try {
    result = await shell.run(command);
    var re = '';
    for (var r in result) {
      re += r.stdout;
    }
    return re;
  } catch (e) {
    // print(e);
  }
  return '';
}

Future<String> loadAsset(String path) async {
  final Directory currentDirectory = Directory.current;
  final String filePath =
      p.join(currentDirectory.path, 'data', 'flutter_assets', path);
  final File file = File(filePath);
  if (await file.exists()) {
    return filePath;
  } else {
    final Directory parentDir = file.parent;
    if (!(await parentDir.exists())) {
      await parentDir.create(recursive: true);
    }
    try {
      ByteData data = await rootBundle.load(path);
      await file.writeAsBytes(
        data.buffer.asUint8List(),
        flush: true,
      );
    } finally {}
    return filePath;
  }
}

void startDuration(
    String duration, String hitokoto, String group, String api) async {
  _currentTimer?.cancel();
  if (duration.isEmpty) {
    return;
  }
  _currentTimer =
      Timer.periodic(Duration(seconds: int.parse(duration)), (timer) {
    /**
         * 执行动作，同时
         * 在以下功能中选择一个执行：
         * 1 输出一言
         * 2 请求模型并得到合适的问候语
         * 3 根据时间简单问候
         */
    if (group.isNotEmpty) {
      sendActionWs();
    }
    var r = [2];
    if (hitokoto.isNotEmpty) {
      r.add(0);
    }
    if (api.isNotEmpty) {
      r.add(1);
    }
    // var random = Random().nextInt(3);
    var random = r[Random().nextInt(r.length)];
    switch (random) {
      case 0:
        sendHitokoto(hitokoto);
        break;
      case 1:
        sendModel();
        break;
      case 2:
        sendTime();
        break;
    }
  });
}

Future<int?> tts(Object message) async {
  var settings = await readSettings();
  var tts = settings['tts'];
  var ttsKey = settings['tts_key'];
  var ttsModel = settings['tts_model'];
  var ttsVoice = settings['tts_voice'];
  if (tts != "" && ttsKey != "" && ttsModel != "" && ttsVoice != "") {
    OpenAI.baseUrl = tts;
    OpenAI.apiKey = ttsKey;
    File speechFile = await OpenAI.instance.audio.createSpeech(
        model: ttsModel,
        input: message.toString(),
        voice: ttsVoice,
        responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
        outputDirectory: Directory.current);
    // print("语音输出:$message\n该语音文件位于:${speechFile.path}");
    final soloud = SoLoud.instance;
    await soloud.init();
    final source = await soloud.loadFile(speechFile.path);
    await speechFile.delete();
    final duration = soloud.getLength(source);
    soloud.play(source);
    return duration.inMilliseconds;
  }
  return null;
}

Future<void> hideWindow() async {
  await windowManager.hide();
}

Future<void> quit() async {
  // if (pid != null) {
  for (var p in _pid) {
    if (p.isNotEmpty) {
      await runCmd("taskkill /F /PID $p");
    }
  }
  exit(0);
}

void insertPid(String pid) {
  _pid.add(pid);
}

Future<String?> getWindow(var infoGetter, var cmd) async {
  return decode(await runCmd(cmd));
}