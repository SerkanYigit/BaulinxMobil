import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Chat/ChatDetailPage.dart';
import 'package:undede/Pages/Chat/CreatChat.dart';
import 'package:undede/Pages/Contact/ContactCRMPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/Services/Chat/ChatDB.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/CustomAppBarWithSearch.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/model/Chat/GetPublicChatListResult.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:undede/model/Chat/GetUserListUser.dart' as a;

import '../../../Controller/ControllerUser.dart';
import '../../../Custom/CustomLoadingCircle.dart';
import '../../../Custom/FileTypesEnum.dart';
import '../../../WidgetsV2/Helper.dart';
import '../../../model/User/GetAllActiveUserResult.dart';
import 'CreateNewGrup2.dart';
import 'SelectedUserModel.dart';

class CreateNewGrup extends StatefulWidget {
  CreateNewGrup();

  @override
  _CreateNewGrupState createState() => _CreateNewGrupState();
}

class _CreateNewGrupState extends State<CreateNewGrup>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  GetUserListResult _getUserListResult = GetUserListResult(hasError: false);
  ControllerUser _controllerUser = ControllerUser();
  GetAllActiveUserResult _getAllActiveUserResult =
      GetAllActiveUserResult(hasError: false);

  bool isLoading = false;
  List<User> SelectedUsers = [];
  List<int> SelectedUsersId = [];
  TextEditingController _search = TextEditingController();
