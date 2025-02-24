import 'dart:io';

import 'package:flutter/material.dart';

class FilePreivew extends StatelessWidget {
  final File file;
  const FilePreivew({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: preview,
    );
  }

  Widget get preview => recognizedByExt(file) 
                        ?? recognizedByContent(file)
                        ?? unknownedBinaryFile;

  Widget get unknownedBinaryFile => const Text("Unknowned binary file");
}


Widget? recognizedByExt(File file) {
  final ext = file.path.split('.').last;

  final imageExt = ['jpg', 'jpeg', 'png', 'gif'];

  if (imageExt.contains(ext)) {
    return Image.file(file);
  } else {
    return null;
  }
}

Widget? recognizedByContent(File file) {
  final content = file.readAsStringSync();
  if (content.isEmpty && file.lengthSync() > 0) {
    return null;
  }
}
