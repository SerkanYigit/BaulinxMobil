import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Services/AuthService.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmationController =
      TextEditingController();

  @override
  void initState() {
    mailController = TextEditingController(
        text: _controllerDB.user.value!.result!.mailAddress!);
    super.initState();
  }

  ChangePassword(String MailAddress, String Password, String NewPassword,
      String NewPasswordConfirmation) {
    _controllerDB.ChangeUserPassword(_controllerDB.headers(),
            Id: _controllerDB.user.value!.result!.id!,
            MailAddress: MailAddress,
            Password: Password,
            NewPassword: NewPassword,
            NewPasswordConfirmation: NewPasswordConfirmation)
        .then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.updated,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.changePassword,
        showNotification: false,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: Get.width,
                color: Get.theme.secondaryHeaderColor,
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Get.theme.scaffoldBackgroundColor,
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          CustomTextField(
                            hint: "E-Mail",
                            controller: mailController,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            hint: AppLocalizations.of(context)!
                                .signInPasswordLabel,
                            controller: passwordController,
                            obscureText: true,
                            maxLine: 1,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            hint: AppLocalizations.of(context)!.newPassword,
                            controller: newPasswordController,
                            obscureText: true,
                            maxLine: 1,
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            hint: AppLocalizations.of(context)!
                                .newPasswordConfirmation,
                            controller: newPasswordConfirmationController,
                            obscureText: true,
                            maxLine: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (newPasswordController.text !=
                    newPasswordConfirmationController.text) {
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.passwordsdonotmatch,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      //backgroundColor: Colors.red,
                      //textColor: Colors.white,
                      fontSize: 16.0);
                  return;
                }
                ChangePassword(
                    mailController.text,
                    passwordController.text,
                    newPasswordController.text,
                    newPasswordConfirmationController.text);
                Get.back();
              },
              child: Container(
                height: 45,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: standartCardShadow(),
                ),
                child: Center(
                    child: Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500),
                )),
              ),
            ),
            SizedBox(
              height: WidgetsBinding.instance.window.viewInsets.bottom == 0
                  ? 100
                  : 5,
            )
          ],
        ),
      ),
    );
  }
}
