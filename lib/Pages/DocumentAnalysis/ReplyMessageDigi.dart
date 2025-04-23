import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplyCardDigi extends StatelessWidget {
  const ReplyCardDigi({Key? key, this.message, this.time, this.Selected})
      : super(key: key);
  final String? message;
  final String? time;
  final bool? Selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Container(
              width: 35,
              height: 45,
              child: Image.asset(
                "assets/images/app_logo/logonew.png",
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Selected! ? Colors.green.withOpacity(0.5) : null,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 45,
                  ),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    // color: Color(0xffdcf8c6),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 20,
                            top: 5,
                            bottom: 20,
                          ),
                          child: RichText(
                            text: TextSpan(children: [
                              message!.isURL
                                  ? TextSpan(
                                      text: message!.replaceFirst("\n\n", ""),
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
                                      text: message!.replaceFirst("\n\n", ""),
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
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
            ),
          ),
        ],
      ),
    );
  }
}
