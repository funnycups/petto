import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'settings.dart';
import 'recognizer.dart';
import 'helper.dart';
import 'model.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: QuestionPage(),
    );
  }
}

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with TrayListener, WindowListener {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _modelNoController = TextEditingController();
  final TextEditingController _LLMCmdController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _hitokotoController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _actionGroupController = TextEditingController();
  final TextEditingController _ASRCmdController = TextEditingController();
  final TextEditingController _recognitionUrlController =
      TextEditingController();
  final TextEditingController _whisperController = TextEditingController();
  final TextEditingController _whisperKeyController = TextEditingController();
  final TextEditingController _whisperModelController = TextEditingController();
  final TextEditingController _exapiController = TextEditingController();
  final TextEditingController _TTSController = TextEditingController();
  final TextEditingController _TTSKeyController = TextEditingController();
  final TextEditingController _TTSModelController = TextEditingController();
  final TextEditingController _TTSVoiceController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _screenInfoCmd = TextEditingController();
  bool _isClosedChecked = false;
  bool _isFlowChecked = false;
  String _windowInfoGetter = '';
  late Recognizer _foregroundRecognizer;
  Recognizer? _backgroundRecognizer;
  bool _isRecording = false;
  String _result = '';
  Timer? _backgroundRecognitionTimer;
  Timer? _foregroundRecognitionTimer;
  bool _isProcessing = false;
  bool _onLaunch = true;

  Future<void> trayManagerInit() async {
    await trayManager.setIcon(await loadAsset('images\\tray_icon.ico'));
    Menu menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: S.current.show),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: S.current.exit),
      ],
    );
    await trayManager.setContextMenu(menu);
    trayManager.addListener(this);
  }

  @override
  Future<void> onWindowMinimize() async {
    await hideWindow();
  }

  @override
  Future<void> onWindowClose() async {
    await quit();
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  @override
  void initState() {
    trayManagerInit();
    windowManager.addListener(this);
    super.initState();
    _init();
    _loadSettings();
    _foregroundRecognizer = Recognizer();
    _foregroundRecognizer.onResult = setResult;
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
    } else if (menuItem.key == 'exit_app') {
      await quit();
    }
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onTrayIconRightMouseUp() async {
    await trayManager.popUpContextMenu();
  }

  @override
  Future<void> onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  void _init() async {
    await windowManager.setPreventClose(true);
    await saveDefaultSettings();
    setState(() {});
  }

  void _startBackgroundRecognition() async {
    if (_keywordsController.text.isEmpty) {
      return;
    }
    _backgroundRecognizer = Recognizer();
    _backgroundRecognizer!.onResult = (String result) async {
      if (_isProcessing) {
        return;
      }
      _isProcessing = true;
      print("result:$result");
      var keywords = _keywordsController.text.split(',');
      var match = keywords.firstWhere((element) => result.contains(element),
          orElse: () => '');
      if (match.isNotEmpty) {
        print("后台识别到唤醒关键词: $match");
        await _backgroundRecognizer!.stop();
        _backgroundRecognitionTimer?.cancel();
        final userMessage = OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                S.current.backgroundRecognized(match),
              ),
            ]);
        var result = await aiApi(userMessage);
        await sendSpeechWs(result as Object, null);
        _toggleRecording();
        await Future.delayed(Duration(seconds: 10));
        _toggleRecording();
      }
      _isProcessing = false;
    };
    // await _backgroundRecognizer!.start(_recognitionUrlController.text, _isFlowChecked);
    _backgroundRecognitionTimer =
        Timer.periodic(Duration(seconds: 10), (timer) async {
      // print("launch");
      await _backgroundRecognizer!.stop();
      await _backgroundRecognizer!
          .start(_recognitionUrlController.text, _isFlowChecked);
    });
  }

  void _loadSettings() async {
    try {
      final data = await readSettings();
      _urlController.text = data['url'] ?? '';
      _keyController.text = data['key'] ?? '';
      _modelController.text = data['model'] ?? '';
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _modelNoController.text = data['model_no'] ?? '';
      _LLMCmdController.text = data['cmd'] ?? '';
      _durationController.text = data['duration'] ?? '';
      _hitokotoController.text = data['hitokoto'] ?? '';
      _userController.text = data['user'] ?? '';
      _responseController.text = data['response'] ?? '';
      _questionController.text = data['question'] ?? '';
      _actionGroupController.text = data['group'] ?? '';
      _ASRCmdController.text = data['speech'] ?? '';
      _recognitionUrlController.text = data['recognition_url'] ?? '';
      _whisperController.text = data['whisper'] ?? '';
      _whisperKeyController.text = data['whisper_key'] ?? '';
      _whisperModelController.text = data['whisper_model'] ?? '';
      _exapiController.text = data['exapi'] ?? '';
      _TTSController.text = data['tts'] ?? '';
      _TTSKeyController.text = data['tts_key'] ?? '';
      _TTSModelController.text = data['tts_model'] ?? '';
      _TTSVoiceController.text = data['tts_voice'] ?? '';
      _keywordsController.text = data['keywords'] ?? '';
      _screenInfoCmd.text = data['screen_info_cmd'] ?? '';
      if (!_onLaunch) {
        return;
      }
      _onLaunch = false;
      if (data['hide'] ?? false) {
        windowManager.waitUntilReadyToShow(null, () async {
          await windowManager.hide();
        });
        // WidgetsBinding.instance.addPostFrameCallback((_) async {
        //   await windowManager.hide();
        // });
        // Future.microtask(() async {
        //   await windowManager.hide();
        // });
      }
      setState(() {
        _isClosedChecked = data['hide'] ?? false;
        _isFlowChecked = data['flow'] ?? false;
        _windowInfoGetter = data['window_info_getter'] ?? '';
      });
      if (_durationController.text.isNotEmpty) {
        startDuration(_durationController.text, _hitokotoController.text,
            _actionGroupController.text, _urlController.text);
      }
      if (_ASRCmdController.text.isNotEmpty) {
        // _pid.insert(0, await powershell(_controller14.text));
        insertPid(await runCmd(_ASRCmdController.text));
      }
      if (_LLMCmdController.text.isNotEmpty) {
        // _pid.insert(0, await powershell(_controller7.text));
        insertPid(await runCmd(_LLMCmdController.text));
      }
      if (_isFlowChecked && _recognitionUrlController.text.isNotEmpty) {
        _startBackgroundRecognition();
      }
    } catch (e) {
      // print('加载设置失败: $e');
    }
  }

  void _saveSettings() async {
    try {
      final data = {
        'url': _urlController.text,
        'key': _keyController.text,
        'model': _modelController.text,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'model_no': _modelNoController.text,
        'cmd': _LLMCmdController.text,
        'duration': _durationController.text,
        'hitokoto': _hitokotoController.text,
        'user': _userController.text,
        'response': _responseController.text,
        'question': _questionController.text,
        'group': _actionGroupController.text,
        'speech': _ASRCmdController.text,
        'recognition_url': _recognitionUrlController.text,
        'flow': _isFlowChecked,
        'keywords': _keywordsController.text,
        'whisper': _whisperController.text,
        'whisper_key': _whisperKeyController.text,
        'whisper_model': _whisperModelController.text,
        'exapi': _exapiController.text,
        'tts': _TTSController.text,
        'tts_key': _TTSKeyController.text,
        'tts_model': _TTSModelController.text,
        'tts_voice': _TTSVoiceController.text,
        'hide': _isClosedChecked,
        'window_info_getter': _windowInfoGetter,
        'screen_info_cmd': _screenInfoCmd.text
      };
      // final file = File(_settingsFile);
      // await file.writeAsString(jsonEncode(data));
      // await _storage.write(key: 'settings', value: jsonEncode(data));
      await saveSettings(jsonEncode(data));
      if (_durationController.text.isNotEmpty) {
        startDuration(_durationController.text, _hitokotoController.text,
            _actionGroupController.text, _urlController.text);
      }
    } catch (e) {
      // print('保存设置失败: $e');
    }
  }

  void setResult(String r) {
    setState(() {
      _result = r;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.current.setting),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: S.current.url),
                ),
                TextField(
                  controller: _keyController,
                  decoration: InputDecoration(labelText: S.current.key),
                ),
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: S.current.model),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: S.current.name),
                ),
                TextField(
                    controller: _descriptionController,
                    decoration:
                        InputDecoration(labelText: S.current.description),
                    maxLines: null),
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(labelText: S.current.user),
                ),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(labelText: S.current.question),
                  maxLines: null,
                ),
                TextField(
                  controller: _responseController,
                  decoration: InputDecoration(labelText: S.current.response),
                  maxLines: null,
                ),
                TextField(
                  controller: _exapiController,
                  decoration: InputDecoration(labelText: S.current.exapi),
                ),
                TextField(
                  controller: _modelNoController,
                  decoration: InputDecoration(labelText: S.current.modelNo),
                ),
                TextField(
                  controller: _LLMCmdController,
                  decoration: InputDecoration(labelText: S.current.LLMCmd),
                ),
                TextField(
                  controller: _ASRCmdController,
                  decoration: InputDecoration(labelText: S.current.ASRCmd),
                ),
                Row(
                  children: [
                    Text(S.current.windowInfoGetter),
                    Expanded(
                        child: StatefulBuilder(builder: (context, setState) {
                      return DropdownMenu(
                        dropdownMenuEntries: [
                          S.current.shell,
                          S.current.screenshot
                        ].map((String value) {
                          return DropdownMenuEntry(value: value, label: value);
                        }).toList(),
                        onSelected: (String? value) {
                          setState(() {
                            _windowInfoGetter = value!;
                          });
                        },
                        initialSelection: _windowInfoGetter,
                      );
                    }))
                  ],
                ),
                TextField(
                  controller: _screenInfoCmd,
                  decoration:
                      InputDecoration(labelText: S.current.screenInfoCmd),
                ),
                TextField(
                  controller: _recognitionUrlController,
                  decoration:
                      InputDecoration(labelText: S.current.flowRecognition),
                ),
                Row(
                  children: [
                    Text(S.current.enableFlow),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Checkbox(
                          value: _isFlowChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isFlowChecked = value!;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _keywordsController,
                  decoration: InputDecoration(labelText: S.current.keywords),
                ),
                TextField(
                  controller: _whisperController,
                  decoration: InputDecoration(labelText: S.current.whisper),
                ),
                TextField(
                  controller: _whisperKeyController,
                  decoration: InputDecoration(labelText: S.current.whisperKey),
                ),
                TextField(
                  controller: _whisperModelController,
                  decoration:
                      InputDecoration(labelText: S.current.whisperModel),
                ),
                TextField(
                  controller: _durationController,
                  decoration: InputDecoration(labelText: S.current.duration),
                ),
                TextField(
                  controller: _hitokotoController,
                  decoration: InputDecoration(labelText: S.current.hitokoto),
                ),
                TextField(
                  controller: _TTSController,
                  decoration: InputDecoration(labelText: S.current.TTS),
                ),
                TextField(
                  controller: _TTSKeyController,
                  decoration: InputDecoration(labelText: S.current.TTSKey),
                ),
                TextField(
                  controller: _TTSModelController,
                  decoration: InputDecoration(labelText: S.current.TTSModel),
                ),
                TextField(
                  controller: _TTSVoiceController,
                  decoration: InputDecoration(labelText: S.current.TTSVoice),
                ),
                TextField(
                  controller: _actionGroupController,
                  decoration: InputDecoration(labelText: S.current.actionGroup),
                ),
                Row(
                  children: [
                    Text(S.current.hide),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Checkbox(
                          value: _isClosedChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isClosedChecked = value!;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _saveSettings();
                Navigator.of(context).pop();
              },
              child: Text(S.current.save),
            ),
            TextButton(
              onPressed: () {
                _loadSettings();
                Navigator.of(context).pop();
              },
              child: Text(S.current.cancel),
            ),
          ],
        );
      },
    );
  }

  void _toggleRecording() async {
    if (_isRecording) {
      print("录音结束，识别结果: $_result");
      await _foregroundRecognizer.stop();
      sendRequest(_result);
      setResult('');
      _foregroundRecognitionTimer?.cancel();
      if (_isFlowChecked) {
        _backgroundRecognitionTimer =
            Timer.periodic(Duration(seconds: 10), (timer) async {
          await _backgroundRecognizer!.stop();
          await _backgroundRecognizer!
              .start(_recognitionUrlController.text, _isFlowChecked);
        });
      }
      // await _backgroundRecognizer?.start(_recognitionUrlController.text, _isFlowChecked);
    } else {
      _backgroundRecognitionTimer?.cancel();
      await _backgroundRecognizer?.stop();
      bool flow;
      if (_recognitionUrlController.text.isNotEmpty) {
        flow = true;
      } else if (_whisperController.text.isNotEmpty ||
          _whisperKeyController.text.isNotEmpty ||
          _whisperModelController.text.isNotEmpty) {
        flow = false;
      } else {
        return;
      }
      await _foregroundRecognizer.start(_recognitionUrlController.text, flow);
      _foregroundRecognitionTimer = Timer(Duration(seconds: 10), () {
        if (_isRecording) {
          _toggleRecording();
        }
      });
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.chat),
        actions: [
          IconButton(
              onPressed: () async {
                await launchUrl(
                    Uri.parse("https://github.com/funnycups/petto"));
              },
              icon: const Icon(Feather.github)),
          IconButton(
            icon: const Icon(Feather.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: S.current.placeholder),
              onSubmitted: (String question) {
                sendRequest(question);
                _controller.clear();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String question = _controller.text;
                sendRequest(question);
                _controller.clear();
              },
              child: Text(
                S.current.confirm,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(_isRecording
                  ? S.current.stopRecording
                  : S.current.startRecording),
            ),
          ],
        ),
      ),
    );
  }
}
