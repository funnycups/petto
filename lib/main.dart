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

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'server.dart';
import 'core/config/constants.dart';
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
