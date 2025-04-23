import 'dart:math';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerMessage.dart';
import 'package:undede/Pages/Chat/ChatDetailPage.dart';
import 'package:undede/Pages/Chat/CreatChat.dart';
import 'package:undede/Pages/Contact/ContactCRMPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Message/MessageDetail.dart';
import 'package:undede/Pages/Message/NewMessage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/Pages/Profile/ProfilePage.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/Message/GetMessageByUserIdResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Custom/CustomLoadingCircle.dart';

class MessagePageTabPage extends StatefulWidget {
  @override
  final int? UserId;

  const MessagePageTabPage({Key? key, this.UserId}) : super(key: key);
  _MessagePageTabPageState createState() => _MessagePageTabPageState();
}

class _MessagePageTabPageState extends State<MessagePageTabPage>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerMessage _controllerMessage = Get.put(ControllerMessage());
  bool isLoading = true;
  bool isLoading1 = true;
  bool isLoading2 = true;
  bool isLoading3 = true;
  List<Tab> tabs = <Tab>[];
  TabController? _tabController;
  List<MessageList> _messageListAll = [];
  List<MessageList> _messageListReceived = [];
  List<MessageList> _messageListSent = [];
  List<MessageList> _messageListDelete = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getMessageByUserIdAll();
      getMessageByUserIdReceived();
      getMessageByUserIdSent();
      getMessageByUserIdDeleted();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    tabs = <Tab>[
      new Tab(text: AppLocalizations.of(context)!.all),
      new Tab(text: AppLocalizations.of(context)!.inbox),
      new Tab(text: AppLocalizations.of(context)!.sent),
      new Tab(text: AppLocalizations.of(context)!.trash),
    ];
    _tabController = new TabController(vsync: this, length: tabs.length);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  getMessageByUserIdAll() async {
    await _controllerMessage.GetMessageByUserIdAll(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            Page: 0,
            Size: 999,
            Type: 0)
        .then((value) {
      isLoading = false;
    });
    setState(() {
      isLoading = false;
    });
  }

  getMessageByUserIdReceived() async {
    await _controllerMessage.GetMessageByUserIdReceived(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        Page: 0,
        Size: 999,
        Type: 1);
    setState(() {
      isLoading1 = false;
    });
  }

  getMessageByUserIdSent() async {
    await _controllerMessage.GetMessageByUserIdSent(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        Page: 0,
        Size: 999,
        Type: 2);

    setState(() {
      isLoading2 = false;
    });
  }

  getMessageByUserIdDeleted() async {
    await _controllerMessage.GetMessageByUserIdDeleted(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            Page: 0,
            Size: 999,
            Type: 3)
        .then((value) {
      setState(() {
        isLoading3 = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerMessage>(
      builder: (_) => Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          body: isLoading && isLoading1 && isLoading2 && isLoading3
              ? Text("message") //CustomLoadingCircle()
              : Container(
                  width: Get.width,
                  height: Get.height,
                  child: Column(children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Get.theme.secondaryHeaderColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 35,
                            margin: EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: TabBar(
                              isScrollable: true,
                              unselectedLabelColor: Colors.grey,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Get.theme.secondaryHeaderColor,
                              indicator: new BubbleTabIndicator(
                                indicatorHeight: 35.0,
                                indicatorColor: Colors.white,
                                tabBarIndicatorSize: TabBarIndicatorSize.label,
                                // Other flags
                                //  indicatorRadius: 1,
                                //insets: EdgeInsets.all(1),
                                padding: EdgeInsets.all(1),
                              ),
                              tabs: tabs,
                              controller: _tabController,
                            ),
                          ),
                        ],
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
                          child:
                              TabBarView(controller: _tabController, children: [
                            TabBarAllMessageWidget(context),
                            TabBarReceivedMessageWidget(context),
                            TabBarSentMessageWidget(context),
                            TabBarDeletedMessageWidget(context),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                )),
    );
  }

  Widget TabBarAllMessageWidget(BuildContext context) {
    _messageListAll.clear();
    for (int i = 0;
        i < _controllerMessage.getAll.value!.result!.messageList!.length;
        i++) {
      for (int j = 0;
          j <
              _controllerMessage
                  .getAll.value!.result!.messageList![i].toUserList!.length;
          j++) {
        print(_controllerMessage
            .getAll.value!.result!.messageList![i].toUserList![j].id);
        if (_controllerMessage.getAll.value!.result!.messageList![i].fromUser ==
                widget.UserId ||
            _controllerMessage
                    .getAll.value!.result!.messageList![i].toUserList![j].id ==
                widget.UserId) {
          _messageListAll
              .add(_controllerMessage.getAll.value!.result!.messageList![i]);
        }
      }
    }
    return Column(
      children: [
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
                    prefixIcon: Icon(Icons.search),
                    hint: AppLocalizations.of(context)!.search,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, right: 20),
              child: PopupMenuButton(
                  child: Center(
                      child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 27,
                  )),
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.newGroup),
                          value: 1,
                        ),
                        PopupMenuItem(
                          child: Text(
                              AppLocalizations.of(context)!.newPublicGroup),
                          value: 2,
                        ),
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.settings),
                          value: 3,
                        )
                      ]),
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _messageListAll.length,
                    itemBuilder: (ctx, i) {
                      return InkWell(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => MessageDetail(
                          //       messageList: _messageListAll[i],differentPage: 1,
                          //     )));
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 20, right: 20, bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        boxShadow: standartCardShadow(),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        _messageListAll[i].fromUserPhotoPath!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 3.0),
                                                child: Text(
                                                  _messageListAll[i]
                                                      .fromUserNameAndSurname!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          _messageListAll[i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(DateFormat.yMMMd().format(DateTime.now()) ==
                                                        DateFormat.yMMMd().format(
                                                            DateTime.parse(
                                                                _messageListAll[i]
                                                                    .createDate!))
                                                    ? DateFormat.Hm(AppLocalizations.of(context)!.date)
                                                        .format(DateTime.parse(
                                                            _messageListAll[i]
                                                                .createDate!))
                                                    : DateFormat.MMMMd(AppLocalizations.of(context)!.date)
                                                        .format(DateTime.parse(_messageListAll[i].createDate!))),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: Text(
                                                    _messageListAll[i]
                                                        .messageSubject!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          _messageListAll[i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _messageListAll[i]
                                                      .messageText!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider()
                          ],
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

  Widget TabBarReceivedMessageWidget(BuildContext context) {
    _messageListReceived.clear();
    for (int i = 0;
        i < _controllerMessage.getReceived.value!.result!.messageList!.length;
        i++) {
      for (int j = 0;
          j <
              _controllerMessage.getReceived.value!.result!.messageList![i]
                  .toUserList!.length;
          j++) {
        print(_controllerMessage
            .getReceived.value!.result!.messageList![i].toUserList![j].id);
        if (_controllerMessage
                    .getReceived.value!.result!.messageList![i].fromUser ==
                widget.UserId ||
            _controllerMessage.getReceived.value!.result!.messageList![i]
                    .toUserList![j].id ==
                widget.UserId) {
          _messageListReceived.add(
              _controllerMessage.getReceived.value!.result!.messageList![i]);
        }
      }
    }
    return Column(
      children: [
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
                    prefixIcon: Icon(Icons.search),
                    hint: AppLocalizations.of(context)!.search,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, right: 20),
              child: PopupMenuButton(
                  child: Center(
                      child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 27,
                  )),
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.newGroup),
                          value: 1,
                        ),
                        PopupMenuItem(
                          child: Text(
                              AppLocalizations.of(context)!.newPublicGroup),
                          value: 2,
                        ),
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.settings),
                          value: 3,
                        )
                      ]),
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _messageListReceived.length,
                    itemBuilder: (ctx, i) {
                      return InkWell(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => MessageDetail(
                          //       messageList: _messageListReceived[i],differentPage: 1,
                          //     )));
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 20, right: 20, bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        boxShadow: standartCardShadow(),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        _messageListReceived[i]
                                            .fromUserPhotoPath!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 3.0),
                                                child: Text(
                                                  _messageListReceived[i]
                                                      .fromUserNameAndSurname!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          _messageListReceived[
                                                                      i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Spacer(),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: Text(DateFormat.yMMMd().format(
                                                              DateTime.now()) ==
                                                          DateFormat.yMMMd().format(
                                                              DateTime.parse(
                                                                  _messageListReceived[i]
                                                                      .createDate!))
                                                      ? DateFormat.Hm(AppLocalizations.of(context)!.date)
                                                          .format(DateTime.parse(
                                                              _messageListReceived[i].createDate!))
                                                      : DateFormat.MMMMd(AppLocalizations.of(context)!.date).format(DateTime.parse(_messageListReceived[i].createDate!)))),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: Text(
                                                    _messageListReceived[i]
                                                        .messageSubject!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          _messageListReceived[
                                                                      i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _messageListReceived[i]
                                                      .messageText!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider()
                          ],
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

  Widget TabBarSentMessageWidget(BuildContext context) {
    _messageListSent.clear();
    for (int i = 0;
        i < _controllerMessage.getSent.value!.result!.messageList!.length;
        i++) {
      for (int j = 0;
          j <
              _controllerMessage
                  .getSent.value!.result!.messageList![i].toUserList!.length;
          j++) {
        print(_controllerMessage
            .getSent.value!.result!.messageList![i].toUserList![j].id);
        if (_controllerMessage
                    .getSent.value!.result!.messageList![i].fromUser ==
                widget.UserId ||
            _controllerMessage
                    .getSent.value!.result!.messageList![i].toUserList![j].id ==
                widget.UserId) {
          _messageListSent
              .add(_controllerMessage.getSent.value!.result!.messageList![i]);
        }
      }
    }
    return Column(
      children: [
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
                    prefixIcon: Icon(Icons.search),
                    hint: AppLocalizations.of(context)!.search,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, right: 20),
              child: PopupMenuButton(
                  child: Center(
                      child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 27,
                  )),
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.newGroup),
                          value: 1,
                        ),
                        PopupMenuItem(
                          child: Text(
                              AppLocalizations.of(context)!.newPublicGroup),
                          value: 2,
                        ),
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.settings),
                          value: 3,
                        )
                      ]),
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _messageListSent.length,
                    itemBuilder: (ctx, i) {
                      return InkWell(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => MessageDetail(
                          //       messageList: _messageListSent[i],differentPage: 1,
                          //     )));
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 20, right: 20, bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        boxShadow: standartCardShadow(),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        _messageListSent[i].fromUserPhotoPath!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 3.0),
                                                child: Text(
                                                  _messageListSent[i]
                                                      .fromUserNameAndSurname!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          _messageListSent[i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(DateFormat.yMMMd().format(DateTime.now()) ==
                                                        DateFormat.yMMMd().format(
                                                            DateTime.parse(
                                                                _messageListSent[i]
                                                                    .createDate!))
                                                    ? DateFormat.Hm(AppLocalizations.of(context)!.date)
                                                        .format(DateTime.parse(
                                                            _messageListSent[i]
                                                                .createDate!))
                                                    : DateFormat.MMMMd(AppLocalizations.of(context)!.date)
                                                        .format(DateTime.parse(_messageListSent[i].createDate!))),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: Text(
                                                    _messageListSent[i]
                                                        .messageSubject!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          _messageListSent[i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _messageListSent[i]
                                                      .messageText!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider()
                          ],
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

  Widget TabBarDeletedMessageWidget(BuildContext context) {
    _messageListDelete.clear();
    for (int i = 0;
        i < _controllerMessage.getDelete.value!.result!.messageList!.length;
        i++) {
      for (int j = 0;
          j <
              _controllerMessage
                  .getDelete.value!.result!.messageList![i].toUserList!.length;
          j++) {
        print(_controllerMessage
            .getDelete.value!.result!.messageList![i].toUserList![j].id);
        if (_controllerMessage
                    .getDelete.value!.result!.messageList![i].fromUser ==
                widget.UserId ||
            _controllerMessage.getDelete.value!.result!.messageList![i]
                    .toUserList![j].id ==
                widget.UserId) {
          _messageListDelete
              .add(_controllerMessage.getDelete.value!.result!.messageList![i]);
        }
      }
    }
    return Column(
      children: [
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
                    prefixIcon: Icon(Icons.search),
                    hint: AppLocalizations.of(context)!.search,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, right: 20),
              child: PopupMenuButton(
                  child: Center(
                      child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 27,
                  )),
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.newGroup),
                          value: 1,
                        ),
                        PopupMenuItem(
                          child: Text(
                              AppLocalizations.of(context)!.newPublicGroup),
                          value: 2,
                        ),
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!.settings),
                          value: 3,
                        )
                      ]),
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _messageListDelete.length,
                    itemBuilder: (ctx, i) {
                      return InkWell(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => MessageDetail(
                          //       messageList: _messageListDelete[i],differentPage: 1,
                          //     )));
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 20, right: 20, bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        boxShadow: standartCardShadow(),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        _messageListDelete[i]
                                            .fromUserPhotoPath!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 3.0),
                                                child: Text(
                                                  _messageListDelete[i]
                                                      .fromUserNameAndSurname!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          _messageListDelete[i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(DateFormat.yMMMd().format(DateTime.now()) ==
                                                        DateFormat.yMMMd().format(
                                                            DateTime.parse(
                                                                _messageListDelete[i]
                                                                    .createDate!))
                                                    ? DateFormat.Hm(AppLocalizations.of(context)!.date)
                                                        .format(DateTime.parse(
                                                            _messageListDelete[i]
                                                                .createDate!))
                                                    : DateFormat.MMMMd(AppLocalizations.of(context)!.date)
                                                        .format(DateTime.parse(_messageListDelete[i].createDate!))),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: Text(
                                                    _messageListDelete[i]
                                                        .messageSubject!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          _messageListDelete[i]
                                                                  .isSeen!
                                                              ? FontWeight.w300
                                                              : FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _messageListDelete[i]
                                                      .messageText!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider()
                          ],
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
}
