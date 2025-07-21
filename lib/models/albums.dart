import 'dart:math';

class Albums {
  static const String noneAsset = "assets/images/album_none.png";
  static const String bilibiliAsset = "assets/images/Bilibili.png";

  static int _currentIndex = 0;
  static int _previousRandomIndex = 0;
  static int _currentRandomIndex = 0;

  static const List<String> albumsAsset = [
    "assets/images/album_1.png",
    "assets/images/album_2.png",
    "assets/images/album_3.png",
    "assets/images/album_4.png",
    "assets/images/album_5.png",
    "assets/images/album_6.png",
    "assets/images/album_7.png",
    "assets/images/album_8.png",
    "assets/images/album_9.png",
    "assets/images/album_10.png",
  ];

  static String random() {
    _currentRandomIndex = Random().nextInt(albumsAsset.length);
    if (_currentRandomIndex == _previousRandomIndex) {
      _currentRandomIndex = (_currentRandomIndex + 1) % albumsAsset.length;
      return albumsAsset[_currentRandomIndex];
    }

    _previousRandomIndex = _currentRandomIndex;
    return albumsAsset[_currentRandomIndex];
  }

  static String next() {
    _currentIndex = (_currentIndex + 1) % albumsAsset.length;
    return albumsAsset[_currentIndex];
  }
}
