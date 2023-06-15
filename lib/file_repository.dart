import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:recase/recase.dart';

class Paths {
  Paths({
    required this.androidAppBuildGradle,
    required this.androidDebugManifest,
    required this.androidManifest,
    required this.androidProfileManifest,
    required this.androidKotlin,
    required this.iosInfoPlist,
    required this.iosProjectPbxproj,
    required this.launcherIcon,
    required this.linuxAppCpp,
    required this.linuxCMakeLists,
    required this.macosAppInfoxproj,
    required this.pubspecYaml,
    required this.webApp,
    required this.windowsApp,
  });
  factory Paths.getInstance() {
    if (Platform.isMacOS || Platform.isLinux) {
      return Paths(
        pubspecYaml: 'pubspec.yaml',
        iosInfoPlist: 'ios/Runner/Info.plist',
        androidAppBuildGradle: 'android/app/build.gradle',
        iosProjectPbxproj: 'ios/Runner.xcodeproj/project.pbxproj',
        macosAppInfoxproj: 'macos/Runner/Configs/AppInfo.xcconfig',
        launcherIcon: 'assets/images/launcherIcon.png',
        linuxCMakeLists: 'linux/CMakeLists.txt',
        linuxAppCpp: 'linux/my_application.cc',
        windowsApp: 'web/index.html',
        androidManifest: 'android/app/src/main/AndroidManifest.xml',
        androidDebugManifest: 'android/app/src/debug/AndroidManifest.xml',
        androidProfileManifest: 'android/app/src/profile/AndroidManifest.xml',
        androidKotlin: 'android/app/src/main/kotlin',
        webApp: 'linux/my_application.cc',
      );
    } else {
      return Paths(
        androidManifest: '.\\android\\app\\src\\main\\AndroidManifest.xml',
        androidDebugManifest:
            '.\\android\\app\\src\\debug\\AndroidManifest.xml',
        androidProfileManifest:
            '.\\android\\app\\src\\profile\\AndroidManifest.xml',
        androidKotlin: '',
        pubspecYaml: '.\\pubspec.yaml',
        iosInfoPlist: '.\\ios\\Runner\\Info.plist',
        androidAppBuildGradle: '.\\android\\app\\build.gradle',
        iosProjectPbxproj: '.\\ios\\Runner.xcodeproj\\project.pbxproj',
        macosAppInfoxproj: '.\\macos\\Runner\\Configs\\AppInfo.xcconfig',
        launcherIcon: '.\\assets\\images\\launcherIcon.png',
        linuxCMakeLists: '.\\linux\\CMakeLists.txt',
        linuxAppCpp: '.\\linux\\my_application.cc',
        webApp: '.\\linux\\my_application.cc',
        windowsApp: '.\\web\\index.html',
      );
    }
  }
  final String androidManifest;
  final String androidDebugManifest;
  final String androidProfileManifest;
  final String pubspecYaml;
  final String iosInfoPlist;
  final String androidAppBuildGradle;
  final String iosProjectPbxproj;
  final String macosAppInfoxproj;
  final String launcherIcon;
  final String linuxCMakeLists;
  final String linuxAppCpp;
  final String webApp;
  final String windowsApp;
  final String androidKotlin;
}

class FileRepository {
  late Logger logger;
  final paths = Paths.getInstance();
  FileRepository() {
    logger = Logger(filter: ProductionFilter());
  }

  List<String?> readFileAsLineByline({required String filePath}) {
    try {
      var fileAsString = File(filePath).readAsStringSync();
      return fileAsString.split('\n');
    } catch (e) {
      return [];
    }
  }

  Future<File> writeFile({required String filePath, required String content}) {
    return File(filePath).writeAsString(content);
  }

