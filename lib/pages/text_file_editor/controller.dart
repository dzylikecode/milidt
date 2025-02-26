part of 'page.dart';

class TextFileEditorPageController extends GetxController {
  final args = Get.arguments as TextFileEditorPageArgs;

  File get file => args.file;
  String get initialContent => args.content;

  // 自动保存
  final saved = true.obs;
  final writingCounts = 0.obs;

  final savingWhenGoBack = false.obs;

  String get fileName => basename(file.path);

  Future<void> onPop(bool didPop, Object? result) async {
    if (didPop) return;
    // can't undo so the content is not changed
    if (!undoController.value.canUndo) {
      Get.back(result: TextFileEditorPageRet());
      return;
    }
    savingWhenGoBack.value = true;
    await saveFile(); // auto save
    final content = await file.readAsString();
    savingWhenGoBack.value = false;
    Get.back(result: TextFileEditorPageRet(content: content));
  }
  
  late StreamSubscription<bool> keyboardSubscription;
  
  @override
  void onInit() {
    super.onInit();
    contentController.text = initialContent;
    focusNode.requestFocus();
    final keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        focusNode.unfocus();
      }
    });
    debounce(writingCounts, (_) => saveFile(), time: const Duration(milliseconds: 500));
  }

  final contentController = TextEditingController();
  final undoController = UndoHistoryController();
  final focusNode = FocusNode();

  Future<void> saveFile() async {
    if (saved.value) return;
    await file.writeAsString(contentController.text);
    saved.value = true;
  }

  void onContentChanged(String content) {
    saved.value = false;
    writingCounts.value++;
  }

  @override
  void onClose() {
    contentController.dispose();
    undoController.dispose();
    focusNode.dispose();
    keyboardSubscription.cancel();
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

class TextFileEditorPageRet {
  final String? content;

  TextFileEditorPageRet({
    this.content,
  });
}