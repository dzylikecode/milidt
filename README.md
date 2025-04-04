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

### 2025/04/05 00:27:45

:sparkles: [app icon](https://pub.dev/packages/icons_launcher):

- generate tools: [canva](https://www.canva.com/design/DAGjsFR0PGw/5ORf4v--ZdJiq-BjFJ-l8Q/edit?referrer=icons-landing-page)
- ~~icon match: [appicon.co](https://appicon.co/)~~ There is no need to use it, because the `flutter_launcher_icons` can generate the icons automatically.

step:

1. configure the `pubspec.yaml`:

```yaml
icons_launcher:
  image_path: "assets/app_icon.png"
  platforms:
    android:
      enable: true
```
2. generate the icons:

```bash
dart run icons_launcher:create
```

untrack generated files:

```bash
# git rm --cached android/app/src/main/ic_launcher-playstore.png
git rm --cached android/app/src/main/res/mipmap-hdpi/ic_launcher.png
git rm --cached android/app/src/main/res/mipmap-mdpi/ic_launcher.png
git rm --cached android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
git rm --cached android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
git rm --cached android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```


### 2025-04-04 16:56:47

:sparkles: image [preview](https://pub.dev/packages/photo_view) & share

:hammer: keep scroller position when toggling the file explorer:

I don't know why I need to create like this:

```dart
GetBuilder<FileTreeController>(
  init: controller.fileTreeController, //here
  initState: (state) => controller.fileTreeController.onInit(),
  dispose: (state) => controller.fileTreeController.onClose(),
  builder: (_) => fileTree,
)
```

### 2025-03-31 18:51:32

:bulb: draw: https://github.com/saber-notes/saber

### 2025-03-31 16:35:05

:sparkles: download files:

[style](https://docs.flutter.dev/cookbook/effects/download-button)


### 2025-03-31 14:48:43

I found that folder name can't be same as the file name in Android.

```mermaid
graph LR
    A[User Operator] --> B[Guard]
    B -->|Success| C[Operator]
    C --> D[Render]
    B -->|Failed| A
```

### 2025-03-30 22:49:29

:hammer: replace animated_tree_view with [two_dimensional_scrollables](https://pub.dev/packages/two_dimensional_scrollables):

https://www.youtube.com/watch?v=UDZ0LPQq-n8

### 2025-03-28 19:24:03

It takes a long time to build the apk to debug, then I find the problem is proxy. (execute `flutter run -v` to see the log)

:sparkles: [share files](https://pub.dev/packages/share_plus)

:sparkles: [receive_sharing_intent](https://pub.dev/packages/receive_sharing_intent):

```xml
<activity
    android:launchMode="singleTask"
>
      <intent-filter>
          <action android:name="android.intent.action.SEND" />
          <category android:name="android.intent.category.DEFAULT" />
          <data android:mimeType="*/*" />
      </intent-filter>
      <intent-filter>
          <action android:name="android.intent.action.SEND_MULTIPLE" />
          <category android:name="android.intent.category.DEFAULT" />
          <data android:mimeType="*/*" />
      </intent-filter>
</activity>
```

because of the compatibility(try to run `flutter analyze --suggestions`), I override the version:

```yaml
dependency_overrides:
  receive_sharing_intent:
    git:
      url: https://github.com/ravijadav812/receive_sharing_intent
```

Files will copy to the `/data/user/0/com.example.milidt/cache/` folder. If checking the file, I can run the below command:

```bash
adb shell
run-as com.example.milidt
ls

# exit
exit
```

I felt sad because I just write the wrong code, and it takes me a long time to find the problem. 

```dart
// wrong
await File(targetPath).copy(sourcePath);
// correct
await File(sourcePath).copy(targetPath);
```

### 2025-02-28 15:26:06

:bulb: [json preview](https://pub.dev/packages/flutter_json_view)

### 2025-02-28 14:07:54

:bulb: [receive_sharing_intent](https://pub.dev/packages/receive_sharing_intent)

:bulb: markdown preview:

If I want to preview the markdown when writing, I have to go back to the preview. But then I lost the history.

:bulb: [share](https://pub.dev/packages/share_plus)

### 2025-02-28 12:19:45

:sparkles: camera & gallery

### 2025-02-27 23:59:18

:sparkles: quick sample

:bulb: long press to prompt the context menu, then select the delete option to delete the file/folder

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
