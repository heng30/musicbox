import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SettingEntry extends StatelessWidget {
  const SettingEntry({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CTheme.borderRadius),
          color: CTheme.secondary,
        ),
        padding: EdgeInsets.all(CTheme.padding * 4),
        margin: EdgeInsets.symmetric(horizontal: CTheme.margin * 5),
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
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}
