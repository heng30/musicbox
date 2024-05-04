import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/textedit.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _textController = TextEditingController();
  final _currentTextCounts = 0.obs;

  void _onTextChange(String text) {
    if (text.length > 2048) {
      Get.snackbar("提 示".tr, "输入长度超过2048个字, 多余的字会被丢弃".tr);
    }

    _currentTextCounts.value = text.length;
  }

  // TODO
  void _sendFeedback() {
    final feedback = _textController.text;
    print(feedback);
    print(Get.deviceLocale);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(CTheme.padding * 2),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Column(
          children: [
            Expanded(
              child: TextEdit(
                controller: _textController,
                hintText: "请输入内容".tr,
                onChanged: _onTextChange,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(CTheme.padding * 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text("${_currentTextCounts.value}/2048"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.cancel,
                          color: CTheme.inversePrimary,
                        ),
                        label: Text(
                          "取消".tr,
                          style: TextStyle(color: CTheme.inversePrimary),
                        ),
                      ),
                      SizedBox(width: CTheme.padding * 5),
                      ElevatedButton.icon(
                        onPressed: _sendFeedback,
                        icon: Icon(
                          IconFonts.send,
                          color: CTheme.inversePrimary,
                        ),
                        label: Text(
                          "发送".tr,
                          style: TextStyle(color: CTheme.inversePrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          title: Text("反 馈".tr),
          backgroundColor: CTheme.background,
        ),
        body: _buildBody(context),
      ),
    );
  }
}
