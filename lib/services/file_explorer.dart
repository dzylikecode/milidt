import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../widgets/file_tree.dart';

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
    loadFileTree();
    onRootDirChanged?.call(newRootDir);
  }

  final fileTreeController = FileTreeController();
  ExplorableNode get fileTree => fileTreeController.rootNode;
  final isLoading = false.obs;
  Future<void> loadFileTree() async {
    isLoading.value = true;
    try {
      // 使用 compute 函数在后台线程中加载文件夹内容
      fileTreeController.rootNode = await compute(FileTree.buildTree, Directory(rootDir.value));
    } catch (e) {
      Get.snackbar("Error", "Failed to load folder contents");
    } finally {
      isLoading.value = false; // 加载完成
    }
  }

  void onTapBackground() {
    fileTreeController.clearSelected();
  }
  void onTapDown(ExplorableNode node) {
    fileTreeController.selected = node;
  }
  void onTapExplorable(ExplorableNode node) {
    if (node.content is File) {
      Get.back();
      goToPreviewFile(node.content as File);
    } else if (node.content is Directory) {
      fileTreeController.toggleNode(node);
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
    final contextItem = fileTreeController.selected ?? fileTree;
    return switch (contextItem.content) {
      Directory _ => contextItem,
      _           => contextItem.parent ?? fileTree,
    };
  }
  String sysPath(String path) {
    if (path[0] == '/') {
      final rel = path.substring(1);
      return join(rootDir.value, rel);
    }
    return join(contextFolder.content.path, path);
  }

  void createFolder(String relativePath) {
    final path = sysPath(relativePath);
    final dir = Directory(path);
    dir.createSync(recursive: true);
    final firstSubDir = getFirstSubPath(contextFolder.content.path, path);
    fileTreeController.add(contextFolder, FileTree.buildTree(Directory(firstSubDir)));
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
    final firstSubDir = getFirstSubPath(contextFolder.content.path, path);
    
    fileTreeController.add(contextFolder, 
      firstSubDir == path
      ? FileTree.buildTree(file)
      : FileTree.buildTree(Directory(firstSubDir))
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
  void onLongPressExplorable(ExplorableNode node) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Rename"),
              onTap: () {
                Get.back();
                createFSDialog(
                  title: 'Rename',
                  onSubmit: (newName) async {
                    final newPath = join(
                      dirname(node.content.path),
                      newName,
                    );
                    final fs = node.content;
                    await fs.rename(newPath);
                    fileTreeController.rename(node, newPath);
                  },
                  initValue: basename(node.content.path),
                );
              },
            ),
            ListTile(
              title: const Text("Delete"),
              onTap: () {
                Get.back();
                deleteFSDialogUtil(
                  title: 'Delete',
                  onDelete: () async {
                    final fs = node.content;
                    await fs.delete(recursive: true);
                    fileTreeController.remove(node);
                  },
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
    );
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

  final activeFile = Rx<File?>(null);
  final fileContent = "".obs;
  var fileType = FilePreviewType.unknown;
  final fileLoading = false.obs;
  Future<void> goToPreviewFile(File file) async {
    activeFile.value = file;
    fileLoading.value = true;
    final (type, content) = await recognizedByExt(file) 
                            ?? await recognizedByContent(file);
    fileLoading.value = false;
    fileType = type;
    fileContent.value = content;
  }

  Future<File?> quickCreateSample(String relativePath) async {
    final path = sysPath(relativePath);
    final file = File(path);
    if (await file.exists()) return null;
    return file.create(recursive: true);

    // 没法调用 createFile，因为 node 更新很奇怪
    // 一开始没有 sample
    // 后面有 sample 了，两次添加 node 不一样
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
        child: const Text("Confirm"),
      ),
      TextButton(
        onPressed: Get.back,
        child: const Text("Cancel"),
      ),
    ],
  );
}

void deleteFSDialogUtil({
  required String title,
  required void Function() onDelete,
}) {
  Get.defaultDialog(
    title: title,
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

String getFirstSubPath(String contextDir, String createdPath) {
  final relativePath = relative(createdPath, from: contextDir);
  final parts = split(relativePath);
  return join(contextDir, parts.first);
}

enum FilePreviewType {
  image,
  text,
  markdown,
  unknown,
}

Future<(FilePreviewType, String)?> recognizedByExt(File file) async {
  final ext = file.path.split('.').last;

  final imageExt = ['jpg', 'jpeg', 'png', 'gif'];
  if (imageExt.contains(ext)) return (FilePreviewType.image, "");

  final markdownExt = ['md', ];
  if (markdownExt.contains(ext)) return (FilePreviewType.markdown, await file.readAsString());

  return null;
}

Future<(FilePreviewType, String)> recognizedByContent(File file) async {
  var content = "";
  try {
    content = await file.readAsString();
  } catch (e) {
    return (FilePreviewType.unknown, "");
  }
  if (content.isEmpty && await file.length() > 0) {
    return (FilePreviewType.unknown, "");
  }
  return (FilePreviewType.text, content);
}