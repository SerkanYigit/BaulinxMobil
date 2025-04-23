/* import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Pages/Collaboration/CollaborationTodoCheckList.dart';
import 'package:undede/Pages/Collaboration/TodoComments/TodoComments.dart';
import 'package:undede/Pages/Contact/CommonDetailEditPage.dart';
import 'package:undede/Pages/Contact/NotePageTabPage.dart';
import 'package:undede/Pages/Note/NotePage.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

class CommonDetailsPage extends StatefulWidget {
  int todoId;
  int commonBoardId;
  int selectedTab;
  String commonBoardTitle;
  final CommonTodo commonTodo;
  Function? toggleSheetClose;
  bool togglePlay;
  int? openCommentId;
  int? calendarId;
  bool? cloudPerm = true;
  bool? isDraggable = false;
  bool isPrivate = false;
  bool refreshPage = false;
  Function? refreshPageFunction;
  CommonDetailsPage(
      {required this.todoId,
      required this.commonBoardId,
      required this.selectedTab,
      required this.commonBoardTitle,
      required this.commonTodo,
      this.isPrivate = false,
      this.openCommentId,
      this.calendarId,
      this.cloudPerm,
      this.isDraggable,
      this.toggleSheetClose,
      this.togglePlay = false,
      this.refreshPage = false,
      this.refreshPageFunction});

  @override
  _CommonDetailsPageState createState() => _CommonDetailsPageState();
}

class _CommonDetailsPageState extends State<CommonDetailsPage>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  TabController? _tabController;
  int currentTab = 0;
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      length: !widget.isPrivate ? 2 : 5,
      vsync: this,
      initialIndex: 0,
    );
    _tabController!.addListener(() {
      print('tabİndex: ${_tabController!.index}');
      setState(() {
        currentTab = _tabController!.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await GetTodoComments();
      setState(() {
        _tabController!.animateTo(widget.selectedTab);
        currentTab = widget.selectedTab;
      });
    });
  }

  GetTodoComments() async {
    await _controllerTodo.GetTodoComments(
      _controllerDB.headers(),
      TodoId: widget.todoId,
      UserId: _controllerDB.user.value!.result!.id!,
    ).then((value) => {
          setState(() {
            print(value);
            isLoading = false;
          })
        });
  }

  deleteTodoAppointment(int Id) async {
    await _controllerCalendar.DeleteTodoAppointment(_controllerDB.headers(), Id)
        .then((value) => {
              if (value)
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.deleted,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    //backgroundColor: Colors.red,
                    //textColor: Colors.white,
                    fontSize: 16.0)
            });
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return GetBuilder<ControllerCommon>(builder: (c) {
      return GetBuilder<ControllerTodo>(builder: (c) {
        return Scaffold(
            backgroundColor: const Color.fromARGB(255, 247, 255, 11),
            // Get.theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: isTablet
                  ? widget.commonTodo.content!
                  : AppLocalizations.of(context)!.collaboration,
              isCollabDetail: true,
              onBackPress: () {
                widget.togglePlay
                    ? widget.toggleSheetClose!()
                    : Navigator.pop(context);
              },
            ),
            body: isLoading
                ? CustomLoadingCircle(
                    widget: Text("CommonDetailsPage"),
                  )
                : Stack(
                    children: [
                      Container(
                          width: Get.width,
                          height: Get.height,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0F7F7),
                                  ),
                                  child: CustomScrollView(
                                    physics: BouncingScrollPhysics(),
                                    slivers: [
                                      SliverFillRemaining(
                                        hasScrollBody: true,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 7),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  !isTablet
                                                      ? Text(
                                                          "${widget.commonBoardTitle}",
                                                          style: TextStyle(
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      : SizedBox(),
                                                  !isTablet
                                                      ? widget.commonBoardTitle
                                                              .isBlank!
                                                          ? Container()
                                                          : Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          3),
                                                              child: Icon(
                                                                Icons
                                                                    .double_arrow,
                                                                color: Get
                                                                    .theme
                                                                    .colorScheme
                                                                    .surface,
                                                              ))
                                                      : SizedBox(),
                                                  !isTablet
                                                      ? Flexible(
                                                          child: Text(
                                                            "${widget.commonTodo.content}",
                                                            style: TextStyle(
                                                                fontSize: 19,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ),
                                            //_tabMenuForTablet(context),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            isTablet
                                                ? Expanded(
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start, //start
                                                      children: [
                                                        Expanded(
                                                            flex: isTablet
                                                                ? 1
                                                                : 3,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child:
                                                                  _tabMenuForTablet(
                                                                      context),
                                                            )),
                                                        VerticalDivider(
                                                          color: Colors.grey,
                                                          thickness: 0.5,
                                                        ),
                                                        Expanded(
                                                          flex: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .longestSide >
                                                                  850
                                                              ? Get.height > 800
                                                                  ? 9
                                                                  : 14
                                                              : 12,
                                                          child: TabBarView(
                                                            controller:
                                                                _tabController,
                                                            children: !widget
                                                                    .isPrivate
                                                                ? [
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                20),
                                                                        child:
                                                                            Navigator(
                                                                          key: Key(
                                                                              'xx'),
                                                                          onGenerateRoute:
                                                                              (routeSettings) {
                                                                            return MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  // !widget
                                                                                  //         .cloudPerm
                                                                                  //     ? Column(
                                                                                  //         children: [
                                                                                  //           Text(
                                                                                  //             AppLocalizations.of(context).about,
                                                                                  //             style: TextStyle(fontSize: 25),
                                                                                  //           ),
                                                                                  //         ],
                                                                                  //       )
                                                                                  //     :
                                                                                  DirectoryDetail(
                                                                                folderName: "",
                                                                                hideHeader: true,
                                                                                fileManagerType: FileManagerType.CommonTask,
                                                                                todoId: widget.todoId, //widget.todoId,
                                                                              ),
                                                                            );
                                                                          },
                                                                        )),
                                                                    CommonDetailEditPage(
                                                                      todoId: widget
                                                                          .todoId,
                                                                      commonBoardId:
                                                                          widget
                                                                              .commonBoardId,
                                                                      commonTodo:
                                                                          widget
                                                                              .commonTodo,
                                                                      isPrivate:
                                                                          widget
                                                                              .isPrivate,
                                                                      toggleSheetClose:
                                                                          () {
                                                                        widget
                                                                            .toggleSheetClose!();
                                                                      },
                                                                    ),
                                                                  ]
                                                                : [
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                20),
                                                                        child:
                                                                            Navigator(
                                                                          key: Key(
                                                                              'xx'),
                                                                          onGenerateRoute:
                                                                              (routeSettings) {
                                                                            return MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  // !widget
                                                                                  //         .cloudPerm
                                                                                  //     ? Column(
                                                                                  //         children: [
                                                                                  //           Text(
                                                                                  //             AppLocalizations.of(context).about,
                                                                                  //             style: TextStyle(fontSize: 25),
                                                                                  //           ),
                                                                                  //         ],
                                                                                  //       )
                                                                                  //     :
                                                                                  DirectoryDetail(
                                                                                folderName: "",
                                                                                hideHeader: true,
                                                                                fileManagerType: FileManagerType.CommonTask,
                                                                                todoId: widget.todoId, //widget.todoId,
                                                                              ),
                                                                            );
                                                                          },
                                                                        )),
                                                                    TodoComments(
                                                                      todoId: widget
                                                                          .todoId,
                                                                      openCommentId:
                                                                          widget
                                                                              .openCommentId,
                                                                      header:
                                                                          "${widget.commonBoardTitle} - ${widget.commonTodo.content}",
                                                                    ),
                                                                    CollaborationTodoCheckList(
                                                                      todoId: widget
                                                                          .todoId,
                                                                    ),
                                                                    NotePageTabPage(
                                                                      CustomerId:
                                                                          widget
                                                                              .todoId,
                                                                      moduleType:
                                                                          37,
                                                                    ),
                                                                    // (_controllerTodo.hasEditTodoPerm(
                                                                    //                 widget
                                                                    //                     .commonBoardId,
                                                                    //                 widget
                                                                    //                     .todoId) ==
                                                                    //             true) &&
                                                                    //         !_controllerCommon
                                                                    //             .hasFileManagerCommonPerm(
                                                                    //           widget
                                                                    //               .commonBoardId,
                                                                    //         )
                                                                    //     ? Column(
                                                                    //         children: [
                                                                    //           Text(
                                                                    //             AppLocalizations.of(
                                                                    //                     context)
                                                                    //                 .noPermission,
                                                                    //             style: TextStyle(
                                                                    //                 fontSize:
                                                                    //                     25),
                                                                    //           ),
                                                                    //         ],
                                                                    //       )
                                                                    //     :
                                                                    CommonDetailEditPage(
                                                                      todoId: widget
                                                                          .todoId,
                                                                      commonBoardId:
                                                                          widget
                                                                              .commonBoardId,
                                                                      commonTodo:
                                                                          widget
                                                                              .commonTodo,
                                                                      isPrivate:
                                                                          widget
                                                                              .isPrivate,
                                                                      toggleSheetClose:
                                                                          () {
                                                                        widget.refreshPage
                                                                            ? widget.refreshPageFunction!()
                                                                            : null;
                                                                        widget
                                                                            .toggleSheetClose!();
                                                                      },
                                                                    ),
                                                                  ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start, //start
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child:
                                                                  _tabMenuForPhone(
                                                                      context),
                                                            )),
                                                        Divider(
                                                          color: Colors.grey,
                                                          thickness: 0.5,
                                                        ),
                                                        Expanded(
                                                          flex: 9,
                                                          child: TabBarView(
                                                            controller:
                                                                _tabController,
                                                            children: !widget
                                                                    .isPrivate
                                                                ? [
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                20),
                                                                        child:
                                                                            Navigator(
                                                                          key: Key(
                                                                              'xx'),
                                                                          onGenerateRoute:
                                                                              (routeSettings) {
                                                                            return MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  // !widget
                                                                                  //         .cloudPerm
                                                                                  //     ? Column(
                                                                                  //         children: [
                                                                                  //           Text(
                                                                                  //             AppLocalizations.of(context).about,
                                                                                  //             style: TextStyle(fontSize: 25),
                                                                                  //           ),
                                                                                  //         ],
                                                                                  //       )
                                                                                  //     :
                                                                                  DirectoryDetail(
                                                                                folderName: "",
                                                                                hideHeader: true,
                                                                                fileManagerType: FileManagerType.CommonTask,
                                                                                todoId: widget.todoId, //widget.todoId,
                                                                              ),
                                                                            );
                                                                          },
                                                                        )),
                                                                    CommonDetailEditPage(
                                                                      todoId: widget
                                                                          .todoId,
                                                                      commonBoardId:
                                                                          widget
                                                                              .commonBoardId,
                                                                      commonTodo:
                                                                          widget
                                                                              .commonTodo,
                                                                      isPrivate:
                                                                          widget
                                                                              .isPrivate,
                                                                      toggleSheetClose:
                                                                          () {
                                                                        widget
                                                                            .toggleSheetClose!();
                                                                      },
                                                                    ),
                                                                  ]
                                                                : [
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                20),
                                                                        child:
                                                                            Navigator(
                                                                          key: Key(
                                                                              'xx'),
                                                                          onGenerateRoute:
                                                                              (routeSettings) {
                                                                            return MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  // !widget
                                                                                  //         .cloudPerm
                                                                                  //     ? Column(
                                                                                  //         children: [
                                                                                  //           Text(
                                                                                  //             AppLocalizations.of(context).about,
                                                                                  //             style: TextStyle(fontSize: 25),
                                                                                  //           ),
                                                                                  //         ],
                                                                                  //       )
                                                                                  //     :
                                                                                  DirectoryDetail(
                                                                                folderName: "",
                                                                                hideHeader: true,
                                                                                fileManagerType: FileManagerType.CommonTask,
                                                                                todoId: widget.todoId, //widget.todoId,
                                                                              ),
                                                                            );
                                                                          },
                                                                        )),
                                                                    TodoComments(
                                                                      todoId: widget
                                                                          .todoId,
                                                                      openCommentId:
                                                                          widget
                                                                              .openCommentId,
                                                                      header:
                                                                          "${widget.commonBoardTitle} - ${widget.commonTodo.content}",
                                                                    ),
                                                                    CollaborationTodoCheckList(
                                                                      todoId: widget
                                                                          .todoId,
                                                                    ),
                                                                    NotePageTabPage(
                                                                      CustomerId:
                                                                          widget
                                                                              .todoId,
                                                                      moduleType:
                                                                          37,
                                                                    ),
                                                                    // (_controllerTodo.hasEditTodoPerm(
                                                                    //                 widget
                                                                    //                     .commonBoardId,
                                                                    //                 widget
                                                                    //                     .todoId) ==
                                                                    //             true) &&
                                                                    //         !_controllerCommon
                                                                    //             .hasFileManagerCommonPerm(
                                                                    //           widget
                                                                    //               .commonBoardId,
                                                                    //         )
                                                                    //     ? Column(
                                                                    //         children: [
                                                                    //           Text(
                                                                    //             AppLocalizations.of(
                                                                    //                     context)
                                                                    //                 .noPermission,
                                                                    //             style: TextStyle(
                                                                    //                 fontSize:
                                                                    //                     25),
                                                                    //           ),
                                                                    //         ],
                                                                    //       )
                                                                    //     :
                                                                    CommonDetailEditPage(
                                                                      todoId: widget
                                                                          .todoId,
                                                                      commonBoardId:
                                                                          widget
                                                                              .commonBoardId,
                                                                      commonTodo:
                                                                          widget
                                                                              .commonTodo,
                                                                      isPrivate:
                                                                          widget
                                                                              .isPrivate,
                                                                      toggleSheetClose:
                                                                          () {
                                                                        widget.refreshPage
                                                                            ? widget.refreshPageFunction!()
                                                                            : null;
                                                                        widget
                                                                            .toggleSheetClose!();
                                                                      },
                                                                    ),
                                                                  ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  /*SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: Get.width,
                                height: 35,
                                padding: EdgeInsets.symmetric(horizontal: 5,),
                                margin: EdgeInsets.only(top: 7),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: ListView(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      TabMenu(Icons.edit, 'Düzenle', 0),
                                      TabMenu(Icons.cloud_upload, 'Yükle', 1),
                                      TabMenu(Icons.comment_outlined, 'Yorumlar', 2),
                                      TabMenu(Icons.checklist, 'Takip', 3),
                                      TabMenu(Icons.note, 'Notlar', 4),
                                      TabMenu(Icons.color_lens, 'Tasarım', 5),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 15,),
                              /*Container(
                                width: Get.width,
                                height: 500,
                                child: NestedScrollView(
                                  headerSliverBuilder: (context, value) {
                                    return [
                                      SliverToBoxAdapter(child: _buildCarousel()),
                                      SliverToBoxAdapter(
                                        child: TabBar(
                                          controller: _tabController2,
                                          labelColor: Colors.redAccent,
                                          isScrollable: false,
                                          tabs: myTabs,
                                        ),
                                      ),
                                    ];
                                  },
                                  body: Container(
                                    child: TabBarView(
                                      controller: _tabController2,
                                      children: [_buildTabContext(2), _buildTabContext(200), _buildTabContext(2)],
                                    ),
                                  ),
                                ),
                              ),*/
                              /*Container(
                                width: Get.width,
                                height: 500,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    commonDetailsEditPage(),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: DirectoryDetail(folderName: "", hideHeader: true)
                                    ),
                                    Container(),
                                    Container(
                                      width: 50,
                                      height: 50,
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                    ),
                                  ],
                                ),
                              ),*/
                              SizedBox(height: 100,)
                            ],
                          ),
                        ),*/
                                ),
                              )
                            ],
                          )),
                      widget.calendarId != null
                          ? Positioned(
                              bottom: 100,
                              left: 5,
                              child: FloatingActionButton(
                                heroTag: "commonDetailsDelete",
                                onPressed: () async {
                                  await deleteTodoAppointment(
                                      widget.calendarId!);
                                  _controllerCalendar.refreshCalendarDetail =
                                      true;
                                  _controllerCalendar.update();
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                ),
                              ))
                          : Container()
                    ],
                  ));
      });
    });
  }

  Container _tabMenuForTablet(BuildContext context) {
    return Container(
      height: Get.height / 1.5,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: !widget.isPrivate
              ? [
                  TabMenu('assets/images/icon/cloud.png',
                      AppLocalizations.of(context)!.cloud, 0),
                  SizedBox(
                    height: 20,
                  ),
                  TabMenu('assets/images/icon/edit.png',
                      AppLocalizations.of(context)!.edit, 1),
                ]
              : [
                  TabMenu('assets/images/icon/cloud.png',
                      AppLocalizations.of(context)!.cloud, 0),
                  SizedBox(
                    height: 20,
                  ),
                  widget.isPrivate
                      ? TabMenu('assets/images/icon/comment.png',
                          AppLocalizations.of(context)!.comments, 1)
                      : SizedBox(),
                  SizedBox(
                    height: widget.isPrivate ? 20 : 0,
                  ),
                  widget.isPrivate
                      ? TabMenu('assets/images/icon/check.png',
                          AppLocalizations.of(context)!.follow, 2)
                      : SizedBox(),
                  SizedBox(
                    height: widget.isPrivate ? 20 : 0,
                  ),
                  widget.isPrivate
                      ? TabMenu('assets/images/icon/notebook.png',
                          AppLocalizations.of(context)!.notes, 3)
                      : SizedBox(),
                  SizedBox(
                    height: widget.isPrivate ? 20 : 0,
                  ),
                  TabMenu('assets/images/icon/edit.png',
                      AppLocalizations.of(context)!.edit, 4),
                ],
        ),
      ),
    );
  }

  Container _tabMenuForPhone(BuildContext context) {
    return Container(
      height: Get.height / 1.5,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: !widget.isPrivate
              ? [
                  TabMenu('assets/images/icon/cloud.png',
                      AppLocalizations.of(context)!.cloud, 0),
                  SizedBox(
                    height: 20,
                  ),
                  TabMenu('assets/images/icon/edit.png',
                      AppLocalizations.of(context)!.edit, 1),
                ]
              : [
                  TabMenu('assets/images/icon/cloud.png',
                      AppLocalizations.of(context)!.cloud, 0),
                  SizedBox(
                    height: 20,
                  ),
                  widget.isPrivate
                      ? TabMenu('assets/images/icon/comment.png',
                          AppLocalizations.of(context)!.comments, 1)
                      : SizedBox(),
                  SizedBox(
                    height: widget.isPrivate ? 20 : 0,
                  ),
                  widget.isPrivate
                      ? TabMenu('assets/images/icon/check.png',
                          AppLocalizations.of(context)!.follow, 2)
                      : SizedBox(),
                  SizedBox(
                    height: widget.isPrivate ? 20 : 0,
                  ),
                  widget.isPrivate
                      ? TabMenu('assets/images/icon/notebook.png',
                          AppLocalizations.of(context)!.notes, 3)
                      : SizedBox(),
                  SizedBox(
                    height: widget.isPrivate ? 20 : 0,
                  ),
                  TabMenu('assets/images/icon/edit.png',
                      AppLocalizations.of(context)!.edit, 4),
                ],
        ),
      ),
    );
  }

  Widget TabMenu(String icondata, String desc, int index) {
    return Tooltip(
      verticalOffset: -15,
      margin: EdgeInsets.only(left: 60),
      textAlign: TextAlign.right,
      message: desc,
      child: GestureDetector(
        onTap: () {
          setState(() {
            print('tabİndex:index: $index');
            currentTab = index;
            _tabController!.animateTo(currentTab);
          });
        },
        child: Container(
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                currentTab == index ? Colors.grey[500] : Get.theme.primaryColor,
            boxShadow: standartCardShadow(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          margin: EdgeInsets.only(right: 3),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  child: ImageIcon(AssetImage(icondata),
                      size: 25,
                      color: currentTab == index
                          ? Get.theme.secondaryHeaderColor
                          : Colors.black.withOpacity(0.5)),
                ),
              ),
              // Icon(
              //   icondata,
              //   size: 19,
              //   color: currentTab == index
              //       ? Get.theme.secondaryHeaderColor
              //       : Colors.black.withOpacity(0.5),
              // ),
              currentTab == index
                  ? SizedBox(
                      width: 3,
                    )
                  : Container(),
              // currentTab == index
              //     ? Expanded(
              //         child: Text(
              //           desc,
              //           style: TextStyle(
              //               color: currentTab == index
              //                   ? Get.theme.secondaryHeaderColor
              //                   : Colors.black.withOpacity(0.8),
              //               fontSize: 12,
              //               fontWeight: FontWeight.w500),
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       )
              //     : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Padding _customIconWithBackground(
      String iconPath, Color color, Function onPressed) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: 40,
        height: 35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Get.theme.colorScheme.primary),
        child: IconButton(
          icon: ImageIcon(
            AssetImage(iconPath),
          ),
          color: color,
          onPressed: () => onPressed,
        ),
      ),
    );
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

  @override
  void dispose() {
    print('CommonDetailsPage Disposed..');

    super.dispose();
  }
}
 */
