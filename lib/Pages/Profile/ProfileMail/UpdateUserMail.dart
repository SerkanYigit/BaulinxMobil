import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/User/GetEmailTypeListResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../../Custom/CustomLoadingCircle.dart';

class UpdateUserMail extends StatefulWidget {
  final String? Mail;
  final int? Id;
  final int? EmailTypeId;
  const UpdateUserMail({Key? key, this.Mail, this.Id, this.EmailTypeId})
      : super(key: key);

  @override
  _UpdateUserMailState createState() => _UpdateUserMailState();
}

class _UpdateUserMailState extends State<UpdateUserMail> {
  bool isLoading = true;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerUser _controllerUser = Get.put(ControllerUser());
  GetEmailTypeListResult _getEmailTypeListResult = GetEmailTypeListResult(hasError: false);
  String? _EmailType;
  List<String> a = <String>[] ;
  int? _emailTypeId;

  TextEditingController mailController = TextEditingController();

  @override
  void initState() {
    mailController = TextEditingController(text: widget.Mail);
    getEmailTypeList();
    _emailTypeId = widget.EmailTypeId;

    super.initState();
  }

  UpdateUserEmail(int Id, int EmailTypeId, String UserName) async {
    await _controllerUser.UpdateUserEmail(_controllerDB.headers(),
            Id: Id,
            UserId: _controllerDB.user.value!.result!.id,
            EmailTypeId: EmailTypeId,
            UserName: UserName)
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
        _controllerUser.GetUserEmailList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, UserEmailId: 0);
      }
    });
  }

  getEmailTypeList() async {
    await _controllerUser.GetEmailTypeList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id)
        .then((value) {
      setState(() {
        _getEmailTypeListResult = value;
        _EmailType = value.result![widget.EmailTypeId! - 1].provider;
        a = List.generate(
            value.result!.length, (index) => value.result![index].provider!);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.emailupdate,
        showNotification: false,
      ),
      body: !isLoading
          ? Container(
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
                          color: Color(0xFFF0F7F7),
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
                                Container(
                                  height: 45,
                                  width: Get.width,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(45),
                                      boxShadow: standartCardShadow()),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      menuMaxHeight: 350,
                                      value: _EmailType,
                                      style: Get
                                          .theme.inputDecorationTheme.hintStyle,
                                      icon: Icon(
                                        Icons.expand_more,
                                        color: Get.theme.colorScheme.surface,
                                      ),
                                      items: a.map((String val) {
                                        return DropdownMenuItem(
                                          value: val,
                                          child: Text(val),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _EmailType = value;
                                          _emailTypeId = a.indexOf(value!) + 1;
                                          print(_emailTypeId);

                                          setState(() {});
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (mailController.isBlank!) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.cannotbeblank,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            //backgroundColor: Colors.red,
                            //textColor: Colors.white,
                            fontSize: 16.0);
                        return;
                      }
                      await UpdateUserEmail(
                          widget.Id!, _emailTypeId!, mailController.text);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(45),
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
                    height:
                        WidgetsBinding.instance.window.viewInsets.bottom == 0
                            ? 100
                            : 5,
                  )
                ],
              ),
            )
          : CustomLoadingCircle(),
    );
  }
}
