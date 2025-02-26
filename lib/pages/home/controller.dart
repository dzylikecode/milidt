
part of 'page.dart';

class HomePageController extends GetxController {
  void pickDir() => FileExplorerService.to.pickDir();

  bool get projectOpened => FileExplorerService.to.rootDir.value.isNotEmpty;

  String get projectName => FileExplorerService.to.rootDirName;

  String get projectPath => FileExplorerService.to.rootDir.value;

  bool get fileOpened => FileExplorerService.to.activeFile.value != null;

  File get openedFile => FileExplorerService.to.activeFile.value!;
  String get fileName => basename(openedFile.path);

  FilePreviewType get fileType => FileExplorerService.to.fileType;
  String get fileContent => FileExplorerService.to.fileContent.value;

  void doubleTapFilePreview() async {
    if (fileType == FilePreviewType.text) {
      final arguments = TextFileEditorPageArgs(file: openedFile, content: fileContent);
      // https://github.com/jonataslaw/getx/issues/734
      final TextFileEditorPageRet ret = await Get.toNamed(Pages.textFileEditor.name, arguments: arguments);
      // 常常可能误触，并没有更改内容
      if (ret.content != null) {
        FileExplorerService.to.fileContent.value = ret.content!;
      }
    }
  }
}