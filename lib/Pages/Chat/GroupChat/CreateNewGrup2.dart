import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Chat/ChatPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';

import 'SelectedUserModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateNewGrup2 extends StatefulWidget {
  final List<int>? SelectedUsersId;
  final List<User>? SelectedUsers;

  const CreateNewGrup2({Key? key, this.SelectedUsers, this.SelectedUsersId})
      : super(key: key);

  @override
  _CreateNewGrup2State createState() => _CreateNewGrup2State();
}

class _CreateNewGrup2State extends State<CreateNewGrup2>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = ControllerChatNew();
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  createNewGroup(String Title) {
    _controllerChatNew.NewGroupChat(_controllerDB.headers(),
            Title: Title, UserIdList: widget.SelectedUsersId)
        .then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.create,
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
        body: Stack(
          children: [
            Container(
              width: Get.width,
              height: Get.height,
              color: Get.theme.scaffoldBackgroundColor,
              child: Column(children: [
                Container(
                  width: Get.width,
                  height: Get.height / 7,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  decoration: BoxDecoration(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network(
                                    _controllerDB.user.value!.result!.photo ??
                                        "https://img2.pngindir.com/20180720/ivv/kisspng-computer-icons-user-profile-avatar-job-icon-5b521c567f49d7.5742234415321078625214.jpg",
                                    height: 35,
                                    width: 35,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12.0,
                                    height: 12.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 1.0,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          child: Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 7,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Row(
                            //   children: [
                            //     GestureDetector(
                            //       onTap: () {
                            //         Navigator.push(
                            //             context,
                            //             new MaterialPageRoute(
                            //                 builder: (BuildContext context) =>
                            //                     GeneralSearchPage()));
                            //       },
                            //       child: Icon(
                            //         Icons.search,
                            //         color: Colors.black,
                            //         size: 27,
                            //       ),
                            //     ),
                            //     SizedBox(
                            //       width: 10,
                            //     ),
                            //     InkWell(
                            //       onTap: () {
                            //         Navigator.push(
                            //             context,
                            //             new MaterialPageRoute(
                            //                 builder: (BuildContext context) =>
                            //                     NotificationPage()));
                            //       },
                            //       child: Icon(
                            //         Icons.notifications_outlined,
                            //         color: Colors.black,
                            //         size: 27,
                            //       ),
                            //     ),
                            //   ],
                            // ),
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
                              width: Get.width,
                              height: 100,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 30,
                                    child: Image.asset(
                                        'assets/images/icon/add.png',
                                        width: 20),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                          hintText: AppLocalizations.of(context)!
                                              .typeYourGroupName),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              width: Get.width,
                              height: 130,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!
                                          .participants +
                                      ": " +
                                      widget.SelectedUsers!.length.toString()),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: widget.SelectedUsers!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Container(
                                              width: Get.height / 15,
                                              height: Get.height / 15,
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(30),
                                                ),
                                                border: Border.all(
                                                  color: Colors.grey[200]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Image.network(
                                                widget.SelectedUsers![index]
                                                    .avatar!,
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(widget
                                                .SelectedUsers![index].name!)
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
            Positioned(
              bottom: 100,
              right: 5,
              child: FloatingActionButton(
                heroTag: "CreateNewGroup2",
                onPressed: () async {
                  if (_controller.text.isBlank!) {
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
                  await createNewGroup(_controller.text);
                  Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) => ChatPage()),
                      (Route<dynamic> route) => false);
                },
                backgroundColor: Get.theme.primaryColor,
                child: Icon(Icons.done),
              ),
            ),
          ],
        ));
  }
}
