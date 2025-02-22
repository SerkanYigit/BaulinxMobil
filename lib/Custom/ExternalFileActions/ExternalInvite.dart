import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';

ExternalInvite(context, int customerId, int invoiceFileId) async {
  List<DropdownMenuItem> cmbEmails = [];
  ControllerUser _controllerUser = Get.put(ControllerUser());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  String selectedMail;
  int selectedMailId;
  TextEditingController _password = TextEditingController();
  TextEditingController _message = TextEditingController();
  TextEditingController _receiver = TextEditingController();
  TextEditingController _subject = TextEditingController();
  List<int> FileIdList = [];
  List<int> selectedFileId = [];

  selectedFileId.add(invoiceFileId);
  selectedMailId = 0;
  cmbEmails.add(DropdownMenuItem(
    value: 0,
    child: Text("Baulinx"),
  ));
  for (int i = 0;
      i < _controllerUser.getUserEmailData.value!.result!.length;
      i++) {
    cmbEmails.add(DropdownMenuItem(
      value: _controllerUser.getUserEmailData.value!.result![i].id,
      child: Text(_controllerUser.getUserEmailData.value!.result![i].userName!),
      key: Key(_controllerUser.getUserEmailData.value!.result![i].userName!),
    ));
  }

  SendEMail(String Receivers, String Subject, String Message,
      List<int> Attachtments, int Type, int UserEmailId, String Password) {
    _controllerFiles.SendEMail(_controllerDB.headers(),
        UserId: customerId ?? _controllerDB.user.value!.result!.id,
        //widget.invoice?.customerId ?? _controllerDB.user.value.result.id,
        Receivers: Receivers,
        Subject: Subject,
        Message: Message,
        Attachtments: Attachtments,
        Type: Type,
        UserEmailId: UserEmailId == 0 ? null : UserEmailId,
        Password: Password == 0 ? null : Password);
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.inviteUsers,
              ),
              content: Container(
                height: 300,
                width: Get.width,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      child: Container(
                        width: Get.width,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(45),
                            boxShadow: standartCardShadow()),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            menuMaxHeight: 350,
                            value: selectedMailId,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontFamily: 'TTNorms',
                                fontWeight: FontWeight.w500),
                            icon: Icon(
                              Icons.expand_more,
                              color: Colors.black,
                            ),
                            items: cmbEmails,
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                if (value == 0) {
                                  selectedMailId = value;
                                  return;
                                }
                                selectedMail = _controllerUser
                                    .getUserEmailData.value!.result!
                                    .firstWhere(
                                        (element) => element.id == value)
                                    .userName!;
                                selectedMailId = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: selectedMailId != 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextField(
                          controller: _password,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .signInPasswordLabel,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _receiver,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.receiver,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _subject,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.subject,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _message,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.signInEmailLabel,
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    SendEMail(
                        _receiver.text,
                        _subject.text,
                        _message.text,
                        selectedFileId.isBlank! ? FileIdList : selectedFileId,
                        0,
                        selectedMailId.isBlank! ? 0 : selectedMailId,
                        _password.text.isBlank! ? "" : _password.text);

                    setState(() {
                      _receiver.clear();
                      _subject.clear();
                      _message.clear();
                      _password.clear();
                    });
                    Get.back();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.sent,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]);
        },
      );
    },
  );
}
