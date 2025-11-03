// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/config/settings_manager.dart';
import '../../core/utils/logger.dart';
import '../dialogs/dialogs.dart';

class UpdateChecker {
  static const String githubApiUrl =
      'https://api.github.com/repos/funnycups/petto/releases/latest';
  static const String releaseUrl =
      'https://github.com/funnycups/petto/releases/latest';

  /// Asynchronously check for updates
  static Future<void> checkForUpdateInBackground(BuildContext context) async {
    try {
      final settings = await SettingsManager.instance.readSettings();
      final bool checkUpdate = settings['check_update'] ?? true;

      if (!checkUpdate) {
        await Logger.instance.writeLog('Update check is disabled in settings');
        return;
      }

      await Logger.instance.writeLog('Starting update check...');

      // Get current version info
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      // Retry mechanism for network requests
      http.Response? response;
      int retryCount = 0;
      const maxRetries = 2;

      while (response == null && retryCount < maxRetries) {
        try {
          response = await http.get(
            Uri.parse(githubApiUrl),
            headers: {
              'Accept': 'application/vnd.github.v3+json',
            },
          ).timeout(const Duration(seconds: 30));
        } catch (e) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Logger.instance.writeLog(
                'Update check failed, retrying... (attempt $retryCount/$maxRetries)');
            await Future.delayed(const Duration(seconds: 2));
          } else {
            throw e;
          }
        }
      }

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tagName = data['tag_name'] ?? '';

        if (tagName.isNotEmpty) {
          // Handle version tags that start with 'v'
          final latestVersion =
              tagName.startsWith('v') ? tagName.substring(1) : tagName;
          await Logger.instance.writeLog(
              'Latest version: $latestVersion, Current version: $currentVersion');

          final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

          if (hasUpdate) {
            await Logger.instance.writeLog('Update available: $latestVersion');

            // Ensure window is visible
            bool isVisible = await windowManager.isVisible();
            if (!isVisible) {
              await windowManager.show();
              await windowManager.focus();
            }

            if (context.mounted) {
              await _showUpdateDialog(
                context,
                latestVersion,
                data['body'] ?? '',
              );
            }
          } else {
            await Logger.instance.writeLog('Already on latest version');
          }
        }
      } else {
        await Logger.instance.writeLog(
            'Failed to check update, status code: ${response?.statusCode}');
      }
    } catch (e) {
      await Logger.instance.writeLog('Error checking for updates: $e');
    }
  }

  /// Compare version numbers
  static int _compareVersions(String version1, String version2) {
    final parts1 =
        version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 =
        version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Ensure both versions have the same number of parts
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }

    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] > parts2[i]) {
        return 1;
      } else if (parts1[i] < parts2[i]) {
        return -1;
      }
    }

    return 0;
  }

  /// Show update dialog
  static Future<void> _showUpdateDialog(
      BuildContext context, String latestVersion, String releaseNotes) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(
        latestVersion: latestVersion,
        releaseNotes: releaseNotes,
        onLater: () {},
        onUpdate: () async {
          await launchUrl(Uri.parse(releaseUrl));
        },
      ),
    );
  }
}
