import 'package:flutter/material.dart';
import 'package:undede/baseStructure.dart';

class MyGradientWidget {
  LinearGradient linear(
      {AlignmentGeometry start = Alignment.topLeft,
      AlignmentGeometry end = Alignment.bottomRight,

      Color? startColor,Color? endColor,
      Color? temp}) {
    List<Color> colors=[startColor??appBarColor!, endColor??appBarColor!];
    colors.insert(0,temp!);
  
    return LinearGradient(
        begin: start,
        end: end,
        colors: colors);
  }
}
