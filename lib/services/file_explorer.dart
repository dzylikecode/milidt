import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path/path.dart';
import 'dart:io';
import 'package:animated_tree_view/animated_tree_view.dart';

class FileExplorerService extends GetxService {
  static FileExplorerService get to => Get.find();

  FileExplorerService({
    String initialRootDir = "",
    this.onRootDirChanged
  }) {
    if (initialRootDir.isNotEmpty) {
      setRootDir(initialRootDir);
    }
  }

  final rootDir = "".obs;
  String get rootDirName => basename(rootDir.value);

  void Function(String)? onRootDirChanged;

  void pickDir() async {
    await requestStoragePermission();
    String? selectedDir = await FilePicker.platform.getDirectoryPath();
    if (selectedDir == null) return;
    setRootDir(selectedDir);
  }

  void setRootDir(String newRootDir) {
    if (rootDir.value == newRootDir) return;
    rootDir.value = newRootDir;
    _cacheFileTree.value = buildTree(newRootDir);
    onRootDirChanged?.call(newRootDir);
  }


  final selected = Rx<ExplorableNode?>(null);
  final _cacheFileTree = ExplorableNode().obs;
  ExplorableNode get fileTree => _cacheFileTree.value;

  void clearSelected() {
    selected.value = null;
  }

  bool isSelected(ExplorableNode node) => selected.value == node;

  void onTapBackground() {
    clearSelected();
  }

  void onTapExplorable(ExplorableNode node) {
    if (node == selected.value) return;
    selected.value = node;
  }

  void onLongPressExplorable(ExplorableNode node) {
  }
}

Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {                                    //; d("requesting storage permission...");
    status = await Permission.storage.request(); 
  }                                                           //; if (!status.isGranted) d("storage permission denied"); else d("storage permission granted");
  status = await Permission.manageExternalStorage.request();  //; if (!status.isGranted) d("manage external storage permission denied"); else d("manage external storage permission granted");
  return status.isGranted;
}

typedef ExplorableNode = TreeNode<FileSystemEntity>;

extension FileSystemEntityX on FileSystemEntity {
  String get pathKey => switch(this) {
    Directory dir   => "dir/${dir.path}".hashCode.toString(),
    File      file  => "file/${file.path}".hashCode.toString(),
    Link      link  => "link/${link.path}".hashCode.toString(),
    _               => "unknown/$path".hashCode.toString(),
  };
}

extension ExplorableExt on ExplorableNode {
  String get name => basename(data?.path ?? "");
  FileSystemEntity get entity => data!;
}



ExplorableNode buildTree(String path) {
  return _buildTreeUtil(Directory(path));
}

ExplorableNode _buildTreeUtil(FileSystemEntity item) {
  return switch(item) {
    Directory dir => ExplorableNode(
                      data: item,
                      key: item.pathKey,
                    )
                    ..addAll(_getChildrenUtil(dir)),
    _             => ExplorableNode(
                      data: item,
                      key: item.pathKey,
                    ),
  };
}

Iterable<ExplorableNode> _getChildrenUtil(Directory dir) {
  final children = dir.listSync();
  children.sort((a, b) {
    if (a is Directory && b is File)  return -1;
    if (a is File && b is Directory)  return 1;
                                      return a.path.compareTo(b.path);
  });
  return children.map((e) => _buildTreeUtil(e));
}
