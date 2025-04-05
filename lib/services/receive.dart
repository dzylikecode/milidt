import 'dart:io';

import 'package:get/get.dart';
import 'package:milidt/services/file_explorer.dart';
import 'package:path/path.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class ReceiveService extends GetxService {
  static ReceiveService get to => Get.find();

  late StreamSubscription _intentSub;

  FileExplorerService workspace;

  ReceiveService(this.workspace);

  @override
  void onInit() {
    super.onInit();
    receiveWhenClosed();
    receiveWhenRunning();
  }
  
  // 后面就是监听了
  void receiveWhenRunning() {
    _intentSub = ReceiveSharingIntent.instance
                  .getMediaStream()
                  .listen(receive, 
                  onError: (err) {
                    Get.snackbar("Error", "Failed to get shared files");
                  });
  }

  // 相当于第一次启动得到发来的数据
  void receiveWhenClosed() async {
    final files = await ReceiveSharingIntent.instance.getInitialMedia();
    await receive(files);
  }

  Future<void> receive(List<SharedMediaFile> files) async {
    if (workspace.rootDir.value.isEmpty) {
      Get.snackbar("Error", "No project opened");
      return;
    }
    try {
      // 并行处理
      await Future.wait(files.map(dealEachFile));
    } catch (e) {
      Get.snackbar("Error", "Failed to process some files: $e");
    }
  }

  Future<void> dealEachFile(SharedMediaFile file) {
    switch (file.type) {
      case SharedMediaType.image:
      case SharedMediaType.video:
      case SharedMediaType.file: return receiveFile(file);
      case SharedMediaType.text:
      case SharedMediaType.url: return receiveText(file);
    }

  }

  Future<void> receiveFile(SharedMediaFile file) async {
    final sourcePath = file.path;
    final name = basenameWithoutExtension(sourcePath);
    final ext = extension(sourcePath);
    var targetPath = workspace.sysPath("/raw/$name$ext");
    if (await File(targetPath).exists()) {
      targetPath = workspace.sysPath("/raw/$name-copy$ext");
    }
    await workspace.copyFile(sourcePath, targetPath);

    Get.snackbar("Success", "stored to ${workspace.wkPath(targetPath)}");
  }

  Future<void> receiveText(SharedMediaFile file) async {
    final text = file.path;
    // 写入到剪切板中
    await Clipboard.setData(ClipboardData(text: text));

    Get.snackbar("Success", "Text copied to clipboard");
  }

  @override
  void onClose() {
    _intentSub.cancel();
    super.onClose();
  }
}