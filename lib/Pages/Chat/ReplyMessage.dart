import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard({Key? key, this.message, this.time, this.Selected})
      : super(key: key);
  final String? message;
  final String? time;
  final int? Selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Selected == 2 ? Colors.green.withOpacity(0.5) : null,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            // color: Color(0xffdcf8c6),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 50,
                    top: 5,
                    bottom: 10,
                  ),
                  child: RichText(
                    text: TextSpan(children: [
                      message!.isURL
                          ? TextSpan(
                              text: message,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 16),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  launch("https://" + message!);
                                })
                          : TextSpan(
                              text: message,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                    ]),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Text(
                    time!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
