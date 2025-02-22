import 'package:flutter/material.dart';

class AvatarWithUsername extends StatelessWidget {
  final String? imagePath;
  final String? username;
  final String? title;
  final double avatarRadius;
  final TextStyle usernameStyle;
  final TextStyle titlestyle;
  final double borderWidth;
  final Color borderColor;

  AvatarWithUsername({
    this.imagePath,
    this.username,
    this.title,
    this.borderWidth = 2.0,
    this.borderColor = Colors.grey,
    this.avatarRadius = 30.0,
    this.usernameStyle = const TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white),
    this.titlestyle = const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: avatarRadius,
          height: avatarRadius,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image(
              image: NetworkImage(imagePath!),
            ),
          ),
        ),
        SizedBox(width: 10.0), // Space between avatar and username
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   username,
            //   style: usernameStyle,
            // ),
            // Text(
            //   title,
            //   style: titlestyle,
            // ),
          ],
        ),
      ],
    );
  }
}
