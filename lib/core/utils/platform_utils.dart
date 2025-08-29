// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart';
import 'package:window_manager/window_manager.dart';

class PlatformUtils {
  static String decode(String str) {
    return utf8.decode(base64.decode(str.replaceAll(RegExp(r'\s+'), '')));
  }

  static Future<String> runCmd(String command) async {
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
      // Log error but return empty string
      return '';
    }
  }

  static Future<String> loadAsset(String path) async {
    // Normalize path separators to forward slashes for cross-platform compatibility
    final normalizedPath = path.replaceAll('\\', '/');

    // Get the correct assets directory based on platform
    final String assetsPath;
    if (Platform.isWindows || Platform.isLinux) {
      // On Windows and Linux, assets are in data/flutter_assets relative to executable
      final executableDir = p.dirname(Platform.resolvedExecutable);
      assetsPath = p.join(executableDir, 'data', 'flutter_assets');
    } else if (Platform.isMacOS) {
      // On macOS, assets are inside the app bundle
      final executableDir = p.dirname(Platform.resolvedExecutable);
      // The executable is at: App.app/Contents/MacOS/App
      // Assets are at: App.app/Contents/Resources/flutter_assets
      final bundleDir =
          p.dirname(p.dirname(executableDir)); // Go up to Contents
      assetsPath = p.join(bundleDir, 'Resources', 'flutter_assets');
    } else {
      // Fallback to current directory approach
      assetsPath = p.join(Directory.current.path, 'data', 'flutter_assets');
    }

    final String filePath = p.join(assetsPath, normalizedPath);
    final File file = File(filePath);

    if (await file.exists()) {
      return filePath;
    } else {
      final Directory parentDir = file.parent;
      if (!(await parentDir.exists())) {
        await parentDir.create(recursive: true);
      }
      try {
        ByteData data = await rootBundle.load(normalizedPath);
        await file.writeAsBytes(
          data.buffer.asUint8List(),
          flush: true,
        );
      } finally {}
      return filePath;
    }
  }

  static Future<void> hideWindow() async {
    await windowManager.hide();
  }

  static Future<String?> getWindow(String infoGetter, String cmd) async {
    return decode(await runCmd(cmd));
  }
}
