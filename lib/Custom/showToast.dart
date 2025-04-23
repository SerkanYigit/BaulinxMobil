import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String s) {
  print('Message: ' + s);
  Fluttertoast.showToast(
      msg: s,
      toastLength:
      Toast.LENGTH_SHORT,
      gravity:
      ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      //backgroundColor: Colors.red,
      //textColor: Colors.white,
      fontSize: 16.0);
}

void showSuccessToast(String s) {
  print('Message: ' + s);
  Fluttertoast.showToast(
      msg: s,
      toastLength:
      Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color(0xFF28a745),
      //textColor: Colors.white,
      fontSize: 16.0);
}

void showErrorToast(String s) {
  print('Message: ' + s);
  Fluttertoast.showToast(
      msg: s,
      toastLength:
      Toast.LENGTH_SHORT,
      gravity:
      ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color(0xFFdc3545),
      //textColor: Colors.white,
      fontSize: 16.0);
}

void showWarningToast(String s) {
  print('Message: ' + s);
  Fluttertoast.showToast(
      msg: s,
      toastLength:
      Toast.LENGTH_SHORT,
      gravity:
      ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color(0xFFffc107),
      //textColor: Colors.white,
      fontSize: 16.0);
}