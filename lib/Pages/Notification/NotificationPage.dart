import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerNotification.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Pages/Collaboration/CollaborationPage.dart';
import 'package:undede/Pages/Collaboration/CommonDetailsPage.dart';
import 'package:undede/Pages/Collaboration/CommonDetailsPage2.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/CustomAppBarWithSearch.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Notifications/GetNotificationListResult.dart';
import 'package:undede/model/Todo/CommonTodo.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerChatNew _controllerChat = Get.put(ControllerChatNew());
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  TextEditingController _searchTextController = new TextEditingController();
  TabController? _tabController;
  int currentTab = 0;
  List<AnimationController> _controller = <AnimationController>[];
  List<bool> listExpand = <bool>[];
  ScrollController notificationScrollController = new ScrollController();
  bool isUploadingNewPage = false;
  int perPage = 50;
  int unreadPage = 0;
  int readPage = 0;
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    _tabController!.addListener(() {
      setState(() {
        currentTab = _tabController!.index;
      });
    });

    notificationScrollController.addListener(() async {
      if (!isUploadingNewPage &&
          notificationScrollController.position.atEdge &&
          notificationScrollController.position.pixels != 0) {
        if (currentTab == 0) {
          //UNREAD
          if (_controllerDB.notificationUnreadCount >
              _controllerDB.notifications
                  .where((e) => e.isRead == false)
                  .length) {
            setState(() {
              unreadPage += 1;
              _controllerDB.getUnreadNotifications(
                  AppLocalizations.of(context)!.localeName, unreadPage);
            });
          }
        } else {
          if (_controllerDB.notificationReadCount >
              _controllerDB.notifications
                  .where((e) => e.isRead == true)
                  .length) {
            setState(() {
              readPage += 1;
              _controllerDB.getReadNotifications(
                  AppLocalizations.of(context)!.localeName, readPage);
            });
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controllerDB
          .initializeNotificationList(AppLocalizations.of(context)!.localeName);
      _controllerDB.update();
      setState(() {});
    });
  }

  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerNotification _controllerNotification = ControllerNotification();

  UpdateAllNotificationRead() {
    _controllerNotification.UpdateAllNotificationRead(_controllerDB.headers())
        .then((value) => {if (value) {}});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerDB>(
        builder: (_) => Scaffold(
              backgroundColor: Get.theme.scaffoldBackgroundColor,
              appBar: CustomAppBarWithSearch(
                  title: AppLocalizations.of(context)!.notification,
                  isNotificationPage: true,
                  onChanged: (val) {},
                  openFilterFunction: () {},
                  openBoardFunction: () {
                    if (_controllerDB.notifications
                            .where((x) => x.isRead == false)
                            .length >
                        0) {
                      _controllerNotification.UpdateAllNotificationRead(
                          _controllerDB.headers());
                      _controllerDB.initializeNotificationList(
                          AppLocalizations.of(context)!.localeName);
                    }
                  }),
              body: Container(
                width: Get.width,
                height: Get.height,
                child: Column(children: [
                  Container(
                    width: Get.width,
                    height: 50,
                    child: DefaultTabController(
                      length: 2,
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/icon/mail.png',
                                  width: 25,
                                  color: Colors.black54,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.unread +
                                      " (${_controllerDB.notificationUnreadCount})",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: currentTab == 0
                                          ? FontWeight.w500
                                          : FontWeight.normal),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/icon/openletter.png',
                                  width: 25,
                                  color: Colors.black54,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.read +
                                      " (${_controllerDB.notificationReadCount})",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: currentTab == 1
                                          ? FontWeight.w500
                                          : FontWeight.normal),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 20),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Expanded(
                  //         child: Container(
                  //           height: 45,
                  //           decoration: BoxDecoration(
                  //               boxShadow: standartCardShadow(),
                  //               borderRadius: BorderRadius.circular(45)),
                  //           child: CustomTextField(
                  //             prefixIcon: Icon(Icons.search),
                  //             hint: AppLocalizations.of(context).search,
                  //             controller: _searchTextController,
                  //             onChanged: (val) {
                  //               setState(() {});
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width: 10,
                  //       ),
                  //       AnimatedContainer(
                  //         duration: Duration(milliseconds: 500),
                  //         width: currentTab == 0
                  //             ? 45
                  //             : _searchTextController.text.isBlank
                  //                 ? 0
                  //                 : 45,
                  //         height: currentTab == 0
                  //             ? 45
                  //             : _searchTextController.text.isBlank
                  //                 ? 0
                  //                 : 45,
                  //         child: FloatingActionButton(
                  //           onPressed: () {
                  //             if (_controllerDB.notifications
                  //                     .where((x) => x.isRead == false)
                  //                     .length >
                  //                 0) {
                  //               _controllerNotification
                  //                   .UpdateAllNotificationRead(
                  //                       _controllerDB.headers());
                  //               _controllerDB.initializeNotificationList(
                  //                   AppLocalizations.of(context).localeName);
                  //             }
                  //           },
                  //           child: !_searchTextController.text.isBlank
                  //               ? Text((currentTab == 0
                  //                       ? filterUnreadNotifications()
                  //                       : filterReadNotifications())
                  //                   .length
                  //                   .toString())
                  //               : Image.asset(
                  //                   'assets/images/icon/mark.png',
                  //                   width: 25,
                  //                   color: Get.theme.primaryColor,
                  //                 ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Container(
                          width: Get.width,
                          color: Get.theme.scaffoldBackgroundColor,
                          child: Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                            ),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              controller: notificationScrollController,
                              child: Column(
                                children: [
                                  ListView.builder(
                                      key: const PageStorageKey<String>(
                                          'unreadListView'),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: ScrollController(
                                          keepScrollOffset: true),
                                      itemCount:
                                          filterUnreadNotifications().length,
                                      itemBuilder: (ctx, index) {
                                        if (filterUnreadNotifications()[index]
                                                .notificationTemplateType !=
                                            15) {
                                          listExpand.add(true);
                                        } else {
                                          listExpand.add(false);
                                        }

                                        _controller.add(new AnimationController(
                                          vsync: this,
                                          duration: Duration(milliseconds: 300),
                                          upperBound: 0.5,
                                        ));
                                        return buildContactCard(
                                            index,
                                            filterUnreadNotifications()[index],
                                            context);
                                      }),
                                  SizedBox(
                                    height: 100,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: Get.width,
                          color: Get.theme.secondaryHeaderColor,
                          child: Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                            ),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              controller: notificationScrollController,
                              child: Column(
                                children: [
                                  ListView.builder(
                                      key: const PageStorageKey<String>(
                                          'readListView'),
                                      controller: ScrollController(
                                          keepScrollOffset: true),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          filterReadNotifications().length,
                                      itemBuilder: (ctx, index) {
                                        listExpand.add(false);
                                        _controller.add(new AnimationController(
                                          vsync: this,
                                          duration: Duration(milliseconds: 300),
                                          upperBound: 0.5,
                                        ));
                                        return buildContactCard(
                                            index,
                                            filterReadNotifications()[index],
                                            context);
                                      }),
                                  SizedBox(
                                    height: 100,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ));
  }

  /*List<NotificationResponseList> filterNotifications(int tab) {
    List<NotificationResponseList> unread =
    new List<NotificationResponseList>();
    List<NotificationResponseList> read = new List<NotificationResponseList>();
    List<NotificationResponseList> finalSortedList =
    new List<NotificationResponseList>();

    String txt = _searchTextController.text;

    unread.addAll(_controllerDB.notifications.where((x) =>
    x.isRead == false &&
        (txt != null && x.text.toLowerCase().contains(txt.toLowerCase()))));
    unread.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    read.addAll(_controllerDB.notifications.where((x) =>
    x.isRead == true &&
        (txt != null && x.text.toLowerCase().contains(txt.toLowerCase()))));
    read.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    if (tab == 0)
      return unread;
    else if (tab == 1) return read;

    // all için kullanılabilir
    finalSortedList = unread + read;
    return finalSortedList;
  }*/

  List<NotificationResponseList> filterUnreadNotifications() {
    List<NotificationResponseList> unread = <NotificationResponseList>[];

    String txt = _searchTextController.text;

    unread.addAll(_controllerDB.notifications.where((x) =>
        x.isRead == false &&
        (x.text!.toLowerCase().contains(txt.toLowerCase()))));
    unread.sort((a, b) => b.createDateTime!.compareTo(a.createDateTime!));

    return unread;
  }

  List<NotificationResponseList> filterReadNotifications() {
    List<NotificationResponseList> read = <NotificationResponseList>[];

    String txt = _searchTextController.text;

    read.addAll(_controllerDB.notifications.where((x) =>
        x.isRead == true &&
        (x.text!.toLowerCase().contains(txt.toLowerCase()))));
    read.sort((a, b) => b.createDateTime!.compareTo(a.createDateTime!));

    return read;
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  Widget buildContactCard(
      int index, NotificationResponseList notify, BuildContext context) {
    String description = removeAllHtmlTags(notify.text!);
    DateTime createDateTime = notify.createDateTime!;
    var dateFormatterDate =
        new DateFormat.yMMMd(AppLocalizations.of(context)!.localeName);
    var dateFormatterTime =
        new DateFormat.Hm(AppLocalizations.of(context)!.localeName);

    return Material(
      color: Color(0xFFF0F7F7),
      child: InkWell(
        onTap: () async {
          if (notify.notificationTemplateType == 9)
            return; // evet veya hayıra basıcak burda işleme gerek yok

          if (notify.isRead! && notify.notificationTemplateType != 15) {
            /*_controllerDB.notifications
                .firstWhere((x) => x.id == notify.id)
                .isRead = false;
            _controllerDB.update();*/
            return;
          } else {
            print("UNREAD' A atıyor");
            /*if (!await _controllerNotification.UpdateInviteProcess(
                _controllerDB.headers(),
                Url: notify.url,
                NotificationId: notify.id,
                IsAccept: true)) {
              _controllerDB.notifications
                  .firstWhere((x) => x.id == notify.id)
                  .isRead = true;
              _controllerDB.update();
            }*/
          }

          if (notify.notificationTemplateType == 15 ||
              notify.notificationTemplateType == 35) {
            CommonTodo? notificationTodo = (await _controllerTodo.GetTodo(
                    _controllerDB.headers(), notify.todoId!))
                .commonTodo;

            Get.to(() => CommonDetailsPage(
                  todoId: notify.todoId!,
                  commonBoardId: notify.commonId!,
                  selectedTab: 1,
                  commonTodo: notificationTodo!,
                  openCommentId: notify.notificationTemplateType == 35
                      ? null
                      : notify.commentId,
                  commonBoardTitle: "",
                  cloudPerm: true,
                ));
            UpdateInviteProcess(notify.url!, notify.id!, true);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: index % 2 != 0 ? 5 : 2),
              decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.only(
                    topLeft: index % 2 != 0 ? Radius.zero : Radius.circular(15),
                    topRight:
                        index % 2 != 0 ? Radius.zero : Radius.circular(15),
                    bottomLeft:
                        index % 2 == 0 ? Radius.zero : Radius.circular(15),
                    bottomRight:
                        index % 2 == 0 ? Radius.zero : Radius.circular(15),
                  )),
              constraints: BoxConstraints(
                  minHeight: 65, minWidth: double.infinity, maxHeight: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              NotificationIcon(
                                  notify.notificationTemplateType!),
                              size: 18,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    NotificationTitle(
                                        notify.notificationTemplateType!),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: Text(
                                      dateFormatterDate.format(createDateTime) +
                                          " " +
                                          dateFormatterTime.format(
                                              createDateTime), //+ " - " + notify.notificationTemplateType.toString(),
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: NotificationDescription(
                                          notify.notificationTemplateType!,
                                          description),
                                    ),
                                    !notify.isRead!
                                        ? SizedBox(
                                            width: 10,
                                          )
                                        : Container(),
                                    !notify.isRead!
                                        ? GestureDetector(
                                            onTap: () {
                                              UpdateInviteProcess(notify.url!,
                                                  notify.id!, true);
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 33,
                                              child: Icon(
                                                //SAĞ ALTTAKİ İKON
                                                Icons.mark_as_unread,
                                                color: Get
                                                    .theme.secondaryHeaderColor,
                                                size: 25,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    RotationTransition(
                                      turns: Tween(begin: 0.0, end: 1.0)
                                          .animate(_controller[index]),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (!notify.isRead! &&
                                              [7, 8].contains(notify
                                                  .notificationTemplateType)) {
                                            setState(() {
                                              if (listExpand[index]) {
                                                _controller[index]
                                                  ..reverse(from: 0.5);
                                              } else {
                                                _controller[index]
                                                  ..forward(from: 0.0);
                                              }
                                              listExpand[index] =
                                                  !listExpand[index];
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 33,
                                          child: Icon(
                                            //SAĞ ALTTAKİ İKON
                                            NotificationSubIcon(notify
                                                .notificationTemplateType!),
                                            color:
                                                Get.theme.secondaryHeaderColor,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  (notify.isRead! ||
                          notify.notificationTemplateType == 15 ||
                          notify.notificationTemplateType == 35 ||
                          notify.notificationTemplateType == 0)
                      ? Container()
                      : AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: listExpand[index] ? 40 : 0,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          margin: EdgeInsets.symmetric(
                              vertical: listExpand[index] ? 3 : 0),
                          decoration: BoxDecoration(
                              //color: Color(0xFFe3d5a4),
                              ),
                          child: Container(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                contactMoreIcon(() {
                                  confirmQuestion(notify, false);
                                }, AppLocalizations.of(context)!.no, index,
                                    Colors.red),
                                Spacer(),
                                contactMoreIcon(() {
                                  confirmQuestion(notify, true);
                                }, AppLocalizations.of(context)!.yes, index,
                                    Colors.green),
                                SizedBox(
                                  width: 20,
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
    );
  }

  void confirmQuestion(NotificationResponseList notify, bool isConfirm) async {
    bool? hasError;

    if (notify.notificationTemplateType == 7) {
      hasError = await _controllerCommon.ConfirmInviteUsersCommonBoard(
              _controllerDB.headers(),
              NotificationId: notify.id,
              UserCommonOrderId: int.parse(notify.url!),
              IsAccept: isConfirm)
          .then((value) async {
        if (isConfirm) {
          _controllerBottomNavigationBar.lockUI = true;
          _controllerBottomNavigationBar.goCollabPage = true;
          _controllerBottomNavigationBar.update();
          _controllerCommon.commonNotificationId = notify.commonId!;
          _controllerCommon.commonRefreshCurrentPage = true;
          _controllerCommon.update();
          Navigator.pop(context);
        }
        _controllerDB.notifications
            .firstWhere((x) => x.id == notify.id)
            .isRead = true;
        _controllerDB.update();
        return true;
      });
    } else if (notify.notificationTemplateType == 8) {
      hasError = await _controllerTodo.ConfirmInviteUsersCommonTask(
              _controllerDB.headers(),
              UserCommonOrderId: int.parse(notify.url!),
              NotificationId: notify.id,
              IsAccept: isConfirm)
          .then((value) {
        if (isConfirm) {
          print(notify.commonId);
          print(notify.todoId);
          _controllerBottomNavigationBar.lockUI = true;
          _controllerBottomNavigationBar.goCollabPage = true;
          _controllerBottomNavigationBar.update();
          _controllerCommon.commonNotificationId = notify.commonId!;
          _controllerCommon.todoNotificationId = notify.todoId!;
          _controllerCommon.commobReloadforNotification = true;
          _controllerCommon.update();
          _controllerBottomNavigationBar.goCollabPage = true;
          _controllerBottomNavigationBar.update();

          Navigator.pop(context);
        }
        _controllerDB.notifications
            .firstWhere((x) => x.id == notify.id)
            .isRead = true;
        _controllerDB.update();
        return true;
      });
    } else if (notify.notificationTemplateType == 9) {
      await _controllerNotification.UpdateInviteProcess(_controllerDB.headers(),
          Url: notify.url, NotificationId: notify.id, IsAccept: isConfirm);
      _controllerChatNew.loadChatUsers = true;
      _controllerChatNew.update();
    } else if (notify.notificationTemplateType == 13) {
      await _controllerCalendar.ConfirmInviteCalendarUser(
          _controllerDB.headers(),
          NotificationId: notify.id,
          UserId: _controllerDB.user.value!.result!.id,
          IsAccept: true,
          Id: int.parse(notify.url!));
    }
    if (!hasError!) {
      await _controllerNotification.UpdateInviteProcess(_controllerDB.headers(),
              Url: (notify.notificationTemplateType == 7 ? notify.commonId : "")
                  .toString(),
              NotificationId: notify.id,
              IsAccept: true)
          .then((res) {
        if (!res.hasError!) {
          _controllerDB.notifications
              .firstWhere((x) => x.id == notify.id)
              .isRead = true;
          _controllerDB.update();
        }
      });
    }
    _controllerDB
        .initializeNotificationList(AppLocalizations.of(context)!.localeName);
  }

  GestureDetector contactMoreIcon(
      Function runOnTap, String title, int index, Color color) {
    return GestureDetector(
      onTap: () {
        runOnTap();
      },
      child: AnimatedOpacity(
        opacity: listExpand[index] ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          width: 55,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color,
            boxShadow: standartCardShadow(),
          ),
          padding: EdgeInsets.all(7),
          child: AnimatedOpacity(
            opacity: listExpand[index] ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String NotificationTitle(int notificationTemplateType) {
    if (notificationTemplateType == 15) {
      return AppLocalizations.of(context)!.incomingComment;
    } else if (notificationTemplateType == 7) {
      return AppLocalizations.of(context)!.boardInvitation;
    } else if (notificationTemplateType == 8) {
      return AppLocalizations.of(context)!.taskInvitation;
    } else if (notificationTemplateType == 9) {
      return AppLocalizations.of(context)!.userInvitation;
    } else if (notificationTemplateType == 35) {
      return "Task Document Uploaded";
    } else if (notificationTemplateType == 0) {
      return AppLocalizations.of(context)!.systemMessage;
    }
    return AppLocalizations.of(context)!.notification +
        " " +
        notificationTemplateType.toString();
  }

  Widget NotificationDescription(int notificationTemplateType, String desc) {
    if (notificationTemplateType == 15) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc.split(",").first.trim()),
          Text(desc
              .split(
                ",",
              )[1]
              .trim()),
          Divider(
            height: 5,
          ),
          Text(desc.split(",").last.trim())
        ],
      );
    } else
      return Text(desc);
  }

  IconData NotificationIcon(int notificationTemplateType) {
    if (notificationTemplateType == 15) {
      return Icons.mark_chat_read_outlined;
    } else if (notificationTemplateType == 7) {
      return Icons.switch_account_outlined;
    } else if (notificationTemplateType == 8) {
      return Icons.task_alt_outlined;
    } else if (notificationTemplateType == 9) {
      return Icons.person_add_outlined;
    }
    return Icons.notifications_active_outlined;
  }

  IconData NotificationSubIcon(int notificationTemplateType) {
    if (notificationTemplateType == 15 || notificationTemplateType == 35) {
      return Icons.double_arrow;
    } else if (notificationTemplateType == 7) {
      return Icons.expand_more;
    } else if (notificationTemplateType == 8) {
      return Icons.expand_more;
    } else if (notificationTemplateType == 9) {
      return Icons.expand_more;
    }
    return Icons.subdirectory_arrow_right;
  }

  UpdateInviteProcess(String Url, int NotificationId, bool IsAccept) {
    Future.delayed(Duration(seconds: 2));
    _controllerNotification.UpdateInviteProcess(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        Url: Url,
        NotificationId: NotificationId,
        IsAccept: IsAccept);
  }
}
