import 'home/page.dart';
import 'text_file_editor/page.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


enum Pages {
  home(
    name: '/home',
    page: HomePage.new,
    binding: HomePageBinding.new,
  ),
  textFileEditor(
    name: '/textFileEditor',
    page: TextFileEditorPage.new,
    binding: TextFileEditorPageBinding.new,
  )
  ;
  final String name;
  final Widget Function() page;
  final Bindings Function() binding;
  const Pages({
    required this.name,
    required this.page,
    required this.binding,
  });

  static Iterable<GetPage> toPages() {
    return values.map((e) => 
      GetPage(
        name: e.name,
        page: e.page,
        binding: e.binding(),
      )
    ,);
  }
}