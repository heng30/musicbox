import 'dart:math';

class Albums {
  static const String noneAsset = "assets/images/none.png";

  static const List<String> albumsAsset = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
    "assets/images/4.png",
    "assets/images/5.png",
    "assets/images/6.png",
    "assets/images/7.png",
    "assets/images/8.png",
    "assets/images/9.png",
    "assets/images/10.png",
  ];

  static String random() {
    int index = Random().nextInt(albumsAsset.length);
    return albumsAsset[index];
  }
}
