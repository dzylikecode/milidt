import 'dart:io';

import 'package:flutter/material.dart';


import '../services/file_explorer.dart';

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
        child: Center(
          child: preview,
      )
    );
  }

  Widget get preview 
  => switch(type) {
    FilePreviewType.image => Image.file(file),
    FilePreviewType.text => textFilePreview,
    FilePreviewType.markdown => Text(content),
    FilePreviewType.unknown => unknownedBinaryFile,
  };

  Widget get unknownedBinaryFile => const Text("Unknowned binary file");

  Widget get textFilePreview 
  => Text(content);
}


