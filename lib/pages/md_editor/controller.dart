part of 'page.dart';

class MdEditorPageController extends GetxController {
  final args = Get.arguments as MdEditorPageArgs;

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
      Get.back(result: MdEditorPageResult());
      return;
    }
    savingWhenGoBack.value = true;
    await saveFile(); // auto save
    final content = await file.readAsString();
    savingWhenGoBack.value = false;
    Get.back(result: MdEditorPageResult(content: content));
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

  void pickImageFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
      if (image == null) return;
      final fileName = basename(image.path);
      final markdownDirPath = dirname(file.path);
      final imagePath = "$markdownDirPath/images/$fileName";
      // images folder 不存在会自动创建吗？
      final imagesDir = Directory("$markdownDirPath/images");
      if (!await imagesDir.exists()) {
        await imagesDir.create();
      }
      await File(image.path).copy(imagePath);
      final relativePath = 'images/$fileName';
      final imageMarkdown = "![image]($relativePath)";
          // 插入图片链接到当前光标位置
      final currentPosition = contentController.selection.baseOffset;
      final text = contentController.text;
      final newText = text.substring(0, currentPosition) + 
                      imageMarkdown + 
                      text.substring(currentPosition);
      contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: currentPosition + imageMarkdown.length),
      );

      // 要自己调用
      onContentChanged(newText);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void pickImageFromCamera() async {
    try {
      final image = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
      if (image == null) return;
      final fileName = basename(image.path);
      final markdownDirPath = dirname(file.path);
      final imagePath = "$markdownDirPath/images/$fileName";
      // images folder 不存在会自动创建吗？
      final imagesDir = Directory("$markdownDirPath/images");
      if (!await imagesDir.exists()) {
        await imagesDir.create();
      }
      await File(image.path).copy(imagePath);
      final relativePath = 'images/$fileName';
      final imageMarkdown = "![image]($relativePath)";
          // 插入图片链接到当前光标位置
      final currentPosition = contentController.selection.baseOffset;
      final text = contentController.text;
      final newText = text.substring(0, currentPosition) + 
                      imageMarkdown + 
                      text.substring(currentPosition);
      contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: currentPosition + imageMarkdown.length),
      );

      // 要自己调用
      onContentChanged(newText);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}

class MdEditorPageArgs {
  final File file;
  final String content;

  MdEditorPageArgs({
    required this.file,
    required this.content,
  });
}

class MdEditorPageResult {
  final String? content;

  MdEditorPageResult({
    this.content,
  });
}