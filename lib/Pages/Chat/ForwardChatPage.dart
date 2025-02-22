import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Pages/Chat/ChatDetailPage.dart';
import 'package:undede/Pages/Chat/GroupChat/ChatGroupDetailPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/Services/Chat/ChatDB.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/model/Chat/GetPublicChatListResult.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/User/GetAllActiveUserResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

import '../../Custom/CustomLoadingCircle.dart';
import 'GroupChat/CreateNewGrup.dart';
import 'package:undede/model/Chat/GetUserListUser.dart' as a;
import 'package:undede/model/Chat/GetPublicChatListResult.dart' as b;
import 'package:undede/model/User/GetAllActiveUserResult.dart' as c;

class ForwardChatPage extends StatefulWidget {
  final List<int>? message;
  final int? id;
  const ForwardChatPage({Key? key, this.message, this.id}) : super(key: key);

  @override
  _ForwardChatPageState createState() => _ForwardChatPageState();
}

enum ChatActivity { Online, Offline, All }

class _ForwardChatPageState extends State<ForwardChatPage>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  ControllerChatNew _controllerChat = Get.put(ControllerChatNew());

  List<bool> listExpand = <bool>[];
  UserDB userDB = new UserDB();
  AdminCustomerResult adminCustomer = new AdminCustomerResult(hasError: false);
  bool isLoading = false;
  bool isLoading1 = false;
  IO.Socket? socket;
  List getOnlineUser = [];
  TextEditingController _search = TextEditingController();

  // selectUser
  bool loading3 = false;
  int initialIndex = 0;
  // Scroll controller
  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  bool refreshing = true;

  // ONLINE OFLINE USER
  ChatActivity _chatActivity = ChatActivity.All;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connection();
    getUserList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels < -125 && refreshing) {
        getUserList();
        setState(() {
          refreshing = false;
        });
        print("içerde");
      }
    });
  }

  @override
  void dispose() {
    socket?.dispose();
    socket?.disconnect();

    super.dispose();
  }

  connection() {
    socket = IO.io(
        "https://websocket.bsabau.com/",
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket?.connect();
    socket?.onConnect((_) {
      print("Connected");

      socket?.emit("addUser", _controllerDB.user.value!.result!.id!);
      socket?.on("newChatMessage", (data) {
        getUserList();
        print(data);
        setState(() {});
      });
      socket?.emit("getOnlineUsers");
      socket?.on("getOnlineUsers", (data) {
        setState(() {
          print(data);
          getOnlineUser.addAll(data);
        });
      });
      socket?.on("setUserOnline", (data) {
        var uuid = Uuid();
        setState(() {
          getOnlineUser.add({"id": uuid, "username": data});
        });
      });
      socket?.on("setUserOffline", (data) {
        print(data);
        setState(() {
          getOnlineUser.removeWhere((element) => element["username"] == data);
        });
      });
    });
    socket?.onConnectError((data) {
      print("hata = $data");
    });
  }

  getUserList({withoutSetState = false}) async {
    await _controllerChatNew.GetUserList(
            _controllerDB.headers(), _controllerDB.user.value!.result!.id!)
        .then((value) => {});
    if (!withoutSetState) {
      setState(() {
        isLoading = true;
        refreshing = true;
      });
    }
    FilterPrivateChat();
  }

  List<int> SelectedUser = [];
  List<int> SelectedGroup = [];
  PostChatMessageSave(int ReceiverId, String Message, int isgroup) async {
    socket?.emit("newChatMessage", {
      "SenderId": _controllerDB.user.value!.result!.id!,
      "ReceiverId": isgroup == 1 ? 0 : ReceiverId,
      "Type": 1,
      "Unread": 1,
      "GroupId": isgroup == 1 ? ReceiverId : 0,
      "PublicId": 0,
      "Message": "",
      "CreateDate": '/Date(1645620370121)/',
      "CreateDateString": '23/02/2022 1:46 PM',
      "Id": widget.id,
      "UserId": _controllerDB.user.value!.result!.id!
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return GetBuilder<ControllerChatNew>(builder: (c) {
      if (c.loadChatUsers) {
        getUserList(withoutSetState: true);
        c.loadChatUsers = false;
        c.update();
      }
      return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          body: !isLoading && !isLoading1 && !loading3
              ? Text("ChatDetailPage") //CustomLoadingCircle()
              : Stack(
                  children: [
                    Container(
                      width: Get.width,
                      height: Get.height,
                      child: Column(children: [
                        Container(
                          width: Get.width,
                          height: 120,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                          ),
                          decoration: BoxDecoration(
                            color: Get.theme.secondaryHeaderColor,
                          ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              Get.back();
                                            },
                                            child: Icon(
                                              Icons.arrow_back,
                                              color: Get.theme.primaryColor,
                                            )),
                                        SizedBox(
                                          width: 40,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.forward,
                                          style: TextStyle(
                                              color: Get.theme.primaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
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
                            color: Get.theme.secondaryHeaderColor,
                            child: Container(
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: Color(0xFFF0F7F7),
                              ),
                              child: buildPrivateChat(context),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Positioned(
                      bottom: 100,
                      right: 5,
                      child: FloatingActionButton(
                        heroTag: "ForwardChatPage",
                        onPressed: () async {
                          SelectedUser.forEach((element) {
                            PostChatMessageSave(element, "", 0);
                          });
                          await _controllerChatNew.ForwardMessages(
                              _controllerDB.headers(),
                              UserId: _controllerDB.user.value!.result!.id!,
                              MessageList: widget.message,
                              ForwardUserList: SelectedUser,
                              ForwardGroupChat: SelectedGroup);
                          Get.back();
                        },
                        backgroundColor: Get.theme.primaryColor,
                        child: Icon(Icons.send),
                      ),
                    ),
                  ],
                ));
    });
  }

  Widget buildPrivateChat(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Container(
              child: Row(
                children: [
                  Radio<ChatActivity>(
                    focusColor: Get.theme.primaryColor,
                    hoverColor: Get.theme.primaryColor,
                    activeColor: Get.theme.primaryColor,
                    fillColor: WidgetStateColor.resolveWith(
                        (states) => Get.theme.primaryColor),
                    value: ChatActivity.All,
                    groupValue: _chatActivity,
                    onChanged: (ChatActivity? value) {
                      setState(() {
                        _chatActivity = value!;
                        FilterPrivateChat();
                      });
                    },
                  ),
                  Text(
                    AppLocalizations.of(context)!.all,
                    style:
                        TextStyle(color: Get.theme.primaryColor, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Container(
              child: Row(
                children: [
                  Radio<ChatActivity>(
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    activeColor: Colors.green,
                    fillColor:
                        WidgetStateColor.resolveWith((states) => Colors.green),
                    value: ChatActivity.Online,
                    groupValue: _chatActivity,
                    onChanged: (ChatActivity? value) {
                      setState(() {
                        _chatActivity = value!;
                        FilterPrivateChat();
                      });
                    },
                  ),
                  Text(
                    AppLocalizations.of(context)!.online,
                    style: TextStyle(color: Colors.green, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Container(
              child: Row(
                children: [
                  Radio<ChatActivity>(
                    focusColor: Colors.red,
                    hoverColor: Colors.red,
                    activeColor: Colors.red,
                    fillColor:
                        WidgetStateColor.resolveWith((states) => Colors.red),
                    value: ChatActivity.Offline,
                    groupValue: _chatActivity,
                    onChanged: (ChatActivity? value) {
                      setState(() {
                        _chatActivity = value!;
                        FilterPrivateChat();
                      });
                    },
                  ),
                  Text(
                    AppLocalizations.of(context)!.offline,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    overflow: TextOverflow.clip,
                  )
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 45,
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      boxShadow: standartCardShadow(),
                      borderRadius: BorderRadius.circular(45)),
                  child: CustomTextField(
                    controller: _search,
                    prefixIcon: Icon(Icons.search),
                    hint: AppLocalizations.of(context)!.search,
                    onChanged: (changed) {
                      setState(() {
                        FilterPrivateChat();
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                !refreshing
                    ? Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: FilterPrivateChat().length != null
                        ? FilterPrivateChat().length
                        : 0,
                    itemBuilder: (ctx, i) {
                      a.Result private = FilterPrivateChat()[i];
                      if (widget.id == private.id) {
                        return Container();
                      }
                      return InkWell(
                        onTap: () {
                          if (private.isGroup == 1) {
                            if (SelectedGroup.any(
                                (element) => element == private.id)) {
                              SelectedGroup.remove(private.id);
                            } else {
                              SelectedGroup.add(private.id!);
                            }
                          } else {
                            if (SelectedUser.any(
                                (element) => element == private.id)) {
                              SelectedUser.remove(private.id);
                            } else {
                              SelectedUser.add(private.id!);
                            }
                          }
                          setState(() {});
                        },
                        child: Container(
                          color: SelectedGroup.any(
                                      (element) => element == private.id) ||
                                  SelectedUser.any(
                                      (element) => element == private.id)
                              ? Get.theme.secondaryHeaderColor.withOpacity(0.2)
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                boxShadow: standartCardShadow(),
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(
                                                private.photo!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          getOnlineUser.any((element) {
                                            if (element["username"]
                                                    .toString() ==
                                                private.id.toString())
                                              return true;
                                            else
                                              return false;
                                          })
                                              ? Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: 16.0,
                                                    height: 16.0,
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
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              width: 1.0,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          child: Center(
                                                            child: Icon(
                                                              Icons.check,
                                                              size: 13,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: 16.0,
                                                    height: 16.0,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Colors.grey.shade300,
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      private.fullName!,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Avenir-Book',
                                                          fontSize: 17.0,
                                                          letterSpacing:
                                                              -0.41000000190734864,
                                                          height: 1.29,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8.0),
                                                    child: Text(DateFormat.yMMMd(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .date)
                                                        .format(DateTime.parse(
                                                            private
                                                                .lastMessageDate!))),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0),
                                                      child: Text(
                                                        private.lastMessage ??
                                                            ".....",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Avenir-Book',
                                                            fontSize: 17.0,
                                                            letterSpacing:
                                                                -0.41000000190734864,
                                                            height: 1.29,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  private.chatUnreadCount != 0
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0),
                                                          child: Container(
                                                            width: 25,
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .orangeAccent,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              private
                                                                  .chatUnreadCount
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<a.Result> FilterPrivateChat() {
    List<a.Result> userList = [];
    if (_chatActivity.index == 2) {
      if (!_search.text.isBlank!) {
        userList = _controllerChatNew.UserListRx!.value!.result!
            .where((c) =>
                c.fullName!.toLowerCase().contains(_search.text.toLowerCase()))
            .toList();
      } else {
        userList = _controllerChatNew.UserListRx!.value!.result!;
      }
    } else if (_chatActivity.index == 0) {
      if (!_search.text.isBlank!) {
        userList = _controllerChatNew.UserListRx!.value!.result!
            .where((c) => getOnlineUser.any((element) {
                  if (element["username"].toString() == c.id.toString())
                    return true;
                  else
                    return false;
                }))
            .where((c) =>
                c.fullName!.toLowerCase().contains(_search.text.toLowerCase()))
            .toList();
      } else {
        userList = _controllerChatNew.UserListRx!.value!.result!
            .where((c) => getOnlineUser.any((element) {
                  if (element["username"].toString() == c.id.toString())
                    return true;
                  else
                    return false;
                }))
            .toList();
      }
    } else if (_chatActivity.index == 1) {
      if (!_search.text.isBlank!) {
        userList = _controllerChatNew.UserListRx!.value!.result!
            .where((c) => !getOnlineUser.any((element) =>
                (element["username"].toString() != c.id.toString())))
            .where((c) =>
                c.fullName!.toLowerCase().contains(_search.text.toLowerCase()))
            .toList();
      } else {
        userList = _controllerChatNew.UserListRx!.value!.result!
            .where((c) => !getOnlineUser.any((element) =>
                (element["username"].toString() == c.id.toString())))
            .toList();
      }
    }
    return userList;
  }

  List<BoxShadow> standartCardShadow() {
    return <BoxShadow>[
      BoxShadow(
        color: Colors.grey,
        offset: Offset(0, 0),
        blurRadius: 15,
        spreadRadius: -11,
      )
    ];
  }
}
