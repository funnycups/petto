// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:io';
import './process_manager_service.dart';

class SystemService {
  static final SystemService _instance = SystemService._internal();
  static SystemService get instance => _instance;

  SystemService._internal();

  // DEPRECATED: Direct PID management is no longer supported
  // Use ProcessManagerService instead
  final List<String> _pids = [];

  @Deprecated('Use ProcessManagerService.startProcess instead')
  void addPid(String pid) {
    _pids.add(pid);
  }

  Future<void> terminateAllProcesses() async {
    // Kill all processes managed by ProcessManagerService
    await ProcessManagerService.instance.killAllProcesses();

    // Legacy PID cleanup - this will be removed in future versions
    // Currently kept for backward compatibility
    /*
    for (var pid in _pids) {
      if (pid.isNotEmpty) {
        await PlatformUtils.runCmd("taskkill /F /PID $pid");
      }
    }
    */
  }

  Future<void> quit() async {
    await terminateAllProcesses();
    exit(0);
  }
}
