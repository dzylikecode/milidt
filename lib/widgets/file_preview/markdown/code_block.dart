import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:highlighting/languages/all.dart';
import 'package:flutter_highlighting/themes/atom-one-light.dart';
import 'package:flutter/services.dart';

// Refer to: https://github.com/flutter/flutter/issues/81755#issuecomment-807917577
class HighlightBuilder extends MarkdownElementBuilder {
  static const String tag = "code";
  final Map<String, TextStyle>? theme;
  final TextStyle? textStyle;
  late String language;
  late String code;

  HighlightBuilder([Map<String, TextStyle>? theme, this.textStyle])
  : theme = Map<String, TextStyle>.from(theme ?? atomOneLightTheme) {
    this.theme!['root'] = TextStyle(
      color: this.theme!['root']!.color,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    context, 
    element, 
    preferredStyle, 
    parentStyle
  ) {
    // 因为无法区分code 语法与 code block 语法，所以强制一定要有class属性
    if (element.attributes['class'] == null) return null;

    language = 'plaintext';
    final pattern = RegExp(r'^language-(.+)$');
    if (element.attributes['class'] != null &&
        pattern.hasMatch(element.attributes['class']!)) {
      language = pattern.firstMatch(element.attributes['class']!)?.group(1) ??
          'plaintext';
    }
    code = element.textContent.trim();
    return codeBlockFeild;
  }

  Widget get codeBlockFeild
  => SizedBox(
    width: double.infinity,
    child: copyableFeild,
  );

  Widget get copyableFeild
  => Stack(
    children: [
      scrollable,
      copyButton,
    ],
  );

  Widget get scrollable
  => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
    scrollDirection: Axis.horizontal,
    child: highlightView,
  );

  Widget get copyButton
  => Positioned(
    right: 0,
    top: 0,
    child: CopyButton(code),
  );

  Widget get highlightView
  => HighlightView(
    code,
    // Avoid null error if language doesn't exist
    languageId:
        builtinLanguages.containsKey(language) ? language : 'plaintext',
    theme: theme ?? {},
    padding: const EdgeInsets.all(8),
    // textStyle: textStyle ??
    //     const TextStyle(fontFamily: 'Monospace', fontSize: 16.0)
  );
}

class CopyButton extends StatefulWidget {
  const CopyButton(
    this.content, {
    this.iconColor,
    super.key,
  });

  final String content;
  final Color? iconColor;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
                width: 25,
                height: 25,
                child: Icon(
                  _copied ? Icons.check : Icons.copy_rounded,
                  size: 18,
                  color: widget.iconColor ?? const Color(0xff999999),
                ),
              ),
        onTap: () async {
          final content = widget.content;
          await Clipboard.setData(ClipboardData(text: content));
          setState(() {
            _copied = true;
            Future.delayed(const Duration(seconds: 1)).then((value) {
              if (mounted) {
                setState(() {
                  _copied = false;
                });
              }
            });
          });
        },
      ),
    );
  }
}
