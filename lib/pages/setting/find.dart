import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../models/util.dart';
import '../../theme/theme.dart';
import '../../widgets/setting_switch.dart';
import '../../models/setting_controller.dart';

class SettingFindPage extends StatefulWidget {
  const SettingFindPage({super.key});

  @override
  State<SettingFindPage> createState() => _SettingFindPageState();
}

class _SettingFindPageState extends State<SettingFindPage> {
  final settingController = Get.find<SettingController>();

  late TextEditingController searchCountController;
  late FocusNode searchCountFocusNode;

  late TextEditingController minSecondLengthController;
  late FocusNode minSecondLengthFocusNode;

  late TextEditingController maxSecondLengthController;
  late FocusNode maxSecondLengthFocusNode;

  @override
  void initState() {
    super.initState();

    searchCountController = TextEditingController();
    searchCountFocusNode = FocusNode();
    searchCountController.text = settingController.find.searchCount.toString();

    minSecondLengthController = TextEditingController();
    minSecondLengthFocusNode = FocusNode();
    minSecondLengthController.text =
        settingController.find.minSecondLength.toString();

    maxSecondLengthController = TextEditingController();
    maxSecondLengthFocusNode = FocusNode();
    maxSecondLengthController.text =
        settingController.find.maxSecondLength.toString();
  }

  @override
  void dispose() {
    searchCountController.dispose();
    minSecondLengthController.dispose();
    maxSecondLengthController.dispose();

    super.dispose();
  }

  void saveSettings() {
    settingController.find.searchCount = int.parse(searchCountController.text);
    settingController.find.minSecondLength =
        int.parse(minSecondLengthController.text);
    settingController.find.maxSecondLength =
        int.parse(maxSecondLengthController.text);

    settingController.save();
  }

  Widget buildSearch(BuildContext context, FocusScopeNode focusScopeNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "搜索设置".tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: CTheme.margin * 4),
        TextField(
          controller: searchCountController,
          focusNode: searchCountFocusNode,
          onSubmitted: (_) =>
              focusScopeNode.requestFocus(minSecondLengthFocusNode),
          decoration: InputDecoration(
            labelText: "每次搜索数量".tr,
            hintText: "10",
            suffixIcon: IconButton(
              onPressed: () => searchCountController.clear(),
              icon: Icon(
                Icons.clear,
                size: CTheme.iconSize * 0.8,
                color: CTheme.primary,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ),
        const SizedBox(height: CTheme.margin * 5),
        TextField(
          controller: minSecondLengthController,
          focusNode: minSecondLengthFocusNode,
          onSubmitted: (_) =>
              focusScopeNode.requestFocus(maxSecondLengthFocusNode),
          decoration: InputDecoration(
            labelText: "时间下限".tr,
            hintText: "90",
            suffixIcon: IconButton(
              onPressed: () => minSecondLengthController.clear(),
              icon: Icon(
                Icons.clear,
                size: CTheme.iconSize * 0.8,
                color: CTheme.primary,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ),
        const SizedBox(height: CTheme.margin * 5),
        TextField(
          controller: maxSecondLengthController,
          focusNode: maxSecondLengthFocusNode,
          onSubmitted: (_) => focusScopeNode.requestFocus(searchCountFocusNode),
          decoration: InputDecoration(
            labelText: "时间上限".tr,
            hintText: "600",
            suffixIcon: IconButton(
              onPressed: () => maxSecondLengthController.clear(),
              icon: Icon(
                Icons.clear,
                size: CTheme.iconSize * 0.8,
                color: CTheme.primary,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ),
        const SizedBox(height: CTheme.padding * 5),
        SettingSwitch(
          margin: EdgeInsets.zero,
          title: settingController.find.enableYoutubeSearch
              ? '已启用Youtube搜索'.tr
              : '未启用Youtube搜索'.tr,
          isOn: settingController.find.enableYoutubeSearch,
          icon: Icons.smart_display,
          onChanged: (v) => settingController.find.enableYoutubeSearch = v,
        ),
        const SizedBox(height: CTheme.padding * 5),
        SettingSwitch(
          margin: EdgeInsets.zero,
          title: settingController.find.enableBilibiliSearch
              ? '已启用Bilibili搜索'.tr
              : '未启用Bilibili搜索'.tr,
          isOn: settingController.find.enableBilibiliSearch,
          icon: Icons.smart_display,
          onChanged: (v) => settingController.find.enableBilibiliSearch = v,
        ),
      ],
    );
  }

  Widget buildOthers(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: CTheme.margin * 5, width: double.infinity),
        if (isFFmpegKitSupportPlatform())
          SettingSwitch(
            margin: EdgeInsets.zero,
            title: settingController.find.enableVideoToAudio
                ? '已启用视频转音频'.tr
                : '未启用视频转音频'.tr,
            isOn: settingController.find.enableVideoToAudio,
            icon: Icons.transform,
            onChanged: (v) => settingController.find.enableVideoToAudio = v,
          ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    final FocusScopeNode focusScopeNode = FocusScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(CTheme.padding * 5),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          children: [
            buildSearch(context, focusScopeNode),
            buildOthers(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Obx(
        () => Scaffold(
          backgroundColor: CTheme.background,
          appBar: AppBar(
            title: Text("发 现".tr),
            centerTitle: true,
            backgroundColor: CTheme.background,
          ),
          body: buildBody(context),
        ),
      ),
      onPopInvoked: (didPop) {
        if (didPop) return;
        try {
          saveSettings();
          Get.back();
        } catch (e) {
          Get.snackbar("提 示".tr, "非法输入".tr);
          return;
        }
      },
    );
  }
}
