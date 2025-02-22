import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCircular extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F7F7),
      body: Center(
          child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(Get.theme.secondaryHeaderColor),
      ) // Image.asset("assets/Video/loading.gif",width: 50,height: 50,),
          ),
    );
  }
}
