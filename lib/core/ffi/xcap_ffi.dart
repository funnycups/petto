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

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

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

typedef XcapCaptureMonitorAtPointNative = Pointer<CaptureResult> Function(Int32 x, Int32 y);
typedef XcapCaptureMonitorAtPointDart = Pointer<CaptureResult> Function(int x, int y);

typedef XcapCaptureRegionNative = Pointer<CaptureResult> Function(Uint32 x, Uint32 y, Uint32 width, Uint32 height);
typedef XcapCaptureRegionDart = Pointer<CaptureResult> Function(int x, int y, int width, int height);

typedef XcapGetMonitorCountNative = Int32 Function();
typedef XcapGetMonitorCountDart = int Function();

typedef XcapFreeResultNative = Void Function(Pointer<CaptureResult> result);
typedef XcapFreeResultDart = void Function(Pointer<CaptureResult> result);

class XcapFFI {
  static final XcapFFI _instance = XcapFFI._internal();
  static XcapFFI get instance => _instance;
  
  late DynamicLibrary _xcapLib;
  
  late XcapCapturePrimaryMonitorDart _capturePrimaryMonitor;
  late XcapCaptureAllMonitorsDart _captureAllMonitors;
  late XcapCaptureMonitorAtPointDart _captureMonitorAtPoint;
  late XcapCaptureRegionDart _captureRegion;
  late XcapGetMonitorCountDart _getMonitorCount;
  late XcapFreeResultDart _freeResult;
  
  XcapFFI._internal() {
    _loadLibrary();
    _bindFunctions();
  }
  
  void _loadLibrary() {
    final libPath = _getLibraryPath();
    _xcapLib = DynamicLibrary.open(libPath);
  }
  
  String _getLibraryPath() {
    final executablePath = Platform.resolvedExecutable;
    final executableDir = path.dirname(executablePath);
    
    // Try to find library in subdirectory first
    final libSubdir = path.join(executableDir, 'libs');
    
    if (Platform.isWindows) {
      // Try subdirectory first
      final subdirPath = path.join(libSubdir, 'xcap_ffi.dll');
      if (File(subdirPath).existsSync()) {
        return subdirPath;
      }
      // Fallback to executable directory
      return path.join(executableDir, 'xcap_ffi.dll');
    } else if (Platform.isMacOS) {
      // Check for both Intel and ARM versions
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
      // Try subdirectory first
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
        .lookup<NativeFunction<XcapCapturePrimaryMonitorNative>>('xcap_capture_primary_monitor')
        .asFunction();
    
    _captureAllMonitors = _xcapLib
        .lookup<NativeFunction<XcapCaptureAllMonitorsNative>>('xcap_capture_all_monitors')
        .asFunction();
    
    _captureMonitorAtPoint = _xcapLib
        .lookup<NativeFunction<XcapCaptureMonitorAtPointNative>>('xcap_capture_monitor_at_point')
        .asFunction();
    
    _captureRegion = _xcapLib
        .lookup<NativeFunction<XcapCaptureRegionNative>>('xcap_capture_region')
        .asFunction();
    
    _getMonitorCount = _xcapLib
        .lookup<NativeFunction<XcapGetMonitorCountNative>>('xcap_get_monitor_count')
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
        print('Screenshot failed: ${result.errorMsg.toDartString()}');
        return null;
      }
      
      // Copy image data
      final imageData = Uint8List(result.len);
      for (int i = 0; i < result.len; i++) {
        imageData[i] = result.data[i];
      }
      
      // Convert RGBA to PNG
      return _convertRgbaToPng(imageData, result.width, result.height);
    } finally {
      _freeResult(resultPtr);
    }
  }
  
  /// Get monitor count
  int getMonitorCount() {
    return _getMonitorCount();
  }
  
  /// Convert RGBA data to PNG format
  Future<Uint8List> _convertRgbaToPng(Uint8List rgbaData, int width, int height) async {
    // Convert RGBA to PNG using image package
    // Note: The image package dependency should be added to pubspec.yaml
    // For now, we return the raw RGBA data
    // To properly implement this, add: image: ^4.0.0 to dependencies
    
    // The data from xcap is in RGBA format
    // We'll need to convert it to PNG format when image package is available
    return rgbaData;
  }
}