// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../generated/l10n.dart';
import '../../core/services/kage_download_service.dart';
import '../../core/utils/logger.dart';

class KageDownloadProgressDialog extends StatefulWidget {
  final String downloadUrl;
  final String installPath;
  final Function(String) onComplete;
  final VoidCallback onError;

  const KageDownloadProgressDialog({
    Key? key,
    required this.downloadUrl,
    required this.installPath,
    required this.onComplete,
    required this.onError,
  }) : super(key: key);

  @override
  State<KageDownloadProgressDialog> createState() =>
      _KageDownloadProgressDialogState();
}

class _KageDownloadProgressDialogState
    extends State<KageDownloadProgressDialog> {
  double _progress = 0.0;
  String _status = '';
  bool _isExtracting = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      setState(() {
        _status = S.current.preparingDownload;
      });

      // Create temp directory
      final tempDir = Directory(KageDownloadService.getTempDirectory());
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      // Get file info
      final fileInfo = KageDownloadService.getPlatformFileInfo();
      final tempFile = path.join(tempDir.path, fileInfo['filename']!);

      setState(() {
        _status = S.current.downloading;
      });

      // Download file
      final downloadedFile = await KageDownloadService.downloadFile(
        url: widget.downloadUrl,
        savePath: tempFile,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress * 0.9; // Download is 90% of total progress
            });
          }
        },
      );

      if (downloadedFile == null) {
        throw Exception(S.current.downloadFailed);
      }

      // Extract file
      setState(() {
        _status = S.current.extracting;
        _isExtracting = true;
        _progress = 0.9;
      });

      final success = await KageDownloadService.extractFile(
        archivePath: downloadedFile,
        extractPath: widget.installPath,
      );

      if (!success) {
        throw Exception(S.current.extractFailed);
      }

      // Verify installation
      final executablePath =
          KageDownloadService.getExecutablePath(widget.installPath);

      setState(() {
        _status = S.current.verifying;
        _progress = 0.95;
      });

      final isValid =
          await KageDownloadService.verifyInstallation(executablePath);
      if (!isValid) {
        throw Exception(S.current.verificationFailed);
      }

      // Clean up temp files
      try {
        await File(downloadedFile).delete();
        await Logger.instance.writeLog('Deleted temp file: $downloadedFile');
      } catch (e) {
        // Ignore cleanup errors
        await Logger.instance.writeLog('Failed to cleanup temp file: $e');
      }

      setState(() {
        _progress = 1.0;
        _status = S.current.installComplete;
      });

      // Delay before closing
      await Future.delayed(Duration(seconds: 1));

      if (mounted) {
        widget.onComplete(executablePath);
      }
    } catch (e) {
      await Logger.instance.writeLog('Download failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _handleRetry() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _progress = 0.0;
      _isExtracting = false;
    });
    _startDownload();
  }

  void _handleCancel() {
    widget.onError();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from closing
      child: AlertDialog(
        title: Text(S.current.downloadingKage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_hasError) ...[
              // Progress indicator
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      _status,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    if (_isExtracting)
                      CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _progress,
                            minHeight: 8,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${(_progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (_progress < 1.0)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    S.current.doNotClose,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ] else ...[
              // Error display
              Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    S.current.downloadError,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: _hasError
            ? [
                TextButton(
                  onPressed: _handleCancel,
                  child: Text(S.current.cancel),
                ),
                ElevatedButton(
                  onPressed: _handleRetry,
                  child: Text(S.current.retry),
                ),
              ]
            : _progress >= 1.0
                ? [
                    ElevatedButton(
                      onPressed: () {
                        // Close dialog - onComplete already called
                        Navigator.of(context).pop();
                      },
                      child: Text(S.current.done),
                    ),
                  ]
                : null,
      ),
    );
  }
}
