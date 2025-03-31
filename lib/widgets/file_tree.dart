import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart';

typedef ExplorableNode = TreeViewNode<FileSystemEntity>;

class FileTreeController extends GetxController {
  ExplorableNode? _selectedNode;
  set selected(ExplorableNode? node) {
    _selectedNode = node;
    update();
  }
  ExplorableNode? get selected => _selectedNode;

  bool isSelected(ExplorableNode node) {
    return _selectedNode == node;
  }
  void clearSelected() {
    selected = null;
  }

  final treeController = TreeViewController();
  ExplorableNode _rootNode = ExplorableNode(Directory(""));
  set rootNode(ExplorableNode node) {
    _rootNode = node;
    update();
  }
  ExplorableNode get rootNode => _rootNode;

  void toggleNode(ExplorableNode node) {
    treeController.toggleNode(node);
  }
  void add(ExplorableNode parent, ExplorableNode child) {
    parent.children.add(child);
    // 虽然可以二分插入，但是我懒
    parent.children.sort((a, b) => _orderFS(a.content, b.content));
    update();
  }
  void remove(ExplorableNode child) {
    if (child == selected) clearSelected();
    final parent = child.parent ?? rootNode;
    parent.children.remove(child);
    update();
  }
  void rename(ExplorableNode node, String newPath) {
    final (newFs, children) = switch(node.content) {
      Directory _ => (Directory(newPath), FileTree.buildChildren(Directory(newPath))),
      _ => (File(newPath), null),
    };
    final newNode = ExplorableNode(
      newFs,
      children: children,
      expanded: node.isExpanded
    );
    remove(node);
    add(node.parent ?? rootNode, newNode);
    update();
  }
}





class FileTree extends StatelessWidget {
  final verticalController = ScrollController();
  final horizontalController = ScrollController();
  final TreeViewController controller;

  final List<TreeViewNode<FileSystemEntity>> tree;
  final TreeRow Function(TreeViewNode<FileSystemEntity>)? rowBuilder;
  final Widget Function(
    BuildContext context,
    TreeViewNode<FileSystemEntity> node,
    AnimationStyle toggleAnimationStyle,
  )? nodeBuilder;

  FileTree({
    super.key,
    required this.tree,
    FileTreeController? controller,
    this.rowBuilder,
    this.nodeBuilder,
  }) : controller = controller?.treeController ?? TreeViewController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: verticalController,
      child: Scrollbar(
        controller: horizontalController,
        child: treeUI,
      )
    );
  }

  Widget get treeUI
  => TreeView<FileSystemEntity>(
      verticalDetails: ScrollableDetails.vertical(
        controller: verticalController,
      ),
      horizontalDetails: ScrollableDetails.horizontal(
        controller: horizontalController,
      ),
      controller: controller,
      tree: tree,
      treeRowBuilder: rowBuilder ?? TreeView.defaultTreeRowBuilder,
      treeNodeBuilder: nodeBuilder ?? TreeView.defaultTreeNodeBuilder,
      // 自己定义缩进
      indentation: TreeViewIndentationType.none,
  );

  static TreeRow row({
    SpanDecoration? foregroundDecoration,
    GestureTapDownCallback? onTapDown,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) => TreeRow(
      extent: FixedTreeRowExtent(30.0),
      foregroundDecoration: foregroundDecoration,
      recognizerFactories: _getTapRecognizer(
        onTap: onTap, 
        onTapDown: onTapDown,
        onLongPress: onLongPress,
      ),
    );

  
  static Widget file(
    String path,
    int? depth,
  ) {
    final name = basename(path);
    return Row(
      key: ValueKey(path),
      children: [
        _rowLine(depth ?? 0),
        Icon(_specailFileIcon(name), size: 20),
        const SizedBox(width: 3.0),
        Text(name),
      ],
    );
  }
  
  static Widget folder(
    String path,
    int? depth,
    bool isExpanded,
  ) {
    final name = basename(path);
    return Row(
      key: ValueKey(path),
      children: [
        _rowLine(depth ?? 0),
        Icon(_specailFolderIcon(name, isExpanded), size: 20),
        const SizedBox(width: 3.0),
        Text(name),
      ],
    );
  }

  static TreeViewNode<FileSystemEntity> buildTree(FileSystemEntity item)
  => _buildTreeUtil(item);

  static List<TreeViewNode<FileSystemEntity>> buildChildren(Directory dir) 
  => _getChildrenUtil(dir);
}

Map<Type, GestureRecognizerFactory> _getTapRecognizer({
  GestureTapDownCallback? onTapDown,
  GestureTapCallback? onTap,
  GestureLongPressCallback? onLongPress,
}) {
  return {
    TapGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => TapGestureRecognizer(),
      (t) {
        t.onTap = onTap;
        t.onTapDown = onTapDown;
      },
    ),
    LongPressGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
      () => LongPressGestureRecognizer(),
      (t) {
        t.onLongPress = onLongPress;
      },
    ),
  };
}

Widget _rowLine(int depth) {
  final BorderSide border = BorderSide(
    width: 0.8,
    color: Colors.grey.withValues(alpha: 0.2),
  );

  final children = <Widget>[];
  for (int i = 0; i < depth; i++) {
    children.add(SizedBox(
      height: 30.0,
      width: 10.0,
    ));
    children.add(
      DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: border),
        ),
        child: const SizedBox(height: 30.0, width: 5.0),
      ),
    );
  }
  return Row(
    children: children,
  );
}

IconData _specailFolderIcon(String name, bool isExpanded) {
  if (isExpanded) {
    return Icons.folder_open;
  }
  return Icons.folder;
}

IconData _specailFileIcon(String name) {
  const imageExt = [".jpg", ".jpeg", ".png"];
  const videoExt = [".mp4", ".avi", ".mov"];
  if (imageExt.contains(extension(name))) return Icons.image;
  if (videoExt.contains(extension(name))) return Icons.image;
  return Icons.insert_drive_file;
}




TreeViewNode<FileSystemEntity> _buildTreeUtil(FileSystemEntity item) 
=> switch(item) {
  Directory _ => TreeViewNode<FileSystemEntity>(
                    item,
                    children: _getChildrenUtil(item),
                  ),
  _           => TreeViewNode<FileSystemEntity>(
                    item,
                  ),
};

List<TreeViewNode<FileSystemEntity>> _getChildrenUtil(Directory dir) {
  final children = dir.listSync();
  children.sort(_orderFS);
  return children.map((e) => _buildTreeUtil(e)).toList();
}

int _orderFS(FileSystemEntity a, FileSystemEntity b) {
  if (a is Directory && b is File) return -1;
  if (a is File && b is Directory) return 1;
  return a.path.compareTo(b.path);
}