  Future<void> readWriteFile({
    required String filePath,
    required String Function(String content) onContentLine,
    required String fileNotExistsInfo,
    required String changedToInfo,
    bool throwIfNotExists = true,
  }) async {
    final contentLineByLine = readFileAsLineByline(
      filePath: filePath,
    );
    if (throwIfNotExists && checkFileExists(contentLineByLine)) {
      logger.w('''
      $fileNotExistsInfo could not be changed because,
      The related file could not be found in that path:  $filePath
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      final contentLine = contentLineByLine[i] ?? '';
      contentLineByLine[i] = onContentLine(contentLine);
    }
    await writeFile(
      filePath: filePath,
      content: contentLineByLine.join('\n'),
    );
    logger.i('$fileNotExistsInfo changed successfully to : $changedToInfo');
  }

  Future<String?> getIosBundleId() async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosProjectPbxproj,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Ios BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.iosProjectPbxproj}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('PRODUCT_BUNDLE_IDENTIFIER')) {
        return (contentLineByLine[i] as String).split('=').last.trim();
      }
    }
    return null;
  }

  Future<File?> changeIosBundleId({String? bundleId}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosProjectPbxproj,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Ios BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.iosProjectPbxproj}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('PRODUCT_BUNDLE_IDENTIFIER')) {
        contentLineByLine[i] = '				PRODUCT_BUNDLE_IDENTIFIER = $bundleId;';
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.iosProjectPbxproj,
      content: contentLineByLine.join('\n'),
    );
    logger.i('IOS BundleIdentifier changed successfully to : $bundleId');
    return writtenFile;
  }

  Future<String?> getMacOsBundleId() async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: '${paths.macosAppInfoxproj}',
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      macOS BundleId could not be changed because,
      The related file could not be found in that path: ${paths.macosAppInfoxproj}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('PRODUCT_BUNDLE_IDENTIFIER')) {
        return (contentLineByLine[i] as String).split('=').last.trim();
      }
    }
    return null;
  }

  Future<File?> changeMacOsBundleId({String? bundleId}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.macosAppInfoxproj,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      macOS BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.macosAppInfoxproj}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('PRODUCT_BUNDLE_IDENTIFIER')) {
        contentLineByLine[i] = 'PRODUCT_BUNDLE_IDENTIFIER = $bundleId;';
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.macosAppInfoxproj,
      content: contentLineByLine.join('\n'),
    );
    logger.i('MacOS BundleIdentifier changed successfully to : $bundleId');
    return writtenFile;
  }

  Future<String?> getAndroidBundleId() async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: 'androidAppBuildGradlePath',
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Android BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.androidAppBuildGradle}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('applicationId')) {
        return (contentLineByLine[i] as String).split('"').elementAt(1).trim();
      }
    }
    return null;
  }

  Future<void> changeAndroidBundleId({String? bundleId}) async {
    if (bundleId == null) return;

    await readWriteFile(
      changedToInfo: bundleId,
      fileNotExistsInfo: 'Android Gradle BundleId',
      filePath: paths.androidAppBuildGradle,
      onContentLine: (contentLine) {
        if (contentLine.contains('applicationId')) {
          return '        applicationId \"$bundleId\"';
        }
        return contentLine;
      },
    );

    await readWriteFile(
      changedToInfo: bundleId,
      fileNotExistsInfo: 'Android Main Manifest BundleId',
      filePath: paths.androidManifest,
      onContentLine: (contentLine) {
        if (contentLine.contains('package')) {
          return '        package=\"$bundleId\"';
        }
        return contentLine;
      },
    );

    await readWriteFile(
      changedToInfo: bundleId,
      fileNotExistsInfo: 'Android Debug Manifest BundleId',
      filePath: paths.androidDebugManifest,
      onContentLine: (contentLine) {
        if (contentLine.contains('package')) {
          return '        package=\"$bundleId\"';
        }
        return contentLine;
      },
    );
    await readWriteFile(
      changedToInfo: bundleId,
      fileNotExistsInfo: 'Android Profile Manifest BundleId',
      filePath: paths.androidProfileManifest,
      onContentLine: (contentLine) {
        if (contentLine.contains('package')) {
          return '        package=\"$bundleId\"';
        }
        return contentLine;
      },
    );

    // find kotlin activity
    final files = Directory(paths.androidKotlin).listSync();
    String findKotlinActivityPath(final List<FileSystemEntity> files) {
      for (final file in files) {
        final stat = file.statSync();
        final type = stat.type;
        final fileName = file.path.split('/').last;
        if (type == FileSystemEntityType.directory) {
          return findKotlinActivityPath(Directory(file.path).listSync());
        } else if (type == FileSystemEntityType.file &&
            fileName == 'MainActivity.kt') {
          return file.path;
        }
      }
      return '';
    }

    final kotlinFilePath = findKotlinActivityPath(files);
    if (kotlinFilePath.isEmpty) {
      logger.w('''
        Kotlin Activity not found.
        The related file could not be found in folders 
        for that path:  ${paths.androidKotlin}
      ''');
      return;
    }

    await readWriteFile(
      changedToInfo: bundleId,
      fileNotExistsInfo: 'pubspec.yaml',
      filePath: kotlinFilePath,
      onContentLine: (contentLine) {
        if (contentLine.startsWith('package')) {
          return 'package $bundleId';
        }
        return contentLine;
      },
    );

    return null;
  }

  Future<void> changePubspec({required final String appName}) async {
    await readWriteFile(
      changedToInfo: appName,
      fileNotExistsInfo: 'pubspec.yaml',
      filePath: paths.pubspecYaml,
      onContentLine: (contentLine) {
        if (contentLine.startsWith('name:')) {
          return 'name: ${appName.snakeCase}';
        }
        return contentLine;
      },
    );
  }

  Future<String?> getLinuxBundleId() async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.linuxCMakeLists,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Linux BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.linuxCMakeLists}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('set(APPLICATION_ID')) {
        return (contentLineByLine[i] as String).split('"').elementAt(1).trim();
      }
    }
    return null;
  }

  Future<File?> changeLinuxBundleId({String? bundleId}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.linuxCMakeLists,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Linux BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.linuxCMakeLists}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('set(APPLICATION_ID')) {
        contentLineByLine[i] = 'set(APPLICATION_ID \"$bundleId\")';
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.linuxCMakeLists,
      content: contentLineByLine.join('\n'),
    );
    logger.i('Linux BundleIdentifier changed successfully to : $bundleId');
    return writtenFile;
  }

  Future<File?> changeIosAppName(String? appName) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosInfoPlist,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Ios AppName could not be changed because,
      The related file could not be found in that path:  ${paths.iosInfoPlist}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('<key>CFBundleName</key>')) {
        contentLineByLine[i + 1] = '\t<string>$appName</string>\r';
        break;
      }
    }

    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('<key>CFBundleDisplayName</key>')) {
        contentLineByLine[i + 1] = '\t<string>$appName</string>\r';
        break;
      }
    }

    var writtenFile = await writeFile(
      filePath: paths.iosInfoPlist,
      content: contentLineByLine.join('\n'),
    );
    logger.i('IOS appname changed successfully to : $appName');
    return writtenFile;
  }

  Future<File?> changeMacOsAppName(String? appName) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.macosAppInfoxproj,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      macOS AppName could not be changed because,
      The related file could not be found in that path:  ${paths.macosAppInfoxproj}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('PRODUCT_NAME')) {
        contentLineByLine[i] = 'PRODUCT_NAME = $appName;';
        break;
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.macosAppInfoxproj,
      content: contentLineByLine.join('\n'),
    );
    logger.i('MacOS appname changed successfully to : $appName');
    return writtenFile;
  }

  Future<File?> changeAndroidAppName(String? appName) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.androidManifest,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Android AppName could not be changed because,
      The related file could not be found in that path:  ${paths.androidManifest}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('android:label=')) {
        contentLineByLine[i] = '        android:label=\"$appName\"';
        break;
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.androidManifest,
      content: contentLineByLine.join('\n'),
    );
    logger.i('Android appname changed successfully to : $appName');
    return writtenFile;
  }

  Future<bool> changeLinuxCppName(String? appName, String oldAppName) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.linuxAppCpp,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Linux AppName could not be changed because,
      The related file could not be found in that path:  ${paths.linuxAppCpp}
      ''');
      return false;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      contentLineByLine[i] =
          contentLineByLine[i].replaceAll(oldAppName, appName);
    }
    return true;
  }

