import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildFiltWidgetV2(
    {String? title,
      bool? number,
      int? maxLength,
      String? initial,
      void Function(String value)? onSaved}) {
  return Column(
    children: [
      Container(
        width: Get.width, // number ? Get.width / 2-50 : Get.width,
        height: 75,
        child: Align(
          alignment: Alignment(0.9, 0),
          child: TextFormField(
            onSaved: onSaved != null ? (value) => onSaved!(value!) : null,
            initialValue: initial,
            validator: (value) {
              if (value!.isEmpty) {
                return "Boş Değer Olamaz";
              } else {
                return null;
              }
            },
            maxLength: maxLength,
            keyboardType: number != null ? TextInputType.number : TextInputType.name,
            decoration: InputDecoration(
              hintText: title,
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      ),
    ],
  );
}