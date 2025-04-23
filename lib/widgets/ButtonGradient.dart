import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonGradient extends StatelessWidget {
  Widget child;
  double circular;
  bool reverse;
  Color? color;

  ButtonGradient(this.child, {this.circular = 30, this.reverse = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(/*
          gradient: reverse
              ? MyGradientWidget().linear(
                  start: Alignment.centerRight, end: Alignment.centerLeft)
              : MyGradientWidget().linear(),*/
        color: this.color ?? Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(circular)),
      child: child,
    );
  }
}
