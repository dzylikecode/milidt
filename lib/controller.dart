import 'package:get/get.dart';
import 'package:milidt/services/receive.dart';

import 'services/file_explorer.dart';
import 'services/system_status.dart';

class AppContorller extends GetxService {
  static Future<void> init() async {
    Get.put(AppContorller());
    await Get.put(SystemStatusService()).init();
    Get.put(FileExplorerService(
      initialRootDir: SystemStatusService.to.rootDir,
      onRootDirChanged: (newRootDir) => SystemStatusService.to.rootDir = newRootDir
    ));
    Get.put(ReceiveService(FileExplorerService.to));
  }
}