import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

import '../theme/controller.dart';

class SettingSwitch extends StatelessWidget {
  const SettingSwitch(
      {super.key,
      required this.title,
      required this.isOn,
      required this.onChanged});

  final String title;
  final bool isOn;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Get.find<ThemeController>().isDarkMode.value
            ? ThemeController.dark.colorScheme.secondary
            : ThemeController.light.colorScheme.secondary,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoSwitch(
            value: isOn,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
