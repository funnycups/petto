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

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:openai_dart/openai_dart.dart';
import '../../generated/l10n.dart';
import '../../core/config/settings_manager.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/greeting_service.dart';
import '../../core/services/recognition_service.dart';
import '../../core/services/system_service.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/utils/logger.dart';
import '../../features/settings/settings_dialog.dart';
import '../../features/tray/tray_service.dart';
import '../../features/update/update_checker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WindowListener {
  // Text controllers
  final Map<String, TextEditingController> _controllers = {
    'url': TextEditingController(),
    'key': TextEditingController(),
    'model': TextEditingController(),
    'name': TextEditingController(),
    'description': TextEditingController(),
    'modelNo': TextEditingController(),
    'LLMCmd': TextEditingController(),
    'duration': TextEditingController(),
    'hitokoto': TextEditingController(),
    'user': TextEditingController(),
    'response': TextEditingController(),
    'question': TextEditingController(),
    'actionGroup': TextEditingController(),
    'ASRCmd': TextEditingController(),
    'recognitionUrl': TextEditingController(),
    'whisper': TextEditingController(),
    'whisperKey': TextEditingController(),
    'whisperModel': TextEditingController(),
    'exapi': TextEditingController(),
    'TTS': TextEditingController(),
    'TTSKey': TextEditingController(),
    'TTSModel': TextEditingController(),
    'TTSVoice': TextEditingController(),
    'keywords': TextEditingController(),
    'screenInfoCmd': TextEditingController(),
  };
  
  final TextEditingController _messageController = TextEditingController();
  
  // State variables
  bool _isClosedChecked = false;
  bool _isFlowChecked = false;
  bool _isLoggingEnabled = false;
  bool _isCheckUpdateEnabled = true;
  String _windowInfoGetter = '';
  bool _isRecording = false;
  String _result = '';
  bool _onLaunch = true;
  
  // Recording and hotkey related
  late Recognizer _foregroundRecognizer;
  Recognizer? _backgroundRecognizer;
  Timer? _backgroundRecognitionTimer;
  Timer? _foregroundRecognitionTimer;
  bool _isProcessing = false;
  
  // Hotkey management
  HotKey? _currentHotKey;
  bool _isHotkeyRegistered = false;
  HotKey? _registeredHotKey;
  
  // Timer management
  Timer? _durationTimer;
  
  @override
  void initState() {
    super.initState();
    _init();
    _loadSettings();
    _foregroundRecognizer = Recognizer();
    _foregroundRecognizer.onResult = _setResult;
    _currentHotKey = null;
  }
  
  @override
  void dispose() {
    try {
      TrayService.instance.dispose();
      windowManager.removeListener(this);
      // Unregister hotkey when disposing
      if (_isHotkeyRegistered && _registeredHotKey != null) {
        hotKeyManager.unregister(_registeredHotKey!).catchError((e) {
          print('Failed to unregister hotkey on dispose: $e');
        });
      }
      // Cancel timers
      _durationTimer?.cancel();
      _backgroundRecognitionTimer?.cancel();
      _foregroundRecognitionTimer?.cancel();
      // Dispose controllers
      _controllers.forEach((key, controller) => controller.dispose());
      _messageController.dispose();
    } catch (e) {
      print('Error in dispose: $e');
    }
    super.dispose();
  }
  
  void _init() async {
    await TrayService.instance.init();
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
    await SettingsManager.instance.saveDefaultSettings();
    setState(() {});
  }
  
  @override
  Future<void> onWindowMinimize() async {
    await PlatformUtils.hideWindow();
  }
  
  @override
  Future<void> onWindowClose() async {
    await SystemService.instance.quit();
  }
  
  @override
  void onWindowFocus() {
    setState(() {});
  }
  
  void _setResult(String r) {
    setState(() {
      _result = r;
    });
  }
  
  void _loadSettings() async {
    try {
      final data = await SettingsManager.instance.readSettings();
      
      // Load text field values
      _controllers['url']!.text = data['url'] ?? '';
      _controllers['key']!.text = data['key'] ?? '';
      _controllers['model']!.text = data['model'] ?? '';
      _controllers['name']!.text = data['name'] ?? '';
      _controllers['description']!.text = data['description'] ?? '';
      _controllers['modelNo']!.text = data['model_no'] ?? '';
      _controllers['LLMCmd']!.text = data['cmd'] ?? '';
      _controllers['duration']!.text = data['duration'] ?? '';
      _controllers['hitokoto']!.text = data['hitokoto'] ?? '';
      _controllers['user']!.text = data['user'] ?? '';
      _controllers['response']!.text = data['response'] ?? '';
      _controllers['question']!.text = data['question'] ?? '';
      _controllers['actionGroup']!.text = data['group'] ?? '';
      _controllers['ASRCmd']!.text = data['speech'] ?? '';
      _controllers['recognitionUrl']!.text = data['recognition_url'] ?? '';
      _controllers['whisper']!.text = data['whisper'] ?? '';
      _controllers['whisperKey']!.text = data['whisper_key'] ?? '';
      _controllers['whisperModel']!.text = data['whisper_model'] ?? '';
      _controllers['exapi']!.text = data['exapi'] ?? '';
      _controllers['TTS']!.text = data['tts'] ?? '';
      _controllers['TTSKey']!.text = data['tts_key'] ?? '';
      _controllers['TTSModel']!.text = data['tts_model'] ?? '';
      _controllers['TTSVoice']!.text = data['tts_voice'] ?? '';
      _controllers['keywords']!.text = data['keywords'] ?? '';
      _controllers['screenInfoCmd']!.text = data['screen_info_cmd'] ?? '';
      
      if (!_onLaunch) {
        return;
      }
      
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
        _isCheckUpdateEnabled = data['check_update'] ?? true;
      });
      
      // Load hotkey settings
      _loadHotkeySettings(data);
      
      // Start duration timer
      if (_controllers['duration']!.text.isNotEmpty) {
        _startDurationTimer();
      }
      
      // Run startup commands
      if (_controllers['ASRCmd']!.text.isNotEmpty) {
        SystemService.instance.addPid(
          await PlatformUtils.runCmd(_controllers['ASRCmd']!.text)
        );
      }
      if (_controllers['LLMCmd']!.text.isNotEmpty) {
        SystemService.instance.addPid(
          await PlatformUtils.runCmd(_controllers['LLMCmd']!.text)
        );
      }
      
      // Start background recognition if enabled
      if (_isFlowChecked && _controllers['recognitionUrl']!.text.isNotEmpty) {
        _startBackgroundRecognition();
      }
      
      // Check for updates on launch
      if (_isCheckUpdateEnabled && _onLaunch) {
        await Logger.instance.writeLog('Version check enabled and on launch, scheduling update check...');
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Logger.instance.writeLog('Starting version update check...');
            UpdateChecker.checkForUpdateInBackground(context);
          }
        });
      } else {
        await Logger.instance.writeLog(
          'Version check skipped: _isCheckUpdateEnabled=$_isCheckUpdateEnabled, _onLaunch=$_onLaunch'
        );
      }
      
      // Set _onLaunch to false after all startup operations
      _onLaunch = false;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }
  
  void _loadHotkeySettings(Map<String, dynamic> data) {
    try {
      if (data['wake_hotkey'] != null && data['wake_hotkey'] is Map) {
        final hotkeyData = data['wake_hotkey'] as Map<String, dynamic>;
        print('Loading hotkey data: ${jsonEncode(hotkeyData)}');
        
        try {
          _currentHotKey = HotKey.fromJson(hotkeyData);
          print('Successfully loaded hotkey: ${_formatHotKey(_currentHotKey)}');
          
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
          // Backward compatibility for old format
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
              
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await Future.delayed(Duration(milliseconds: 500));
                try {
                  await _registerHotKey();
                  print('Hotkey registered successfully (old format)');
                } catch (e) {
                  print('Failed to register hotkey on startup (old format): $e');
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
  }
  
  Future<void> _saveSettings() async {
    try {
      final data = {
        'url': _controllers['url']!.text,
        'key': _controllers['key']!.text,
        'model': _controllers['model']!.text,
        'name': _controllers['name']!.text,
        'description': _controllers['description']!.text,
        'model_no': _controllers['modelNo']!.text,
        'cmd': _controllers['LLMCmd']!.text,
        'duration': _controllers['duration']!.text,
        'hitokoto': _controllers['hitokoto']!.text,
        'user': _controllers['user']!.text,
        'response': _controllers['response']!.text,
        'question': _controllers['question']!.text,
        'group': _controllers['actionGroup']!.text,
        'speech': _controllers['ASRCmd']!.text,
        'recognition_url': _controllers['recognitionUrl']!.text,
        'flow': _isFlowChecked,
        'keywords': _controllers['keywords']!.text,
        'whisper': _controllers['whisper']!.text,
        'whisper_key': _controllers['whisperKey']!.text,
        'whisper_model': _controllers['whisperModel']!.text,
        'exapi': _controllers['exapi']!.text,
        'tts': _controllers['TTS']!.text,
        'tts_key': _controllers['TTSKey']!.text,
        'tts_model': _controllers['TTSModel']!.text,
        'tts_voice': _controllers['TTSVoice']!.text,
        'hide': _isClosedChecked,
        'window_info_getter': _windowInfoGetter,
        'screen_info_cmd': _controllers['screenInfoCmd']!.text,
        'enable_logging': _isLoggingEnabled,
        'check_update': _isCheckUpdateEnabled,
        'wake_hotkey': _currentHotKey?.toJson(),
      };
      
      print('Saving settings: ${jsonEncode(data)}');
      await SettingsManager.instance.saveSettings(jsonEncode(data));
      
      if (_controllers['duration']!.text.isNotEmpty) {
        _startDurationTimer();
      }
      
      // Register the hotkey after saving
      try {
        await _registerHotKey();
      } catch (e) {
        print('Failed to register hotkey after saving: $e');
      }
    } catch (e) {
      print('Failed to save settings: $e');
    }
  }
  
  void _startDurationTimer() {
    _durationTimer?.cancel();
    final durationText = _controllers['duration']!.text;
    if (durationText.isEmpty) return;
    
    _durationTimer = Timer.periodic(
      Duration(seconds: int.parse(durationText)),
      (timer) {
        // Execute action
        if (_controllers['actionGroup']!.text.isNotEmpty) {
          GreetingService.instance.sendAction();
        }
        
        // Choose greeting type
        var options = [2];
        if (_controllers['hitokoto']!.text.isNotEmpty) {
          options.add(0);
        }
        if (_controllers['url']!.text.isNotEmpty) {
          options.add(1);
        }
        
        var random = options[DateTime.now().millisecondsSinceEpoch % options.length];
        switch (random) {
          case 0:
            GreetingService.instance.sendHitokoto(_controllers['hitokoto']!.text);
            break;
          case 1:
            GreetingService.instance.sendModelGreeting();
            break;
          case 2:
            GreetingService.instance.sendTimeGreeting();
            break;
        }
      },
    );
  }
  
  void _startBackgroundRecognition() async {
    if (_controllers['keywords']!.text.isEmpty) {
      return;
    }
    
    _backgroundRecognizer = Recognizer();
    _backgroundRecognizer!.onResult = (String result) async {
      if (_isProcessing) {
        return;
      }
      _isProcessing = true;
      
      var keywords = _controllers['keywords']!.text.split(',');
      var match = keywords.firstWhere(
        (element) => result.contains(element),
        orElse: () => '',
      );
      
      if (match.isNotEmpty) {
        await _backgroundRecognizer!.stop();
        _backgroundRecognitionTimer?.cancel();
        
        final userMessage = [
          ChatCompletionMessage.system(
            content: S.current.backgroundRecognized(match),
          )
        ];
        
        var result = await AiService.instance.sendChatRequest(userMessage);
        if (result != null) {
          await GreetingService.instance.sendSpeechMessage(result, null);
        }
        
        _toggleRecording();
        await Future.delayed(Duration(seconds: 10));
        _toggleRecording();
      }
      _isProcessing = false;
    };
    
    _backgroundRecognitionTimer = Timer.periodic(
      Duration(seconds: 10),
      (timer) async {
        await _backgroundRecognizer!.stop();
        await _backgroundRecognizer!.start(
          _controllers['recognitionUrl']!.text,
          _isFlowChecked,
        );
      },
    );
  }
  
  Future<void> _registerHotKey() async {
    try {
      // First unregister any existing hotkey
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
      print('Failed to register hotkey: $e');
      _isHotkeyRegistered = false;
      _registeredHotKey = null;
    }
  }
  
  void _handleHotKeyPressed() async {
    if (await windowManager.isVisible()) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }
  
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SettingsDialog(
          controllers: _controllers,
          isClosedChecked: _isClosedChecked,
          isFlowChecked: _isFlowChecked,
          isLoggingEnabled: _isLoggingEnabled,
          isCheckUpdateEnabled: _isCheckUpdateEnabled,
          windowInfoGetter: _windowInfoGetter,
          currentHotKey: _currentHotKey,
          onSave: (values) async {
            _isClosedChecked = values['isClosedChecked'];
            _isFlowChecked = values['isFlowChecked'];
            _isLoggingEnabled = values['isLoggingEnabled'];
            _isCheckUpdateEnabled = values['isCheckUpdateEnabled'];
            _windowInfoGetter = values['windowInfoGetter'];
            _currentHotKey = values['currentHotKey'];
            
            await _saveSettings();
          },
          onCancel: () {
            _loadSettings();
          },
        );
      },
    );
  }
  
  void _toggleRecording() async {
    if (_isRecording) {
      await _foregroundRecognizer.stop();
      _sendRequest(_result);
      _setResult('');
      _foregroundRecognitionTimer?.cancel();
      
      if (_isFlowChecked) {
        _backgroundRecognitionTimer = Timer.periodic(
          Duration(seconds: 10),
          (timer) async {
            await _backgroundRecognizer!.stop();
            await _backgroundRecognizer!.start(
              _controllers['recognitionUrl']!.text,
              _isFlowChecked,
            );
          },
        );
      }
    } else {
      _backgroundRecognitionTimer?.cancel();
      await _backgroundRecognizer?.stop();
      
      bool flow;
      if (_controllers['recognitionUrl']!.text.isNotEmpty) {
        flow = true;
      } else if (_controllers['whisper']!.text.isNotEmpty ||
          _controllers['whisperKey']!.text.isNotEmpty ||
          _controllers['whisperModel']!.text.isNotEmpty) {
        flow = false;
      } else {
        return;
      }
      
      await _foregroundRecognizer.start(
        _controllers['recognitionUrl']!.text,
        flow,
      );
      
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
  
  void _sendRequest(String question) async {
    await PlatformUtils.hideWindow();
    
    final userMessage = [
      ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(question)
      )
    ];
    
    var response = await AiService.instance.sendChatRequest(userMessage);
    if (response == null || response.isEmpty) {
      await Logger.instance.writeLog('AI API returned null or empty response.');
      return;
    }
    
    await Logger.instance.writeLog('Got AI API response: $response');
    
    try {
      await Logger.instance.writeLog('Calling sendSpeechMessage');
      await GreetingService.instance.sendSpeechMessage(response, null);
      await Logger.instance.writeLog('sendSpeechMessage successfully called.');
    } catch (e, st) {
      await Logger.instance.writeLog('Error calling sendSpeechMessage: $e\n$st');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.chat),
        actions: [
          IconButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse("https://github.com/funnycups/petto")
              );
            },
            icon: const Icon(Feather.github),
          ),
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
              controller: _messageController,
              decoration: InputDecoration(labelText: S.current.placeholder),
              onSubmitted: (String question) {
                _sendRequest(question);
                _messageController.clear();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String question = _messageController.text;
                _sendRequest(question);
                _messageController.clear();
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
              child: Text(
                _isRecording
                    ? S.current.stopRecording
                    : S.current.startRecording
              ),
            ),
          ],
        ),
      ),
    );
  }
}