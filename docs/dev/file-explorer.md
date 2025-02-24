# file explorer

添加像vscode一样的explorer

## 主页默认

参考 [animated_tree_view](https://pub.dev/packages/animated_tree_view)

## 文件夹的选取

[file_picker](https://pub.dev/packages/file_picker)

## 文件读写权限的获取

[permission_handler](https://pub.dev/packages/permission_handler)

android 需要在`android/app/src/main/AndroidManifest.xml`添加：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
    ...
</manifest>
```

## ndkversion

因为permission handler，设置了ndk的version

## shared_preferences store app state


## tree

[animated_tree_view](https://pub.dev/packages/animated_tree_view) 好看，但是drawer收回的时候，它就不会展开了，后面需要自己改