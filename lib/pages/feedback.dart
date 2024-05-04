import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

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
          title: Text("反 馈".tr),
          backgroundColor: CTheme.background,
        ),
        body: _buildBody(context),
      ),
    );
  }
}
