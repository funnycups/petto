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
  
  static Future<void> hideWindow() async {
    await windowManager.hide();
  }
  
  static Future<String?> getWindow(String infoGetter, String cmd) async {
    return decode(await runCmd(cmd));
  }
}