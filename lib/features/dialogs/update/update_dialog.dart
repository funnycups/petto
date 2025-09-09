// SPDX-License-Identifier: GPL-3.0-or-later
//
// Petto: An intelligent desktop assistant.
// Copyright (C) 2025 FunnyCups (https://github.com/funnycups)

import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/common/markdown_viewer.dart';

class UpdateDialog extends StatelessWidget {
  final String latestVersion;
  final String releaseNotes;
  final VoidCallback onLater;
  final VoidCallback onUpdate;

  const UpdateDialog({
    super.key,
    required this.latestVersion,
    required this.releaseNotes,
    required this.onLater,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.updateAvailable),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.current.updateMessage(latestVersion)),
            if (releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Release Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 240),
                child: MarkdownViewer(text: releaseNotes),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onLater();
            Navigator.of(context).pop();
          },
          child: Text(S.current.updateLater),
        ),
        ElevatedButton(
          onPressed: () {
            onUpdate();
            Navigator.of(context).pop();
          },
          child: Text(S.current.updateNow),
        ),
      ],
    );
  }
}
