import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'dart:io';
import 'dart:async';

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
      await fileTreeController.load(rootDir.value);
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

  ExplorableNode get contextFolder => fileTreeController.contextFolder;
  String sysPath(String path) => fileTreeController.sysPath(path);

  Future<void> createFolder(String relativePath) 
  => fileTreeController.createDir(sysPath(relativePath));

  Future<void> createFile(String relativePath) 
  => fileTreeController.createFile(sysPath(relativePath));
  Future<void> removeByNode(ExplorableNode node) {
    return fileTreeController.remove(node);
  }
  Future<void> renameByNode(ExplorableNode node, String newName) async {
    final newPath = join(
      dirname(node.content.path),
      newName,
    );
    if (newPath == node.content.path) return;
    return await fileTreeController.rename(node, newPath);
  }

  Rx<File?> get activeFile => fileTreeController.activeFile;
  final fileContent = "".obs;
  var fileType = FilePreviewType.unknown;
  final fileLoading = false.obs;
  Future<void> goToPreviewFile(File file) async {
    fileTreeController.selectFile(file); // guard 程序调用
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
    await createFile(relativePath);
    return file;
  }

  final allIsExpanded = false.obs;
  void toggleAll() {
    allIsExpanded.value = !allIsExpanded.value;
    if (allIsExpanded.value) {
      fileTreeController.expandAll();
    } else {
      fileTreeController.collapseAll();
    }
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

enum FilePreviewType {
  image,
  text,
  markdown,
  pdf,
  unknown,
}

Future<(FilePreviewType, String)?> recognizedByExt(File file) async {
  final ext = file.path.split('.').last;

  final imageExt = ['jpg', 'jpeg', 'png', 'gif'];
  if (imageExt.contains(ext)) return (FilePreviewType.image, "");

  final markdownExt = ['md', ];
  if (markdownExt.contains(ext)) return (FilePreviewType.markdown, await file.readAsString());

  final pdfExt = ['pdf', ];
  if (pdfExt.contains(ext)) return (FilePreviewType.pdf, "");

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