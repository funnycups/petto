// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../generated/l10n.dart';
import '../../../core/services/kage_download_service.dart';
import '../../../core/utils/logger.dart';

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

      final tempDir = Directory(KageDownloadService.getTempDirectory());
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      final fileInfo = KageDownloadService.getPlatformFileInfo();
      final tempFile = path.join(tempDir.path, fileInfo['filename']!);

      setState(() {
        _status = S.current.downloading;
      });

      final downloadedFile = await KageDownloadService.downloadFile(
        url: widget.downloadUrl,
        savePath: tempFile,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress * 0.9;
            });
          }
        },
      );

      if (downloadedFile == null) {
        throw Exception(S.current.downloadFailed);
      }

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

      try {
        await File(downloadedFile).delete();
        await Logger.instance.writeLog('Deleted temp file: $downloadedFile');
      } catch (e) {
        await Logger.instance.writeLog('Failed to cleanup temp file: $e');
      }

      setState(() {
        _progress = 1.0;
        _status = S.current.installComplete;
      });
      await Future.delayed(const Duration(seconds: 1));
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
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(S.current.downloadingKage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_hasError) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (_isExtracting)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _progress,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_progress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
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
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    S.current.doNotClose,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ] else ...[
              Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.current.downloadError,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 13),
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
