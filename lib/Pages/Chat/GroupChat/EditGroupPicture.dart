import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Chat/ChatPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/model/Chat/GetChatResult.dart';

import 'SelectedUserModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditGroupPicture extends StatefulWidget {
  final String? picture;
  final int? groupId;

  const EditGroupPicture({Key? key, this.picture, this.groupId})
      : super(key: key);

  @override
  _EditGroupPictureState createState() => _EditGroupPictureState();
}

class _EditGroupPictureState extends State<EditGroupPicture> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  TextEditingController _controller = TextEditingController();
  String base64Image = "";
  XFile? profileImage;
  dynamic _pickImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    _controller.selection =
        TextSelection(baseOffset: 0, extentOffset: _controller.text.length);

    super.initState();
  }

  updateGroupPicture(String Base64) {
    print(widget.groupId);
    _controllerChatNew.UpdateGroupChatPicture(_controllerDB.headers(),
            GroupId: widget.groupId, FileName: "deneme.png", Base64: Base64)
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
        _controllerChatNew.GetUserList(
            _controllerDB.headers(), _controllerDB.user.value!.result!.id!);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return GetBuilder<ControllerChatNew>(
        builder: (_) => Scaffold(
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
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.groupPicture,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                _showPicker(context);
                              },
                              child: Icon(
                                Icons.edit,
                                size: 25,
                                color: Colors.white,
                              ),
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
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(_controllerChatNew
                                  .UserListRx!.value!.result!
                                  .firstWhere(
                                      (element) => element.id == widget.groupId)
                                  .photo!))),
                    ),
                  ),
                ),
              ]),
            )));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                      ),
                      title:
                          new Text(AppLocalizations.of(context)!.photoLibrary),
                      onTap: () {
                        _onImageButtonPressed(ImageSource.gallery,
                            context: context);

                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                    ),
                    title: new Text(AppLocalizations.of(context)!.camera),
                    onTap: () {
                      _onImageButtonPressed(ImageSource.camera,
                          context: context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      setState(() {
        profileImage = pickedFile;
        List<int> imageBytes = File(profileImage!.path).readAsBytesSync();
        base64Image = base64Encode(imageBytes);

        updateGroupPicture(base64Image);
      });
    } catch (e) {
      setState(() {
        _pickImage = e;
      });
    }
  }
}
