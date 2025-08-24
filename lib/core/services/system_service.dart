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
import '../utils/platform_utils.dart';

class SystemService {
  static final SystemService _instance = SystemService._internal();
  static SystemService get instance => _instance;
  
  SystemService._internal();
  
  final List<String> _pids = [];
  
  void addPid(String pid) {
    _pids.add(pid);
  }
  
  Future<void> terminateAllProcesses() async {
    for (var pid in _pids) {
      if (pid.isNotEmpty) {
        await PlatformUtils.runCmd("taskkill /F /PID $pid");
      }
    }
  }
  
  Future<void> quit() async {
    await terminateAllProcesses();
    exit(0);
  }
}