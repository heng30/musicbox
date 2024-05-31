<div style="display: flex, margin: 8px">
    <img src="./screenshot/1.png" width="100"/>
    <img src="./screenshot/2.png" width="100"/>
    <img src="./screenshot/3.png" width="100"/>
    <img src="./screenshot/4.png" width="100"/>
    <img src="./screenshot/5.png" width="100"/>
    <img src="./screenshot/6.png" width="100"/>
    <img src="./screenshot/7.png" width="100"/>
    <img src="./screenshot/8.png" width="100"/>
    <img src="./screenshot/9.png" width="100"/>
    <img src="./screenshot/10.png" width="100"/>
</div>

[English Document](./README.md)
[演示视频](https://www.bilibili.com/video/BV1rT421U76C/?vd_source=da23da82658adda9cbdfd045a9e6daf7#reply1704805075)

#### 简介
这是一个专门为安卓开发的音乐播放器。不过你也可以编译到Linux平台。如果你想编译到Macos, ios 和 Windows 平台，可以尝试以下，但不保证能够编译成功。最后，这是一个基于Flutter 和 Rust的软件。

#### 功能
- [x] 播放本地音乐
- [x] 管理播放列表
- [x] 搜索和下载youtube的视频和bilibili音频文件
- [x] 搜索，预览和下载歌词
- [x] 调整歌词播放速度
- [x] 设置：白天/黑暗主题切换，中英文语言切换，支持http和socks5代理下载音乐
- [x] 本地备份/恢复数据库和配置

#### 如何构建？
- 安装 `Rust` 和 `Cargo`
- 安装 `Flutter` 和 `FVM`(可选)
- 安装 Android `sdk`, `ndk`, `jdk`和设置环境变量
- 运行 `make` 去构建安卓发布版本
- 运行 `make run` 运行桌面版本程序
- 参考 [Makefile](./Makefile) 了解更多信息

#### 开发环境
- Linux: 6.7.2-arch1-2 #1 SMP PREEMPT_DYNAMIC Wed, 31 Jan 2024 09:22:15 +0000 x86_64 GNU/Linux
- Flutter version: 3.22.0
- Rust version: 1.77.1

#### 参考
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [svg to png](https://cloudconvert.com/svg-to-png)
- [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
- [freepik.com](https://www.freepik.com/)
- [flutter-action](https://github.com/marketplace/actions/flutter-action)
- [supported-formats](https://developer.android.com/media/platform/supported-formats)
- [music_api](https://github.com/yhsj0919/music_api)
