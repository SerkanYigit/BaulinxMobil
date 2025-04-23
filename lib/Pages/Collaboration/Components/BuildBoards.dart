import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Custom/CustomLoadingCircle.dart';
import 'package:undede/Pages/Collaboration/CommonDetailsPage2.dart';
import 'package:undede/Pages/HomePage/DashBoardNew.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

import '../../../Controller/ControllerCommon.dart';
import '../../../Controller/ControllerDB.dart';
import '../../../Controller/ControllerLabel.dart';
import '../../../Controller/ControllerTodo.dart';
import '../../../Custom/dropdownSearchFn.dart';
import '../../../Custom/showModalCommonUsers.dart';
import '../../../Custom/showToast.dart';
import '../../../Services/Common/CommonDB.dart';
import '../../../WidgetsV2/Helper.dart';
import '../../../WidgetsV2/confirmDeleteWidget.dart';
import '../../../WidgetsV2/customCardShadow.dart';
import '../../../WidgetsV2/searchableDropDown.dart';
import '../../../model/Common/CareateOrJoinMettingResult.dart';
import '../../../model/Common/CommonGroup.dart';
import '../../../model/Common/GetCommonUserListResult.dart';
import '../../../model/Common/GetPermissionListResult.dart';
import '../../../model/Todo/CommonTodo.dart';
import '../../../widgets/buildBottomNavigationBar.dart';
import '../../Camera/CameraPage.dart';
import '../../HomePage/Provider/HomePageProvider.dart';
import '../../Private/PrivateCommon.dart';
import '../BoardCloudPage.dart';
import '../CommonDetailsPage.dart';

class BuildBoards extends StatefulWidget {
  final Function? changeCommon;
  final CommonBoardListItem? commonBoardListItem;
  final bool gridBuilder;
  BuildBoards(
      {Key? key,
      this.commonBoardListItem,
      this.gridBuilder = false,
      this.changeCommon})
      : super(key: key);

  @override
  State<BuildBoards> createState() => _BuildBoardsState();
}

class _BuildBoardsState extends State<BuildBoards> {
  String? Base64Image;
  bool isLoading = true;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerTodo _controllerTodo = ControllerTodo();
  List<CommonGroup> _commonGroup = <CommonGroup>[];
  GetAllCommonsResult _commons = new GetAllCommonsResult(hasError: false);
  PageController? pageController;
  int? selectedCommonGroupId;
  int? selectedCommonGroupIdForMove;
  String SearchKey = "";
  // background pic
  bool backGround = true;
  // update board
  TextEditingController updateBoardController = TextEditingController();
  final List<DropdownMenuItem> cboLabelsList = [];

  List<int> selectedLabelsId = [];
  List<int> selectedLabelIndexes = [];
  final List<DropdownMenuItem> cboUserList = [];
  List<int> selectedUserIds = [];
  List<int> selectedUserIndexes = [];

  List<DropdownMenuItem> cboTypeWhoList = [];
  int selectedTypeWhoId = 0;
  List<DropdownMenuItem> cboWhichSectionList = [];
  int selectedWhichSectionId = 0;
  List<DropdownMenuItem> cboIncludeElementList = [];
  int selectedIncludeElementId = 0;
  List<DropdownMenuItem> cboReminderIncludeList = [];
  int selectedReminderIncludeId = 0;
  DateTime? StartDate;
  DateTime? EndDate;
  List<int> selectedUsers = [];
  int? selectedMenuItemIncommons;
  final int perPage = 30;
  int page = 0;
  bool hasMore = false;
  List<int> SelectedMenuItemsCopy = [];
  bool loading = true;
  String lastSearchText = "";
  PanelController _pc = new PanelController();
  double _panelMinSize = 0.0;
  TextEditingController _InsertCommonTodosText = TextEditingController();

  CareateOrJoinMettingResult _careateOrJoinMettingResult =
      CareateOrJoinMettingResult(hasError: false);
  final List<DropdownMenuItem> cboUsersList = [];
  Rx<GetAllCommonsResult>? getAllCommons; //! null.obs silindi

//**
  int _selectedFilterId = 99;
  List<PopupMenuEntry<MenuItem>> comboboxItems = [];
  List<DropdownMenuItem> cboTodoFilters = [];
  CommonDB _commonService = CommonDB();
  List<CommonPermission> MyPermissionsOnBoards = [];

  int initialBoard = 0;
  int? changedInitalBoard;
  Color get noPermissionColor => Color(0xFFd3d3d3);

  Future<void> getAllCommans() async {
    await _controllerCommon.GetAllCommons(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id,
      groupId: selectedCommonGroupId,
      search: SearchKey,
      UserIds: selectedUserIds,
      LabelList: selectedLabelsId,
      TypeWho: selectedTypeWhoId,
      WhichSection: selectedWhichSectionId,
      IncludeElement: selectedIncludeElementId,
      ReminderInclude: selectedReminderIncludeId,
      StartDate: StartDate == null ? null : StartDate!.toIso8601String(),
      EndDate: EndDate == null ? null : EndDate!.toIso8601String(),
    );
    try {
      selectedMenuItemIncommons = _controllerCommon
          .getAllCommons.value!.result!.commonBoardList!.first.id;
    } catch (e) {
      selectedMenuItemIncommons = 0;
    }
    _commons = _controllerCommon.getAllCommons.value!;
    _commons.result!.totalCount =
        _controllerCommon.getAllCommons.value!.result!.commonBoardList!.length;
  }

