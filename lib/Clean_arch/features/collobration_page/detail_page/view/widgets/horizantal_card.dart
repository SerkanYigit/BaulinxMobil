import 'package:flutter/material.dart';

class HorizontalCard extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Function onPressed;
  final int index;
  int selectedCarouselIndex = 0;

  HorizontalCard({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.onPressed,
    required this.index,
    required this.selectedCarouselIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Card(
        color: selectedCarouselIndex != index
            ? Color.fromARGB(253, 197, 200, 205)
            // Color.fromARGB(254, 225, 228, 234)
            : const Color.fromARGB(255, 109, 135, 178),
        // const Color(0xfff1d26c),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        child: SizedBox(
          width: 180,
          height: 100,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
