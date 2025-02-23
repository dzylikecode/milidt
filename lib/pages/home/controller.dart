
part of 'page.dart';

class HomePageController extends GetxController {
  void pickDir() => FileExplorerService.to.pickDir();

  bool get projectOpened => FileExplorerService.to.rootDir.value.isNotEmpty;

  String get projectName => FileExplorerService.to.rootDirName;
}