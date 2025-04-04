import 'package:flutter_markdown/flutter_markdown.dart' as render_md;
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:path/path.dart';
import 'dart:io';


import '../../image_view.dart';

import 'code_block.dart';


part 'katex.dart';


class MarkdownPreview extends StatelessWidget {
  final String content;
  final String dir;

  const MarkdownPreview({
    super.key,
    this.content = '',
    this.dir = '',
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
        if (uri.scheme == 'http' || uri.scheme == 'https') {
          return ImageView.network(uri.toString());
        } else {
          var path = uri.toFilePath();
          if (path[0] != '/') {
            path = join(dir, path);
          }
          return ImageView.file(File(path));
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