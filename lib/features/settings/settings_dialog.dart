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

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../generated/l10n.dart';

class SettingsDialog extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final bool isClosedChecked;
  final bool isFlowChecked;
  final bool isLoggingEnabled;
  final bool isCheckUpdateEnabled;
  final String windowInfoGetter;
  final HotKey? currentHotKey;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;
  
  const SettingsDialog({
    Key? key,
    required this.controllers,
    required this.isClosedChecked,
    required this.isFlowChecked,
    required this.isLoggingEnabled,
    required this.isCheckUpdateEnabled,
    required this.windowInfoGetter,
    required this.currentHotKey,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);
  
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _isClosedChecked;
  late bool _isFlowChecked;
  late bool _isLoggingEnabled;
  late bool _isCheckUpdateEnabled;
  late String _windowInfoGetter;
  
  HotKey? _currentHotKey;
  HotKey? _recordingHotKey;
  bool _isRecordingHotKey = false;
  
  @override
  void initState() {
    super.initState();
    _isClosedChecked = widget.isClosedChecked;
    _isFlowChecked = widget.isFlowChecked;
    _isLoggingEnabled = widget.isLoggingEnabled;
    _isCheckUpdateEnabled = widget.isCheckUpdateEnabled;
    _windowInfoGetter = widget.windowInfoGetter;
    _currentHotKey = widget.currentHotKey;
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
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.setting),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.controllers['url'],
              decoration: InputDecoration(labelText: S.current.url),
            ),
            TextField(
              controller: widget.controllers['key'],
              decoration: InputDecoration(labelText: S.current.key),
            ),
            TextField(
              controller: widget.controllers['model'],
              decoration: InputDecoration(labelText: S.current.model),
            ),
            TextField(
              controller: widget.controllers['name'],
              decoration: InputDecoration(labelText: S.current.name),
            ),
            TextField(
              controller: widget.controllers['description'],
              decoration: InputDecoration(labelText: S.current.description),
              maxLines: null,
            ),
            TextField(
              controller: widget.controllers['user'],
              decoration: InputDecoration(labelText: S.current.user),
            ),
            TextField(
              controller: widget.controllers['question'],
              decoration: InputDecoration(labelText: S.current.question),
              maxLines: null,
            ),
            TextField(
              controller: widget.controllers['response'],
              decoration: InputDecoration(labelText: S.current.response),
              maxLines: null,
            ),
            TextField(
              controller: widget.controllers['exapi'],
              decoration: InputDecoration(labelText: S.current.exapi),
            ),
            TextField(
              controller: widget.controllers['modelNo'],
              decoration: InputDecoration(labelText: S.current.modelNo),
            ),
            TextField(
              controller: widget.controllers['LLMCmd'],
              decoration: InputDecoration(labelText: S.current.LLMCmd),
            ),
            TextField(
              controller: widget.controllers['ASRCmd'],
              decoration: InputDecoration(labelText: S.current.ASRCmd),
            ),
            Row(
              children: [
                Text(S.current.windowInfoGetter),
                Expanded(
                  child: DropdownMenu(
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
                  ),
                ),
              ],
            ),
            TextField(
              controller: widget.controllers['screenInfoCmd'],
              decoration: InputDecoration(labelText: S.current.screenInfoCmd),
            ),
            TextField(
              controller: widget.controllers['recognitionUrl'],
              decoration: InputDecoration(labelText: S.current.flowRecognition),
            ),
            Row(
              children: [
                Text(S.current.enableFlow),
                Checkbox(
                  value: _isFlowChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isFlowChecked = value!;
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: widget.controllers['keywords'],
              decoration: InputDecoration(labelText: S.current.keywords),
            ),
            TextField(
              controller: widget.controllers['whisper'],
              decoration: InputDecoration(labelText: S.current.whisper),
            ),
            TextField(
              controller: widget.controllers['whisperKey'],
              decoration: InputDecoration(labelText: S.current.whisperKey),
            ),
            TextField(
              controller: widget.controllers['whisperModel'],
              decoration: InputDecoration(labelText: S.current.whisperModel),
            ),
            TextField(
              controller: widget.controllers['duration'],
              decoration: InputDecoration(labelText: S.current.duration),
            ),
            TextField(
              controller: widget.controllers['hitokoto'],
              decoration: InputDecoration(labelText: S.current.hitokoto),
            ),
            TextField(
              controller: widget.controllers['TTS'],
              decoration: InputDecoration(labelText: S.current.TTS),
            ),
            TextField(
              controller: widget.controllers['TTSKey'],
              decoration: InputDecoration(labelText: S.current.TTSKey),
            ),
            TextField(
              controller: widget.controllers['TTSModel'],
              decoration: InputDecoration(labelText: S.current.TTSModel),
            ),
            TextField(
              controller: widget.controllers['TTSVoice'],
              decoration: InputDecoration(labelText: S.current.TTSVoice),
            ),
            TextField(
              controller: widget.controllers['actionGroup'],
              decoration: InputDecoration(labelText: S.current.actionGroup),
            ),
            Row(
              children: [
                Text(S.current.hide),
                Checkbox(
                  value: _isClosedChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isClosedChecked = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(S.current.enableLogging),
                Checkbox(
                  value: _isLoggingEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      _isLoggingEnabled = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(S.current.checkUpdate),
                Checkbox(
                  value: _isCheckUpdateEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      _isCheckUpdateEnabled = value!;
                    });
                  },
                ),
              ],
            ),
            // Hotkey recording section
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.current.wakeHotkey,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(S.current.currentHotkey(_formatHotKey(_currentHotKey))),
                  SizedBox(height: 12),
                  Column(
                    children: [
                      if (_isRecordingHotKey)
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                if (_recordingHotKey != null)
                                  HotKeyVirtualView(hotKey: _recordingHotKey!)
                                else
                                  Text(S.current.hotkeyRecording),
                              ],
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!_isRecordingHotKey) ...[
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isRecordingHotKey = true;
                                  _recordingHotKey = null;
                                });
                              },
                              child: Text(S.current.recordHotkey),
                            ),
                            if (_currentHotKey != null)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _recordingHotKey = null;
                                    _currentHotKey = null;
                                  });
                                },
                                child: Text(S.current.clearHotkey),
                              ),
                          ] else ...[
                            ElevatedButton(
                              onPressed: _recordingHotKey == null
                                  ? null
                                  : () {
                                      setState(() {
                                        _currentHotKey = _recordingHotKey;
                                        _isRecordingHotKey = false;
                                      });
                                    },
                              child: Text(S.current.saveHotkey),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isRecordingHotKey = false;
                                  _recordingHotKey = null;
                                });
                              },
                              child: Text(S.current.cancel),
                            ),
                          ],
                        ],
                      ),
                      if (_isRecordingHotKey)
                        Container(
                          height: 0,
                          width: 0,
                          child: HotKeyRecorder(
                            onHotKeyRecorded: (hotKey) {
                              setState(() {
                                _recordingHotKey = hotKey;
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
          onPressed: () {
            widget.onSave({
              'isClosedChecked': _isClosedChecked,
              'isFlowChecked': _isFlowChecked,
              'isLoggingEnabled': _isLoggingEnabled,
              'isCheckUpdateEnabled': _isCheckUpdateEnabled,
              'windowInfoGetter': _windowInfoGetter,
              'currentHotKey': _currentHotKey,
            });
            Navigator.of(context).pop();
          },
          child: Text(S.current.save),
        ),
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        ),
      ],
    );
  }
}