import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';

class CustomDialogs {




  static final CustomDialogs _instance = CustomDialogs._();

  factory CustomDialogs() => _instance;

  CustomDialogs._();

  infoDialog(
      {required BuildContext context,
       required String title,
       required String desc,
       required Function cancelOnTap,
    Function? okOnTap,
        String btnOkText ="Tamam",
        String btnCancelText ="Vazgeç",


      Widget? body}) {

    return AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      body: body,
      title: title,
      desc: desc,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      //!   btnCancelOnPress: cancelOnTap,
     //! btnOkOnPress: okOnTap,
      btnCancelOnPress: () => cancelOnTap(),
      btnOkOnPress: okOnTap != null ? () => okOnTap() : null,
    )..show();

  }

  errorDialog(
      {required BuildContext context,
      required String title,
       String? desc,
       Function? cancelOnTap,
    Function? okOnTap,
        String btnOkText ="Tamam",
        String btnCancelText ="Vazgeç",
      Widget? body}) {

    return AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      body: body,
      title: title,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      desc: desc,
      //!   btnCancelOnPress: cancelOnTap,
      //! btnOkOnPress: okOnTap,
      btnCancelOnPress: cancelOnTap != null ? () => cancelOnTap() : null,
      btnOkOnPress: okOnTap != null ? () => okOnTap() : null,
    )..show();

  }
}
