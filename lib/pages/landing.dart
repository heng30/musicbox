import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late PageController _pageController;
  final _currentStep = 0.obs;
  final duration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pageController.addListener(() {
      if (!_pageController.hasClients) {
        return;
      }

      if (_pageController.page == 0.0) {
        _currentStep.value = 0;
      } else if (_pageController.page == 1.0) {
        _currentStep.value = 1;
      } else if (_pageController.page == 2.0) {
        _currentStep.value = 2;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget buildStep(
    BuildContext context, {
    required String image,
    required String title,
    required String content,
  }) {
    final size = MediaQuery.of(context).size;
    final maxSize = min(500.0, min(size.width * 0.6, size.height * 0.6));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: CTheme.padding * 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
            width: maxSize,
          ),
          SizedBox(height: CTheme.margin * 5),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: CTheme.margin * 5),
          Text(
            content,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: CTheme.margin * 10),
          buildIndicator(context),
        ],
      ),
    );
  }

  Widget _indicator(BuildContext context, {required bool isActive}) {
    return AnimatedContainer(
      duration: duration,
      height: 4,
      width: isActive ? 20 : 8,
      margin: EdgeInsets.only(right: CTheme.margin * 1.5),
      decoration: BoxDecoration(
        color: CTheme.secondaryBrand,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget buildIndicator(BuildContext context) {
    List<Widget> items = [];
    for (int i = 0; i < 3; i++) {
      if (_currentStep.value == i) {
        items.add(_indicator(context, isActive: true));
      } else {
        items.add(_indicator(context, isActive: false));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }

  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          children: [
            buildStep(
              context,
              image: CImages.landingPlayer,
              title: "播放音乐".tr,
              content: "你可以播放本地音乐，创建播放列表。".tr,
            ),
            buildStep(
              context,
              image: CImages.landingDownload,
              title: "下载音乐".tr,
              content: "你可以下载Youtube 和 Bilibili 上的音乐，进行离线播放。".tr,
            ),
            buildStep(
              context,
              image: CImages.landingWelcome,
              title: "欢迎使用".tr,
              content: "享受你的音乐之旅".tr,
            ),
          ],
        ),
        Positioned(
          left: CTheme.margin * 5,
          right: CTheme.margin * 5,
          bottom: CTheme.margin * 5,
          child: Row(
            mainAxisAlignment: _currentStep.value == 0
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep.value != 0)
                TextButton(
                  onPressed: () {
                    _currentStep.value -= 1;
                    _pageController.previousPage(
                      duration: duration,
                      curve: Curves.linearToEaseOut,
                    );
                  },
                  child: Text("返回".tr),
                ),
              TextButton(
                onPressed: () {
                  if (_currentStep.value != 2) {
                    _currentStep.value += 1;
                    _pageController.nextPage(
                      duration: duration,
                      curve: Curves.linearToEaseOut,
                    );
                  } else {
                    Get.toNamed("/");
                  }
                },
                child: Obx(
                  () => Text(
                    _currentStep.value == 2 ? "完成".tr : "下一步".tr,
                    style: TextStyle(color: CTheme.secondaryBrand),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CTheme.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CTheme.background,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(
                top: CTheme.padding * 5,
                right: CTheme.padding * 5,
              ),
              child: TextButton(
                onPressed: () => Get.toNamed("/"),
                child: Text("跳过".tr),
              ),
            ),
          ],
        ),
        body: buildBody(context),
      ),
    );
  }
}
