import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildLocationWidgetV2({Function? onTap, String? title}) {
  return Padding(
    padding: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap != null ? () => onTap!() : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey),
          )
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title!,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          trailing: Icon(Icons.arrow_forward, color: Get.theme.colorScheme.surface),
        ),
      ),
    ),
  );
}