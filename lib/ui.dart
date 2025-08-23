import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
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
  bool _isLoggingEnabled = false;
  String _windowInfoGetter = '';
  late Recognizer _foregroundRecognizer;
  Recognizer? _backgroundRecognizer;
  bool _isRecording = false;
  String _result = '';
  Timer? _backgroundRecognitionTimer;
  Timer? _foregroundRecognitionTimer;
  bool _isProcessing = false;
  bool _onLaunch = true;
  HotKey? _currentHotKey;
  HotKey? _recordingHotKey;
  bool _isRecordingHotKey = false;

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
    // Initialize hotkey variables to null
    _currentHotKey = null;
    _recordingHotKey = null;
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
    try {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
      // Unregister hotkey when disposing
      if (_isHotkeyRegistered && _registeredHotKey != null) {
        hotKeyManager.unregister(_registeredHotKey!).catchError((e) {
          print('Failed to unregister hotkey on dispose: $e');
        });
      }
    } catch (e) {
      print('Error in dispose: $e');
    }
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
      var keywords = _keywordsController.text.split(',');
      var match = keywords.firstWhere((element) => result.contains(element),
          orElse: () => '');
      if (match.isNotEmpty) {
        await _backgroundRecognizer!.stop();
        _backgroundRecognitionTimer?.cancel();
        final userMessage = [
          ChatCompletionMessage.system(
            content: S.current.backgroundRecognized(match),
          )
        ];
        var result = await aiApi(userMessage);
        await sendSpeechWs(result as Object, null);
        _toggleRecording();
        await Future.delayed(Duration(seconds: 10));
        _toggleRecording();
      }
      _isProcessing = false;
    };
    _backgroundRecognitionTimer =
        Timer.periodic(Duration(seconds: 10), (timer) async {
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
      }
      setState(() {
        _isClosedChecked = data['hide'] ?? false;
        _isFlowChecked = data['flow'] ?? false;
        _windowInfoGetter = data['window_info_getter'] ?? '';
        _isLoggingEnabled = data['enable_logging'] ?? false;
      });

      // Load hotkey settings using HotKey.fromJson
      try {
        if (data['wake_hotkey'] != null && data['wake_hotkey'] is Map) {
          final hotkeyData = data['wake_hotkey'] as Map<String, dynamic>;
          print('Loading hotkey data: ${jsonEncode(hotkeyData)}');

          try {
            _currentHotKey = HotKey.fromJson(hotkeyData);
            print(
                'Successfully loaded hotkey: ${_formatHotKey(_currentHotKey)}');

            // Delay hotkey registration to avoid startup issues
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await Future.delayed(Duration(milliseconds: 500));
              try {
                await _registerHotKey();
                print('Hotkey registered successfully');
              } catch (e) {
                print('Failed to register hotkey on startup: $e');
              }
            });
          } catch (e) {
            print('Failed with new format, trying old format: $e');
            // If that fails, try the old format (backward compatibility)
            if (hotkeyData.containsKey('key') && hotkeyData['key'] is int) {
              final key = PhysicalKeyboardKey.findKeyByCode(hotkeyData['key']);
              if (key != null) {
                List<HotKeyModifier> modifiers = [];
                if (hotkeyData['modifiers'] is List) {
                  for (var modName in hotkeyData['modifiers']) {
                    try {
                      final modifier = HotKeyModifier.values.firstWhere(
                        (m) => m.name == modName,
                      );
                      modifiers.add(modifier);
                    } catch (e) {
                      print('Failed to load modifier: $modName');
                    }
                  }
                }
                _currentHotKey = HotKey(
                  key: key,
                  modifiers: modifiers.isEmpty ? null : modifiers,
                  scope: HotKeyScope.system,
                );

                // Also delay registration for old format
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await Future.delayed(Duration(milliseconds: 500));
                  try {
                    await _registerHotKey();
                    print('Hotkey registered successfully (old format)');
                  } catch (e) {
                    print(
                        'Failed to register hotkey on startup (old format): $e');
                  }
                });
              }
            }
          }
        }
      } catch (e) {
        print('Failed to load hotkey settings: $e');
        _currentHotKey = null;
      }

      if (_durationController.text.isNotEmpty) {
        startDuration(_durationController.text, _hitokotoController.text,
            _actionGroupController.text, _urlController.text);
      }
      if (_ASRCmdController.text.isNotEmpty) {
        insertPid(await runCmd(_ASRCmdController.text));
      }
      if (_LLMCmdController.text.isNotEmpty) {
        insertPid(await runCmd(_LLMCmdController.text));
      }
      if (_isFlowChecked && _recognitionUrlController.text.isNotEmpty) {
        _startBackgroundRecognition();
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      // Debug: Log hotkey JSON
      if (_currentHotKey != null) {
        try {
          final hotkeyJson = _currentHotKey!.toJson();
          print('Hotkey JSON: ${jsonEncode(hotkeyJson)}');
        } catch (e) {
          print('Failed to serialize hotkey: $e');
        }
      }

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
        'screen_info_cmd': _screenInfoCmd.text,
        'enable_logging': _isLoggingEnabled,
        'wake_hotkey': _currentHotKey?.toJson(),
      };
      print('Saving settings: ${jsonEncode(data)}');
      await saveSettings(jsonEncode(data));
      if (_durationController.text.isNotEmpty) {
        startDuration(_durationController.text, _hitokotoController.text,
            _actionGroupController.text, _urlController.text);
      }
      // Register the hotkey after saving
      try {
        await _registerHotKey();
      } catch (e) {
        print('Failed to register hotkey after saving: $e');
      }
    } catch (e) {
      print('Failed to save settings: $e');
      // Optionally show an error dialog to the user
    }
  }

  void setResult(String r) {
    setState(() {
      _result = r;
    });
  }

  // Track if hotkey is registered
  bool _isHotkeyRegistered = false;
  HotKey? _registeredHotKey;  // Track the actually registered hotkey

  // Register the wake-up hotkey
  Future<void> _registerHotKey() async {
    try {
      // First unregister any existing hotkey if it was registered
      if (_isHotkeyRegistered && _registeredHotKey != null) {
        try {
          await hotKeyManager.unregister(_registeredHotKey!);
          _isHotkeyRegistered = false;
          _registeredHotKey = null;
          print('Previous hotkey unregistered');
        } catch (e) {
          print('Failed to unregister previous hotkey: $e');
        }
      }

      // Only register if _currentHotKey is not null
      if (_currentHotKey != null) {
        await hotKeyManager.register(
          _currentHotKey!,
          keyDownHandler: (hotKey) {
            _handleHotKeyPressed();
          },
        );
        _isHotkeyRegistered = true;
        _registeredHotKey = _currentHotKey;
        print('Hotkey registered: ${_formatHotKey(_currentHotKey)}');
      } else {
        print('No hotkey to register (cleared)');
      }
    } catch (e) {
      // Log error but don't crash
      print('Failed to register hotkey: $e');
      _isHotkeyRegistered = false;
      _registeredHotKey = null;
    }
  }

  // Handle hotkey press - toggle window visibility
  void _handleHotKeyPressed() async {
    if (await windowManager.isVisible()) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  // Format hotkey for display
  String _formatHotKey(HotKey? hotKey) {
    if (hotKey == null) return S.current.none;

    List<String> parts = [];
    if (hotKey.modifiers != null) {
      for (var modifier in hotKey.modifiers!) {
        if (modifier.physicalKeys.isNotEmpty) {
          parts.add(modifier.physicalKeys.first.keyLabel);
        }
      }
    }
    parts.add(hotKey.physicalKey.keyLabel);
    return parts.join(' + ');
  }

  void _showSettingsDialog() {
    // Create local copies of the hotkey variables for the dialog
    HotKey? dialogCurrentHotKey = _currentHotKey;
    HotKey? dialogRecordingHotKey = _recordingHotKey;
    bool dialogIsRecordingHotKey = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
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
                      decoration:
                          InputDecoration(labelText: S.current.question),
                      maxLines: null,
                    ),
                    TextField(
                      controller: _responseController,
                      decoration:
                          InputDecoration(labelText: S.current.response),
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
                        Expanded(child:
                            StatefulBuilder(builder: (context, setState) {
                          return DropdownMenu(
                            dropdownMenuEntries: [
                              S.current.shell,
                              S.current.screenshot
                            ].map((String value) {
                              return DropdownMenuEntry(
                                  value: value, label: value);
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
                      decoration:
                          InputDecoration(labelText: S.current.keywords),
                    ),
                    TextField(
                      controller: _whisperController,
                      decoration: InputDecoration(labelText: S.current.whisper),
                    ),
                    TextField(
                      controller: _whisperKeyController,
                      decoration:
                          InputDecoration(labelText: S.current.whisperKey),
                    ),
                    TextField(
                      controller: _whisperModelController,
                      decoration:
                          InputDecoration(labelText: S.current.whisperModel),
                    ),
                    TextField(
                      controller: _durationController,
                      decoration:
                          InputDecoration(labelText: S.current.duration),
                    ),
                    TextField(
                      controller: _hitokotoController,
                      decoration:
                          InputDecoration(labelText: S.current.hitokoto),
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
                      decoration:
                          InputDecoration(labelText: S.current.TTSModel),
                    ),
                    TextField(
                      controller: _TTSVoiceController,
                      decoration:
                          InputDecoration(labelText: S.current.TTSVoice),
                    ),
                    TextField(
                      controller: _actionGroupController,
                      decoration:
                          InputDecoration(labelText: S.current.actionGroup),
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
                    Row(
                      children: [
                        Text(S.current.enableLogging),
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Checkbox(
                              value: _isLoggingEnabled,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isLoggingEnabled = value!;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    // Hotkey recording section
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.current.wakeHotkey,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(S.current.currentHotkey(
                              _formatHotKey(dialogCurrentHotKey))),
                          SizedBox(height: 12),
                          Column(
                            children: [
                              if (dialogIsRecordingHotKey)
                                Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        if (dialogRecordingHotKey != null)
                                          HotKeyVirtualView(
                                              hotKey: dialogRecordingHotKey!)
                                        else
                                          Text(S.current.hotkeyRecording),
                                      ],
                                    ),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (!dialogIsRecordingHotKey) ...[
                                    ElevatedButton(
                                      onPressed: () {
                                        dialogSetState(() {
                                          dialogIsRecordingHotKey = true;
                                          dialogRecordingHotKey = null;
                                        });
                                      },
                                      child: Text(S.current.recordHotkey),
                                    ),
                                    if (dialogCurrentHotKey != null)
                                      ElevatedButton(
                                        onPressed: () {
                                          dialogSetState(() {
                                            dialogRecordingHotKey = null;
                                            dialogCurrentHotKey = null;
                                          });
                                        },
                                        child: Text(S.current.clearHotkey),
                                      ),
                                  ] else ...[
                                    ElevatedButton(
                                      onPressed: dialogRecordingHotKey == null
                                          ? null
                                          : () {
                                              dialogSetState(() {
                                                dialogCurrentHotKey =
                                                    dialogRecordingHotKey;
                                                dialogIsRecordingHotKey = false;
                                              });
                                            },
                                      child: Text(S.current.saveHotkey),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        dialogSetState(() {
                                          dialogIsRecordingHotKey = false;
                                          dialogRecordingHotKey = null;
                                        });
                                      },
                                      child: Text(S.current.cancel),
                                    ),
                                  ],
                                ],
                              ),
                              if (dialogIsRecordingHotKey)
                                Container(
                                  height: 0,
                                  width: 0,
                                  child: HotKeyRecorder(
                                    onHotKeyRecorded: (hotKey) {
                                      dialogSetState(() {
                                        dialogRecordingHotKey = hotKey;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    // Update the main state with dialog values
                    _currentHotKey = dialogCurrentHotKey;
                    _recordingHotKey = dialogRecordingHotKey;

                    await _saveSettings();
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
      },
    );
  }

  void _toggleRecording() async {
    if (_isRecording) {
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
