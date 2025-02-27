import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:io';


import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:flutter_prism/flutter_prism.dart';


part 'katex.dart';

class MarkdownPreview extends StatelessWidget {
  final String content;

  const MarkdownPreview({
    super.key,
    this.content = '',
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownViewer(
      content,
      enableTaskList: true,
      syntaxExtensions: [TexSyntax()],
      elementBuilders: [
        TexBuilder(),
      ],
      imageBuilder: (uri, info) {
        try {
          if (uri.scheme == 'http' || uri.scheme == 'https') {
            return Image.network(uri.toString());
          } else {
            final file = File(uri.toFilePath());
            if (!file.existsSync()) {
              throw Exception("File not found");
            }
            return Image.file(File(uri.toFilePath()));
          }
        } catch (e) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.red,
              size: 50.0,
            ),
          );
        }
      },
      highlightBuilder: (text, language, infoString) {
        final prism = Prism(
          mouseCursor: SystemMouseCursors.text,
        );
        return prism.render(text, language ?? 'plain');
      },
    );
  }
}