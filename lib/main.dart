// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'server.dart';
import 'core/config/constants.dart';
import 'core/config/settings_manager.dart';
import 'core/services/process_manager_service.dart';
import 'core/services/kage_websocket_service.dart';
import 'core/utils/logger.dart';
import 'features/chat/chat_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For hot reload, unregister all hotkeys
  try {
    await hotKeyManager.unregisterAll();
  } catch (e) {
    print('Failed to unregister all hotkeys: $e');
  }
  int port = Constants.defaultPort;
  while (true) {
    if (await isPortInUse(port)) {
      try {
        String? response = await sendMessage('isrunning', port);
        if (response == 'running') {
          await sendMessage('show', port);
          exit(0);
        } else {
          port++;
        }
      } catch (e) {
        port++;
      }
    } else {
      startServer(port);
      break;
    }
  }

  // Launch Kage if configured
  await _launchKageIfNeeded();

  await windowManager.ensureInitialized();
  double windowWidth = Constants.windowWidth;
  double windowHeight = Constants.windowHeight;
  await WindowManager.instance.setSize(Size(windowWidth, windowHeight));
  await WindowManager.instance.center();
  await WindowManager.instance.setAlwaysOnTop(true);
  runApp(const PettoApp());
}

class PettoApp extends StatelessWidget {
  const PettoApp({super.key});

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
      home: const ChatPage(),
    );
  }
}

/// Launch Kage application if configured
Future<void> _launchKageIfNeeded() async {
  try {
    final settings = await SettingsManager.instance.readSettings();
    final petMode = settings['pet_mode'] ?? 'kage';
    final kageExecutable = settings['kage_executable'] ?? '';
    final kageModelPath = settings['kage_model_path'] ?? '';
    final kageApiUrl = settings['kage_api_url'] ?? 'ws://localhost:23333';

    if (petMode == 'kage' &&
        kageExecutable.isNotEmpty &&
        await File(kageExecutable).exists()) {
      await Logger.instance.writeLog('Launching Kage from: $kageExecutable');

      // Launch Kage using ProcessManagerService
      await ProcessManagerService.instance
          .startProcess('kage', kageExecutable, []);

      // Wait a bit for Kage to start
      await Future.delayed(Duration(seconds: 2));

      // If model path is provided, set it via API
      if (kageModelPath.isNotEmpty && await File(kageModelPath).exists()) {
        try {
          final kageService = KageWebSocketService(kageApiUrl);
          await kageService.connect();
          await kageService.setModelPath(kageModelPath);
          await kageService.close();
          await Logger.instance.writeLog('Set Kage model to: $kageModelPath');
        } catch (e) {
          await Logger.instance.writeLog('Failed to set Kage model: $e');
        }
      }
    }
  } catch (e) {
    await Logger.instance.writeLog('Failed to launch Kage: $e');
  }
}
