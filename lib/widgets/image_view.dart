import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class ImageView extends StatelessWidget {
  final ImageProvider imageProvider;
  final Image cover;
  final void Function()? onShare;
  ImageView.file(File file, {super.key})
      : imageProvider = FileImage(file),
        cover = Image.file(file, errorBuilder: _errorBuilder),
        onShare = _shareFile(file.path)
      ;

  ImageView.network(String url, {super.key})
      : imageProvider = NetworkImage(url),
        cover = Image.network(
                  url, 
                  loadingBuilder: _networkLoadingBuilder,
                  errorBuilder: _errorBuilder
                ),
        onShare = _shareUri(url)
      ;
          

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showViewer,
      child: cover,
    );
  }

  void showViewer() {
    Get.dialog(
      viewer,
    );
  }

  Widget get viewer
  => SafeArea(
    child: Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          toolbar,
          Expanded(
            child: image,
          ),
        ],
      ),
    ),
  );

  Widget get toolbar
  => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: Get.back,
      ),
      IconButton(
        icon: const Icon(Icons.ios_share),
        onPressed: onShare,
      ),
    ],
  );
  

  Widget get image 
  => PhotoView(
        imageProvider: imageProvider,
        heroAttributes: const PhotoViewHeroAttributes(tag: "image"),
        onTapUp: (_, __, ___) { Get.back(); },
      );
}

Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
  return Center(
    child: Icon(
      Icons.broken_image,
      color: Colors.red,
      size: 50.0,
    ),
  );
}

Widget _networkLoadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
  if (loadingProgress == null) return child;
  return Center(
    child: CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
          : null,
    )
  );
}

void Function() _shareFile(String path) 
=> () => Share.shareXFiles([XFile(path)]);

void Function()? _shareUri(String uri)
=> () => Share.shareUri(Uri.parse(uri));


