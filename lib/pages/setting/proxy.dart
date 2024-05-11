import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../models/setting_controller.dart';

class SettingProxyPage extends StatefulWidget {
  const SettingProxyPage({super.key});

  @override
  State<SettingProxyPage> createState() => _SettingProxyPageState();
}

class _SettingProxyPageState extends State<SettingProxyPage> {
  final settingController = Get.find<SettingController>();

  late TextEditingController httpUrlController;
  late FocusNode httpUrlFocusNode;

  late TextEditingController httpPortController;
  late FocusNode httpPortFocusNode;

  late TextEditingController socks5UrlController;
  late FocusNode socks5UrlFocusNode;

  late TextEditingController socks5PortController;
  late FocusNode socks5PortFocusNode;

  @override
  void initState() {
    super.initState();

    httpUrlController = TextEditingController();
    httpUrlFocusNode = FocusNode();
    httpUrlController.text = settingController.proxy.httpUrl;

    httpPortController = TextEditingController();
    httpPortFocusNode = FocusNode();
    httpPortController.text = settingController.proxy.httpPort.toString();

    socks5UrlController = TextEditingController();
    socks5UrlFocusNode = FocusNode();
    socks5UrlController.text = settingController.proxy.socks5Url;

    socks5PortController = TextEditingController();
    socks5PortFocusNode = FocusNode();
    socks5PortController.text = settingController.proxy.socks5Port.toString();
  }

  @override
  void dispose() {
    httpUrlController.dispose();
    httpPortController.dispose();
    socks5UrlController.dispose();
    socks5PortController.dispose();

    super.dispose();
  }

  void saveSettings() {
    settingController.proxy.httpUrl = httpUrlController.text.trim();
    settingController.proxy.httpPort = int.parse(httpPortController.text);
    settingController.proxy.socks5Url = socks5UrlController.text.trim();
    settingController.proxy.socks5Port = int.parse(socks5PortController.text);

    settingController.save();
  }

  Widget buildHttp(
    BuildContext context,
    FocusScopeNode focusScopeNode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Http 代理".tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: CTheme.margin * 2),
        TextField(
          controller: httpUrlController,
          focusNode: httpUrlFocusNode,
          onSubmitted: (_) => focusScopeNode.requestFocus(httpPortFocusNode),
          decoration: InputDecoration(
            labelText: "URL",
            hintText: "127.0.0.1",
            suffixIcon: IconButton(
              onPressed: () => httpUrlController.clear(),
              icon: Icon(
                Icons.clear,
                size: CTheme.iconSize * 0.8,
                color: CTheme.primary,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: CTheme.margin * 5),
        TextField(
          controller: httpPortController,
          focusNode: httpPortFocusNode,
          onSubmitted: (_) => focusScopeNode.requestFocus(socks5UrlFocusNode),
          decoration: InputDecoration(
            labelText: "端口".tr,
            hintText: "3128",
            suffixIcon: IconButton(
              onPressed: () => httpPortController.clear(),
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
      ],
    );
  }

  Widget buildSocks5(BuildContext context, FocusScopeNode focusScopeNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Socks5 代理".tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: CTheme.margin * 2),
        TextField(
          controller: socks5UrlController,
          focusNode: socks5UrlFocusNode,
          onSubmitted: (_) => focusScopeNode.requestFocus(socks5PortFocusNode),
          decoration: InputDecoration(
            labelText: "URL",
            hintText: "127.0.0.1",
            suffixIcon: IconButton(
              onPressed: () => socks5UrlController.clear(),
              icon: Icon(
                Icons.clear,
                size: CTheme.iconSize * 0.8,
                color: CTheme.primary,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: CTheme.margin * 5),
        TextField(
          controller: socks5PortController,
          focusNode: socks5PortFocusNode,
          onSubmitted: (_) => focusScopeNode.requestFocus(httpUrlFocusNode),
          decoration: InputDecoration(
            labelText: "端口".tr,
            hintText: "1080",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () => socks5PortController.clear(),
              icon: Icon(
                Icons.clear,
                size: CTheme.iconSize * 0.8,
                color: CTheme.primary,
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ),
      ],
    );
  }

  Widget buildCheckboxs(BuildContext context) {
    return Obx(
      () {
        final proxy = settingController.proxy;
        return Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: settingController.proxy.enableBilibiliHttp,
                  onChanged: (v) {
                    proxy.enableBilibiliHttp = v ?? false;

                    if (v == true && proxy.enableBilibiliSocks5) {
                      proxy.enableBilibiliSocks5 = false;
                    }
                  },
                ),
                Text(
                  settingController.proxy.enableBilibiliHttp
                      ? "Bilibili 已启用Http代理".tr
                      : "Bilibili 未启用Http代理".tr,
                ),
              ],
            ),
            const SizedBox(height: CTheme.margin * 2),
            Row(
              children: [
                Checkbox(
                  value: settingController.proxy.enableBilibiliSocks5,
                  onChanged: (v) {
                    proxy.enableBilibiliSocks5 = v ?? false;

                    if (v == true && proxy.enableBilibiliHttp) {
                      proxy.enableBilibiliHttp = false;
                    }
                  },
                ),
                Text(
                  settingController.proxy.enableBilibiliSocks5
                      ? "Bilibili 已启用Socks5代理".tr
                      : "Bilibili 未启用Socks5代理".tr,
                ),
              ],
            ),
            const SizedBox(height: CTheme.margin * 4),
            Row(
              children: [
                Checkbox(
                  value: settingController.proxy.enableYoutubeHttp,
                  onChanged: (v) {
                    proxy.enableYoutubeHttp = v ?? false;

                    if (v == true && proxy.enableYoutubeSocks5) {
                      proxy.enableYoutubeSocks5 = false;
                    }
                  },
                ),
                Text(
                  settingController.proxy.enableYoutubeHttp
                      ? "Youtube 已启用Http代理".tr
                      : "Youtube 未启用Http代理".tr,
                ),
              ],
            ),
            const SizedBox(height: CTheme.margin * 2),
            Row(
              children: [
                Checkbox(
                  value: settingController.proxy.enableYoutubeSocks5,
                  onChanged: (v) {
                    proxy.enableYoutubeSocks5 = v ?? false;

                    if (v == true && proxy.enableYoutubeHttp) {
                      proxy.enableYoutubeHttp = false;
                    }
                  },
                ),
                Text(
                  settingController.proxy.enableYoutubeSocks5
                      ? "Youtube 已启用Socks5代理".tr
                      : "Youtube 未启用Socks5代理".tr,
                ),
              ],
            ),
          ],
        );
      },
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
            buildHttp(context, focusScopeNode),
            const SizedBox(height: CTheme.margin * 8),
            buildSocks5(context, focusScopeNode),
            const SizedBox(height: CTheme.margin * 8),
            buildCheckboxs(context),
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
            title: Text("代 理".tr),
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
