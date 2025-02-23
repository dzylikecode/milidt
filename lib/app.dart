import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/pages.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Pages.home.name,
      // theme: appThemeData,
      defaultTransition: Transition.fade,
      // initialBinding: SplashBinding(),
      getPages: Pages.toPages().toList(),
    );
  }
}