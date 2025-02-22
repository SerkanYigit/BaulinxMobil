import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Pages/Profile/ProfileMail/UpdateUserMail.dart';
import 'package:undede/Pages/Profile/ProfileMail/UserEmailCreate.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/User/GetEmailTypeListResult.dart';
import 'package:undede/model/User/GetUserEmailListResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:undede/model/User/GetUserEmailListResult.dart'
    as a;

import '../../../Custom/CustomLoadingCircle.dart';

class ProfileMail extends StatefulWidget {
  const ProfileMail({Key? key}) : super(key: key);

  @override
  _ProfileMailState createState() => _ProfileMailState();
}

class _ProfileMailState extends State<ProfileMail>
    with TickerProviderStateMixin {
  bool loading = true;
  List<bool> listExpand = <bool>[];
  List<AnimationController> _controller = <AnimationController>[];

  @override
  void initState() {
    super.initState();
    getUserEmailList();
  }

  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerUser _controllerUser = Get.put(ControllerUser());
  GetUserEmailListResult _getUserEmailListResult = GetUserEmailListResult(hasError: false);
  List<a.Result> _searchedEmailResult = [];
  TextEditingController _search = TextEditingController();
  getUserEmailList() async {
    await _controllerUser.GetUserEmailList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, UserEmailId: 0)
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  UserEmailDelete(int Id) async {
    await _controllerUser.UserEmailDelete(
      _controllerDB.headers(),
      Id: Id,
      UserId: _controllerDB.user.value!.result!.id,
    ).then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.deleted,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
        getUserEmailList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerUser>(
        builder: (_) => Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: "E-mail",
              showNotification: false,
            ),
            body: !loading
                ? Stack(
                    children: [
                      Container(
                        width: Get.width,
                        height: Get.height,
                        child: Column(children: [
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
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Container(
                                          height: 45,
                                          margin: EdgeInsets.only(top: 15),
                                          decoration: BoxDecoration(
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(45)),
                                          child: CustomTextField(
                                            controller: _search,
                                            onChanged: (changed) {
                                              setState(() {
                                                _searchedEmailResult.clear();
                                              });
                                              if (changed.toString() == "") {
                                                return;
                                              }

                                              for (int i = 0;
                                                  i <
                                                      _controllerUser
                                                          .getUserEmailData
                                                          .value!
                                                          .result!
                                                          .length;
                                                  i++) {
                                                if (_controllerUser
                                                    .getUserEmailData
                                                    .value!
                                                    .result![i]
                                                    .userName!
                                                    .toLowerCase()
                                                    .contains(changed
                                                        .toString()
                                                        .camelCase!)) {
                                                  _searchedEmailResult.add(
                                                      _controllerUser
                                                          .getUserEmailData
                                                          .value!
                                                          .result![i]);
                                                }
                                              }
                                            },
                                            prefixIcon: Icon(Icons.search),
                                            hint: AppLocalizations.of(context)!
                                                .search,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Visibility(
                                        visible: !_search.text.isBlank!,
                                        child: ListView.builder(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                _searchedEmailResult.length,
                                            itemBuilder: (ctx, index) {
                                              listExpand.add(false);

                                              _controller
                                                  .add(new AnimationController(
                                                vsync: this,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                upperBound: 0.5,
                                              ));
                                              return buildContactCardSearch(
                                                index,
                                                context,
                                              );
                                            }),
                                      ),
                                      Visibility(
                                        visible: _search.text.isBlank!,
                                        child: ListView.builder(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: _controllerUser
                                                    .getUserEmailData
                                                    .value!
                                                    .result!
                                                    .length ??
                                                0,
                                            itemBuilder: (ctx, index) {
                                              listExpand.add(false);

                                              _controller
                                                  .add(new AnimationController(
                                                vsync: this,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                upperBound: 0.5,
                                              ));
                                              return buildContactCard(
                                                  index, context);
                                            }),
                                      ),
                                      SizedBox(
                                        height: 100,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Positioned(
                        bottom: 100,
                        right: 5,
                        child: FloatingActionButton(
                          heroTag: "ProfileMail",
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserEmailCreate()));
                          },
                          backgroundColor: Get.theme.primaryColor,
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  )
                : CustomLoadingCircle()));
  }

  Widget buildContactCard(int index, BuildContext context) {
    return Material(
      color: Color(0xFFF0F7F7),
      child: InkWell(
        onTap: () {
          setState(() {
            if (listExpand[index]) {
              _controller[index]..reverse(from: 0.5);
            } else {
              _controller[index]..forward(from: 0.0);
            }
            listExpand[index] = !listExpand[index];
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                //boxShadow: standartCardShadow(),
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(children: [
                        Icon(
                          Icons.mail,
                          color: Get.theme.secondaryHeaderColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(_controllerUser
                            .getUserEmailData.value!.result![index].userName!),
                        Spacer(),
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0)
                              .animate(_controller[index]),
                          child: Icon(Icons.expand_more),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: listExpand[index] ? 40 : 0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: listExpand[index] ? 3 : 0),
              decoration: BoxDecoration(
                  //color: Color(0xFFe3d5a4),
                  ),
              child: Container(
                child: Row(
                  children: [
                    Spacer(),
                    contactMoreIcon(() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UpdateUserMail(
                                Id: _controllerUser
                                    .getUserEmailData.value!.result![index].id!,
                                Mail: _controllerUser.getUserEmailData.value!
                                    .result![index].userName!,
                                EmailTypeId: _controllerUser.getUserEmailData
                                    .value!.result![index].emailTypeId!,
                              )));
                    }, Icons.edit, index),
                    SizedBox(
                      width: 5,
                    ),
                    contactMoreIcon(() {
                      setState(() {
                        UserEmailDelete(_controllerUser
                            .getUserEmailData.value!.result![index].id!);
                      });
                    }, Icons.delete, index),
                  ],
                ),
              ),
            ),
            Container(
              width: Get.width,
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector contactMoreIcon(
      Function runOnTap, IconData iconData, int index) {
    return GestureDetector(
      onTap: () {
        runOnTap();
      },
      child: AnimatedOpacity(
        opacity: listExpand[index] ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xFFe3d5a4),
            boxShadow: standartCardShadow(),
          ),
          padding: EdgeInsets.all(7),
          child: AnimatedOpacity(
            opacity: listExpand[index] ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child:
                Icon(iconData, size: 19, color: Get.theme.secondaryHeaderColor),
          ),
        ),
      ),
    );
  }

  Widget buildContactCardSearch(int index, BuildContext context) {
    return Material(
      color: Color(0xFFF0F7F7),
      child: InkWell(
        onTap: () {
          setState(() {
            if (listExpand[index]) {
              _controller[index]..reverse(from: 0.5);
            } else {
              _controller[index]..forward(from: 0.0);
            }
            listExpand[index] = !listExpand[index];
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                //boxShadow: standartCardShadow(),
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(children: [
                        Icon(
                          Icons.mail,
                          color: Get.theme.secondaryHeaderColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(_searchedEmailResult[index].userName!),
                        Spacer(),
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0)
                              .animate(_controller[index]),
                          child: Icon(Icons.expand_more),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: listExpand[index] ? 40 : 0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: listExpand[index] ? 3 : 0),
              decoration: BoxDecoration(
                  //color: Color(0xFFe3d5a4),
                  ),
              child: Container(
                child: Row(
                  children: [
                    Spacer(),
                    contactMoreIconSearch(() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UpdateUserMail(
                                Id: _controllerUser
                                    .getUserEmailData.value!.result![index].id!,
                                Mail: _controllerUser.getUserEmailData.value!
                                    .result![index].userName!,
                                EmailTypeId: _controllerUser.getUserEmailData
                                    .value!.result![index].emailTypeId!,
                              )));
                    }, Icons.edit, index),
                    SizedBox(
                      width: 5,
                    ),
                    contactMoreIconSearch(() {
                      setState(() {
                        UserEmailDelete(_controllerUser
                            .getUserEmailData.value!.result![index].id!);
                      });
                    }, Icons.delete, index),
                  ],
                ),
              ),
            ),
            Container(
              width: Get.width,
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector contactMoreIconSearch(
      Function runOnTap, IconData iconData, int index) {
    return GestureDetector(
      onTap: () {
        runOnTap();
      },
      child: AnimatedOpacity(
        opacity: listExpand[index] ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xFFe3d5a4),
            boxShadow: standartCardShadow(),
          ),
          padding: EdgeInsets.all(7),
          child: AnimatedOpacity(
            opacity: listExpand[index] ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child:
                Icon(iconData, size: 19, color: Get.theme.secondaryHeaderColor),
          ),
        ),
      ),
    );
  }
}
