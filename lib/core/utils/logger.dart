// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import '../config/constants.dart';
import '../config/settings_manager.dart';

class Logger {
  static final Logger _instance = Logger._internal();
  static Logger get instance => _instance;

  Logger._internal();

  final _logLock = Lock();
  bool _logFileInitialized = false;

  Future<void> _initLogging() async {
    if (!_logFileInitialized) {
      final settings = await SettingsManager.instance.readSettings();
      final bool enableLogging = settings['enable_logging'] ?? false;
      if (enableLogging) {
        final logFile =
            File(p.join(Directory.current.path, Constants.logFileName));
        if (await logFile.exists()) {
          try {
            await logFile.delete();
          } catch (e) {
            print('Failed to delete old log file: $e');
          }
        }
      }
      _logFileInitialized = true;
    }
  }

  Future<void> writeLog(String logContent) async {
    await _initLogging();
    final settings = await SettingsManager.instance.readSettings();
    final bool enableLogging = settings['enable_logging'] ?? false;

    if (!enableLogging) {
      return;
    }

    await _logLock.synchronized(() async {
      final logFile =
          File(p.join(Directory.current.path, Constants.logFileName));
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '$timestamp - $logContent\n';
      try {
        await logFile.writeAsString(logEntry,
            mode: FileMode.append, flush: true);
      } catch (e) {
        print('Failed to write to log file: $e');
      }
    });
  }
}
