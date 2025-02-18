import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:recase/recase.dart';

class Paths {
  Paths({
    required this.androidAppBuildGradle,
    required this.androidAppBuildGradleKts,
    required this.androidDebugManifest,
    required this.androidManifest,
    required this.androidProfileManifest,
    required this.androidKotlin,
    required this.iosInfoPlist,
    required this.iosInfoReleasePlist,
    required this.iosProjectPbxproj,
    required this.iosGeneratedConfig,
    required this.launcherIcon,
    required this.linuxAppCpp,
    required this.linuxCMakeLists,
    required this.macosAppInfoxproj,
    required this.pubspecYaml,
    required this.webApp,
    required this.windowsApp,
    required this.firebaseConfigurationPlist,
  });
  factory Paths.getInstance() {
    if (Platform.isMacOS || Platform.isLinux) {
      return Paths(
        pubspecYaml: 'pubspec.yaml',
        iosInfoPlist: 'ios/Runner/Info.plist',
        iosInfoReleasePlist: 'ios/Runner/Info-Release.plist',
        iosProjectPbxproj: 'ios/Runner.xcodeproj/project.pbxproj',
        iosGeneratedConfig: 'ios/Flutter/Generated.xcconfig',
        macosAppInfoxproj: 'macos/Runner/Configs/AppInfo.xcconfig',
        launcherIcon: 'assets/images/launcherIcon.png',
        linuxCMakeLists: 'linux/CMakeLists.txt',
        linuxAppCpp: 'linux/my_application.cc',
        windowsApp: 'web/index.html',
        androidManifest: 'android/app/src/main/AndroidManifest.xml',
        androidAppBuildGradle: 'android/app/build.gradle',
        androidAppBuildGradleKts: 'android/app/build.gradle.kts',
        androidDebugManifest: 'android/app/src/debug/AndroidManifest.xml',
        androidProfileManifest: 'android/app/src/profile/AndroidManifest.xml',
        androidKotlin: 'android/app/src/main/kotlin',
        webApp: 'linux/my_application.cc',
        firebaseConfigurationPlist: 'ios/Runner/GoogleService-Info.plist',
      );
    } else {
      return Paths(
        pubspecYaml: '.\\pubspec.yaml',
        iosInfoPlist: '.\\ios\\Runner\\Info.plist',
        iosInfoReleasePlist: '.\\ios\\Runner\\Info-Release.plist',
        iosProjectPbxproj: '.\\ios\\Runner.xcodeproj\\project.pbxproj',
        iosGeneratedConfig: '.\\ios\\Flutter\\Generated.xcconfig',
        macosAppInfoxproj: '.\\macos\\Runner\\Configs\\AppInfo.xcconfig',
        launcherIcon: '.\\assets\\images\\launcherIcon.png',
        linuxCMakeLists: '.\\linux\\CMakeLists.txt',
        linuxAppCpp: '.\\linux\\my_application.cc',
        windowsApp: '.\\web\\index.html',
        androidManifest: '.\\android\\app\\src\\main\\AndroidManifest.xml',
        androidAppBuildGradle: '.\\android\\app\\build.gradle',
        androidAppBuildGradleKts: '.\\android\\app\\build.gradle.kts',
        androidDebugManifest: '.\\android\\app\\src\\debug\\AndroidManifest.xml',
        androidProfileManifest: '.\\android\\app\\src\\profile\\AndroidManifest.xml',
        androidKotlin: '.\\android\\app\\src\\main\\kotlin',
        webApp: '.\\linux\\my_application.cc',
        firebaseConfigurationPlist: '.\\ios\\Runner\\GoogleService-Info.plist',
      );
    }
  }
  final String androidManifest;
  final String androidDebugManifest;
  final String androidProfileManifest;
  final String androidAppBuildGradle;
  final String androidAppBuildGradleKts;
  final String androidKotlin;
  final String pubspecYaml;
  final String iosInfoPlist;
  final String iosInfoReleasePlist;
  final String iosProjectPbxproj;
  final String iosGeneratedConfig;
  final String macosAppInfoxproj;
  final String launcherIcon;
  final String linuxCMakeLists;
  final String linuxAppCpp;
  final String webApp;
  final String windowsApp;
  final String firebaseConfigurationPlist;
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

