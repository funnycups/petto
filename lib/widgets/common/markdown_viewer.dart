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

import 'package:flutter/material.dart';

/// Simple Markdown viewer widget
class MarkdownViewer extends StatelessWidget {
  final String text;
  
  const MarkdownViewer({Key? key, required this.text}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];
    
    for (var line in lines) {
      line = line.trim();
      
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      // Handle headings
      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            line.substring(4),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            line.substring(3),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            line.substring(2),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ));
      }
      // Handle list items
      else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: _parseInlineMarkdown(line.substring(2)),
              ),
            ],
          ),
        ));
      }
      // Regular text
      else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _parseInlineMarkdown(line),
        ));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  /// Parse inline Markdown (bold, italic, code)
  Widget _parseInlineMarkdown(String text) {
    final List<TextSpan> spans = [];
    final RegExp pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)');
    
    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // Add regular text
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      
      final matchText = match.group(0)!;
      
      // Bold
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      }
      // Italic
      else if (matchText.startsWith('*') && matchText.endsWith('*')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }
      // Code
      else if (matchText.startsWith('`') && matchText.endsWith('`')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Color(0xFFE0E0E0),
          ),
        ));
      }
      
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: spans,
      ),
    );
  }
}