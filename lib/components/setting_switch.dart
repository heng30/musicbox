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
        borderRadius: BorderRadius.circular(12),
        color: CTheme.secondary,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon),
          SizedBox(width: CTheme.padding * 2),
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
