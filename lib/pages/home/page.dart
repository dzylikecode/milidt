import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

import '../../widgets/file_explorer.dart';
import '../../services/file_explorer.dart';
import '../../widgets/file_preview.dart';
import '../pages.dart';
import '../txt_editor/page.dart';
import '../md_editor/page.dart';

part 'controller.dart';
part 'binding.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
      controller.projectOpened
      ? projectOpened
      : projectNotOpened
    );
  }

  Widget get openProject => Center(
                              child: ElevatedButton(
                                onPressed: controller.pickDir,
                                child: const Text("Open Project"),
                              ),
                            );
  
  Widget get projectNotOpened =>  Scaffold(
                                    body: openProject,
                                  );


  Widget get projectOpened 
  => Scaffold(
      appBar: AppBar(
        title: Obx(() => 
          controller.fileOpened
          ? Text(controller.fileName)
          : Text(controller.projectName)
        ),
      ),
      drawer: Drawer(
        child: FileExplorer(
          key: ValueKey(controller.projectPath),
        ),
      ),
      body: controller.fileOpened
          ? filePreivew
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: controller.quickCreateSample,
        tooltip: 'sample',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

  Widget get filePreivew => Obx(() => 
                              controller.fileLoading || controller.isCreatingSample.value
                              ? const Center(child: CircularProgressIndicator(),)
                              : FilePreivew(
                                  key: ValueKey(controller.openedFile.path),
                                  file: controller.openedFile, 
                                  type: controller.fileType,
                                  content: controller.fileContent,
                                  onDoubleTap: controller.doubleTapFilePreview,
                                )
                            );
  
}