import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';


import '../services/file_explorer.dart';

import 'file_tree.dart';


class FileExplorer extends StatelessWidget {
  final controller = FileExplorerService.to;
  FileExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: controller.onTapBackground,
        child: body,
      )
    );
  }

  Widget get body => Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          header,
                          explorerSpace, 
                          footer
                        ],
                      );

  Widget get header =>  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              openDir,
                              refreshFileTree,
                            ],
                          ),
                        );
  
  Widget get openDir => IconButton(
                          icon: Row(
                            children: [
                              const Icon(Icons.work),
                              Text(controller.rootDirName),
                            ],
                          ),
                          onPressed: controller.pickDir,
                        );

  Widget get refreshFileTree => IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: controller.loadFileTree,
                              tooltip: "Refresh file tree",
                            );

  Widget get explorerSpace => Expanded(
                                child: Obx(() => 
                                  controller.isLoading.value
                                  ? loading
                                  : GetBuilder<FileTreeController>(
                                      init: controller.fileTreeController, //here
                                      initState: (state) => controller.fileTreeController.onInit(),
                                      dispose: (state) => controller.fileTreeController.onClose(),
                                      builder: (_) => fileTree,
                                    )
                                ),
                              );
  
  Widget get footer 
  => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Colors.grey.withValues(alpha: 0.8),
          width: 0.5,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        createFolder,
        createFile,
        toggleAll,
      ],
    ),
  );
  
  Widget get createFolder => IconButton(
                              icon: const Icon(Icons.create_new_folder),
                              onPressed: onCreateFolder,
                            );
  
  Widget get createFile =>  IconButton(
                              icon: const Icon(Icons.note_add),
                              onPressed: onCreateFile,
                            );

  Widget get loading => Center(
                          child: CircularProgressIndicator(),
                        );

  Widget get toggleAll => Obx(()
  => IconButton(
    icon: controller.allIsExpanded.value
          ? const Icon(Icons.expand_less)
          : const Icon(Icons.expand_more),
    onPressed: controller.toggleAll,
  ));

  Widget get fileTree 
  => FileTree(
    key: ValueKey(controller.rootDir),
    controller: controller.fileTreeController,
    tree: controller.fileTree.children,
    rowBuilder: (node) =>
                  FileTree.row(
                    foregroundDecoration:
                    controller.fileTreeController.isSelected(node)
                    ? TreeRowDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                    )
                    : null,
                    onTap: () => controller.onTapExplorable(node),
                    onTapDown: (_) => controller.onTapDown(node),
                    onLongPress: () => showBottomSheet(node),
                  ),
    nodeBuilder: (context, node, toggleAnimationStyle) 
                  => switch(node.content) {
                      Directory _ => FileTree.folder(node.content.path, node.depth, node.isExpanded),
                      _      => FileTree.file(node.content.path, node.depth),
                    },
  );

  void showBottomSheet(ExplorableNode node)
  => Get.bottomSheet(
    _BottomSheet(
      node: node, 
      onDelete: onDelete, 
      onRename: onRename
    ),
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
  );

  void onCreateFolder()
  => createFSDialog(
    title: 'Create Folder',
    onSubmit: controller.createFolder,
    onValidate: controller.fileTreeController.validateCreate,
  );

  void onCreateFile()
  => createFSDialog(
    title: 'Create File',
    onSubmit: controller.createFile,
    onValidate: controller.fileTreeController.validateCreate,
  );

  void onDelete(ExplorableNode node) {
    deleteFSDialog(
      title: 'Delete',
      onDelete: () => controller.removeByNode(node),
    );
  }

  void onRename(ExplorableNode node) {
    createFSDialog(
      title: 'Rename',
      onSubmit: (newName) => controller.renameByNode(node, newName),
      onValidate: (newName) => controller.fileTreeController.validateRename(node.content.path, newName),
      initValue: basename(node.content.path),
    );
  }
}


typedef _BottomSheetCallback = void Function(ExplorableNode node);

class _BottomSheet extends StatelessWidget {
  final _BottomSheetCallback onDelete;
  final _BottomSheetCallback onRename;
  final ExplorableNode node;
  const _BottomSheet({
    required this.node,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        rename,
        delete,
      ],
    );
  }

  Widget get delete
  => button("Delete", onDelete);
  
  Widget get rename
  => button("Rename", onRename);
  
  Widget button(String name, _BottomSheetCallback callback)
  => ListTile(
        title: Text(name),
        onTap: () {
          Get.back();
          callback(node);
        },
      );
}


void createFSDialog({
  required String title,
  required Future<void> Function(String) onSubmit,
  required String? Function(String?) onValidate, 
  String       initValue = '',
}) {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController(text: initValue);

  void submit(String text) async {
    if (!formKey.currentState!.validate()) return;
    await onSubmit(text);
    Get.back();
  }

  var disponsed = false;
  Future<bool> onWillPop() async {
    if (disponsed) return true;
    disponsed = true;
    controller.dispose();
    return true;
  }
  Get.defaultDialog(
    title: title,
    content: Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        autofocus: true,
        controller: controller,
        validator: onValidate,
        onFieldSubmitted: submit,
        decoration: const InputDecoration(
          hintText: "use / as separator",
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => submit(controller.text),
        child: const Text("Confirm"),
      ),
      TextButton(
        onPressed: Get.back,
        child: const Text("Cancel"),
      ),
    ],
    onWillPop: onWillPop,
  );
}

void deleteFSDialog({
  required String title,
  required void Function() onDelete,
}) {
  Get.defaultDialog(
    title: title,
    titleStyle: const TextStyle(color: Colors.red),
    content: const Text("Are you sure you want to delete this file?"),
    actions: [
      TextButton(
        onPressed: () {
          onDelete(); 
          Get.back();
        },
        child: const Text("Confirm"),
      ),
      TextButton(
        onPressed: Get.back,
        child: const Text("Cancel"),
      ),
    ],
  );
}
