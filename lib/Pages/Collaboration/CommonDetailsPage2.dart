import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:undede/Clean_arch/features/collobration_page/detail_page/view/common_detail_page.dart';
import 'package:undede/Clean_arch/features/detail_page/DirectoryDetailNeu2.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Pages/Collaboration/CollaborationTodoCheckList.dart';
import 'package:undede/Pages/Collaboration/TodoComments/TodoComments.dart';
import 'package:undede/Pages/Contact/CommonDetailEditPage.dart';
import 'package:undede/Pages/Contact/NotePageTabPage.dart';
import 'package:undede/Pages/Note/NotePage.dart';
//import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/CustomLoadingCircle.dart';
import 'package:undede/Custom/DioDownloader.dart';
import 'package:undede/Custom/FileGeneratorExcellorWord.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseCommon.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseCustomer.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseFileManagerType.dart';
import 'package:undede/Custom/showModalTextInput.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/DocumentAnalysis/DocumentAnalysis.dart';
import 'package:undede/Pages/FileViewers/openFileFn.dart';
import 'package:undede/Pages/ObjectDetection/detection_camera.dart';
import 'package:undede/Pages/Private/CopyAndMovePage.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/confirmDeleteWidget.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Label/uploadLabels.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _tabController!.dispose();

    super.dispose();
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

  /*  deleteTodoAppointment(int Id) async {
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
 */
  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return GetBuilder<ControllerCommon>(builder: (c) {
      return GetBuilder<ControllerTodo>(builder: (c) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            // Get.theme.scaffoldBackgroundColor,
            /*    appBar: CustomAppBar(
              title: isTablet
                  ? widget.commonTodo.content!
                  : AppLocalizations.of(context)!.collaboration,
              isCollabDetail: true,
              onBackPress: () {
                widget.togglePlay
                    ? widget.toggleSheetClose!()
                    : Navigator.pop(context);
              },
            ), */
            body: isLoading
                ? CustomLoadingCircle(
                    widget: Text("CommonDetailsPage"),
                  )
                :
                // Container(child: Text("test")
                //)
                //);

                Stack(
                    children: [
                      Container(
                          width: Get.width,
                          //  height: Get.height,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  height: Get.height,
                                  width: Get.width,
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: CustomScrollView(
                                    physics: BouncingScrollPhysics(),
                                    slivers: [
                                      SliverFillRemaining(
                                        hasScrollBody: true,
                                        child: Column(
                                          children: <Widget>[
                                            //? TITLE
                                            /*  Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 7),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  !isTablet
                                                      //! Title buradan aliyor
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
                                                          child:
                                                              //! Title buradan aliyor
                                                              Text(
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
                                            ), */
                                            isTablet
                                                ? _tabMenuForTablet(context)
                                                : _tabMenuForPhone(context),
                                            /*   SizedBox(
                                              height: 15,
                                            ), */

                                            Expanded(
                                              child: Expanded(
                                                flex: 9,
                                                child: TabBarView(
                                                    controller: _tabController,
                                                    children: [
                                                      ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          child: Navigator(
                                                            key: Key('xx'),
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
                                                                    DirectoryDetailNeu2(
                                                                  folderName:
                                                                      "",
                                                                  hideHeader:
                                                                      true,
                                                                  fileManagerType:
                                                                      FileManagerType
                                                                          .CommonTask,
                                                                  todoId: widget
                                                                      .todoId, //widget.todoId,
                                                                ),
                                                              );
                                                            },
                                                          )),
                                                      CommonDetailEditPage(
                                                        todoId: widget.todoId,
                                                        commonBoardId: widget
                                                            .commonBoardId,
                                                        commonTodo:
                                                            widget.commonTodo,
                                                        isPrivate:
                                                            widget.isPrivate,
                                                        toggleSheetClose: () {
                                                          widget
                                                              .toggleSheetClose!();
                                                        },
                                                      ),
                                                    ]
                                                    /*   : [
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
                                                              ], */
                                                    ),
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
                      /*     widget.calendarId != null
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
                          : Container(
                              child: Text("calendarId is null"),
                            ) */
                    ],
                  ));
      });
    });
  }

  Container _tabMenuForTablet(BuildContext context) {
    return Container(
      height: Get.height / 15,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
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
      height: Get.height / 15,
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
          height: Get.height / 17,
          width: Get.height / 17,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: currentTab == index ? Colors.grey[500] : Colors.white,
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
                          : Colors.pink),
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

/* 
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
 */
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
