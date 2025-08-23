import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'settings.dart';
import 'server.dart';
import 'ui.dart';
import 'helper.dart';
import 'weather.dart';
import 'model.dart';
import 'recognizer.dart';
// const String _settingsFile = 'settings.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For hot reload, unregisterAll needs to be called
  try {
    await hotKeyManager.unregisterAll();
  } catch (e) {
    print('Failed to unregister all hotkeys: $e');
  }
  int port = 4040;
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
  double windowWidth = 400;
  double windowHeight = 400;
  await WindowManager.instance.setSize(Size(windowWidth, windowHeight));
  await WindowManager.instance.center();
  await WindowManager.instance.setAlwaysOnTop(true);
  runApp(const MyApp());
}
