import 'dart:math';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/textedit.dart';
import '../models/setting_controller.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();
  final _currentTextCounts = 0.obs;
  final _feedbackUrl = "https://heng30.xyz/apisvr/musicbox/feedback";
  bool _isSending = false;

  static const int maxFeedbackLen = 2048;

  void _onTextChange(String text) {
    if (text.length > maxFeedbackLen) {
      Get.snackbar("提 示".tr, "输入长度超过$maxFeedbackLen个字, 多余的字会被丢弃".tr);
    }

    _currentTextCounts.value = text.length;
  }

  void _sendFeedback() async {
    Dio dio = Dio();
    final settingController = Get.find<SettingController>();

    var feedback = _textController.text.trim();
    feedback = feedback.substring(0, min(maxFeedbackLen, feedback.length));

    if (feedback.isEmpty) {
      Get.snackbar("提 示".tr, "请输入反馈信息".tr);
      return;
    }

    _textFocusNode.unfocus();

    if (_isSending) {
      Get.snackbar("提 示".tr, "请不要重复发送".tr);
      return;
    }

    Get.snackbar("提 示".tr, "正在发送...".tr);

    _isSending = true;

    Map<String, dynamic> data = {
      "appid": settingController.appid,
      "type": "feedback",
      "data": feedback,
    };

    try {
      final response = await dio.post(
        _feedbackUrl,
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        Get.snackbar("提 示".tr, "发送成功".tr);
      } else {
        Get.snackbar(
            "发送失败".tr, "${response.statusCode}: ${response.statusMessage}");
      }
    } catch (e) {
      Get.snackbar("发送失败".tr, e.toString());
      Logger().d(e.toString());
    } finally {
      _isSending = false;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CTheme.padding * 2),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Column(
          children: [
            Expanded(
              child: TextEdit(
                controller: _textController,
                focusNode: _textFocusNode,
                hintText: "请输入内容".tr,
                onChanged: _onTextChange,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(CTheme.padding * 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text("${_currentTextCounts.value}/$maxFeedbackLen"),
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
                      const SizedBox(width: CTheme.padding * 5),
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