  Future<void> loadPage(int page) async {
    setState(() {
      isLoading = true;
    });
    lastSearchText = SearchKey;
    await _controllerCommon.GetCommons(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id,
      page: page,
      take: perPage,
      groupId: selectedCommonGroupId,
      search: SearchKey,
      UserIds: selectedUserIds,
      LabelList: selectedLabelsId,
      TypeWho: selectedTypeWhoId,
      WhichSection: selectedWhichSectionId,
      IncludeElement: selectedIncludeElementId,
      ReminderInclude: selectedReminderIncludeId,
      StartDate: StartDate == null ? null : StartDate!.toIso8601String(),
      EndDate: EndDate == null ? null : EndDate!.toIso8601String(),
    ).then((value) async {
      hasMore = value.result!.totalPage! > page;

      setState(() {
        int iterateCountForPage = _currentPageItemCount;
        print("BUILDBOARDS iterateCountForPage : " +
            _currentPageItemCount.toString());

        for (int i = 0; i < iterateCountForPage; i++) {
          print("BUILDBOARDS FOR 1 " + _commons.result!.toString());
          _commons.result!.commonBoardList![(page * perPage) + i].users.clear();
          _commons.result!.commonBoardList![(page * perPage) + i].todos.clear();
          print("BUILDBOARDS FOR 2 " +
              _controllerCommon.MyPermissionsOnBoards.toString());
          //! MyPermissionsOnBoards NULL geliyor.
          _controllerCommon.MyPermissionsOnBoards.removeWhere((e) =>
              e.commonId ==
              _commons.result!.commonBoardList![(page * perPage) + i].id);
          _controllerTodo.MyPermissionsOnTodos.removeWhere((e) =>
              e.commonId ==
              _commons.result!.commonBoardList![(page * perPage) + i].id);
        }

        _commons.result!.totalCount = value.result!.totalCount!;
        _commons.result!.totalPage = value.result!.totalPage!;

        for (int i = 0; i < iterateCountForPage; i++) {
          print("BUILDBOARDS FOR 3 " +
              _commons.result!.commonBoardList!.toString());
          _commons.result!.commonBoardList!.removeAt((perPage * page) + i);
          _commons.result!.commonBoardList!
              .insert((perPage * page) + i, value.result!.commonBoardList![i]);
        }
      });

      for (var i = 0; i < value.result!.commonBoardList!.length; i++) {
        print("BUILDBOARDS FOR 4 " + value.result!.commonBoardList!.toString());
        await _controllerCommon.GetCommonUserList(
          _controllerDB.headers(),
          UserId: _controllerDB.user.value!.result!.id,
          CommonId: value.result!.commonBoardList![i].id,
        ).then((commonUserList) async {
          if (!commonUserList.hasError!) {
            /*
            _commons.result.commonBoardList
                .firstWhere((e) => e.id == value.result.commonBoardList[i].id,
                    orElse: () => null)
                .users
                .clear();*/
            _commons.result!.commonBoardList!
                .firstWhere(
                  (e) => e.id == value.result!.commonBoardList![i].id,
                )
                //  orElse: () => null) //! pasife alındı
                .users
                .addAll(commonUserList.result!);

            /* Kullanıcı boardun ownerı değil permission liste bak */
            if (value.result!.commonBoardList![i].userId !=
                _controllerDB.user.value!.result!.id) {
              await _controllerCommon.GetPermissionList(_controllerDB.headers(),
                      DefinedRoleId:
                          value.result!.commonBoardList![i].definedRoleId)
                  .then((permissionListResult) {
                if (!permissionListResult.hasError!) {
                  _controllerCommon.MyPermissionsOnBoards.add(
                      new CommonPermission(permissionListResult.permissionList!,
                          value.result!.commonBoardList![i].id!));
                }
              });
            }
            /* Kullanıcı boardun ownerı boş atalım*/
            else {
              _controllerCommon.MyPermissionsOnBoards.add(new CommonPermission(
                  <Permission>[],
                  value.result!.commonBoardList![i]
                      .id!)); //! new List<Permission>()
            }
            /* Kullanıcı boardun ownerı değil permission liste bak */
          }
        });
      }

      for (var i = 0; i < value.result!.commonBoardList!.length; i++) {
        String todoSearchKey = value.result!.commonBoardList![i].title!
                .toLowerCase()
                .contains(SearchKey.toLowerCase())
            ? ""
            : SearchKey;
        print("*/*///*/*/*");
        print(value.result!.commonBoardList![i].id);
        print(value.result!.commonBoardList![i].isSearchResultTodo);
        print("*/*///*/*/*");

        await _controllerTodo.GetCommonTodos(_controllerDB.headers(),
                userId: _controllerDB.user.value!.result!.id,
                commonId: value.result!.commonBoardList![i].id!,
                search: value.result!.commonBoardList![i].isSearchResultTodo!
                    ? SearchKey
                    : null)
            .then((todoResult) {
          _commons.result!.commonBoardList!
              .firstWhere(
                (e) => e.id == value.result!.commonBoardList![i].id,
                //   orElse: () => null
              )
              .todos
              .clear();
          _commons.result!.commonBoardList!
              .firstWhere((e) => e.id == value.result!.commonBoardList![i].id)
              .todos
              .addAll(todoResult.listOfCommonTodo!);

          print('todoResult.listOfCommonTodo.length : ' +
              todoResult.listOfCommonTodo!.first.content.toString());

          for (var k = 0; k < todoResult.listOfCommonTodo!.length; k++) {
            _controllerTodo.GetTodoComments(
              _controllerDB.headers(),
              TodoId: todoResult.listOfCommonTodo![k].id!,
              UserId: _controllerDB.user.value!.result!.id,
            ).then((todoCommentResult) => {
                  setState(() {
                    _commons.result!.commonBoardList!
                        .firstWhere(
                            (e) => e.id == value.result!.commonBoardList![i].id)
                        .todos
                        .firstWhere(
                            (e) => e.id == todoResult.listOfCommonTodo![k].id)
                        .todoComments!
                        .addAll(todoCommentResult.result!);
                  })
                });
          }
          //   /* Kullanıcı todonun ownerı değil permission liste bak */
          //   if (todoResult.listOfCommonTodo[k].userId !=
          //       _controllerDB.user.value.result.id) {
          //     _controllerCommon.GetPermissionList(_controllerDB.headers(),
          //             DefinedRoleId:
          //                 todoResult.listOfCommonTodo[k].definedRoleId)
          //         .then((permissionListResult) {
          //       if (!permissionListResult.hasError) {
          //         _controllerTodo.MyPermissionsOnTodos.add(new TodoPermission(
          //             permissionListResult.permissionList,
          //             todoResult.listOfCommonTodo[k].id,
          //             value.result.commonBoardList[i].id));
          //         _controllerTodo.update();
          //       }
          //     });
          //   }
          //   /* Kullanıcı todonun ownerı boş atalım*/
          //   else {
          //     _controllerTodo.MyPermissionsOnTodos.add(new TodoPermission(
          //         new List<Permission>(),
          //         todoResult.listOfCommonTodo[k].id,
          //         value.result.commonBoardList[i].id));
          //     _controllerTodo.update();
          //   }
          //   /* Kullanıcı todonun ownerı değil permission liste bak */
          // }
        });
      }
    });
    setState(() {
      isLoading = true;
    });
  }

  Future<void> CareateOrJoinMetting(int OwnerId, int ModuleType) async {
    await _controllerCommon.CareateOrJoinMetting(_controllerDB.headers(),
            OwnerId: OwnerId,
            UserId: _controllerDB.user.value!.result!.id,
            TargetUserIdList: [],
            ModuleType: ModuleType)
        .then((value) {
      setState(() {
        _careateOrJoinMettingResult = value;
        loading = false;
      });
    });
  }

