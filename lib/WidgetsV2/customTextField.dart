import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'customCardShadow.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final Color? baseColor;
  final Color? borderColor;
  final Color? errorColor;
  final TextInputType? inputType;
  final bool obscureText;
  final Function? validator;
  final Function? onChanged;
  final Function? onTap;
  final Widget? prefixIcon;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final double? height;
  final int? minLine;
  final int? maxLine;
  final bool? autofocus;
  final bool? readOnly;

  CustomTextField({
    this.hint,
    this.label,
    this.controller,
    this.onChanged,
    this.baseColor,
    this.borderColor,
    this.errorColor,
    this.inputType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onTap,
    this.prefixIcon,
    this.enabled = true,
    this.inputFormatters,
    this.height = 45,
    this.minLine,
    this.maxLine,
    this.autofocus = false,
    this.readOnly = false,
  });

  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Color? currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.borderColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: standartCardShadow(),
          borderRadius: BorderRadius.circular(45),
        ),
        child: TextFormField(
          autofocus: widget.autofocus ?? false,
          maxLines: widget.maxLine,
          minLines: widget.minLine,
          controller: widget.controller,
          obscureText: widget.obscureText,
          onChanged: (value) => widget.onChanged,//! bu kisim degistirildi
          keyboardType: widget.inputType,
          inputFormatters: widget.inputFormatters,
          readOnly: widget.readOnly ?? false,
          decoration: new InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: widget.hint,
            hintStyle: Get.theme.inputDecorationTheme.hintStyle,
            labelText: widget.label,
            labelStyle: TextStyle(fontSize: 15),
            alignLabelWithHint: true,
            fillColor: Colors.white,
            filled: true,
            enabled: !widget.enabled
                ? false
                : widget.onTap == null
                    ? true
                    : false,
            prefixIcon: widget.prefixIcon,
          ),
        ),
      ),
    );
  }
}
