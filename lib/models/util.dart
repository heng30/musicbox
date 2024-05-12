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

String formattedTime(int seconds) {
  int hours = (seconds / 3600).truncate();
  int minutes = ((seconds % 3600) / 60).truncate();
  int remainingSeconds = seconds % 60;

  if (hours > 0) {
    return '$hours:$minutes:$remainingSeconds';
  } else if (minutes > 0) {
    return '$minutes:$remainingSeconds';
  } else {
    return '$remainingSeconds';
  }
}
