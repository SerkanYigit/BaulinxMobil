import 'package:flutter/material.dart';

class OwnComment extends StatelessWidget {
  const OwnComment({Key? key, this.message, this.time, this.Selected})
      : super(key: key);
  final String? message;
  final String? time;
  final int? Selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Selected == 1 ? Colors.green.withOpacity(0.5) : null,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 10,
              minWidth: MediaQuery.of(context).size.width - 10,
              minHeight: 50),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Color(0xffdcf8c6),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 30,
                    top: 5,
                    bottom: 20,
                  ),
                  child: Text(
                    message!,
                    style: TextStyle(
                      fontSize: 16,
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
