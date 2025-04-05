import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart';

typedef ExplorableNode = TreeViewNode<FileSystemEntity>;

class FileTreeController extends GetxController {
  final verticalController = ScrollController();
  final horizontalController = ScrollController();

  double _verticalScrollOffset = 0.0;
  double _horizontalScrollOffset = 0.0;

  @override
  void onInit() {
    super.onInit();
    verticalController.addListener(_saveVerticalScrollOffset);
    horizontalController.addListener(_saveHorizontalScrollOffset);

    // restore scroll offset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verticalController.jumpTo(_verticalScrollOffset);
      horizontalController.jumpTo(_horizontalScrollOffset);
    });
  }
  void _saveVerticalScrollOffset() {
    _verticalScrollOffset = verticalController.offset;
  }
  void _saveHorizontalScrollOffset() {
    _horizontalScrollOffset = horizontalController.offset;
  }
  @override
  void onClose() {
    verticalController.removeListener(_saveVerticalScrollOffset);
    horizontalController.removeListener(_saveHorizontalScrollOffset);
    super.onClose();
  }

  ExplorableNode? _selectedNode;
  final activeFile = Rx<File?>(null);
  set selected(ExplorableNode? node) {
    _selectedNode = node;
    if (node != null && node.content is File) {
      activeFile.value = node.content as File;
    } else if (node == null) {
      activeFile.value = null;
    }
    update();
  }
  ExplorableNode? get selected => _selectedNode;
  void selectFile(File file) {
    selected = getNode(file.path);
  }

  bool isSelected(ExplorableNode node) {
    return _selectedNode == node;
  }
  void clearSelected() {
    selected = null;
  }
  ExplorableNode _rootNode = ExplorableNode(Directory(""));
  set rootNode(ExplorableNode node) {
    _rootNode = node;
    update();
  }
  ExplorableNode get rootNode => _rootNode;
  bool outOfRoot(String path) => !_isSubPath(rootNode.content.path, path);
  String sysPath(String path) {
    if (path[0] == '/') {
      final rel = path.substring(1);
      return join(rootNode.content.path, rel);
    }
    return join(contextFolder.content.path, path);
  }
  String wkPath(String path) {
    final rel = relative(path, from: rootNode.content.path);
    return rel;
  }

  ExplorableNode get contextFolder {
    final contextItem = selected ?? rootNode;
    return switch (contextItem.content) {
      Directory _ => contextItem,
      _           => contextItem.parent ?? rootNode, // 顶层的没有设置 parent
    };
  }

  Future<void> load(String path) async {
    final oldRoot = rootNode;
    rootNode = await _buildTreeUtil(Directory(path), oldRoot);
    // 重新设置选中状态
    if (selected != null) {
      selected = _getNodeByPath(rootNode, selected!.content.path);
    }
  }

  final treeController = TreeViewController();

  void toggleNode(ExplorableNode node) {
    treeController.toggleNode(node);
  }
  void expandAll() {
    treeController.expandAll();
  }
  void collapseAll() {
    treeController.collapseAll();
  }
  ExplorableNode? getNode(String path) => _getNodeByPath(rootNode, path);
  void expandToRoot(ExplorableNode node) => _expandToRoot(rootNode, node);

  String? validateCreate(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return "cannot be empty";
    }
    final path = sysPath(relativePath);
    if (outOfRoot(path)) {
      return "out of root dir";
    }
    // 安卓不能文件与文件夹同名
    if (Directory(path).existsSync() || File(path).existsSync()) {
      return "already exists";
    }
    return null;
  }

  String? validateRename(String oldPath, String? newName) {
    if (newName == null || newName.isEmpty) {
      return "cannot be empty";
    }
    if (newName.contains(Platform.pathSeparator)) {
      return "cannot contain path separator";
    }
    if (newName.split('').every((char) => char == '.')) {
      return "cannot be all dots";
    }
    final newPath = join(dirname(oldPath), newName,);
    if (newPath == oldPath) return null;
    // 安卓不能文件与文件夹同名
    if (Directory(newPath).existsSync() || File(newPath).existsSync()) {
      return "already exists";
    }
    return null;
  }

  Future<ExplorableNode> createDirOP(String dirPath) async {
    final existNode = getNode(dirPath);
    if (existNode != null) return existNode;
    final parent = dirname(dirPath);
    var parentNode = getNode(parent) ?? await createDirOP(parent);
    final dir = Directory(dirPath);
    if (!await dir.exists()) await dir.create(recursive: false);
    final newNode = ExplorableNode(dir);
    parentNode.children.add(newNode);
    // 虽然可以二分插入，但是我懒
    parentNode.children.sort((a, b) => _orderFS(a.content, b.content));
    return newNode;
  }

  Future<void> createDir(String dirPath) async {
    final dirNode = await createDirOP(dirPath);
    expandToRoot(dirNode); // 会改变 node，所以要重新获取
    selected = getNode(dirPath);
    update();
  }

  Future<void> createFileOP(String path) async {
    final existNode = getNode(path);
    if (existNode != null) return;
    final parent = dirname(path);
    var parentNode = getNode(parent) ?? await createDirOP(parent);
    final file = File(path);
    if (!await file.exists()) await file.create(recursive: false);
    final newNode = ExplorableNode(file);
    parentNode.children.add(newNode);
    parentNode.children.sort((a, b) => _orderFS(a.content, b.content));
  }

  Future<void> createFile(String path) async {
    await createFileOP(path);
    final node = getNode(path);
    expandToRoot(node!);
    selected = getNode(path);
    update();
  }

  Future<void> removeOP(ExplorableNode node) async {
    final fs = node.content;
    await fs.delete(recursive: true);
    final parent = node.parent ?? rootNode;
    parent.children.remove(node);
  }

  Future<void> remove(ExplorableNode node) async {
    await removeOP(node);
    if (node == selected) clearSelected();
    update();
  }

  Future<void> renameFileOP(ExplorableNode node, String newPath) async {
    final fs = node.content;
    final parent = node.parent ?? rootNode;
    await fs.rename(newPath);
    parent.children.remove(node);
    final newNode = ExplorableNode(File(newPath));
    parent.children.add(newNode);
    parent.children.sort((a, b) => _orderFS(a.content, b.content));
  }

  Future<void> renameFile(ExplorableNode node, String newPath) async {
    await renameFileOP(node, newPath);
    selected = getNode(newPath);
    update();
  }

  Future<void> renameFolderOP(ExplorableNode node, String newPath) async {
    final fs = node.content;
    final parent = node.parent ?? rootNode;
    await fs.rename(newPath);
    parent.children.remove(node);
    final newNode = _renameFileTree(node, fs.path, newPath);
    parent.children.add(newNode);
    parent.children.sort((a, b) => _orderFS(a.content, b.content));
  }

  Future<void> renameFolder(ExplorableNode node, String newPath) async {
    await renameFolderOP(node, newPath);
    selected = getNode(newPath);
    update();
  }

  Future<void> rename(ExplorableNode node, String newPath) async {
    if (node.content is Directory) {
      await renameFolder(node, newPath);
    } else {
      await renameFile(node, newPath);
    }
  }

  /// 目标文件存在的处理在外面实现
  Future<void> copyFileOp(String source, String target) async {
    if (source == target) return;
    final targetDirPath = dirname(target);
    if (!await Directory(targetDirPath).exists()) {
      await Directory(targetDirPath).create(recursive: true);
    }
    final sourceFile = File(source);
    final targetFile = File(target);
    if (await targetFile.exists()) return;
    await sourceFile.copy(target);
    await createFileOP(target);
  }

  Future<void> copyFile(String source, String target) async {
    await copyFileOp(source, target);
    final node = getNode(target);
    if (node != null) {
      expandToRoot(node);
      selected = node;
    }
    update();
  }
}



