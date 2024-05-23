import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import './track_shape.dart';

class VSlider extends StatelessWidget {
  const VSlider({
    super.key,
    this.width = 15,
    this.minValue = 0,
    this.maxValue = 100,
    required this.initValue,
    required this.onChanged,
  });

  final double width;
  final double initValue;
  final double minValue;
  final double maxValue;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    final currentValue = initValue.obs;

    return RotatedBox(
      quarterTurns: 3, // 旋转90度以使其垂直
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
          trackShape: CustomTrackShape(horizontalPadding: CTheme.padding * 2),
          trackHeight: width,
          activeTrackColor: CTheme.primary,
        ),
        child: Obx(
          () => Slider(
            value: currentValue.value,
            min: minValue,
            max: maxValue,
            onChanged: (value) {
              currentValue.value = value;
              onChanged(value);
            },
          ),
        ),
      ),
    );
  }
}

void showVSliderDialog(
  BuildContext context, {
  double height = 300,
  double width = 30,
  double minValue = 0,
  double maxValue = 100,
  required initValue,
  required Function(double) onChanged,
}) {
  final size = MediaQuery.of(context).size;
  final orientation = MediaQuery.of(context).orientation;

  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: orientation == Orientation.portrait
              ? (size.width - width) / 2
              : (size.width - width - CTheme.margin * 8) / 2,
        ),
        child: SizedBox(
          height: height,
          child: VSlider(
            width: width * 0.6,
            minValue: minValue,
            maxValue: maxValue,
            initValue: initValue,
            onChanged: onChanged,
          ),
        ),
      );
    },
  );
}
