import 'dart:io' show Platform;

bool isDesktopPlatform() {
  return Platform.isMacOS ||
      Platform.isLinux ||
      Platform.isWindows ||
      Platform.isFuchsia;
}

bool isSqfliteSupportPlatform() {
  return Platform.isIOS || Platform.isAndroid;
}

bool isRustSqliteSupportPlatform() {
  return Platform.isLinux ||
      Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isFuchsia;
}