//  GetUserListResult _getUserListResultSearch = GetUserListResult();
  List<a.Result> _getUserListResultSearch = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserList();
    GetAllActiveUser();
  }

  getUserList() async {
    await _controllerChatNew.GetUserList(
            _controllerDB.headers(), _controllerDB.user.value!.result!.id!)
        .then((value) => {_getUserListResult = value});
    setState(() {
      isLoading = true;
    });
  }

  GetAllActiveUser({withoutSetState = false, String search = ""}) async {
    await _controllerUser.GetAllActiveUser(_controllerDB.headers(),
            search: search)
        .then((value) {
      _getAllActiveUserResult = value;
    });
    if (!withoutSetState) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: CustomAppBarWithSearch(
          title: AppLocalizations.of(context)!.selectParticipants,
          isSelectParticipantsPage: true,
          openFilterFunction: () {},
          openBoardFunction: () {},
          onChanged: (changed) {
            setState(() {
              _getUserListResultSearch.clear();
            });

            for (int i = 0; i < _getUserListResult.result!.length; i++) {
              if (_getUserListResult.result![i].isGroup == 0) {
                if (_getUserListResult.result![i].fullName!
                    .toLowerCase()
                    .contains(changed.toString().camelCase!)) {
                  _getUserListResultSearch.add(_getUserListResult.result![i]);
                  print(_getUserListResult.result![i]);
                }
                print(_getUserListResult.result![i].fullName!
                    .toLowerCase()
                    .contains(changed.toString().camelCase!));
              }
            }
          },
        ),
        body: !isLoading
            ? Text("createnewgroup") //CustomLoadingCircle()
            : Stack(
                children: [
                  Container(
                    width: Get.width,
                    height: Get.height,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Get.theme.scaffoldBackgroundColor,
                    ),
                    child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Visibility(
                              visible: !_search.text.isBlank!,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _getUserListResultSearch.length != null
                                          ? _getUserListResultSearch.length
                                          : 0,
                                  itemBuilder: (ctx, i) {
                                    return _getUserListResultSearch[i]
                                                .isGroup ==
                                            0
                                        ? InkWell(
                                            onTap: () {
                                              if (SelectedUsers.any((element) =>
                                                  element.id ==
                                                  _getUserListResultSearch[i]
                                                      .id)) {
                                                SelectedUsersId.remove(
                                                    _getUserListResultSearch[i]
                                                        .id);
                                                SelectedUsers.removeWhere(
                                                    (element) =>
                                                        element.id ==
                                                        _getUserListResultSearch[
                                                                i]
                                                            .id);

                                                setState(() {});
                                              } else {
                                                SelectedUsersId.add(
                                                    _getUserListResultSearch[i]
                                                        .id!);
                                                SelectedUsers.add(User(
                                                    id: _getUserListResultSearch[
                                                            i]
                                                        .id!,
                                                    avatar:
                                                        _getUserListResultSearch[
                                                                i]
                                                            .photo!,
                                                    name:
                                                        _getUserListResultSearch[
                                                                i]
                                                            .fullName!));
                                                setState(() {});
                                              }
                                              print(SelectedUsersId);
                                              print(SelectedUsers);
                                            },
                                            child: Container(
                                              color: SelectedUsers.any((element) =>
                                                      element.id ==
                                                      _getUserListResultSearch[
                                                              i]
                                                          .id)
                                                  ? Get.theme
                                                      .secondaryHeaderColor
                                                      .withOpacity(0.2)
                                                  : Colors.transparent,
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 10,
                                                    right: 20,
                                                    left: 20,
                                                    top: 10),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                  boxShadow:
                                                                      standartCardShadow(),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30)),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                child: Image
                                                                    .network(
                                                                  _getUserListResultSearch[
                                                                          i]
                                                                      .photo!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SelectedUsers.any(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        _getUserListResultSearch[i]
                                                                            .id)
                                                                ? Positioned(
                                                                    right: 0,
                                                                    bottom: 0,
                                                                    child:
                                                                        Container(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 12),
                                                                      decoration: BoxDecoration(
                                                                          color: Get
                                                                              .theme
                                                                              .primaryColor,
                                                                          shape:
                                                                              BoxShape.circle),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container()
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  top: 12),
                                                          child: Text(
                                                            _getUserListResultSearch[
                                                                    i]
                                                                .fullName!,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Avenir-Book',
                                                                fontSize: 17.0,
                                                                letterSpacing:
                                                                    -0.41000000190734864,
                                                                height: 1.29,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container();
                                  }),
                            ),
                            Visibility(
                              visible: _search.text.isBlank!,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _getUserListResult.result!.length != null
                                          ? _getUserListResult.result!.length
                                          : 0,
                                  itemBuilder: (ctx, i) {
                                    return _getUserListResult
                                                .result![i].isGroup ==
                                            0
                                        ? InkWell(
                                            onTap: () {
                                              if (SelectedUsers.any((element) =>
                                                  element.id ==
                                                  _getUserListResult
                                                      .result![i].id)) {
                                                SelectedUsersId.remove(
                                                    _getUserListResult
                                                        .result![i].id);
                                                SelectedUsers.removeWhere(
                                                    (element) =>
                                                        element.id ==
                                                        _getUserListResult
                                                            .result![i].id);

                                                setState(() {});
                                              } else {
                                                SelectedUsersId.add(
                                                    _getUserListResult
                                                        .result![i].id!);
                                                SelectedUsers.add(User(
                                                    id: _getUserListResult
                                                        .result![i].id!,
                                                    avatar: _getUserListResult
                                                        .result![i].photo!,
                                                    name: _getUserListResult
                                                        .result![i].fullName!));
                                                setState(() {});
                                              }
                                              print(SelectedUsersId);
                                              print(SelectedUsers);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: SelectedUsers.any(
                                                          (element) =>
                                                              element.id ==
                                                              _getUserListResult
                                                                  .result![i]
                                                                  .id)
                                                      ? Get.theme
                                                          .secondaryHeaderColor
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              margin: EdgeInsets.only(
                                                  right: 20,
                                                  bottom: 10,
                                                  left: 20,
                                                  top: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width:
                                                              Get.height / 18,
                                                          height:
                                                              Get.height / 18,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                          .grey[
                                                                      200]!,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            child:
                                                                Image.network(
                                                              _getUserListResult
                                                                  .result![i]
                                                                  .photo!,
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                            ),
                                                          ),
                                                        ),
                                                        SelectedUsers.any(
                                                                (element) =>
                                                                    element
                                                                        .id ==
                                                                    _getUserListResult
                                                                        .result![
                                                                            i]
                                                                        .id)
                                                            ? Positioned(
                                                                right: 0,
                                                                bottom: 0,
                                                                child:
                                                                    Container(
                                                                  width: 20,
                                                                  height: 20,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              12),
                                                                  decoration: BoxDecoration(
                                                                      color: Get
                                                                          .theme
                                                                          .primaryColor,
                                                                      shape: BoxShape
                                                                          .circle),
                                                                  child: Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 14,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 7,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                _getUserListResult
                                                                    .result![i]
                                                                    .fullName!,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Avenir-Book',
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        -0.41000000190734864,
                                                                    height:
                                                                        1.29,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              _getUserListResult
                                                                          .result![
                                                                              i]
                                                                          .lastMessageDate !=
                                                                      ''
                                                                  ? Text(DateFormat.yMMMd(
                                                                          AppLocalizations.of(context)!
                                                                              .date)
                                                                      .format(DateTime.parse(_getUserListResult
                                                                          .result![
                                                                              i]
                                                                          .lastMessageDate!)))
                                                                  : Text(''),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              LastMessageWidget(
                                                                  _getUserListResult
                                                                      .result![i]),
                                                              Spacer(),
                                                              _getUserListResult
                                                                          .result![
                                                                              i]
                                                                          .chatUnreadCount !=
                                                                      0
                                                                  ? Container(
                                                                      width: 25,
                                                                      height:
                                                                          25,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .orangeAccent,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      child: Center(
                                                                          child: Text(
                                                                        _getUserListResult
                                                                            .result![i]
                                                                            .chatUnreadCount
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      )),
                                                                    )
                                                                  : Container(),
                                                              _getUserListResult
                                                                          .result![
                                                                              i]
                                                                          .isGroup ==
                                                                      1
                                                                  ? Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .green,
                                                                          borderRadius: BorderRadius.circular(
                                                                              15)),
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.of(context)!
                                                                            .group,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ))
                                                                  : tags(_getUserListResult
                                                                      .result![i]),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container();
                                  }),
                            ),
                          ],
                        )),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 5,
                    child: FloatingActionButton(
                      heroTag: "CreateNewGroup",
                      onPressed: () {
                        if (SelectedUsers.isBlank!) {
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CreateNewGrup2(
                                  SelectedUsers: SelectedUsers,
                                  SelectedUsersId: SelectedUsersId,
                                )));
                      },
                      backgroundColor: Get.theme.primaryColor,
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ));
  }

  Widget tags(a.Result private) {
    return PopupMenuButton(
      onSelected: (a) {
        if (a == 1) {
          _controllerUser.AddUsersToAdministration(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id,
                  TargetUserId: private.id,
                  TargetCustomerId: private.customerId)
              .then((value) {
            if (value) {
              setState(() {
                _controllerChatNew.UserListRx!.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .isMyPerson = true;
              });
            } else {}
          });
        }
        if (a == 2) {
          _controllerUser.AddUsersToCustomer(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id!,
                  TargetUserId: private.id!,
                  TargetCustomerId: private.customerId!)
              .then((value) {
            if (value) {
              setState(() {
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .customerId = _controllerDB.user.value!.result!.id;
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .isMyPerson = false;
              });
            } else {}
          });
        }
        if (a == 3) {
          _controllerUser.DeleteUsersToCustomer(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id!,
                  TargetUserId: private.id!,
                  TargetCustomerId: private.customerId!)
              .then((value) {
            if (value) {
              setState(() {
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .customerId = 0;
              });
            } else {}
          });
          _controllerUser.DeleteUsersToAdministration(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id,
                  TargetUserId: private.id,
                  TargetCustomerId: private.customerId)
              .then((value) {
            if (value)
              setState(() {
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .isMyPerson = false;
              });
          });
        }
      },
      itemBuilder: (context) => (private.isMyPerson!)
          ? [
              PopupMenuItem(
                child: Text(AppLocalizations.of(context)!.customer),
                value: 2,
              ),
              PopupMenuItem(
                child: Text(AppLocalizations.of(context)!.private),
                value: 3,
              ),
            ]
          : (private.customerId == _controllerDB.user.value!.result!.id)
              ? [
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.personal),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.private),
                    value: 3,
                  ),
                ]
              : [
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.personal),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.customer),
                    value: 2,
                  ),
                ],
      child: Container(
          padding: EdgeInsets.all(3),
          width: Get.width / 6,
          decoration: BoxDecoration(
              color: private.isMyPerson!
                  ? Get.theme.colorScheme.onPrimaryContainer
                  : private.customerId == _controllerDB.user.value!.result!.id
                      ? Get.theme.colorScheme.onSecondaryContainer
                      : Get.theme.colorScheme.onTertiaryContainer,
              borderRadius: BorderRadius.circular(15)),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              private.isMyPerson!
                  ? AppLocalizations.of(context)!.personal
                  : private.customerId == _controllerDB.user.value!.result!.id
                      ? AppLocalizations.of(context)!.customer
                      : AppLocalizations.of(context)!.private,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          )),
    );
  }

  Widget LastMessageWidget(a.Result private) {
    String exten =
        private.lastMessage.toString().split(".").last.split("\"").first;
    switch (exten) {
      case "pdf":
      case 'xls':
      case 'docx':
      case 'xlsx':
      case 'doc':
      case 'jpg':
      case 'png':
      case 'jpeg':
      case 'txt':
      case 'm4a':
      case 'mp4':
      case 'mp3':
        return Expanded(
          child: Row(
            children: [
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(getImagePathByFileExtension(exten)))),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                exten.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Avenir-Book',
                    fontSize: 15.0,
                    letterSpacing: -0.41000000190734864,
                    height: 1.29,
                    color: Colors.grey,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
        );
        break;
      default:
        return Expanded(
          child: Text(
            private.lastMessage ?? ".....",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Avenir-Book',
                fontSize: 15.0,
                letterSpacing: -0.41000000190734864,
                height: 1.29,
                color: Colors.grey,
                fontWeight: FontWeight.w300),
          ),
        );
    }
  }
}
