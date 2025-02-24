import 'package:flutter/material.dart';
import 'app.dart';
import 'controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppContorller.init();
  runApp(const App());
}

