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
import 'package:synchronized/synchronized.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'generated/l10n.dart';
import 'settings.dart';
import 'model.dart';

Timer? _currentTimer;
List<String> _pid = [];

const String _logFileName = 'error.log';
bool _logFileInitialized = false;
final _logLock = Lock();

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
  await _logLock.synchronized(() async {
    final logFile = File(p.join(Directory.current.path, _logFileName));
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp - $logContent\n';
    try {
      await logFile.writeAsString(logEntry, mode: FileMode.append, flush: true);
    } catch (e) {
      // print('Failed to write to log file: $e');
    }
  });
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

// 更新检查相关函数

/// 异步检查更新
Future<void> checkForUpdateInBackground(BuildContext context) async {
  try {
    final settings = await readSettings();
    final bool checkUpdate = settings['check_update'] ?? true;

    if (!checkUpdate) {
      await writeLog('Update check is disabled in settings');
      return;
    }

    await writeLog('Starting update check...');

    // 获取当前版本信息
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;

    // 增加超时时间，并添加重试机制
    http.Response? response;
    int retryCount = 0;
    const maxRetries = 2;

    while (response == null && retryCount < maxRetries) {
      try {
        response = await http.get(
          Uri.parse(
              'https://api.github.com/repos/funnycups/petto/releases/latest'),
          headers: {
            'Accept': 'application/vnd.github.v3+json',
          },
        ).timeout(const Duration(seconds: 30)); // 增加超时时间到30秒
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await writeLog(
              'Update check failed, retrying... (attempt $retryCount/$maxRetries)');
          await Future.delayed(const Duration(seconds: 2)); // 等待2秒后重试
        } else {
          throw e;
        }
      }
    }

    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tagName = data['tag_name'] ?? '';

      if (tagName.isNotEmpty) {
        // 处理 v 开头的版本号
        final latestVersion =
            tagName.startsWith('v') ? tagName.substring(1) : tagName;
        await writeLog(
            'Latest version: $latestVersion, Current version: $currentVersion');

        final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

        if (hasUpdate) {
          await writeLog('Update available: $latestVersion');

          // 确保窗口显示
          bool isVisible = await windowManager.isVisible();
          if (!isVisible) {
            await windowManager.show();
            await windowManager.focus();
          }

          if (context.mounted) {
            await _showUpdateDialog(
              context,
              latestVersion,
              data['body'] ?? '',
            );
          }
        } else {
          await writeLog('Already on latest version');
        }
      }
    } else {
      await writeLog(
          'Failed to check update, status code: ${response?.statusCode}');
    }
  } catch (e) {
    await writeLog('Error checking for updates: $e');
  }
}

/// 比较版本号
int _compareVersions(String version1, String version2) {
  final parts1 = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final parts2 = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  // 确保两个版本号有相同的部分数量
  while (parts1.length < parts2.length) {
    parts1.add(0);
  }
  while (parts2.length < parts1.length) {
    parts2.add(0);
  }

  for (int i = 0; i < parts1.length; i++) {
    if (parts1[i] > parts2[i]) {
      return 1;
    } else if (parts1[i] < parts2[i]) {
      return -1;
    }
  }

  return 0;
}

/// 显示更新对话框
Future<void> _showUpdateDialog(
    BuildContext context, String latestVersion, String releaseNotes) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(S.current.updateAvailable),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.current.updateMessage(latestVersion)),
            if (releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Release Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: _buildSimpleMarkdown(releaseNotes),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.current.updateLater),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await launchUrl(Uri.parse(
                  'https://github.com/funnycups/petto/releases/latest'));
            },
            child: Text(S.current.updateNow),
          ),
        ],
      );
    },
  );
}

/// 简单的 Markdown 解析器
Widget _buildSimpleMarkdown(String text) {
  final lines = text.split('\n');
  final List<Widget> widgets = [];

  for (var line in lines) {
    line = line.trim();

    if (line.isEmpty) {
      widgets.add(const SizedBox(height: 8));
      continue;
    }

    // 处理标题
    if (line.startsWith('### ')) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          line.substring(4),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ));
    } else if (line.startsWith('## ')) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          line.substring(3),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ));
    } else if (line.startsWith('# ')) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          line.substring(2),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ));
    }
    // 处理列表项
    else if (line.startsWith('- ') || line.startsWith('* ')) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: _parseInlineMarkdown(line.substring(2)),
            ),
          ],
        ),
      ));
    }
    // 普通文本
    else {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _parseInlineMarkdown(line),
      ));
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}

/// 解析行内 Markdown（粗体、斜体、代码）
Widget _parseInlineMarkdown(String text) {
  final List<TextSpan> spans = [];
  final RegExp pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)');

  int lastEnd = 0;
  for (final match in pattern.allMatches(text)) {
    // 添加普通文本
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
    }

    final matchText = match.group(0)!;

    // 粗体
    if (matchText.startsWith('**') && matchText.endsWith('**')) {
      spans.add(TextSpan(
        text: matchText.substring(2, matchText.length - 2),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
    }
    // 斜体
    else if (matchText.startsWith('*') && matchText.endsWith('*')) {
      spans.add(TextSpan(
        text: matchText.substring(1, matchText.length - 1),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
    }
    // 代码
    else if (matchText.startsWith('`') && matchText.endsWith('`')) {
      spans.add(TextSpan(
        text: matchText.substring(1, matchText.length - 1),
        style: const TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Color(0xFFE0E0E0),
        ),
      ));
    }

    lastEnd = match.end;
  }

  // 添加剩余的文本
  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd)));
  }

  return RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black, fontSize: 14),
      children: spans,
    ),
  );
}
