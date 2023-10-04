import 'package:rename/file_repository.dart';

/// You should call this function in your flutter project root directory
///
FileRepository fileRepository = FileRepository();

enum Platform {
  android,
  ios,
  linux,
  macOS,
  windows,
  web,
}

Future changeAppName(String? appName, Iterable<Platform> platforms) async {
  if (platforms.isEmpty || platforms.contains(Platform.ios)) {
    await fileRepository.changeIosAppName(appName);
  }
  if (platforms.isEmpty || platforms.contains(Platform.macOS)) {
    await fileRepository.changeMacOsAppName(appName);
  }
  if (platforms.isEmpty || platforms.contains(Platform.android)) {
    await fileRepository.changeAndroidAppName(appName);
  }
  if (platforms.isEmpty || platforms.contains(Platform.linux)) {
    await fileRepository.changeLinuxAppName(appName);
  }
  if (platforms.isEmpty || platforms.contains(Platform.web)) {
    await fileRepository.changeWebAppName(appName);
  }
  if (platforms.isEmpty || platforms.contains(Platform.windows)) {
    await fileRepository.changeWindowsAppName(appName);
  }
}

Future<void> changePubspec(final String appName) async {
  await fileRepository.changePubspec(appName: appName);
}

Future changeBundleId(String? bundleId, Iterable<Platform> platforms) async {
  if (platforms.isEmpty || platforms.contains(Platform.ios)) {
    await fileRepository.changeIosBundleId(bundleId: bundleId);
  }
  if (platforms.isEmpty || platforms.contains(Platform.macOS)) {
    await fileRepository.changeMacOsBundleId(bundleId: bundleId);
  }
  if (platforms.isEmpty || platforms.contains(Platform.android)) {
    await fileRepository.changeAndroidBundleId(bundleId: bundleId);
  }
  if (platforms.isEmpty || platforms.contains(Platform.linux)) {
    await fileRepository.changeLinuxBundleId(bundleId: bundleId);
  }
}

Future<void> changeApplicationVersion(String? appVersion, Iterable<Platform> platforms) async {
  if (platforms.isEmpty || platforms.contains(Platform.ios)) {
    await fileRepository.changeIosApplicationVersion(appVersion: appVersion);
  }
  if (platforms.isEmpty || platforms.contains(Platform.macOS)) {
    await fileRepository.changeMacOsApplicationVersion(appVersion: appVersion);
  }
  if (platforms.isEmpty || platforms.contains(Platform.android)) {
    await fileRepository.changeAndroidApplicationVersion(appVersion: appVersion);
  }
}

Future<void> changeApplicationBuild(String? appBuild, Iterable<Platform> platforms) async {
  if (platforms.isEmpty || platforms.contains(Platform.ios)) {
    await fileRepository.changeIosApplicationBuild(appBuild: appBuild);
  }
  if (platforms.isEmpty || platforms.contains(Platform.macOS)) {
    await fileRepository.changeMacOsApplicationBuild(appBuild: appBuild);
  }
  if (platforms.isEmpty || platforms.contains(Platform.android)) {
    await fileRepository.changeAndroidApplicationBuild(appBuild: appBuild);
  }
}

Future<void> changeProvisioningProfile(String? appProvisioningProfile, Iterable<Platform> platforms) async {
  if (platforms.isEmpty || platforms.contains(Platform.ios)) {
    await fileRepository.changeIosProvisioningProfile(appProvisioningProfile: appProvisioningProfile);
  }
  if (platforms.isEmpty || platforms.contains(Platform.macOS)) {
    await fileRepository.changeMacOsProvisioningProfile(appProvisioningProfile: appProvisioningProfile);
  }
  if (platforms.isEmpty || platforms.contains(Platform.android)) {
    await fileRepository.changeAndroidProvisioningProfile(appProvisioningProfile: appProvisioningProfile);
  }
}

Future<void> changeFirebaseGoogleAppId(String? firebaseGoogleAppId, Iterable<Platform> platforms) async {
  if (platforms.isEmpty || platforms.contains(Platform.ios)) {
    await fileRepository.changeIosFirebaseGoogleAppId(firebaseGoogleAppId: firebaseGoogleAppId);
  }
  if (platforms.isEmpty || platforms.contains(Platform.macOS)) {
    await fileRepository.changeMacOsFirebaseGoogleAppId(firebaseGoogleAppId: firebaseGoogleAppId);
  }
  if (platforms.isEmpty || platforms.contains(Platform.android)) {
    await fileRepository.changeAndroidFirebaseGoogleAppId(firebaseGoogleAppId: firebaseGoogleAppId);
  }
}

Future<String?> getIosAppName() async {
  return fileRepository.getCurrentIosAppName();
}

Future<String?> getAndroidAppName() async {
  return fileRepository.getCurrentAndroidAppName();
}