  void onClickMenu(MenuItem item, int commonId) async {
    switch (item) {
      case MenuItem.call:
        if (!_controllerCommon.hasDeleteCommonPerm(commonId)) {
          showWarningToast('Yetkiniz yoktur');
          return;
        }
        setState(() {
          _pc.open();
          _panelMinSize = 170.0;
        });
        CareateOrJoinMetting(commonId, 16);
        break;

      case MenuItem.delete:
        if (!_controllerCommon.hasDeleteCommonPerm(commonId)) {
          showWarningToast('Yetkiniz yoktur');
          return;
        }

        bool isAccepted = await confirmDeleteWidget(context);
        if (isAccepted) {
          await DeleteCommon(
              _commons.result!.commonBoardList![initialBoard].id!);
        }
        break;

      case MenuItem.public:
        await _controllerCommon.UpdateCommon(_controllerDB.headers(),
            Id: commonId,
            UserId: _controllerDB.user.value!.result!.id,
            IsPublic: true);
        await changeGroup();
        break;

      case MenuItem.notifications:
        await _controllerCommon.UpdateCommon(_controllerDB.headers(),
            Id: commonId,
            UserId: _controllerDB.user.value!.result!.id,
            IsPublic: !(_commons.result!.commonBoardList!
                .firstWhere((element) => element.id == commonId)
                .isPublic!));
        await changeGroup();
        break;

      case MenuItem.settings:
        // Add settings related functionality here
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      double screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        loading = true;
      });
      await getAllCommans();

      cboTodoFilters = [
        DropdownMenuItem(
          child: Container(
            height: 15,
            width: 15,
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          value: 99,
          key: Key("All Status"),
        ),
        DropdownMenuItem(
          child: Container(
            height: 15,
            width: 15,
            decoration:
                BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          ),
          value: 0,
          key: Key("Waiting"),
        ),
        DropdownMenuItem(
          child: Container(
            height: 15,
            width: 15,
            decoration:
                BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
          ),
          value: 1,
          key: Key(AppLocalizations.of(context)!.pending),
        ),
        DropdownMenuItem(
          child: Container(
            height: 15,
            width: 15,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          value: 2,
          key: Key(AppLocalizations.of(context)!.approwed),
        ),
        DropdownMenuItem(
          child: Container(
            height: 15,
            width: 15,
            decoration:
                BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          value: 4,
          key: Key(AppLocalizations.of(context)!.completed),
        ),
      ];
      await _controllerCommon.GetListCommonGroup(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id,
      ).then((value) async {
        print("res GetGroupByIdddd = " + jsonEncode(value.listOfCommonGroup));
        // common gruplar çekildikten sonra önyüze yansıtır
        _commonGroup = value.listOfCommonGroup!;
        selectedCommonGroupId = _commonGroup.first.id;
        selectedCommonGroupIdForMove = _commonGroup.first.id;
        await changeGroup();
      }).catchError((e) {
        print("res GetGroupById error " + e.toString());
      });

      comboboxItems = [
        PopupMenuItem<MenuItem>(
          value: MenuItem.call,
          child: Text(AppLocalizations.of(context)!.call),
        ),
        PopupMenuItem<MenuItem>(
          value: MenuItem.delete,
          child: Text(AppLocalizations.of(context)!.delete),
        ),
        PopupMenuItem<MenuItem>(
          value: MenuItem.notifications,
          child: Text(AppLocalizations.of(context)!.notification),
        ),
        PopupMenuItem<MenuItem>(
          value: MenuItem.public,
          child: (_commons.result!.commonBoardList!
                      .firstWhere(
                          (element) =>
                              element.id == widget.commonBoardListItem!.id,
                          orElse: () =>
                              CommonBoardListItem() //! null kaldirildi
                          ) // Provide a fallback if no element is found
                      .isPublic ??
                  false) // Null check to prevent further errors
              ? Text(AppLocalizations.of(context)!.defineAListOfDefects)
              : Text(AppLocalizations.of(context)!.setModule),
        ),
      ];

      setState(() {
        loading = false;
      });
    });
  }