  Future<File?> changeLinuxAppName(String? appName) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.linuxCMakeLists,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Linux AppName could not be changed because,
      The related file could not be found in that path:  ${paths.linuxCMakeLists}
      ''');
      return null;
    }
    String? oldAppName;
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].startsWith('set(BINARY_NAME')) {
        oldAppName = RegExp(r'set\(BINARY_NAME "(\w+)"\)')
            .firstMatch(contentLineByLine[i])
            ?.group(1);
        contentLineByLine[i] = 'set(BINARY_NAME \"$appName\")';
        break;
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.linuxCMakeLists,
      content: contentLineByLine.join('\n'),
    );
    if (oldAppName != null) {
      if (await changeLinuxCppName(appName, oldAppName) == false) {
        return null;
      }
    }
    logger.i('Linux appname changed successfully to : $appName');
    return writtenFile;
  }

  // ignore: missing_return
  Future<String?> getCurrentIosAppName() async {
    var contentLineByLine = (readFileAsLineByline(
      filePath: paths.iosInfoPlist,
    ));
    for (var i = 0; i < contentLineByLine.length; i++) {
      final contentLine = contentLineByLine[i] ?? '';
      if (contentLine.contains('<key>CFBundleName</key>')) {
        return (contentLineByLine[i + 1] as String).trim().substring(5, 5);
      }
    }
    return null;
  }

  Future<String?> getCurrentAndroidAppName() async {
    var contentLineByLine = (readFileAsLineByline(
      filePath: paths.androidManifest,
    ));
    for (var i = 0; i < contentLineByLine.length; i++) {
      final contentLine = contentLineByLine[i] ?? '';
      if (contentLine.contains('android:label')) {
        return (contentLineByLine[i] as String).split('"')[1];
      }
    }
    return null;
  }

  bool checkFileExists(List? fileContent) {
    return fileContent == null || fileContent.isEmpty;
  }

  Future<String?> getWebAppName() async {
    return null;
  }

  Future<File?> changeWebAppName(String? appName) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.windowsApp,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Windows Appname could not be changed because,
      The related file could not be found in that path:  ${paths.windowsApp}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('<title>') &&
          contentLineByLine[i].contains('</title>')) {
        contentLineByLine[i] = '  <title>$appName</title>';
        break;
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.windowsApp,
      content: contentLineByLine.join('\n'),
    );
    logger.i('Windows appname changed successfully to : $appName');
    return writtenFile;
  }

  Future<String?> getWindowsAppName() async {
    return null;
  }

  Future<String?> changeWindowsAppName(String? appName) async {
    return null;
  }
}
