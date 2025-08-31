// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import 'kage_websocket_service.dart';

class KageDownloadService {
  static const String GITHUB_API_URL =
      'https://api.github.com/repos/funnycups/kage/releases/latest';

  /// Get default installation directory
  static String getDefaultInstallDirectory() {
    final homeDir = Platform.isWindows
        ? Platform.environment['USERPROFILE']!
        : Platform.environment['HOME']!;
    return path.join(homeDir, '.petto', 'kage');
  }

  /// Get temporary download directory
  static String getTempDirectory() {
    if (Platform.isWindows) {
      return path.join(Platform.environment['TEMP']!, 'petto_download');
    } else {
      return '/tmp/petto_download';
    }
  }

  /// Check if Kage needs to be downloaded
  static Future<bool> shouldDownloadKage(Map<String, dynamic> settings) async {
    final petMode = settings['pet_mode'] ?? 'kage';
    final kageExecutable = settings['kage_executable'] ?? '';
    final kageApiUrl = settings['kage_api_url'] ?? 'ws://localhost:23333';

    await Logger.instance.writeLog('Checking if Kage download is needed...');
    await Logger.instance.writeLog('Pet mode: $petMode');
    await Logger.instance.writeLog('Kage executable: $kageExecutable');

    if (petMode != 'kage') {
      await Logger.instance.writeLog('Not in Kage mode, skip download check');
      return false;
    }

    if (kageExecutable.isNotEmpty) {
      final execFile = File(kageExecutable);
      if (await execFile.exists()) {
        await Logger.instance
            .writeLog('Kage executable exists at: $kageExecutable');
        return false;
      } else {
        await Logger.instance
            .writeLog('Kage executable not found at: $kageExecutable');
      }
    } else {
      await Logger.instance.writeLog('Kage executable path is empty');
    }

    final isAccessible =
        await KageWebSocketService.isKageAccessible(kageApiUrl);
    return !isAccessible;
  }

  /// Get latest release information from GitHub
  static Future<Map<String, dynamic>?> getLatestRelease() async {
    try {
      await Logger.instance
          .writeLog('Fetching latest Kage release from GitHub');
      final response = await http.get(
        Uri.parse(GITHUB_API_URL),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await Logger.instance.writeLog('Got release: ${data['tag_name']}');
        return data;
      } else {
        await Logger.instance
            .writeLog('Failed to get release: ${response.statusCode}');
      }
    } catch (e) {
      await Logger.instance.writeLog('Failed to get latest release: $e');
    }
    return null;
  }

