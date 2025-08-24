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

import 'dart:typed_data';
import '../ffi/xcap_ffi.dart';
import '../utils/logger.dart';

class ScreenshotService {
  static final ScreenshotService _instance = ScreenshotService._internal();
  static ScreenshotService get instance => _instance;
  
  ScreenshotService._internal();
  
  /// Take a fullscreen screenshot and return PNG data
  Future<Uint8List?> takeScreenshot() async {
    try {
      await Logger.instance.writeLog('Taking screenshot using xcap_ffi');
      
      final screenshotData = await XcapFFI.instance.capturePrimaryMonitor();
      
      if (screenshotData != null) {
        await Logger.instance.writeLog('Screenshot captured successfully, size: ${screenshotData.length} bytes');
      } else {
        await Logger.instance.writeLog('Screenshot capture failed');
      }
      
      return screenshotData;
    } catch (e) {
      await Logger.instance.writeLog('Error taking screenshot: $e');
      return null;
    }
  }
  
  /// Get the number of monitors
  int getMonitorCount() {
    try {
      return XcapFFI.instance.getMonitorCount();
    } catch (e) {
      Logger.instance.writeLog('Error getting monitor count: $e');
      return 0;
    }
  }
}