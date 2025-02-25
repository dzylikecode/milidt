part of 'page.dart';

class TextFileEditorPageController extends GetxController {
  final args = Get.arguments as TextFileEditorPageArgs;

  File get file => args.file;
  String get initialContent => args.content;

  // 希望用来提示即时保存
  final saved = true.obs;

  String get fileName => basename(file.path);

  void onPop(bool didPop, Object? result) {
    if (didPop) return;
    saveFile(); // auto save
    final content = file.readAsStringSync();
    Get.back(result: content);
  }

  final contentController = TextEditingController();
  void saveFile() {
    if (saved.value) return;
    file.writeAsStringSync(contentController.text);
  }

  void onContentChanged(String content) {
    saved.value = false;
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}

class TextFileEditorPageArgs {
  final File file;
  final String content;

  TextFileEditorPageArgs({
    required this.file,
    required this.content,
  });
}