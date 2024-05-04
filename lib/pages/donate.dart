import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  Widget _buildBody(BuildContext context) {
    return Container(
      color: CTheme.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
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
