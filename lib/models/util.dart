import 'dart:io' show Platform;

bool isDesktopPlatform() {
  return Platform.isMacOS ||
      Platform.isLinux ||
      Platform.isWindows ||
      Platform.isFuchsia;
}
