// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../utils/logger.dart';

// FFI bindings for xcap_ffi

// C struct definition
final class CaptureResult extends Struct {
  @Bool()
  external bool success;

  external Pointer<Uint8> data;

  @Size()
  external int len;

  @Uint32()
  external int width;

  @Uint32()
  external int height;

  external Pointer<Utf8> errorMsg;
}

// Function signatures
typedef XcapCapturePrimaryMonitorNative = Pointer<CaptureResult> Function();
typedef XcapCapturePrimaryMonitorDart = Pointer<CaptureResult> Function();

typedef XcapCaptureAllMonitorsNative = Pointer<CaptureResult> Function();
typedef XcapCaptureAllMonitorsDart = Pointer<CaptureResult> Function();

typedef XcapCaptureMonitorAtPointNative = Pointer<CaptureResult> Function(
    Int32 x, Int32 y);
typedef XcapCaptureMonitorAtPointDart = Pointer<CaptureResult> Function(
    int x, int y);

typedef XcapCaptureRegionNative = Pointer<CaptureResult> Function(
    Uint32 x, Uint32 y, Uint32 width, Uint32 height);
typedef XcapCaptureRegionDart = Pointer<CaptureResult> Function(
    int x, int y, int width, int height);

typedef XcapGetMonitorCountNative = Int32 Function();
typedef XcapGetMonitorCountDart = int Function();

typedef XcapFreeResultNative = Void Function(Pointer<CaptureResult> result);
typedef XcapFreeResultDart = void Function(Pointer<CaptureResult> result);

class XcapFFI {
  static final XcapFFI _instance = XcapFFI._internal();
  static XcapFFI get instance => _instance;

  late DynamicLibrary _xcapLib;

  late XcapCapturePrimaryMonitorDart _capturePrimaryMonitor;
  late XcapGetMonitorCountDart _getMonitorCount;
  late XcapFreeResultDart _freeResult;

  XcapFFI._internal() {
    _loadLibrary();
    _bindFunctions();
  }

  void _loadLibrary() {
    final libPath = _getLibraryPath();
    try {
      _xcapLib = DynamicLibrary.open(libPath);
      Logger.instance.writeLog('xcap_ffi loaded from: ' + libPath);
    } catch (e) {
      Logger.instance.writeLog(
          'Failed to open xcap_ffi at ' + libPath + ': ' + e.toString());
      rethrow;
    }
  }

  String _getLibraryPath() {
    final executablePath = Platform.resolvedExecutable;
    final executableDir = path.dirname(executablePath);

    // 1) Prefer Flutter Native Assets location (Flutter >=3.22)
    // During run/build, Flutter copies native assets to build/native_assets/<platform>/
    // and the runner install step copies them next to the executable.
    final nativeAssetsDir =
        path.join(path.dirname(path.dirname(executableDir)), 'native_assets');
    final nativeAssetsWindows = path.join(nativeAssetsDir, 'windows');
    final nativeAssetsLinux = path.join(nativeAssetsDir, 'linux');
    final nativeAssetsMacos = path.join(nativeAssetsDir, 'macos');

    // Try to find library in subdirectory first (legacy)
    final libSubdir = path.join(executableDir, 'libs');

    if (Platform.isWindows) {
      // Prefer native assets
      final naPath = path.join(nativeAssetsWindows, 'xcap_ffi.dll');
      if (File(naPath).existsSync()) {
        return naPath;
      }
      // Try subdirectory first
      final subdirPath = path.join(libSubdir, 'xcap_ffi.dll');
      if (File(subdirPath).existsSync()) {
        return subdirPath;
      }
      // Fallback to executable directory
      return path.join(executableDir, 'xcap_ffi.dll');
    } else if (Platform.isMacOS) {
      // Prefer native assets
      final naPath = path.join(nativeAssetsMacos, 'libxcap_ffi.dylib');
      if (File(naPath).existsSync()) {
        return naPath;
      }
      // Check for both Intel and ARM versions (legacy)
      final armSubdirPath = path.join(libSubdir, 'libxcap_ffi_arm64.dylib');
      final intelSubdirPath = path.join(libSubdir, 'libxcap_ffi.dylib');
      final armPath = path.join(executableDir, 'libxcap_ffi_arm64.dylib');
      final intelPath = path.join(executableDir, 'libxcap_ffi.dylib');

      // Try subdirectory first
      if (Platform.version.contains('arm64')) {
        if (File(armSubdirPath).existsSync()) return armSubdirPath;
        if (File(armPath).existsSync()) return armPath;
      }
      if (File(intelSubdirPath).existsSync()) return intelSubdirPath;
      return intelPath;
    } else if (Platform.isLinux) {
      // Prefer native assets
      final naPath = path.join(nativeAssetsLinux, 'libxcap_ffi.so');
      if (File(naPath).existsSync()) {
        return naPath;
      }
      // Try subdirectory first (legacy)
      final subdirPath = path.join(libSubdir, 'libxcap_ffi.so');
      if (File(subdirPath).existsSync()) {
        return subdirPath;
      }
      // Fallback to executable directory
      return path.join(executableDir, 'libxcap_ffi.so');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  void _bindFunctions() {
    _capturePrimaryMonitor = _xcapLib
        .lookup<NativeFunction<XcapCapturePrimaryMonitorNative>>(
            'xcap_capture_primary_monitor')
        .asFunction();

    _getMonitorCount = _xcapLib
        .lookup<NativeFunction<XcapGetMonitorCountNative>>(
            'xcap_get_monitor_count')
        .asFunction();

    _freeResult = _xcapLib
        .lookup<NativeFunction<XcapFreeResultNative>>('xcap_free_result')
        .asFunction();
  }

  /// Capture primary monitor and return as PNG bytes
  Future<Uint8List?> capturePrimaryMonitor() async {
    final resultPtr = _capturePrimaryMonitor();
    if (resultPtr.address == 0) return null;

    try {
      final result = resultPtr.ref;
      if (!result.success) {
        final msg = result.errorMsg.address != 0
            ? result.errorMsg.toDartString()
            : 'unknown error';
        await Logger.instance.writeLog('Screenshot failed: ' + msg);
        return null;
      }

      // Copy image data
      final imageData = Uint8List(result.len);
      for (int i = 0; i < result.len; i++) {
        imageData[i] = result.data[i];
      }

      // Convert RGBA to PNG
      final png =
          await _convertRgbaToPng(imageData, result.width, result.height);

      return png;
    } finally {
      _freeResult(resultPtr);
    }
  }

  /// Get monitor count
  int getMonitorCount() {
    return _getMonitorCount();
  }

  /// Convert RGBA data to PNG format
  Future<Uint8List> _convertRgbaToPng(
      Uint8List rgbaData, int width, int height) async {
    try {
      final image = img.Image(width: width, height: height);
      final bytesPerPixel = 4;
      if (rgbaData.length != width * height * bytesPerPixel) {
        await Logger.instance.writeLog(
            'Unexpected RGBA length: ${rgbaData.length}, width=$width, height=$height');
      }

      int idx = 0;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final r = rgbaData[idx++];
          final g = rgbaData[idx++];
          final b = rgbaData[idx++];
          final a = rgbaData[idx++];
          image.setPixelRgba(x, y, r, g, b, a);
        }
      }

      final pngBytes = Uint8List.fromList(img.encodePng(image));
      return pngBytes;
    } catch (e) {
      await Logger.instance.writeLog('PNG encode failed: ' + e.toString());
      return rgbaData;
    }
  }
}
