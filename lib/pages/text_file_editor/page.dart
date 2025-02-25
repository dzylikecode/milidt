import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path/path.dart';

part 'controller.dart';
part 'binding.dart';

class TextFileEditorPage extends GetView<TextFileEditorPageController> {
  const TextFileEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: controller.onPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(controller.fileName),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: controller.saveFile,
            ),
          ],
        ),
        body: Center(
          child: Text("TextFileEditorPage"),
        ),
      ),
    );
  }
}