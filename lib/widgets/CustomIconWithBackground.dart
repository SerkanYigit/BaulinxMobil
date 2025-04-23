import 'package:flutter/material.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';

class CustomIconWithBackground extends StatelessWidget {
  final String iconName;
  final Color color;
  final VoidCallback onPressed;
  final double size;

  const CustomIconWithBackground({
    Key? key,
    required this.iconName,
    required this.color,
    required this.onPressed,
    this.size = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: 35 * size,
        height: 30 * size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primaryYellowColor,
          //Theme.of(context).colorScheme.primary,
        ),
        child: IconButton(
          icon: ImageIcon(
            AssetImage('assets/images/icon/${iconName}.png'),
          ),
          color: color,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