  Future<void> readWriteTwoFiles({
    required String filePathFirst,
    required String filePathSecond,
    required String Function(String content) onContentLine,
    required String fileNotExistsInfo,
    required String changedToInfo,
    bool throwIfNotExists = true,
  }) async {
    String? currentFilePath = null;
    var contentLineByLine = readFileAsLineByline(
      filePath: filePathFirst,
    );
    if (checkFileExists(contentLineByLine)) {
      contentLineByLine = readFileAsLineByline(
        filePath: filePathSecond,
      );
      currentFilePath = filePathSecond;
    } else {
      currentFilePath = filePathFirst;
    }
    if (throwIfNotExists && checkFileExists(contentLineByLine)) {
      logger.w('''
      $fileNotExistsInfo could not be changed because,
      The related file could not be found in that path:  $filePathFirst or $filePathSecond
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      final contentLine = contentLineByLine[i] ?? '';
      contentLineByLine[i] = onContentLine(contentLine);
    }
    await writeFile(
      filePath: currentFilePath!,
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
    logger.i('In file : ${paths.iosProjectPbxproj}');
    logger.i('IOS BundleIdentifier changed successfully to : $bundleId');
    return writtenFile;
  }

  Future<File?> changeIosFirebaseBundleId({String? bundleId}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosProjectPbxproj,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Ios BundleId in Firebase Configuration could not be changed because,
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
    logger.i('In file : ${paths.iosProjectPbxproj}');
    logger.i('IOS BundleIdentifier in Firebase Configuration changed successfully to : $bundleId');
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
    logger.i('In file : ${paths.macosAppInfoxproj}');
    logger.i('MacOS BundleIdentifier changed successfully to : $bundleId');
    return writtenFile;
  }

  Future<String?> getAndroidBundleId() async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.androidAppBuildGradle,
    );
    if (checkFileExists(contentLineByLine)) {
      contentLineByLine = readFileAsLineByline(
        filePath: paths.androidAppBuildGradleKts,
      );
    }
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Android BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.androidAppBuildGradle} or ${paths.androidAppBuildGradleKts}
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

    await readWriteTwoFiles(
      changedToInfo: bundleId,
      fileNotExistsInfo: 'Android Gradle BundleId',
      filePathFirst: paths.androidAppBuildGradle,
      filePathSecond: paths.androidAppBuildGradleKts,
      onContentLine: (contentLine) {
        if (contentLine.contains('applicationId')) {
          if (contentLine.contains(';')) {
            return '        applicationId \"$bundleId\"';
          } else {
            return '        applicationId = \"$bundleId\"';
          }
        }
        return contentLine;
      },
    );

    await readWriteFile(
      changedToInfo: bundleId,
      fileNotExistsInfo: 'Android Gradle Namespace',
      filePath: paths.androidAppBuildGradleKts,
      onContentLine: (contentLine) {
        if (contentLine.contains('namespace')) {
          return '        namespace = \"$bundleId\"';
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
        } else if (type == FileSystemEntityType.file && fileName == 'MainActivity.kt') {
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

  Future<File?> changeIosApplicationVersion({String? appVersion}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosGeneratedConfig,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Ios BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.iosGeneratedConfig}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('FLUTTER_BUILD_NAME')) {
        contentLineByLine[i] = 'FLUTTER_BUILD_NAME=$appVersion';
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.iosGeneratedConfig,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.iosGeneratedConfig}');
    logger.i('IOS Application Version changed successfully to : $appVersion');
    return writtenFile;
  }

  Future<void> changeMacOsApplicationVersion({String? appVersion}) async {
    return null;
  }

  Future<void> changeAndroidApplicationVersion({String? appVersion}) async {
    return null;
  }

  Future<File?> changeIosApplicationBuild({String? appBuild}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosGeneratedConfig,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Ios BundleId could not be changed because,
      The related file could not be found in that path:  ${paths.iosGeneratedConfig}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('FLUTTER_BUILD_NUMBER')) {
        contentLineByLine[i] = 'FLUTTER_BUILD_NUMBER=$appBuild';
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.iosGeneratedConfig,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.iosGeneratedConfig}');
    logger.i('IOS Application Revision changed successfully to : $appBuild');
    return writtenFile;
  }

  Future<void> changeMacOsApplicationBuild({String? appBuild}) async {
    return null;
  }

  Future<void> changeAndroidApplicationBuild({String? appBuild}) async {
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
    logger.i('In file : ${paths.linuxCMakeLists}');
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
    logger.i('In file : ${paths.iosInfoPlist}');
    logger.i('IOS appname changed successfully to : $appName');
    return writtenFile;
  }

  Future<File?> changeIosAppNameInRelease(String? appName) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosInfoReleasePlist,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      Ios AppName in Release could not be changed because,
      The related file could not be found in that path:  ${paths.iosInfoReleasePlist}
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
      filePath: paths.iosInfoReleasePlist,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.iosInfoReleasePlist}');
    logger.i('IOS appname in Release changed successfully to : $appName');
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
    logger.i('In file : ${paths.macosAppInfoxproj}');
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
    logger.i('In file : ${paths.androidManifest}');
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
      contentLineByLine[i] = contentLineByLine[i].replaceAll(oldAppName, appName);
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
        oldAppName = RegExp(r'set\(BINARY_NAME "(\w+)"\)').firstMatch(contentLineByLine[i])?.group(1);
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
    logger.i('In file : ${paths.linuxCMakeLists}');
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
      if (contentLineByLine[i].contains('<title>') && contentLineByLine[i].contains('</title>')) {
        contentLineByLine[i] = '  <title>$appName</title>';
        break;
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.windowsApp,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.windowsApp}');
    logger.i('Windows appname changed successfully to : $appName');
    return writtenFile;
  }

  Future<String?> getWindowsAppName() async {
    return null;
  }

  Future<String?> changeWindowsAppName(String? appName) async {
    return null;
  }

  Future<File?> changeIosProvisioningProfile({String? appProvisioningProfile}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosProjectPbxproj,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      IOS Provisioning Profile could not be changed because,
      The related file could not be found in that path:  ${paths.iosProjectPbxproj}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('PROVISIONING_PROFILE_SPECIFIER')) {
        contentLineByLine[i] = '				"PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]" = "$appProvisioningProfile";';
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.iosProjectPbxproj,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.iosProjectPbxproj}');
    logger.i('IOS Provisioning Profile changed successfully to : $appProvisioningProfile');
    return writtenFile;
  }

  Future<File?> changeMacOsProvisioningProfile({String? appProvisioningProfile}) async {
    return null;
  }

  Future<File?> changeAndroidProvisioningProfile({String? appProvisioningProfile}) async {
    return null;
  }

  Future<File?> changeIosFirebaseGoogleAppId({String? firebaseGoogleAppId}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.iosProjectPbxproj,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      IOS Firebase Google App ID could not be changed because,
      The related file could not be found in that path:  ${paths.iosProjectPbxproj}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('FIREBASE_GOOGLE_APP_ID')) {
        contentLineByLine[i] = '				FIREBASE_GOOGLE_APP_ID = "$firebaseGoogleAppId";';
      }
    }
    var writtenFile = await writeFile(
      filePath: paths.iosProjectPbxproj,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.iosProjectPbxproj}');
    logger.i('IOS Firebase Google App ID changed successfully to : $firebaseGoogleAppId');
    return writtenFile;
  }

  Future<File?> changeMacOsFirebaseGoogleAppId({String? firebaseGoogleAppId}) async {
    return null;
  }

  Future<File?> changeAndroidFirebaseGoogleAppId({String? firebaseGoogleAppId}) async {
    return null;
  }

  Future<File?> changeIosFirebaseBundleIdInConfig({String? bundleId}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.firebaseConfigurationPlist,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      IOS BundleId in Firebase Config could not be changed because,
      The related file could not be found in that path:  ${paths.firebaseConfigurationPlist}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('<key>BUNDLE_ID</key>')) {
        contentLineByLine[i + 1] = '\t<string>$bundleId</string>\r';
        break;
      }
    }

    var writtenFile = await writeFile(
      filePath: paths.firebaseConfigurationPlist,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.firebaseConfigurationPlist}');
    logger.i('IOS BundleId in Firebase Config changed successfully to : $bundleId');
    return writtenFile;
  }

  Future<File?> changeMacOsFirebaseBundleIdInConfig({String? bundleId}) async {
    return null;
  }

  Future<File?> changeAndroidFirebaseBundleIdInConfig({String? bundleId}) async {
    return null;
  }

  Future<File?> changeIosFirebaseGoogleAppIdInConfig({String? firebaseGoogleAppId}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.firebaseConfigurationPlist,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      IOS Google Api Id in Firebase Config could not be changed because,
      The related file could not be found in that path:  ${paths.firebaseConfigurationPlist}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('<key>GOOGLE_APP_ID</key>')) {
        contentLineByLine[i + 1] = '\t<string>$firebaseGoogleAppId</string>\r';
        break;
      }
    }

    var writtenFile = await writeFile(
      filePath: paths.firebaseConfigurationPlist,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.firebaseConfigurationPlist}');
    logger.i('IOS Google Api Id in Firebase Config changed successfully to : $firebaseGoogleAppId');
    return writtenFile;
  }

  Future<File?> changeMacOsFirebaseGoogleAppIdInConfig({String? firebaseGoogleAppId}) async {
    return null;
  }

  Future<File?> changeAndroidFirebaseGoogleAppIdInConfig({String? firebaseGoogleAppId}) async {
    return null;
  }

  Future<File?> changeIosFirebaseStorageBucket({String? firebaseStorageBucket}) async {
    List? contentLineByLine = readFileAsLineByline(
      filePath: paths.firebaseConfigurationPlist,
    );
    if (checkFileExists(contentLineByLine)) {
      logger.w('''
      IOS Google Api Id in Firebase Config could not be changed because,
      The related file could not be found in that path:  ${paths.firebaseConfigurationPlist}
      ''');
      return null;
    }
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('<key>STORAGE_BUCKET</key>')) {
        contentLineByLine[i + 1] = '\t<string>$firebaseStorageBucket</string>\r';
        break;
      }
    }

    var writtenFile = await writeFile(
      filePath: paths.firebaseConfigurationPlist,
      content: contentLineByLine.join('\n'),
    );
    logger.i('In file : ${paths.firebaseConfigurationPlist}');
    logger.i('IOS Google Api Id in Firebase Config changed successfully to : $firebaseStorageBucket');
    return writtenFile;
  }

  Future<void> changeMacOsFirebaseStorageBucket({String? firebaseStorageBucket}) async {
    return;
  }

  Future<void> changeAndroidFirebaseStorageBucket({String? firebaseStorageBucket}) async {
    return;
  }

  Future<void> changeIOSSfxPushNameId(String sfxPushNameId) async {
    return;
  }

  Future<void> changeMacOSSfxPushNameId(String sfxPushNameId) async {
    return;
  }

  Future<void> changeAndroidSfxPushNameId(String sfxPushNameId) async {
    await readWriteFile(
      changedToInfo: sfxPushNameId,
      fileNotExistsInfo: 'Android Manifest SfxPushNameId',
      filePath: paths.androidManifest,
      onContentLine: (contentLine) {
        if (contentLine.contains('<action android:name="pl.softax.intent.RECEIVE_INTENT_HCE_BY_SOFTAX')) {
          return '                <action android:name="pl.softax.intent.RECEIVE_INTENT_HCE_BY_SOFTAX.${sfxPushNameId}" />';
        }
        return contentLine;
      },
    );
  }
}
