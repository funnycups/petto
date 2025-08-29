// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

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
        await Logger.instance.writeLog(
            'Screenshot captured successfully, size: ${screenshotData.length} bytes');
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
