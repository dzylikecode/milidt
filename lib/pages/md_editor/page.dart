import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path/path.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';



part 'controller.dart';
part 'binding.dart';

class MdEditorPage extends GetView<MdEditorPageController> {
  const MdEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: controller.onPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(controller.fileName),
        ),
        body: Obx(() => 
          controller.savingWhenGoBack.value
          ? savingWhenGoBack
          : fileEditor
        ),
      ),
    );
  }

  Widget get savingWhenGoBack 
  => Center(child: const CircularProgressIndicator(),);

  Widget get fileEditor 
  => SafeArea(
    maintainBottomViewPadding: true,
    child: FooterLayout(
      footer: toolbar,
      child: inputField,
    ),
  );

  Widget get inputField
  => GestureDetector(
    onTap: controller.focusNode.requestFocus,
    child: Column(
      children: [
        Expanded(child: textField),
      ],
    ),
  );

  Widget get textField
  => TextField(
    controller: controller.contentController,
    undoController: controller.undoController,
    focusNode: controller.focusNode,
    onChanged: controller.onContentChanged,
    maxLines: null,
    decoration: InputDecoration(
      border: InputBorder.none,
    ),
  );

  Widget get toolbar
  => ValueListenableBuilder<UndoHistoryValue>(
      valueListenable: controller.undoController,
      builder: (BuildContext context, UndoHistoryValue value, Widget? child) {
        return Row(
          children: <Widget>[
            undo(value.canUndo),
            redo(value.canRedo),
            picture,
            camera,
          ],
        );
      },
    );
  
  Widget undo(bool can) => IconButton(
    icon: Icon(Icons.undo, color: can ? null : Colors.grey),
    onPressed: can ? controller.undoController.undo : null,
  );

  Widget redo(bool can) => IconButton(
    icon: Icon(Icons.redo, color: can ? null : Colors.grey),
    onPressed: can ? controller.undoController.redo : null,
  );

  Widget get picture => IconButton(
    icon: Icon(Icons.image),
    onPressed: controller.pickImageFromGallery,
  );

  Widget get camera => IconButton(
    icon: Icon(Icons.camera_alt),
    onPressed: controller.pickImageFromCamera,
  );
}