
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircleGradientContainer extends StatelessWidget {
  final Widget icon;

  CircleGradientContainer(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(30)
      ),
      child: icon,
    );
  }
}
