import 'dart:math';

class Albums {
  static const String noneAsset = "assets/images/album_none.png";

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
    int index = Random().nextInt(albumsAsset.length);
    return albumsAsset[index];
  }
}
