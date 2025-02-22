import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Chat/ChatPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/model/Chat/GetChatResult.dart';

import 'SelectedUserModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditGroupName extends StatefulWidget {
  final String? Name;
  final int? groupId;

  const EditGroupName({Key? key, this.Name, this.groupId}) : super(key: key);

  @override
  _EditGroupNameState createState() => _EditGroupNameState();
}

class _EditGroupNameState extends State<EditGroupName> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    _controller = TextEditingController(text: widget.Name);
    _controller.selection =
        TextSelection(baseOffset: 0, extentOffset: _controller.text.length);

    super.initState();
  }

  updateChatGroupTitle(String Title) async {
    print(widget.groupId);
    await _controllerChatNew.UpdateChatGroupTitle(_controllerDB.headers(),
            Title: Title, GroupId: widget.groupId)
        .then((value) {
      if (value) {
        _controllerChatNew.GetUserList(
            _controllerDB.headers(), _controllerDB.user.value!.result!.id!);
        _controllerChatNew.GetChat(
            _controllerDB.headers(), widget.groupId!, 0, 1, 0);
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
    Size size = Get.size;
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Container(
          width: Get.width,
          height: Get.height,
          child: Column(children: [
            Container(
              width: Get.width,
              height: 100,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              decoration: BoxDecoration(
                color: Get.theme.secondaryHeaderColor,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.enterANewName,
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: Get.width,
                height: Get.height,
                decoration: BoxDecoration(
                  color: Color(0xFFF0F7F7),
                ),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .typeYourGroupName),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Expanded(
                              child: Container(
                                height: 50,
                                width: Get.width / 2,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 0.5),
                                  color: Get.theme.primaryColor,
                                ),
                                child: Center(
                                  child:
                                      Text(AppLocalizations.of(context)!.cancel),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await updateChatGroupTitle(_controller.text);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              width: Get.width / 2,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 0.5),
                                color: Get.theme.primaryColor,
                              ),
                              child: Center(
                                  child: Text(
                                      AppLocalizations.of(context)!.confirm)),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
