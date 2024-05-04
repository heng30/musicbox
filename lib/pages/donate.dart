import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _buildTabItems(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = min(size.height * 0.7, min(500.0, size.width * 0.7));

    return [
      Center(
        child: Image.asset(
          CImages.wechatPay,
          width: width,
          height: width,
          fit: BoxFit.cover,
        ),
      ),
      Center(
        child: Image.asset(
          CImages.metamaskPay,
          width: width,
          height: width,
          fit: BoxFit.cover,
        ),
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: CTheme.padding * 2),
        child: Column(
          children: [
            TabBar(
              dividerColor: Colors.transparent,
              controller: _tabController,
              indicatorColor: CTheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        CIcons.wechat,
                        width: CTheme.iconSize,
                        height: CTheme.iconSize,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyMedium?.color ??
                              CTheme.inversePrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: CTheme.padding * 2),
                      Text(
                        "微信支付".tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        CIcons.metamask,
                        width: CTheme.iconSize,
                        height: CTheme.iconSize,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyMedium?.color ??
                              CTheme.inversePrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: CTheme.padding * 2),
                      Text(
                        "加密支付".tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                children: _buildTabItems(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CTheme.background,
        appBar: AppBar(
          centerTitle: true,
          title: Text("捐 赠".tr),
          backgroundColor: CTheme.background,
        ),
        body: _buildBody(context),
      ),
    );
  }
}
