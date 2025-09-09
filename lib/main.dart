// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:io';
import 'dart:convert';
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
import 'core/services/kage_download_service.dart';
import 'core/utils/logger.dart';
import 'features/chat/chat_page.dart';
import 'features/dialogs/dialogs.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  await windowManager.ensureInitialized();
  double windowWidth = Constants.windowWidth;
  double windowHeight = Constants.windowHeight;
  await WindowManager.instance.setSize(Size(windowWidth, windowHeight));
  await WindowManager.instance.center();
  await WindowManager.instance.setAlwaysOnTop(true);
  runApp(const PettoApp());
}

class PettoApp extends StatefulWidget {
  const PettoApp({super.key});

  @override
  State<PettoApp> createState() => _PettoAppState();
}

class _PettoAppState extends State<PettoApp> {
  @override
  void initState() {
    super.initState();
    // Launch Kage after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchKageIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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

/// Launch Kage application if configured or download if needed
Future<void> _launchKageIfNeeded() async {
  try {
    final settings = await SettingsManager.instance.readSettings();
    final petMode = settings['pet_mode'] ?? 'kage';
    final kageApiUrl = settings['kage_api_url'] ?? 'ws://localhost:23333';

    // Only proceed if in Kage mode
    if (petMode != 'kage') {
      await Logger.instance.writeLog('Not in Kage mode, skipping Kage launch');
      return;
    }

    // Check if Kage is already running (might be started externally)
    if (await KageWebSocketService.isKageAccessible(kageApiUrl)) {
      await Logger.instance
          .writeLog('Kage is already running, skipping launch');
      return;
    }

    // Check if we need to download Kage
    if (await KageDownloadService.shouldDownloadKage(settings)) {
      await Logger.instance
          .writeLog('Kage download needed, checking for release');

      // Get latest release info
      final releaseInfo = await KageDownloadService.getLatestRelease();
      if (releaseInfo == null) {
        await Logger.instance.writeLog('Failed to get Kage release info');
        return;
      }

      // Show download confirmation dialog
      final BuildContext? context = navigatorKey.currentContext;
      if (context == null) {
        await Logger.instance.writeLog('No context available for dialog');
        return;
      }

      final result = await showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (context) => KageDownloadDialog(releaseInfo: releaseInfo),
      );

      if (result != null && result['download'] == true) {
        final installPath = result['installPath'] as String;
        final useGhProxy = result['useGhProxy'] as bool? ?? false;

        // Find download URL
        var downloadUrl = KageDownloadService.findDownloadUrl(releaseInfo);
        if (downloadUrl == null) {
          await Logger.instance
              .writeLog('Download URL not found for current platform');
          return;
        }

        // Apply ghproxy if selected
        if (useGhProxy) {
          const ghProxyPrefix = 'https://ghfast.top/';
          downloadUrl = ghProxyPrefix + downloadUrl;
          await Logger.instance.writeLog('Using ghproxy: $downloadUrl');
        }

        // Show download progress dialog
        String? executablePath;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => KageDownloadProgressDialog(
            downloadUrl: downloadUrl!,
            installPath: installPath,
            onComplete: (path) async {
              executablePath = path;

              // Update settings with new executable path
              settings['kage_executable'] = path;
              await SettingsManager.instance.saveSettings(jsonEncode(settings));
              await Logger.instance
                  .writeLog('Updated Kage executable path: $path');

              Navigator.of(dialogContext).pop();
            },
            onError: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.current.downloadFailed)),
              );
            },
          ),
        );

        // If download was successful, launch Kage
        if (executablePath != null) {
          await _launchKage(executablePath!, settings);
        }
      }
    } else {
      // Normal launch flow - Kage already exists
      final kageExecutable = settings['kage_executable'] ?? '';
      if (kageExecutable.isNotEmpty && await File(kageExecutable).exists()) {
        await _launchKage(kageExecutable, settings);
      }
    }
  } catch (e) {
    await Logger.instance.writeLog('Failed in _launchKageIfNeeded: $e');
  }
}

/// Launch Kage with the given executable path
Future<void> _launchKage(
    String executablePath, Map<String, dynamic> settings) async {
  try {
    await Logger.instance.writeLog('Launching Kage from: $executablePath');

    final kageModelPath = settings['kage_model_path'] ?? '';
    final kageApiUrl = settings['kage_api_url'] ?? 'ws://localhost:23333';

    // Launch Kage using ProcessManagerService
    // This ensures Kage will be terminated when the app exits
    await ProcessManagerService.instance
        .startProcess('kage', executablePath, []);

    // Wait for Kage to fully start (check periodically up to 10 seconds)
    bool kageStarted = false;
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(seconds: 1));
      if (await KageWebSocketService.isKageAccessible(kageApiUrl)) {
        kageStarted = true;
        await Logger.instance
            .writeLog('Kage started successfully after ${i + 1} seconds');
        break;
      }
    }

    if (!kageStarted) {
      await Logger.instance
          .writeLog('Kage did not start within timeout period');
      return;
    }

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
  } catch (e) {
    await Logger.instance.writeLog('Failed to launch Kage: $e');
  }
}
