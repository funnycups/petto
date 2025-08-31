// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../generated/l10n.dart';
import '../../core/services/kage_download_service.dart';

class KageDownloadDialog extends StatefulWidget {
  final Map<String, dynamic> releaseInfo;

  const KageDownloadDialog({
    Key? key,
    required this.releaseInfo,
  }) : super(key: key);

  @override
  State<KageDownloadDialog> createState() => _KageDownloadDialogState();
}

class _KageDownloadDialogState extends State<KageDownloadDialog> {
  String _installPath = KageDownloadService.getDefaultInstallDirectory();
  bool _isPathCustomized = false;
  bool _useGhProxy = false;

  Future<void> _selectInstallPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: S.current.selectInstallPath,
    );
    if (selectedDirectory != null) {
      setState(() {
        _installPath = path.join(selectedDirectory, 'kage');
        _isPathCustomized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = widget.releaseInfo['tag_name'] ?? 'unknown';
    final fileInfo = KageDownloadService.getPlatformFileInfo();
    final fileName = fileInfo['filename'] ?? '';

    return AlertDialog(
      title: Text(S.current.kageDownloadTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.current.kageNotFound),
            SizedBox(height: 16),
            // Version info
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  S.current.version(version),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            // File info
            Row(
              children: [
                Icon(Icons.file_download, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.downloadFile(fileName),
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),
            // Install path
            Text(
              S.current.installPath,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _installPath,
                          style: TextStyle(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_isPathCustomized)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              S.current.customPath,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: _selectInstallPath,
                    tooltip: S.current.changePath,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            // GhProxy option for China users
            CheckboxListTile(
              value: _useGhProxy,
              onChanged: (value) {
                setState(() {
                  _useGhProxy = value ?? false;
                });
              },
              title: Text(
                S.current.useGhProxy,
                style: TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                S.current.ghProxyHint,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 8),
            // Info text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, size: 14, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.downloadInfo,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop({
            'download': true,
            'installPath': _installPath,
            'useGhProxy': _useGhProxy,
          }),
          child: Text(S.current.download),
        ),
      ],
    );
  }
}
