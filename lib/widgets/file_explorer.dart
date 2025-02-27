import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:path/path.dart';

import '../services/file_explorer.dart';

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
                                  : Obx(() => fileTree)
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
  =>  TreeView.simpleTyped<FileSystemEntity, ExplorableNode>(
        // 用这个 key 来解决切换目录时，会报错的问题
        key: ValueKey(controller.rootDir),
        showRootNode: false,
        expansionBehavior: ExpansionBehavior.none,
        // !!! width + offset.x = 24, width 过小会导致有双竖线
        indentation: const Indentation(
          width: 12,
          style: IndentStyle.scopingLine,
          offset: Offset(12, 0),
        ),
        onItemTap: controller.onTapExplorable,
        tree: controller.fileTree,
        expansionIndicatorBuilder: (context, node) => expansionIndicator(node),
        builder: (context, node) => explorerable(node),
        // [ ] BUG: 没办法记住之前的展开状态
        // onTreeReady 会导致换project会出问题
        // onTreeReady: (controller) {
        //   void forceExpaned(ExplorableNode node) {
        //     if (node.isExpanded && !node.isRoot) {
        //       controller.expandNode(node);
        //     }
        //     for (final child in node.childrenAsList) {
        //       forceExpaned(child as ExplorableNode);
        //     }
        //   }
        //   forceExpaned(controller.tree);
        // },
      );
  
  Widget explorerable(ExplorableNode node) 
  =>  GestureDetector(
        onLongPress: () => controller.onLongPressExplorable(node),
        child: Obx(() => explorerUI(node)),
      );


  Widget explorerUI(ExplorableNode node)
  => Container(
        color:  controller.isSelected(node)
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            key: ValueKey(node.entity.path),
            children: [
              const SizedBox(width: 15), 
              nodeIcon(node), 
              // 参考 obsidian 的做法，过长就折叠
              Flexible(
                child: Text(
                  node.name,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      );

  ExpansionIndicator expansionIndicator(ITreeNode<dynamic> node)
  => ChevronIndicator.rightDown(
      tree: node,
      alignment: Alignment.centerLeft,
      color: Colors.grey[700],
    );
}


Icon nodeIcon(ExplorableNode node)
=>  switch(node.entity) {
  Directory _ => specailFolderIcon(node.name, node.isExpanded),
  File _      => specailFileIcon(node.name),
  Link _      => const Icon(Icons.link),
  _           => const Icon(Icons.help_outline),
};

Icon specailFolderIcon(String name, bool isExpanded) {
  if (isExpanded) {
    return const Icon(Icons.folder_open);
  }
  return const Icon(Icons.folder);
}

Icon specailFileIcon(String name) {
  const imageExt = [".jpg", ".jpeg", ".png"];
  const videoExt = [".mp4", ".avi", ".mov"];
  if (imageExt.contains(extension(name))) return const Icon(Icons.image);
  if (videoExt.contains(extension(name))) return const Icon(Icons.video_library);
  return const Icon(Icons.insert_drive_file);
}