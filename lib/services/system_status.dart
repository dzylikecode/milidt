import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SystemStatusService extends GetxService {
  static SystemStatusService get to => Get.find();
  static late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  String get rootDir => prefs.getString("rootDir") ?? "";
  set rootDir(String dir) => prefs.setString("rootDir", dir);
}