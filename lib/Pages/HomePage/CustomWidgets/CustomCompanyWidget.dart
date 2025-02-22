import 'package:flutter/material.dart';

import '../../Contact/ContactCRMPage.dart';

class CustomCompanyWidget extends StatelessWidget {
  final String? imagePath;
  final String? username;
  final String? title;
  final int? customerId;
  final double avatarRadius;
  final TextStyle usernameStyle;
  final double borderWidth;
  final Color borderColor;

  CustomCompanyWidget({
    this.imagePath,
    this.username,
    this.title,
    this.customerId,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
    this.avatarRadius = 30.0,
    this.usernameStyle =
        const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    new ContactCRMPage(index: 1, customerId: customerId)));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: avatarRadius * 2 + borderWidth * 2,
                  height: avatarRadius * 2 + borderWidth * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://onlinefiles.dsplc.net//Content/UploadPhoto/User/$imagePath',
                      fit: BoxFit.contain,
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                    ),
                  ),
                ),
                SizedBox(width: 10.0), // Space between avatar and username
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username!,
                      style: usernameStyle,
                    ),
                    Text(
                      title!,
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_right, size: 30),
          ],
        ),
      ),
    );
  }
}
