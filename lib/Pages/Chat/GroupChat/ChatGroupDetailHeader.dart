import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Chat/GroupChat/EditGroupName.dart';
import 'package:undede/Pages/Chat/GroupChat/EditGroupPicture.dart';
import 'package:undede/model/Chat/GetChatResult.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatGroupDetailHeader extends StatefulWidget {
  final List<UserList>? userList;
  final String? Name;
  final String? Photo;
  final int? groupId;

  const ChatGroupDetailHeader(
      {Key? key, this.userList, this.Name, this.Photo, this.groupId})
      : super(key: key);

  @override
  _ChatGroupDetailHeaderState createState() => _ChatGroupDetailHeaderState();
}

class _ChatGroupDetailHeaderState extends State<ChatGroupDetailHeader>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    _controller = TextEditingController(text: widget.Name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return GetBuilder<ControllerChatNew>(
        builder: (_) => Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                Container(
                                  child: PopupMenuButton(
                                      onSelected: (a) {
                                        if (a == 1) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditGroupName(
                                                          Name:
                                                              widget.Name ?? "",
                                                          groupId:
                                                              widget.groupId ??
                                                                  0)));
                                        }
                                      },
                                      child: Center(
                                        child: Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                      itemBuilder: (context) => [
                                            PopupMenuItem(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .newGroup),
                                              value: 1,
                                            ),
                                          ]),
                                ),
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
                        child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditGroupPicture(
                                                          picture:
                                                              widget.Photo ??
                                                                  "",
                                                          groupId:
                                                              widget.groupId ??
                                                                  0)));
                                        },
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundImage: NetworkImage(
                                              _controllerChatNew
                                                  .UserListRx!.value!.result!
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      widget.groupId)
                                                  .photo!),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        _controllerChatNew
                                            .UserListRx!.value!.result!
                                            .firstWhere((element) =>
                                                element.id == widget.groupId)
                                            .fullName!,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.group +
                                            " " +
                                            AppLocalizations.of(context)!
                                                .participants +
                                            ": " +
                                            widget.userList!.length.toString(),
                                        style: TextStyle(
                                            fontSize: 18,
                                            color:
                                                Colors.black.withOpacity(0.5)),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),

                                      /*
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                          hintText: AppLocalizations.of(context)
                                              .typeYourGroupName),
                                    ),
                                  ),*/
                                    ],
                                  ),
                                ),
                                Container(
                                  width: Get.width,
                                  height: 500,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: _controllerChatNew
                                              .messages.value!.userList!.length,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 25,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                _controllerChatNew
                                                                    .messages
                                                                    .value!
                                                                    .userList![
                                                                        index]
                                                                    .photo!),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(_controllerChatNew
                                                              .messages
                                                              .value!
                                                              .userList![index]
                                                              .name! +
                                                          " " +
                                                          _controllerChatNew
                                                              .messages
                                                              .value!
                                                              .userList![index]
                                                              .surname!),
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  thickness: 1,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                  ]),
                ),
                /*
            Positioned(
              bottom: 100,
              right: 5,
              child: FloatingActionButton(
                heroTag: "ChatGroupDetailHeader",
                onPressed: () async {
                  /*
                  if (_controller.text.isBlank) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context).cannotbeblank,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        //backgroundColor: Colors.red,
                        //textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                  */

                },
                backgroundColor: Get.theme.primaryColor,
                child: Icon(Icons.done),
              ),
            ),*/
              ],
            )));
  }
}
