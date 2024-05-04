import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../models/about_controller.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget _buildBody(BuildContext context) {
    final aboutController = Get.find<AboutController>();
    final size = MediaQuery.of(context).size;
    final iconSize = min(min(100.0, size.width * 0.5), size.height * 0.5);

    return Padding(
      padding: EdgeInsets.only(
        top: CTheme.padding * 5,
        left: CTheme.padding * 2,
        right: CTheme.padding * 2,
        bottom: CTheme.padding * 2,
      ),
      child: Container(
        alignment: Alignment.center,
        color: CTheme.background,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Column(
            children: [
              Text(
                "${aboutController.packageInfo.appName} v${aboutController.packageInfo.version}",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: CTheme.padding * 5),
              SizedBox(
                width: min(size.width * 0.8, 500),
                child: Text(
                  aboutController.detail,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: CTheme.padding * 5),
              Image.asset(
                aboutController.logo,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("关 于".tr),
          backgroundColor: CTheme.background,
        ),
        body: _buildBody(context),
      ),
    );
  }
}
