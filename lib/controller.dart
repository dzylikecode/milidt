import 'package:get/get.dart';

import 'services/file_explorer.dart';


class AppContorller extends GetxService {
  static Future<void> init() async {
    Get.put(AppContorller());
    Get.put(FileExplorerService());
  }
}