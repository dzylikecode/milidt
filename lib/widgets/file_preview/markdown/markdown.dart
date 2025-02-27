import 'package:flutter_markdown/flutter_markdown.dart' as render_md;
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'dart:io';


import 'code_block.dart';


part 'katex.dart';


class MarkdownPreview extends StatelessWidget {
  final String content;

  const MarkdownPreview({
    super.key,
    this.content = '',
  });

  @override
  Widget build(BuildContext context) {
    return render_md.Markdown(
      data: content,
      selectable: true,
      builders: {
        'latex': LatexElementBuilderFixed(),
        HighlightBuilder.tag: HighlightBuilder(),
      },
      imageBuilder: (uri, title, alt) {
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
      extensionSet: md.ExtensionSet(
        [LatexBlockSyntax(), ...md.ExtensionSet.gitHubWeb.blockSyntaxes],
        [LatexInlineSyntax(),  md.EmojiSyntax(), ...md.ExtensionSet.gitHubWeb.inlineSyntaxes],
      ),
      styleSheet: render_md.MarkdownStyleSheet(
          p: TextStyle(fontSize: 16),
          code: TextStyle(backgroundColor: Colors.grey[200]),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
    );
  }
}