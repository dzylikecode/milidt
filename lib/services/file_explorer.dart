import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path/path.dart';


class FileExplorerService extends GetxService {
  static FileExplorerService get to => Get.find();

  FileExplorerService({
    String initialRootDir = "",
    this.onRootDirChanged
  }): 
  rootDir = initialRootDir.obs;

  RxString rootDir;
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
    onRootDirChanged?.call(newRootDir);
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