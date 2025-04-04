import 'dart:io';

import 'package:flutter/material.dart';

import '../services/file_explorer.dart';
import 'file_preview/markdown/markdown.dart';
import 'image_view.dart';

class FilePreivew extends StatelessWidget {
  final File file;
  final FilePreviewType type;
  final String content;
  final void Function()? onDoubleTap;
  const FilePreivew({
    super.key, 
    required this.file,
    required this.type,
    this.content = "",
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
        child: SafeArea(child: preview),
    );
  }

  Widget get preview 
  => switch(type) {
    FilePreviewType.image => image,
    FilePreviewType.text => textFilePreview,
    FilePreviewType.markdown => markdown,
    FilePreviewType.unknown => unknownedBinaryFile,
  };

  Widget get unknownedBinaryFile => const Text("Unknowned binary file");

  Widget get image => Center(child: ImageView.file(file));

  Widget get textContentPreview 
  => SelectableText(
      content,
      style: const TextStyle(fontSize: 16.0),
    );

  Widget get textEmptyPrompt => Text(
                                  "Empty file, double tap to edit",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16.0,
                                  ),
                                );

  Widget get textFilePreview 
  => Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: content.isEmpty
                  ? textEmptyPrompt
                  : textContentPreview,
            )
          ),
        )
      ],
    );
  
  Widget get markdown 
  => content.isEmpty
        ? TextFilePreviewContainer(
          child: textEmptyPrompt,
          )
        : MarkdownPreview(
          content: content,
          dir: file.parent.path,
        );

}

class TextFilePreviewContainer  extends StatelessWidget {
  final Widget child;
  const TextFilePreviewContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: child,
            )
          ),
        )
      ],
    );
  }
}
