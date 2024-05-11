import 'package:flutter/cupertino.dart';

import '../theme/theme.dart';

class SettingSwitch extends StatelessWidget {
  const SettingSwitch({
    super.key,
    required this.title,
    required this.isOn,
    required this.icon,
    required this.onChanged,
  });

  final String title;
  final bool isOn;
  final IconData icon;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CTheme.borderRadius),
        color: CTheme.secondary,
      ),
      padding: const EdgeInsets.all(CTheme.padding * 4),
      margin: const EdgeInsets.symmetric(horizontal: CTheme.margin * 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon),
          const SizedBox(width: CTheme.padding * 2),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
