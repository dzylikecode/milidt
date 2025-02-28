import 'home/page.dart';
import 'txt_editor/page.dart';
import 'md_editor/page.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


enum Pages {
  home(
    name: '/home',
    page: HomePage.new,
    binding: HomePageBinding.new,
  ),
  txtEditor(
    name: '/textFileEditor',
    page: TxtEditorPage.new,
    binding: TxtEditorPageBinding.new,
  ),
  mdEditor(
    name: '/markdownEditor',
    page: MdEditorPage.new,
    binding: MdEditorPageBinding.new,
  ),
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