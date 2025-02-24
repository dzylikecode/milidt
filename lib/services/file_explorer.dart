import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
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
    // [ ] enhanced 最好改成异步加载，要不然耗时太长了
    loadFileTree();
    onRootDirChanged?.call(newRootDir);
  }

  final selected = Rx<ExplorableNode?>(null);
  final _cacheFileTree = ExplorableNode().obs;
  ExplorableNode get fileTree => _cacheFileTree.value;
  final isLoading = false.obs;
  Future<void> loadFileTree() async {
    isLoading.value = true;
    try {
      // 使用 compute 函数在后台线程中加载文件夹内容
      _cacheFileTree.value = await compute(buildTree, rootDir.value);
    } catch (e) {
      Get.snackbar("Error", "Failed to load folder contents");
    } finally {
      isLoading.value = false; // 加载完成
    }
  }

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
    if (node.entity is File) {
      Get.back();
      goToPreviewFile(node.entity as File);
    }
  }

  final formKey = GlobalKey<FormState>();
  final editController = TextEditingController();
  void createFolderPrompt() => createFSDialog(
                                title: 'Create New Folder', 
                                onSubmit: createFolder,
                                onValidate: validateCreateFolder
                              );
  void createFilePrompt() =>  createFSDialog(
                                title: 'Create New File', 
                                onSubmit: createFile,
                                onValidate: validateCreateFile
                              );
  ExplorableNode get contextFolder {
    // 一定要是 fileTree，因为后续的 add 会用到
    final contextItem = selected.value ?? fileTree;
    return switch (contextItem.entity) {
      Directory _ => contextItem,
      _           => contextItem.parent! as ExplorableNode,
    };
  }
  String sysPath(String path) {
    if (path[0] == '/') {
      final rel = path.substring(1);
      return join(rootDir.value, rel);
    }
    return join(contextFolder.entity.path, path);
  }

  void createFolder(String relativePath) {
    final path = sysPath(relativePath);
    final dir = Directory(path);
    dir.createSync(recursive: true);
    final firstSubDir = getFirstSubPath(contextFolder.entity.path, path);
    contextFolder.add(buildTree(firstSubDir));
  }
  String? validateCreateFolder(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return "Folder name cannot be empty";
    }
    final path = sysPath(relativePath);
    if (Directory(path).existsSync()) {
      return "Folder already exists";
    }
    return null;
  }

  void createFile(String relativePath) {
    final path = sysPath(relativePath);
    final file = File(path);
    file.createSync(recursive: true);
    final firstSubDir = getFirstSubPath(contextFolder.entity.path, path);
    contextFolder.add(firstSubDir == path
                      ? ExplorableNode(data: file)
                      : buildTree(firstSubDir)
                      );
  }

  String? validateCreateFile(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return "File name cannot be empty";
    }
    final path = sysPath(relativePath);
    if (File(path).existsSync()) {
      return "File already exists";
    }
    return null;
  }


  void goToPreviewFile(File file) {

  }

  void onLongPressExplorable(ExplorableNode node) {
  }

  void createFSDialog({
    required String title,
    required void Function(String) onSubmit,
    String? Function(String?)? onValidate,
    String initValue = '',
  }) => createFSDialogUtil(
    title: title,
    formKey: formKey,
    controller: editController,
    onSubmit: onSubmit,
    onValidate: onValidate ?? (text) => null,
    initValue: initValue,
  );

  @override
  void onClose() {
    editController.dispose();
    super.onClose();
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

void createFSDialogUtil({
  required String title,
  required GlobalKey<FormState> formKey,
  required TextEditingController controller,
  required void Function(String) onSubmit,
  required String? Function(String?) onValidate, 
  String       initValue = '',
}) {
  controller.text = initValue;
  void submit(String text) {
    if (formKey.currentState!.validate()) {
      onSubmit(text);
      Get.back();
    }
  }
  Get.defaultDialog(
    title: title,
    content: Form(
      key: formKey,
      child: TextFormField(
        autofocus: true,
        controller: controller,
        validator: onValidate,
        onFieldSubmitted: submit,
        decoration: const InputDecoration(
          hintText: "Folder Name",
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => submit(controller.text),
        child: const Text("Create"),
      ),
      TextButton(
        onPressed: Get.back,
        child: const Text("Cancel"),
      ),
    ],
  );
}

String getFirstSubPath(String contextDir, String createdPath) {
  final relativePath = relative(createdPath, from: contextDir);
  final parts = split(relativePath);
  return join(contextDir, parts.first);
}