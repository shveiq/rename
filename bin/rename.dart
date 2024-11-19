import 'package:args/args.dart';
import 'package:rename/rename.dart' as rename;

const android = 'android';
const macOS = 'macOS';
const ios = 'ios';
const linux = 'linux';
const web = 'web';
const pubspec = 'pubspec';

const target = 'target';
const appname = 'appname';
const bundleId = 'bundleId';
const appVersion = 'appversion';
const appBuild = 'appbuild';
const appProvisioningProfile = 'appProvisioningProfile';
const firebaseGoogleAppId = 'firebaseGoogleAppId';
const sfxPushNameId = 'sfxPushNameId';
const launcherIcon = 'launcherIcon';
const help = 'help';

final argParser = ArgParser()
  ..addMultiOption(target,
      abbr: 't',
      allowed: [android, macOS, ios, linux, web],
      help: 'Set which platforms to target.')
  ..addOption(appname, abbr: 'a', help: 'Sets the name of the app.')
  ..addOption(bundleId, abbr: 'b', help: 'Sets the bundle id.')
  ..addOption(appVersion, abbr: 'v', help: "Sets app's version.")
  ..addOption(appBuild, abbr: 'r', help: "Set app's revision.")
  ..addOption(appProvisioningProfile, abbr: 'f', help: "Set app's provisioning profile.")
  ..addOption(firebaseGoogleAppId, abbr: 'g', help: "Set google app id for firebase id.")
  ..addOption(sfxPushNameId, abbr: 's', help: "Set sfx push name.")
  ..addFlag(
    pubspec,
    abbr: 'p',
    help: 'Sets the name of the app in the pubspec.yaml file.',
    negatable: false,
  )
  ..addFlag(help, abbr: 'h', help: 'Shows help.', negatable: false);

void main(List<String> arguments) async {
  try {
    final results = argParser.parse(arguments);
    if (results[help] || results.arguments.isEmpty) {
      print(argParser.usage);
      return;
    }

    final targets = results['target'];
    final platforms = <rename.Platform>{
      if (targets.contains(macOS)) rename.Platform.macOS,
      if (targets.contains(android)) rename.Platform.android,
      if (targets.contains(ios)) rename.Platform.ios,
      if (targets.contains(linux)) rename.Platform.linux,
      if (targets.contains(web)) rename.Platform.web,
    };

    if (results[appname] != null) {
      await rename.changeAppName(results[appname], platforms);
      if (results[pubspec] == true) {
        await rename.changePubspec(results[appname]);
      }
    }
    if (results[bundleId] != null) {
      await rename.changeBundleId(results[bundleId], platforms);
    }
    if (results[appVersion] != null) {
      await rename.changeApplicationVersion(results[appVersion], platforms);
    }
    if (results[appBuild] != null) {
      await rename.changeApplicationBuild(results[appBuild], platforms);
    }
    if (results[appProvisioningProfile] != null) {
      await rename.changeProvisioningProfile(results[appProvisioningProfile], platforms);
    }
    if (results[firebaseGoogleAppId] != null) {
      await rename.changeFirebaseGoogleAppId(results[firebaseGoogleAppId], platforms);
    }
    if (results[sfxPushNameId] != null) {
      await rename.changeSfxPushNameId(results[sfxPushNameId], platforms);
    }
  } on FormatException catch (e) {
    print(e.message);
    print('');
    print(argParser.usage);
  }
}
