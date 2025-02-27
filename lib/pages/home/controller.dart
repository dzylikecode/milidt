
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
  bool get fileLoading => FileExplorerService.to.fileLoading.value;

  Future<void> doubleTapFilePreview() async {
    if (fileType == FilePreviewType.text
    || fileType == FilePreviewType.markdown
    ) {
      final arguments = TextFileEditorPageArgs(file: openedFile, content: fileContent);
      // https://github.com/jonataslaw/getx/issues/734
      final TextFileEditorPageRet ret = await Get.toNamed(Pages.textFileEditor.name, arguments: arguments);
      // 常常可能误触，并没有更改内容
      if (ret.content != null) {
        FileExplorerService.to.fileContent.value = ret.content!;
      }
    }
  }

  final isCreatingSample = false.obs;
  void quickCreateSample() async {
    isCreatingSample.value = true;
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd-HH-mm-ss').format(now);
    final file = await FileExplorerService.to.quickCreateSample("/sample/$formattedDate/content.md");
    if (file == null) {
      isCreatingSample.value = false;
      Get.snackbar("Error", "File already exists");
      return;
    }
    await FileExplorerService.to.goToPreviewFile(file);
    await doubleTapFilePreview();
    isCreatingSample.value = false;
  }
}