class FileTree extends StatelessWidget {

  final FileTreeController controller;

  final List<ExplorableNode> tree;
  final TreeRow Function(ExplorableNode)? rowBuilder;
  final Widget Function(
    BuildContext context,
    ExplorableNode node,
    AnimationStyle toggleAnimationStyle,
  )? nodeBuilder;

  const FileTree({
    super.key,
    required this.tree,
    required this.controller,
    this.rowBuilder,
    this.nodeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller.verticalController,
      child: Scrollbar(
        controller: controller.horizontalController,
        child: treeUI,
      )
    );
  }

  Widget get treeUI
  => TreeView<FileSystemEntity>(
      verticalDetails: ScrollableDetails.vertical(
        controller: controller.verticalController,
      ),
      horizontalDetails: ScrollableDetails.horizontal(
        controller: controller.horizontalController,
      ),
      controller: controller.treeController,
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




Future<ExplorableNode> _buildTreeUtil(FileSystemEntity item, ExplorableNode oldState) async 
=> switch(item) {
  Directory _ => ExplorableNode(
                    item,
                    children: await _getChildrenUtil(item, oldState),
                    expanded: _getNodeByPath(oldState, item.path)?.isExpanded ?? false,
                  ),
  _           => ExplorableNode(
                    item,
                  ),
};

Future<List<ExplorableNode>> _getChildrenUtil(Directory dir, ExplorableNode oldState) async {
  final children = await dir.list().toList();
  children.sort(_orderFS);
  return Future.wait(children.map((e) => _buildTreeUtil(e, oldState)));
}

int _orderFS(FileSystemEntity a, FileSystemEntity b) {
  if (a is Directory && b is File) return -1;
  if (a is File && b is Directory) return 1;
  return a.path.compareTo(b.path);
}

ExplorableNode? _getNodeByPath(
  ExplorableNode root,
  String path,
) {
  if (root.content.path == path) return root;
  // 找到父目录
  final matchDir = root.children.firstWhereOrNull((e) => _isSubPath(e.content.path, path));
  if (matchDir == null) return null;
  return _getNodeByPath(matchDir, path);
}

bool _isSubPath(String parent, String child) {
  if (parent == child) return true;
  // 确保路径以路径分隔符结尾
  if (!parent.endsWith(Platform.pathSeparator)) {
    parent += Platform.pathSeparator;
  }
  return child.startsWith(parent);
}

ExplorableNode _renameFileTree(ExplorableNode root, String oldName, String newName) {
  return ExplorableNode(
    switch (root.content) {
      Directory _ => Directory(root.content.path.replaceAll(oldName, newName)),
      _ => File(root.content.path.replaceAll(oldName, newName)),
    },
    children: root.children.map((e) => _renameFileTree(e, oldName, newName)).toList(),
    expanded: root.isExpanded,
  );
}

ExplorableNode _expandToRoot(ExplorableNode root, ExplorableNode leaf) {
  final parentPath = dirname(leaf.content.path);
  final parentNode = _getNodeByPath(root, parentPath);
  if (parentNode == null) throw Exception("Parent node not found");
  parentNode.children.remove(leaf);
  parentNode.children.add(ExplorableNode(
    leaf.content,
    children: leaf.children,
    expanded: true,
  ));
  parentNode.children.sort((a, b) => _orderFS(a.content, b.content));
  if (parentNode == root) return root;
  return _expandToRoot(root, parentNode);
}