  InsertCommonTodos(int CommonBoardId, String TodoName) async {
    await _controllerTodo.InsertCommonTodos(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CommonBoardId: CommonBoardId,
            TodoName: TodoName,
            ModuleType: 14)
        .then((value) {
      print('value : ' + value.toString());
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.create,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          //backgroundColor: Colors.red,
          //textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    var isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return (loading || isLoading)
        ?
        // CircularProgressIndicator( semanticsLabel: "buildboard", )
        CustomLoadingCircle()
        : Container(
            height: 700,
            width: Get.width,
            margin: EdgeInsets.only(
                bottom: 0,
                /* isTablet
                    ? (orientation == Orientation.portrait ? 0 : 50)
                    : Get.height * 0.1, */
                right: widget.gridBuilder ? 0 : 20,
                left: widget.gridBuilder ? 0 : 20),
            decoration: widget.gridBuilder
                ? BoxDecoration(
                    color: Colors.white, //Color.fromRGBO(249, 249, 249, 1),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(
                        0xFFeef8f9), //Colors.white, //Color.fromRGBO(249, 249, 249, 1),
                    boxShadow: standartCardShadow(),
                  ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () async {
                            int? fileUploadType;
                            await selectUploadType(context)
                                .then((value) => fileUploadType = value);
                            if (fileUploadType == 0) {
                              await _imgFromCamera(
                                  widget.commonBoardListItem!.id!,
                                  widget.commonBoardListItem!.title!);
                            } else if (fileUploadType == 1) {
                              await openFile(widget.commonBoardListItem!.id!,
                                  widget.commonBoardListItem!.title!);
                            }
                          },
                          child: Text('')
                          // child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(7),
                          //     child: Image.network(
                          //       (commonBoardListItem.photo != null
                          //           ? commonBoardListItem.photo
                          //           : 'https://onlinefiles.dsplc.net/Content/CommonDocumentDefault.jpg'),
                          //       width: 35,
                          //       height: 35,
                          //       fit: BoxFit.cover,
                          //     )),
                          ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11.0),
                          child: GestureDetector(
                            onTap: () {
                              updateTitle(widget.commonBoardListItem!.id!);
                            },
                            child: widget.gridBuilder
                                ? Text('')
                                : Text(
                                    widget.commonBoardListItem!.title == null
                                        ? ""
                                        : widget.commonBoardListItem!.title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                          ),
                        ),
                      ),
                      widget.gridBuilder
                          ? SizedBox()
                          : ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton(
                                items: cboTodoFilters,
                                value: _selectedFilterId,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFilterId = value;
                                  });
                                },
                                dropdownColor: Colors.white.withOpacity(0.7),
                                underline: Container(),
                                icon: Container(),
                              ),
                            ),
                      SizedBox(
                        width: 15,
                      ),
                      widget.gridBuilder
                          ? SizedBox()
                          : PopupMenuButton<MenuItem>(
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.black,
                                size: 27,
                              ),
                              onSelected: (MenuItem item) {
                                onClickMenu(
                                    item,
                                    widget.commonBoardListItem!
                                        .id!); // Call the onClickMenu function when an item is selected
                              },
                              itemBuilder: ((context) => comboboxItems),
                            )
                    ],
                  ),
                ),
                Container(
                  //color: Colors.brown,
                  height: 30,
                  margin: EdgeInsets.only(bottom: 5),
                  child: ListView.builder(
                      itemCount: widget.commonBoardListItem!.users.length,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (contex, index) {
                        return Container(
                          height: 22,
                          width: 22,
                          margin: EdgeInsets.only(right: 3),
                          child: CircleAvatar(
                            radius: 15.0,
                            backgroundImage: widget.commonBoardListItem!
                                        .users[index].photo !=
                                    null
                                ? NetworkImage(
                                    widget.commonBoardListItem!.users[index]
                                        .photo!,
                                  )
                                : null,
                            backgroundColor: Colors.transparent,
                          ),
                        );
                      }),
                ),
                Expanded(
                  child: widget.commonBoardListItem!.todos != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: widget.gridBuilder
                                ? _gridView(context)
                                : _listView(context),
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.thereisnotodo),
                ),
                Container(
                  width: Get.width,
                  height: 50,
                  padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: orientation == Orientation.portrait ? 0 : 0),
                  decoration: widget.gridBuilder
                      ? BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        )
                      : BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                  child: widget.gridBuilder
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              // if (_controllerCommon.hasInsertCommonPerm(
                              //     widget.commonBoardListItem.id)) {
                              //   return false;
                              // }
                            },
                            child: boardBottomButtonForDashboard(
                              'assets/images/icon/addtask1.png',
                              iconColor: Color.fromARGB(255, 227, 217, 217),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: () {
                                  // if (_controllerCommon.hasInsertCommonPerm(
                                  //     widget.commonBoardListItem.id)) {
                                  //   return false;
                                  // }
                                  _onAlertWithCustomContentPressed2(
                                      widget.commonBoardListItem!.id!, context);
                                },
                                child: boardBottomButton(
                                    'assets/images/icon/addtask1.png',
                                    iconColor: _controllerCommon
                                            .hasInsertCommonPerm(
                                                widget.commonBoardListItem!.id!)
                                        ? Colors
                                            .transparent //! null yerine transparent koyuldu
                                        : noPermissionColor)),
                            InkWell(
                                onTap: () {
                                  if (!_controllerCommon
                                      .hasFileManagerCommonPerm(
                                          widget.commonBoardListItem!.id!)) {
                                    return; //! false kaldirildi
                                  }
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              BoardCloudPage(
                                                  boardId: widget
                                                      .commonBoardListItem!.id!,
                                                  boardTitle: widget
                                                      .commonBoardListItem!
                                                      .title!)));
                                },
                                child: boardBottomButton(
                                    'assets/images/icon/cloud4.png',
                                    iconColor: _controllerCommon
                                            .hasFileManagerCommonPerm(
                                                widget.commonBoardListItem!.id!)
                                        ? Colors
                                            .transparent //! null yerine transparent koyuldu
                                        : noPermissionColor)),
                            GestureDetector(
                              onTap: () async {
                                if (!_controllerCommon.hasMoveCommonPerm(
                                    widget.commonBoardListItem!.id!)) {
                                  return;
                                }
                                MoveBoard(widget.commonBoardListItem!.id!);
                                //  ChangeCommonGroup(CommonId, CommonGroupId);
                              },
                              child: boardBottomButton(
                                  'assets/images/icon/move.png',
                                  iconColor: Colors.red),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (!_controllerCommon.hasCopyCommonPerm(
                                    widget.commonBoardListItem!.id!)) {
                                  return;
                                }
                                print(widget.commonBoardListItem!.id!);
                                await CopyCommon(
                                    widget.commonBoardListItem!.id!);
                                await changeGroup();
                              },
                              child: boardBottomButton(
                                  'assets/images/icon/copy3.png',
                                  iconColor: Colors.red),
                            ),
                            Container(
                              height: 30,
                              width: 30,
                              margin: EdgeInsets.only(right: 3),
                              child: CachedNetworkImage(
                                  imageUrl: widget
                                      .commonBoardListItem!.ownerUserPhoto!,
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )),
                            ),
                            GestureDetector(
                                onTap: () async {
                                  if (!_controllerCommon.hasUserInvitePerm(
                                      widget.commonBoardListItem!.id!)) {
                                    return;
                                  }
                                  var InviteUsersCommonBoardType = jsonDecode(
                                      await showModalCommonUsers(
                                          context,
                                          'Common Users',
                                          '',
                                          _commons
                                              .result!
                                              .commonBoardList![initialBoard]
                                              .id!,
                                          _commons
                                              .result!
                                              .commonBoardList![initialBoard]
                                              .users));

                                  if (InviteUsersCommonBoardType != null) {
                                    _controllerCommon.InviteUsersCommonBoard(
                                        _controllerDB.headers(),
                                        CommonId:
                                            widget.commonBoardListItem!.id!,
                                        RoleId: InviteUsersCommonBoardType[
                                            "RoleId"],
                                        TargetUserIdList:
                                            InviteUsersCommonBoardType[
                                                    "TargetUserIdList"]
                                                .cast<int>());
                                  }
                                },
                                child: boardBottomButton(
                                    'assets/images/icon/users.png',
                                    iconColor: Colors.orange)),
                            Tooltip(
                                message: _commonGroup
                                        .firstWhere(
                                            (element) =>
                                                element.id ==
                                                widget.commonBoardListItem!
                                                    .commonGroupId!,
                                            orElse: () {
                                          return CommonGroup(groupName: "");
                                        })
                                        .groupName!
                                        .isEmpty
                                    ? ""
                                    : _commonGroup
                                        .firstWhere(
                                          (element) =>
                                              element.id ==
                                              widget.commonBoardListItem!
                                                  .commonGroupId,
                                          //  orElse: () {}
                                        )
                                        .groupName,
                                preferBelow: false,
                                child: boardBottomButton(
                                  'assets/images/icon/categories.png',
                                )),
                            Container(
                              height: 23,
                              width: 23,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                  child: Text(
                                getTodoCount(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                            ),
                            //Icon(Icons.lens, color: Colors.transparent),
                          ],
                        ),
                ),
              ],
            ),
          );
  }

  ListView _listView(BuildContext context) {
    return ListView.builder(
        itemCount: widget.commonBoardListItem!.todos
            .where((element) => _selectedFilterId == 99
                ? true
                : element.status == _selectedFilterId)
            .length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        itemBuilder: (ctx, index) {
          CommonTodo boardTodo = widget.commonBoardListItem!.todos[index];
          return Container(
            width: Get.width,
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              boxShadow: standartCardShadow(),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new CommonDetailsPage(
                            todoId: boardTodo.id!,
                            commonBoardId: widget.commonBoardListItem!.id!,
                            selectedTab: 0,
                            commonTodo: boardTodo,
                            commonBoardTitle:
                                widget.commonBoardListItem!.title!,
                            cloudPerm: (_controllerTodo.hasFileManagerTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!)) ==
                                    true ||
                                _controllerCommon.hasFileManagerCommonPerm(
                                  widget.commonBoardListItem!.id!,
                                ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: Get.width,
                      height: 110,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(width: 0.5, color: Colors.grey))),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: boardTodo.labelList!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Container(
                                                width: 55,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  color: HexColor(boardTodo
                                                      .labelList![i]
                                                      .labelColor!),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: boardTodo.userList!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        print('length' +
                                            boardTodo.userList!.length
                                                .toString());
                                        return CachedNetworkImage(
                                          imageUrl:
                                              boardTodo.userList![i].photo!,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.fitHeight),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            boardTodo.content!,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                      width: Get.width,
                      height: 55,
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.lens,
                            size: 21,
                            color: boardTodo.status == 0
                                ? Colors.grey.withOpacity(0.1)
                                : boardTodo.status == 1
                                    ? Colors.amber
                                    : boardTodo.status == 2
                                        ? Colors.red
                                        : Colors.green,
                          ),
                          // Container(
                          //   child: Tooltip(
                          //     message: boardTodo.ownerName,
                          //     child: CircleAvatar(
                          //       rfadius: 12,
                          //       backgroundImage: NetworkImage(
                          //           boardTodo.userPhoto),
                          //     ),
                          //   ),
                          // ),
                          _customIconButton(
                            'assets/images/icon/call.png',
                            _controllerTodo.hasCreateCallTodoPerm(
                                      widget.commonBoardListItem!.id!,
                                      boardTodo.id!,
                                    ) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () async {
                              setState(() {
                                _pc.open();
                                _panelMinSize = 170.0;
                              });
                              await CareateOrJoinMetting(boardTodo.id!, 21);
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/cloud4.png',
                            (_controllerTodo.hasFileManagerTodoPerm(
                                            widget.commonBoardListItem!.id!,
                                            boardTodo.id!)) !=
                                        null ||
                                    _controllerCommon.hasFileManagerCommonPerm(
                                      widget.commonBoardListItem!.id!,
                                    )
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              _controllerTodo.update();
                              _controllerCommon.update();
                              if (!_controllerCommon.hasFileManagerCommonPerm(
                                widget.commonBoardListItem!.id!,
                              )) {
                                return;
                              }
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new CommonDetailsPage(
                                    todoId: boardTodo.id!,
                                    commonBoardId:
                                        widget.commonBoardListItem!.id!,
                                    selectedTab: 0,
                                    commonTodo: boardTodo,
                                    commonBoardTitle:
                                        widget.commonBoardListItem!.title!,
                                    cloudPerm:
                                        (_controllerTodo.hasFileManagerTodoPerm(
                                                    widget.commonBoardListItem!
                                                        .id!,
                                                    boardTodo.id!)) !=
                                                null ||
                                            _controllerCommon
                                                .hasFileManagerCommonPerm(
                                              widget.commonBoardListItem!.id!,
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/move.png',
                            _controllerTodo.hasMoveTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              MoveTodo(context, boardTodo.id!);
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/copy3.png',
                            _controllerTodo.hasCopyTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              CopyTodo(boardTodo.id!);
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/edit.png',
                            _controllerTodo.hasEditTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new CommonDetailsPage(
                                    todoId: boardTodo.id!,
                                    commonBoardId:
                                        widget.commonBoardListItem!.id!,
                                    selectedTab: 4,
                                    commonTodo: boardTodo,
                                    commonBoardTitle:
                                        widget.commonBoardListItem!.title!,
                                    cloudPerm:
                                        (_controllerTodo.hasFileManagerTodoPerm(
                                                    widget.commonBoardListItem!
                                                        .id!,
                                                    boardTodo.id!)) ==
                                                true ||
                                            _controllerCommon
                                                .hasFileManagerCommonPerm(
                                              widget.commonBoardListItem!.id!,
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/delete.png',
                            _controllerTodo.hasDeleteTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () async {
                              bool isAccepted =
                                  await confirmDeleteWidget(context);
                              if (isAccepted) {
                                await deleteTodo(boardTodo.id!);

                                await loadPage(
                                    (initialBoard ~/ perPage).ceil());
                              }
                            },
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
        });
  }

  GridView _gridView(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    final draggableSheetController =
        Provider.of<DraggableSheetController>(context);
    var isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                isTablet ? (orientation == Orientation.portrait ? 2 : 3) : 1,
            childAspectRatio: 1.8,
            crossAxisSpacing: 20,
            mainAxisSpacing: 10),
        itemCount: widget.commonBoardListItem!.todos
            .where((element) => _selectedFilterId == 99
                ? true
                : element.status == _selectedFilterId)
            .length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        itemBuilder: (ctx, index) {
          CommonTodo boardTodo = widget.commonBoardListItem!.todos[index];
          return Container(
            width: Get.width,
            //  margin: EdgeInsets.only(bottom: 55),
            decoration: BoxDecoration(
              border: Border.all(),
              // color: Colors.pink,
              boxShadow: standartCardShadow(),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      draggableSheetController.updateBoardTodoAndListItem(
                          widget.commonBoardListItem!.todos[index],
                          widget.commonBoardListItem!);
                      draggableSheetController.toggleSheet();
                    },
                    child: Container(
                      width: Get.width,
                      height: isTablet ? 110 : 135,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(width: 1, color: Colors.black))),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: boardTodo.labelList!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Container(
                                                width: 55,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  color: HexColor(boardTodo
                                                      .labelList![i]
                                                      .labelColor!),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: boardTodo.userList!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        return CachedNetworkImage(
                                          imageUrl:
                                              boardTodo.userList![i].photo!,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.fitHeight),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            boardTodo.content!,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                      width: Get.width,
                      height: context.height / 15,
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 188, 189, 190),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.lens,
                              size: 21,
                              color: boardTodo.status == 0
                                  ? Colors.grey.withOpacity(0.1)
                                  : boardTodo.status == 1
                                      ? Colors.amber
                                      : boardTodo.status == 2
                                          ? Colors.red
                                          : Colors.green,
                            ),
                          ),
                          // Container(
                          //   child: Tooltip(
                          //     message: boardTodo.ownerName,
                          //     child: CircleAvatar(
                          //       rfadius: 12,
                          //       backgroundImage: NetworkImage(
                          //           boardTodo.userPhoto),
                          //     ),
                          //   ),
                          // ),
                          _customIconButton(
                            'assets/images/icon/call.png',
                            _controllerTodo.hasCreateCallTodoPerm(
                                      widget.commonBoardListItem!.id!,
                                      boardTodo.id!,
                                    ) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () async {
                              setState(() {
                                _pc.open();
                                _panelMinSize = 170.0;
                              });
                              await CareateOrJoinMetting(boardTodo.id!, 21);
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/cloud4.png',
                            (_controllerTodo.hasFileManagerTodoPerm(
                                            widget.commonBoardListItem!.id!,
                                            boardTodo.id!)) !=
                                        null ||
                                    _controllerCommon.hasFileManagerCommonPerm(
                                      widget.commonBoardListItem!.id!,
                                    )
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              _controllerTodo.update();
                              _controllerCommon.update();
                              if (!_controllerCommon.hasFileManagerCommonPerm(
                                widget.commonBoardListItem!.id!,
                              )) {
                                return;
                              }
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new CommonDetailsPage(
                                    todoId: boardTodo.id!,
                                    commonBoardId:
                                        widget.commonBoardListItem!.id!,
                                    selectedTab: 0,
                                    commonTodo: boardTodo,
                                    commonBoardTitle:
                                        widget.commonBoardListItem!.title!,
                                    cloudPerm:
                                        (_controllerTodo.hasFileManagerTodoPerm(
                                                    widget.commonBoardListItem!
                                                        .id!,
                                                    boardTodo.id!)) !=
                                                null ||
                                            _controllerCommon
                                                .hasFileManagerCommonPerm(
                                              widget.commonBoardListItem!.id!,
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/move.png',
                            _controllerTodo.hasMoveTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              MoveTodo(context, boardTodo.id!);
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/copy3.png',
                            _controllerTodo.hasCopyTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              CopyTodo(boardTodo.id!);
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/edit.png',
                            _controllerTodo.hasEditTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new CommonDetailsPage(
                                    todoId: boardTodo.id!,
                                    commonBoardId:
                                        widget.commonBoardListItem!.id!,
                                    selectedTab: 4,
                                    commonTodo: boardTodo,
                                    commonBoardTitle:
                                        widget.commonBoardListItem!.title!,
                                    cloudPerm:
                                        (_controllerTodo.hasFileManagerTodoPerm(
                                                    widget.commonBoardListItem!
                                                        .id!,
                                                    boardTodo.id!)) ==
                                                true ||
                                            _controllerCommon
                                                .hasFileManagerCommonPerm(
                                              widget.commonBoardListItem!.id!,
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                          _customIconButton(
                            'assets/images/icon/delete.png',
                            _controllerTodo.hasDeleteTodoPerm(
                                        widget.commonBoardListItem!.id!,
                                        boardTodo.id!) !=
                                    null
                                ? Get.theme.secondaryHeaderColor
                                : noPermissionColor,
                            () async {
                              bool isAccepted =
                                  await confirmDeleteWidget(context);
                              if (isAccepted) {
                                await deleteTodo(boardTodo.id!);

                                await loadPage(
                                    (initialBoard ~/ perPage).ceil());
                              }
                            },
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera(int id, String Title) async {
    //! void kaldirildi
    Get.to(() => CameraPage())?.then((value) async {
      if (value != null) {
        List<int> fileBytes = <int>[];
        value.forEach((file) async {
          fileBytes = new File(file.path).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          Base64Image = fileContent;
          await UpdateBoard(id, Title, Base64Image!);
          changeGroup();
        });
        setState(() {});
      }
    });
  }

  changeGroup() async {
    setState(() {
      isLoading = true;
    });

    page = 0;
    await getAllCommans();
    await loadPage(page);

    setState(() {
      isLoading = false;
    });
  }

  UpdateBoard(int Id, String Title, String Photo) async {
    await _controllerCommon.UpdateCommon(_controllerDB.headers(),
            Id: Id,
            UserId: _controllerDB.user.value!.result!.id,
            Title: Title,
            Photo: Photo)
        .then((value) {
      if (value)
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.updated,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
    });
  }

  int get _currentPageItemCount {
    print("totalCount : " + _commons.result!.totalCount!.toString());
    if (_commons.result!.totalCount! < 5) {
      return _commons.result!.totalCount!;
    } else if ((_currentPage + 1) * perPage > _commons.result!.totalCount!) {
      return _commons.result!.totalCount! % perPage;
    } else {
      return 5;
    }
  }

  int get _currentPage {
    print("_currentPage = " + ((initialBoard) ~/ perPage).ceil().toString());
    return ((initialBoard) ~/ perPage).ceil();
  }

  String getTodoCount() {
    if (initialBoard > _commons.result!.commonBoardList!.length - 1) return "";
    print('todoResult : count :' +
        _commons.result!.commonBoardList![initialBoard].todos.length
            .toString());

    return _commons.result!.commonBoardList!.length == 0
        ? "0"
        : (_commons.result!.commonBoardList![initialBoard].todos.length ?? 0)
            .toString();
  }

  Future<void> openFile(int id, String Title) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpeg', 'jpg', 'png'],
          allowMultiple: false);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) async {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        Base64Image = fileContent;
        await UpdateBoard(id, Title, Base64Image!);
        changeGroup();
      });
      setState(() {});

      print('aaa');
    } catch (e) {}
  }

  DeleteCommon(int CommonId) async {
    await _controllerCommon.DeleteCommon(
      _controllerDB.headers(),
      CommonId: CommonId,
      UserId: _controllerDB.user.value!.result!.id,
    ).then((hasError) async {
      if (!hasError) {
        String deletedCommonTitle = _commons.result!.commonBoardList!
            .firstWhere((x) => x.id == CommonId)
            .title!;
        showSuccessToast(
            "${deletedCommonTitle} ${AppLocalizations.of(context)!.deletedSuccesfully}");

        setState(() {
          _commons.result!.commonBoardList!
              .removeWhere((e) => e.id == CommonId);
          _commons.result!.totalCount = _commons.result!.totalCount! - 1;
          _commons.result!.totalPage =
              (_commons.result!.commonBoardList!.length / 5).ceil();
          _controllerCommon.MyPermissionsOnBoards.removeWhere(
              (e) => e.commonId == CommonId);
          _controllerTodo.MyPermissionsOnTodos.removeWhere(
              (e) => e.commonId == CommonId);

          if (initialBoard + 1 > _commons.result!.commonBoardList!.length)
            pageController!.jumpToPage(initialBoard - 1);
        });

        //await loadPage(_currentPage);
      } else {
        showSuccessToast("${AppLocalizations.of(context)!.anErrorHasOccured}");
      }
    });
  }

  void updateTitle(int id) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 250,
                  width: Get.width,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: 250,
                        height: 45,
                        decoration: BoxDecoration(
                            boxShadow: standartCardShadow(),
                            borderRadius: BorderRadius.circular(15)),
                        child: TextFormField(
                          controller: updateBoardController,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: new InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(45),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(45),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(45),
                            ),
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 11, top: 11, right: 15),
                            hintText: AppLocalizations.of(context)!.title,
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () async {
                          if (updateBoardController.text.isBlank!) {
                            Fluttertoast.showToast(
                                msg:
                                    AppLocalizations.of(context)!.cannotbeblank,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Get.theme.secondaryHeaderColor,
                                textColor: Get.theme.primaryColor,
                                fontSize: 16.0);
                            return;
                          }
                          await UpdateBoard(id, updateBoardController.text,
                              "" //! null yerine "" eklendi
                              );
                          changeGroup();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 250,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Get.theme.secondaryHeaderColor,
                              borderRadius: BorderRadius.circular(45)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.save,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.white),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Container _customIconButton(
      String iconPath, Color color, Function onPressed) {
    return Container(
      width: 40,
      height: 40,
      child: IconButton(
        icon: ImageIcon(
          AssetImage(iconPath),
        ),
        color: color,
        onPressed: () => onPressed(),
      ),
    );
  }

  copyTodo(int TodoId, List<int> TargetCommonIdList) async {
    await _controllerTodo.CopyTodo(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            TodoId: TodoId,
            TargetCommonIdList: TargetCommonIdList)
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
      }
    });
  }

  void CopyTodo(int boardTodoId) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        builder: (context) {
          return GetBuilder<ControllerCommon>(
              builder: (_) => StatefulBuilder(builder: (context, setState) {
                    return Container(
                      height: 300,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            width: 250,
                            decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                menuMaxHeight: 350,
                                value: selectedCommonGroupId,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontFamily: 'TTNorms',
                                    fontWeight: FontWeight.w500),
                                icon: Icon(
                                  Icons.expand_more,
                                  color: Colors.black,
                                ),
                                items:
                                    _commonGroup.map((CommonGroup commonGroup) {
                                  return DropdownMenuItem(
                                    value: commonGroup.id,
                                    child: Text(commonGroup.groupName!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCommonGroupId = value;
                                    changeGroup();
                                    pageController!.jumpToPage(0);
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 250,
                            decoration: BoxDecoration(
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(15)),
                            child: SearchableDropdown.multiple(
                              items: _controllerCommon
                                  .getAllCommons.value!.result!.commonBoardList!
                                  .map((CommonBoardListItem e) {
                                return DropdownMenuItem(
                                  value: e.title!.trim(),
                                  child: Text(
                                    e.title!.trim(),
                                  ),
                                );
                              }).toList(),
                              hint: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                    AppLocalizations.of(context)!.boardName),
                              ),
                              onChanged: (value) {
                                SelectedMenuItemsCopy.clear();
                                for (int i = 0; i < value.length; i++) {
                                  SelectedMenuItemsCopy.add(_controllerCommon
                                      .getAllCommons
                                      .value!
                                      .result!
                                      .commonBoardList!
                                      .elementAt(value[i])
                                      .id!);
                                }
                              },
                              displayItem: (item, selected) {
                                return (Row(children: [
                                  selected
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank,
                                          color: Colors.grey,
                                        ),
                                  SizedBox(width: 7),
                                  Expanded(
                                    child: item,
                                  ),
                                ]));
                              },
                              selectedValueWidgetFn: (item) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFdedede),
                                      borderRadius: BorderRadius.circular(30)),
                                  margin: EdgeInsets.only(right: 5),
                                  child: Center(child: (Text(item.toString()))),
                                );
                              },
                              doneButton: (selectedItemsDone, doneContext) {
                                return (ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(doneContext);
                                    setState(() {});
                                  },
                                  child:
                                      Text(AppLocalizations.of(context)!.save),
                                ));
                              },
                              closeButton: null,
                              style: Get.theme.inputDecorationTheme.hintStyle,
                              searchFn: (String keyword, items) {
                                List<int> ret = <int>[];
                                if (items != null && keyword.isNotEmpty) {
                                  keyword.split(" ").forEach((k) {
                                    int i = 0;
                                    items.forEach((item) {
                                      if (k.isNotEmpty &&
                                          (item.value
                                              .toString()
                                              .toLowerCase()
                                              .contains(k.toLowerCase()))) {
                                        ret.add(i);
                                      }
                                      i++;
                                    });
                                  });
                                }
                                if (keyword.isEmpty) {
                                  ret = Iterable<int>.generate(items.length)
                                      .toList();
                                }
                                return (ret);
                              },
                              //clearIcon: Icons(null), todo:nullable yap
                              icon: Icon(
                                Icons.expand_more,
                                size: 31,
                              ),
                              underline: Container(
                                height: 0.0,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.teal, width: 0.0))),
                              ),
                              iconDisabledColor: Colors.grey,
                              iconEnabledColor: Get.theme.colorScheme.surface,
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await copyTodo(
                                  boardTodoId, SelectedMenuItemsCopy);
                              await loadPage((initialBoard ~/ perPage).ceil());

                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 250,
                              decoration: BoxDecoration(
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 11),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.copy,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }));
        });
  }

  void MoveTodo(BuildContext context, int boardTodo) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        builder: (context) {
          return GetBuilder<ControllerCommon>(
              builder: (_) => StatefulBuilder(builder: (context, setState) {
                    return Container(
                      height: 300,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            width: 250,
                            decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                menuMaxHeight: 350,
                                value: selectedCommonGroupId,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontFamily: 'TTNorms',
                                    fontWeight: FontWeight.w500),
                                icon: Icon(
                                  Icons.expand_more,
                                  color: Colors.black,
                                ),
                                items:
                                    _commonGroup.map((CommonGroup commonGroup) {
                                  return DropdownMenuItem(
                                    value: commonGroup.id,
                                    child: Text(commonGroup.groupName!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCommonGroupId = value;
                                    changeGroup();
                                    pageController!.jumpToPage(0);
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 250,
                            decoration: BoxDecoration(
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(15)),
                            child: SearchableDropdown.single(
                              color: Colors.white,
                              displayClearIcon: false,
                              menuBackgroundColor:
                                  Get.theme.scaffoldBackgroundColor,
                              items: _controllerCommon
                                  .getAllCommons.value!.result!.commonBoardList!
                                  .map((CommonBoardListItem e) {
                                return DropdownMenuItem(
                                  value: e.id,
                                  key: Key(e.title!.trim()),
                                  child: Text(
                                    e.title!.trim(),
                                  ),
                                );
                              }).toList(),
                              value: selectedMenuItemIncommons,
                              icon: Icon(Icons.expand_more),
                              hint:
                                  "* ${AppLocalizations.of(context)!.selectboard}",
                              searchHint:
                                  AppLocalizations.of(context)!.selectboard,
                              onChanged: (value) {
                                setState(() {
                                  selectedMenuItemIncommons = value;
                                });
                              },
                              doneButton: AppLocalizations.of(context)!.done,
                              displayItem: (item, selected) {
                                return (Row(children: [
                                  selected
                                      ? Icon(
                                          Icons.radio_button_checked,
                                          color: Colors.grey,
                                        )
                                      : Icon(
                                          Icons.radio_button_unchecked,
                                          color: Colors.grey,
                                        ),
                                  SizedBox(width: 7),
                                  Expanded(
                                    child: item,
                                  ),
                                ]));
                              },
                              isExpanded: true,
                              searchFn: dropdownSearchFn,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              print(selectedMenuItemIncommons);
                              await moveTodo(
                                  boardTodo, selectedMenuItemIncommons!);
                              await loadPage((initialBoard ~/ perPage).ceil());
                              Navigator.pop(context);
                            },
                            child: Container(
                                width: 250,
                                decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 11),
                                child: Center(
                                    child: Text(
                                  AppLocalizations.of(context)!.move,
                                  style: TextStyle(fontSize: 18),
                                ))),
                          )
                        ],
                      ),
                    );
                  }));
        });
  }

  moveTodo(int TodoId, int TargetCommonId) async {
    await _controllerTodo.MoveTodo(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            TodoId: TodoId,
            TargetCommonId: TargetCommonId)
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
      }
    });
  }

  deleteTodo(int TodoId) async {
    await _controllerTodo.DeleteTodo(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id,
      TodoId: TodoId,
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
      }
    });
  }

  _onAlertWithCustomContentPressed2(int Id, context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(AppLocalizations.of(context)!.newTodos),
                content: Container(
                  height: Get.height * 0.1,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _InsertCommonTodosText,
                        decoration: InputDecoration(
                          icon: Icon(Icons.add_task),
                          labelText: AppLocalizations.of(context)!.todoName,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    color: HexColor('27d1df'),
                    onPressed: () async {
                      if (_InsertCommonTodosText.text.isBlank!) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.cannotbeblank,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Get.theme.secondaryHeaderColor,
                            textColor: Get.theme.primaryColor,
                            fontSize: 16.0);
                        return;
                      }
                      changedInitalBoard = initialBoard;
                      await InsertCommonTodos(Id, _InsertCommonTodosText.text);
                      widget.changeCommon!();
                      Navigator.pop(context);
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => HomePage()),
                      //   (Route<dynamic> route) => false,
                      // );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.add,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }

  ClipRRect boardBottomButton(String imagePath, {Color? iconColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 35,
        height: 35,
        color: Get.theme.scaffoldBackgroundColor,
        child: IconButton(
          icon: ImageIcon(
            AssetImage(imagePath),
          ),
          color: Colors.black54,
          onPressed: () {},
          /*  onPressed: () {
            _onAlertWithCustomContentPressed2(
                widget.commonBoardListItem!.id!, context);
          }, */ //! otomatik olusturulan kod
        ),
      ),
    );
  }

  ClipRRect boardBottomButtonForDashboard(String imagePath,
      {Color? iconColor}) {
    var isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return ClipRRect(
      child: Container(
        width: isTablet ? Get.width * 0.21 : Get.width * 0.15,
        height: isTablet ? 80 : 60,
        decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: ImageIcon(
                  AssetImage(imagePath),
                  // size: 10,
                ),
                color: Colors.black,
                onPressed: () {
                  _onAlertWithCustomContentPressed2(
                      widget.commonBoardListItem!.id!, context);
                },
              ),
              isTablet
                  ? Text(
                      AppLocalizations.of(context)!.newDefect,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  void MoveBoard(int boardTodo) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        builder: (context) {
          return GetBuilder<ControllerCommon>(
              builder: (_) => StatefulBuilder(builder: (context, setState) {
                    return Container(
                      height: 300,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            width: 250,
                            decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                menuMaxHeight: 350,
                                value: selectedCommonGroupIdForMove,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontFamily: 'TTNorms',
                                    fontWeight: FontWeight.w500),
                                icon: Icon(
                                  Icons.expand_more,
                                  color: Colors.black,
                                ),
                                items:
                                    _commonGroup.map((CommonGroup commonGroup) {
                                  return DropdownMenuItem(
                                    value: commonGroup.id,
                                    child: Text(commonGroup.groupName!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCommonGroupIdForMove = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              print(selectedCommonGroupIdForMove);
                              print(boardTodo);
                              await ChangeCommonGroup(
                                  boardTodo, selectedCommonGroupIdForMove!);
                              await loadPage((initialBoard ~/ perPage).ceil());

                              Navigator.pop(context);
                            },
                            child: Container(
                                width: 250,
                                decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 11),
                                child: Center(
                                    child: Text(
                                  AppLocalizations.of(context)!.move,
                                  style: TextStyle(fontSize: 18),
                                ))),
                          )
                        ],
                      ),
                    );
                  }));
        });
  }

  ChangeCommonGroup(int CommonId, int CommonGroupId) async {
    await _controllerCommon.ChangeCommonGroup(_controllerDB.headers(),
            CommonId: CommonId,
            UserId: _controllerDB.user.value!.result!.id,
            CommonGroupId: CommonGroupId)
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
      }
    });
  }

  CopyCommon(int CommonId) async {
    await _controllerCommon.CopyCommon(_controllerDB.headers(),
            CommonId: CommonId, UserId: _controllerDB.user.value!.result!.id)
        .then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.copied,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
}

enum MenuItem { call, delete, public, notifications, settings }
