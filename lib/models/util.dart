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

  String m = minutes.toString().padLeft(2, '0');
  String s = remainingSeconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:$m:$s';
  } else if (minutes > 0) {
    return '$minutes:$s';
  } else {
    return '$remainingSeconds';
  }
}

String formattedNumber(int num) {
  String result = '';
  String input = num.toString();

  for (int i = input.length - 1, count = 0; i >= 0; i--) {
    result = input[i] + result;
    if (++count % 3 == 0 && i > 0) {
      result = ",$result";
    }
  }

  return result;
}
