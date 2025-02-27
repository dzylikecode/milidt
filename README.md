# milidt /ˈmɪlaɪt/

What is life? It's too profound. Let's break it down with calculus. Life can be seen as a series of integrals:

<!-- e is kind of like t -->
<!-- how to write f like d? -->

$$
\text{life} \approx \int i \cdot \text{f}e
$$

What is "ife"? I think time is the most crucial part. As for "i", that's up to our imagination:

$$
\text{lidt} = \int i \text{d}t 
$$

How does it come to life? Reality always chooses the best way:

$$
\text{milidt} = \min \int i \text{d}t
$$

:stuck_out_tongue_winking_eye:

## development

build anroid apk：

```bash
flutter build apk
```

## timeline

symbols:

- :gear: repository configuration
- :sparkles: feature
- :bug: bug remains
- :rocket: action 
- :page_facing_up: code style
- :bulb: idea
- :hammer: fix

### 2025-02-27 21:01:43

:sparkles: markdown preview implementation:

- copy to clipboard: [copybutton](https://github.com/tagnote-app/markdown_viewer/blob/master/lib/src/widgets/copy_button.dart) and [layout](https://github.com/tagnote-app/markdown_viewer/blob/master/lib/src/builders/code_block_builder.dart)
- highlight code: [highlight](https://github.com/DanXi-Dev/DanXi/blob/main/lib/widget/forum/render/render_impl.dart)

### 2025-02-27 18:07:03

:sparkles: [markdown viewer](https://pub.dev/packages/markdown_viewer) is not maintained, so I use the official package and refer to these [code](https://github.com/DanXi-Dev/DanXi/blob/v1.4.7/lib/widget/forum/render/render_impl.dart)

### 2025-02-27 16:14:36

:bulb: https://github.com/asjqkkkk/markdown_widget/tree/dev

### 2025-02-26 21:49:17

:rocket: test markdown mathtex regex:

- inline: 
  
  ```txt
  \$(?:\\\$|[^$]|\n(?!\n))+?\$|\\\((?:[^\\(]|\n(?!\n))+?\\\)
  ```

- block: 

  ```txt
  \$\$(?:\\\$|[^$]|\n(?!\n))+\$\$|\\\[(?:[^\\[]|\n(?!\n))+?\\\]
  ```

virualize: https://regex-vis.com/
test here: https://regexr.com/

### 2025-02-26 19:23:16

:sparkles: [markdown viewer](https://pub.dev/packages/markdown_viewer)

### 2025-02-26 10:56:45

:hammer: [Typed return values for named routes](https://github.com/jonataslaw/getx/issues/734): if using the getx 5.0.0, then the `Get.back()` will not work; in the version 4.7.2, it can't deal with the nullable return value. So I just wrap it in a class.

```dart
final String? result = await Get.toNamed('/somePage');
```

```dart
final Ret result = await Get.toNamed('/somePage');
if (result.content != null) {
  // do something
}
```


### 2025-02-25 17:12:38

:sparkles: [undo/redo](https://api.flutter.dev/flutter/widgets/UndoHistoryController-class.html) toolbar which is [attached to the keyboard](https://pub.dev/packages/keyboard_attachable)

### 2025-02-25 14:41:34

:sparkles: image preview

### 2025-02-25 13:55:23

:bulb: loading file animation:

- [fleather](https://fleather-editor.github.io/docs/getting-started/quick-start/)
- [zefyr](https://zefyr-editor.gitbook.io/docs/quick-start)

:bulb: good markdown editor:

- [appflowy](https://github.com/appflowy-io/appflowy-editor)
- [fleather](https://fleather-editor.github.io/docs/getting-started/quick-start/)
- [zefyr](https://zefyr-editor.gitbook.io/docs/quick-start)

:bulb: [quick action](https://pub.dev/packages/quick_actions)

### 2025-02-25 01:03:19

:sparkles: create file/folder based on the selected file/folder:

- when `dir1/dir2` is selected, typing `dir3/file` will create a file `dir1/dir2/dir3/file`
- tap backgroud equals to select the root folder
- `/` is the root folder

### 2025-02-24 15:05:14

:sparkles: create a file explorer like vscode

:bug: if collapse the file explorer and then open it again, the file list is collapsed, see the issue [here](https://github.com/embraceitmobile/animated_tree_view/issues/61)

:gear: request permission to access the file system on android:

add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
    ...
</manifest>
```

:gear: change `ndkVersion` in [`android/app/build.gradle`](android/app/build.gradle.kts) because of `permission_handler`:

```gradle
android {
    namespace = "com.example.milidt"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.0.13004108"//flutter.ndkVersion

    ...
}
```

### 2025-02-23 15:46:40

:page_facing_up: adapt the "getx" framework, here is the file structure:

```plaintext
- main.dart             ---> entry 
- app.dart              ---> app widget implements
- controller.dart       ---> app state management
- pages/                ---> page widgets
  - xxx/                ---> page implementation
    - page.dart         ---> page layout
    - controller.dart   ---> page state management
    - binding.dart      ---> getx injection 
  - pages.dart          ---> export all pages
- widgets/
  - xxxx/
  - xxxxx.dart
- services/             ---> app state, api
  - xxx.dart
```

### 2025-02-23 15:40:07

:rocket: run the template generated by `flutter create` command

:gear: [Android Gradle proxy configuration](https://stackoverflow.com/questions/5991194/gradle-proxy-configuration), add the following to `gradle.properties`:

```properties
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=7890
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=7890
```
