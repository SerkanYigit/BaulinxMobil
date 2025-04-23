import 'package:flutter/material.dart';

class TimeMessage extends StatelessWidget {
  const TimeMessage({Key? key, this.message}) : super(key: key);
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Color(0xffdcf8c6),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, right: 5, left: 5),
              child: Center(child: Text(message!))),
        ),
      ),
    );
  }
}
