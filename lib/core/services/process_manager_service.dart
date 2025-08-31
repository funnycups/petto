// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:io';
import '../utils/logger.dart';

/// Service for managing background processes
class ProcessManagerService {
  static final ProcessManagerService _instance =
      ProcessManagerService._internal();
  static ProcessManagerService get instance => _instance;

  ProcessManagerService._internal();

  // Map to store running processes
  final Map<String, Process> _processes = {};

  /// Start a process and track it
  /// The process will be automatically terminated when the app exits
  Future<void> startProcess(
      String key, String executable, List<String> arguments) async {
    try {
      // Kill existing process if any
      await killProcess(key);

      await Logger.instance.writeLog(
          'Starting process $key: $executable ${arguments.join(' ')}');

      // Start the process
      final process = await Process.start(
        executable,
        arguments,
        mode: ProcessStartMode.detached,
        runInShell: Platform.isWindows,
      );

      _processes[key] = process;

      // Log process output
      process.stdout.listen((data) {
        Logger.instance.writeLog('[$key stdout] ${String.fromCharCodes(data)}');
      });

      process.stderr.listen((data) {
        Logger.instance.writeLog('[$key stderr] ${String.fromCharCodes(data)}');
      });

      await Logger.instance
          .writeLog('Process $key started with PID: ${process.pid}');
    } catch (e) {
      await Logger.instance.writeLog('Failed to start process $key: $e');
      throw e;
    }
  }

  /// Kill a tracked process
  Future<void> killProcess(String key) async {
    if (_processes.containsKey(key)) {
      final process = _processes[key]!;
      try {
        if (Platform.isWindows) {
          // Use taskkill on Windows
          await Process.run('taskkill', ['/F', '/PID', process.pid.toString()]);
        } else {
          process.kill();
        }
        _processes.remove(key);
        await Logger.instance.writeLog('Process $key killed');
      } catch (e) {
        await Logger.instance.writeLog('Failed to kill process $key: $e');
      }
    }
  }

  /// Kill all tracked processes
  Future<void> killAllProcesses() async {
    final keys = _processes.keys.toList();
    for (final key in keys) {
      await killProcess(key);
    }
  }

  /// Check if a process is running
  bool isProcessRunning(String key) {
    return _processes.containsKey(key);
  }
}
