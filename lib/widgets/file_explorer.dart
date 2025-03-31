import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                                      builder: (_) => fileTree,
                                    )
                                ),
                              );
  
  Widget get footer =>  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            createFolder,
                            createFile,
                          ],
                        );
  
  Widget get createFolder => IconButton(
                              icon: const Icon(Icons.create_new_folder),
                              onPressed: controller.createFolderPrompt,
                            );
  
  Widget get createFile =>  IconButton(
                              icon: const Icon(Icons.note_add),
                              onPressed: controller.createFilePrompt,
                            );

  Widget get loading => Center(
                          child: CircularProgressIndicator(),
                        );

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
                    onLongPress: () => controller.onLongPressExplorable(node),
                  ),
    nodeBuilder: (context, node, toggleAnimationStyle) 
                  => switch(node.content) {
                      Directory _ => FileTree.folder(node.content.path, node.depth, node.isExpanded),
                      _      => FileTree.file(node.content.path, node.depth),
                    },
  );
  
}