  /// Get platform-specific file information
  static Map<String, String> getPlatformFileInfo() {
    if (Platform.isWindows) {
      return {'filename': 'Kage-win-x64.zip', 'executable': 'kage.exe'};
    } else if (Platform.isMacOS) {
      // Detect ARM or Intel
      final isARM = Platform.version.toLowerCase().contains('arm64');
      return {
        'filename': isARM ? 'Kage-mac-arm64.zip' : 'Kage-mac-x64.zip',
        'executable': 'Kage.app'
      };
    } else if (Platform.isLinux) {
      return {'filename': 'Kage-linux-x64.tar.gz', 'executable': 'kage'};
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Find download URL from release assets
  static String? findDownloadUrl(Map<String, dynamic> releaseInfo) {
    final fileInfo = getPlatformFileInfo();
    final assets = releaseInfo['assets'] as List<dynamic>?;

    if (assets == null) return null;

    for (var asset in assets) {
      if (asset['name'] == fileInfo['filename']) {
        return asset['browser_download_url'] as String?;
      }
    }
    return null;
  }

  static Future<String?> downloadFile({
    required String url,
    required String savePath,
    required Function(double) onProgress,
  }) async {
    HttpClient? httpClient;
    IOSink? sink;

    try {
      await Logger.instance.writeLog('Starting download from: $url');

      // Ensure temp directory exists
      final dir = Directory(path.dirname(savePath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      httpClient = HttpClient();

      // Set up proxy from system environment
      httpClient.findProxy = HttpClient.findProxyFromEnvironment;

      // Configure timeouts
      httpClient.connectionTimeout = Duration(seconds: 30);
      httpClient.idleTimeout = Duration(seconds: 30);

      // Enable auto decompression
      httpClient.autoUncompress = true;

      final uri = Uri.parse(url);

      // Log proxy information if using one
      // The proxy will be automatically used through findProxyFromEnvironment
      await Logger.instance.writeLog('Downloading with system proxy settings');

      final request = await httpClient.getUrl(uri);

      final response = await request.close();

      if (response.statusCode != 200) {
        if (response.statusCode >= 300 && response.statusCode < 400) {
          final location = response.headers.value('location');
          if (location != null) {
            await Logger.instance.writeLog('Redirecting to: $location');
            httpClient.close();
            return downloadFile(
              url: location,
              savePath: savePath,
              onProgress: onProgress,
            );
          }
        }
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      await Logger.instance.writeLog('Content length: $contentLength bytes');

      final file = File(savePath);
      sink = file.openWrite();

      int received = 0;
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          onProgress(received / contentLength);
        }
      }

      await sink.close();
      httpClient.close();

      await Logger.instance.writeLog('Download completed: $savePath');
      return savePath;
    } catch (e) {
      await Logger.instance.writeLog('Download error: $e');

      // Clean up resources
      try {
        await sink?.close();
      } catch (_) {}

      try {
        httpClient?.close();
      } catch (_) {}

      // Clean up partial file
      try {
        final file = File(savePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      return null;
    }
  }

  /// Extract downloaded archive
  static Future<bool> extractFile({
    required String archivePath,
    required String extractPath,
  }) async {
    try {
      await Logger.instance.writeLog('Extracting $archivePath to $extractPath');

      final file = File(archivePath);
      if (!await file.exists()) {
        await Logger.instance.writeLog('Archive file not found');
        return false;
      }

      // Ensure target directory exists
      final dir = Directory(extractPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (archivePath.endsWith('.zip')) {
        // Handle ZIP files
        final bytes = await file.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);

        for (final file in archive) {
          final filename = path.join(extractPath, file.name);
          if (file.isFile) {
            final outFile = File(filename);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);
          } else {
            await Directory(filename).create(recursive: true);
          }
        }
      } else if (archivePath.endsWith('.tar.gz')) {
        // Handle TAR.GZ files
        final bytes = await file.readAsBytes();
        final gzipBytes = GZipDecoder().decodeBytes(bytes);
        final archive = TarDecoder().decodeBytes(gzipBytes);

        for (final file in archive) {
          final filename = path.join(extractPath, file.name);
          if (file.isFile) {
            final outFile = File(filename);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);

            // Set executable permission on Linux
            if (Platform.isLinux && file.name.contains('kage')) {
              await Process.run('chmod', ['+x', filename]);
              await Logger.instance
                  .writeLog('Set executable permission: $filename');
            }
          } else {
            await Directory(filename).create(recursive: true);
          }
        }
      } else {
        await Logger.instance.writeLog('Unsupported archive format');
        return false;
      }

      await Logger.instance.writeLog('Extraction completed successfully');
      return true;
    } catch (e) {
      await Logger.instance.writeLog('Extract error: $e');
      return false;
    }
  }

  /// Get executable path in the installation directory
  static String getExecutablePath(String installDir) {
    final fileInfo = getPlatformFileInfo();
    final executableName = fileInfo['executable']!;

    if (Platform.isMacOS && executableName.endsWith('.app')) {
      // For macOS .app bundles, the actual executable is inside
      return path.join(installDir, executableName);
    } else {
      // For Windows and Linux, it's directly in the install dir
      return path.join(installDir, executableName);
    }
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = Directory(getTempDirectory());
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await Logger.instance.writeLog('Cleaned up temp directory');
      }
    } catch (e) {
      await Logger.instance.writeLog('Failed to cleanup temp files: $e');
    }
  }

  /// Verify if the installation was successful
  static Future<bool> verifyInstallation(String executablePath) async {
    try {
      final file = File(executablePath);
      if (Platform.isMacOS && executablePath.endsWith('.app')) {
        // For macOS app bundles, check if the directory exists
        final dir = Directory(executablePath);
        return await dir.exists();
      } else {
        // For regular executables, check if file exists
        return await file.exists();
      }
    } catch (e) {
      await Logger.instance.writeLog('Failed to verify installation: $e');
      return false;
    }
  }
}
