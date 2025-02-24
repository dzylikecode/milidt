import 'package:get/get.dart';
import 'package:flutter/material.dart';


import '../../widgets/file_explorer.dart';
import '../../services/file_explorer.dart';

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
  
  Widget get projectNotOpened => Scaffold(
                                body: openProject,
                              );


  Widget get projectOpened => Scaffold(
                                appBar: AppBar(
                                  title: Text(controller.projectName),
                                ),
                                drawer: Drawer(
                                  child: FileExplorer(
                                    key: ValueKey(controller.projectPath),
                                  ),
                                ),
                              );
}