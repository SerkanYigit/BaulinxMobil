import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:ionicons/ionicons.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Clean_arch/features/collobration_page/detail_page/view/common_detail_page.dart';
import 'package:undede/Clean_arch/features/collobration_page/detail_page/view/CommonDetailsPage2.dart';
import 'package:undede/Pages/HomePage%20copy/Bauzeienplan.dart';
import 'package:undede/Pages/HomePage/DashBoardNew.dart';
import 'package:undede/Pages/HomePage/Provider/HomePageProvider.dart';
import 'package:undede/Pages/Mangel/MangelPage.dart';
import 'package:undede/Pages/Note/DetetcsPage.dart';

import 'package:undede/testcore/awesome_notification/notification_service.dart'
    as awe;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerNotification.dart';
import 'package:undede/Controller/ControllerSocial.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/InvoiceWithDocumentType.dart';
import 'package:undede/Custom/ScaleSize.dart';
import 'package:undede/Custom/removeAllHtmlTags.dart';
import 'package:undede/Custom/showModalDeleteYesOrNo.dart';
import 'package:undede/Custom/showModalFilter.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Business/InvoiceStatistic.dart';
import 'package:undede/Pages/Business/InvoiceWithDocumentPage.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Chat/ChatPage.dart';
import 'package:undede/Pages/Collaboration/Components/BuildBoards.dart';
import 'package:undede/Pages/Contact/ContactCRMPage.dart';
import 'package:undede/Pages/Contact/ContactPage.dart';
import 'package:undede/Pages/DocumentAnalysis/DocumentAnalysis.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Message/MessagePage.dart';
import 'package:undede/Pages/Note/NotePage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/Pages/ObjectDetection/detection_camera.dart';
import 'package:undede/Pages/PDFCreater/PDFSignature.dart';
import 'package:undede/Pages/Private/PrivatePage.dart';
import 'package:undede/Pages/Profile/ProfilePage.dart';
import 'package:undede/Pages/Public/PublicCardProfile.dart';
import 'package:undede/Pages/Social/SocialList.dart';
import 'package:undede/Pages/Social/SocialPage.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/model/Common/CareateOrJoinMettingResult.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Common/GetPublicMeetingsResult.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/Social/SocialResult.dart';
import 'package:undede/widgets/CallWeSlide.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:undede/model/Common/GetPermissionListResult.dart';

import '../../Custom/CustomLoadingCircle.dart';
import '../../Custom/dropdownSearchFn.dart';
import '../../Custom/showModalPaymentRequired.dart';
import '../../WidgetsV2/searchableDropDown.dart';
import '../../model/Common/Commons.dart';
import '../../model/Common/GetCommonGroupBackgroundResult.dart';
import '../../model/Common/GetPermissionListResult.dart';
import '../../model/Label/GetInvoiceModel.dart';
import '../../model/Label/GetLabelByUserId.dart';
import '../../model/Todo/CommonTodo.dart';
import '../../model/User/GetDetailAndSendNotificationResult.dart';
import '../../widgets/CustomPageRouteBuilder.dart';
import '../../widgets/CustomSearchDropdownMenu.dart';
import '../Collaboration/CollaborationPage.dart';
import '../Collaboration/CommonDetailsPage.dart';
import '../Customer/CustomerPage.dart';
import '../Profile/CustomAvatarWidget.dart';
import 'CustomWidgets/CustomCompanyWidget.dart';
import 'Provider/HomePageProvider.dart';
import 'package:provider/provider.dart';
//import 'package:undede/core/awesome_notification/test1/noti1.dart'
//   as notest;

class HomePage3 extends StatefulWidget {
  List<CommonBoardListItem>? commonBoardListItem = [];
  CommonGroup? commonGroupSelected = CommonGroup();

  HomePage3({
    super.key,
    this.commonBoardListItem, //! 119 sabit
    this.commonGroupSelected,
  });
  @override
  _HomePage3State createState() => _HomePage3State();
}

class _HomePage3State extends State<HomePage3> with TickerProviderStateMixin {
  bool isLoading = true;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerTodo _controllerTodo = ControllerTodo();
  ControllerNotification _controllerNotification = ControllerNotification();
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  UserDB userDB = new UserDB();
  GetCommonTodosResult? timePeriod;
  CommonDB commonDB = new CommonDB();
  AdminCustomerResult adminCustomer = new AdminCustomerResult(hasError: false);
  CareateOrJoinMettingResult _careateOrJoinMettingResult =
      CareateOrJoinMettingResult(hasError: false);
  Color themeColor = Get.theme.colorScheme.secondary;
  final _formKey = GlobalKey<FormState>();
  TextStyle buttonStyle = TextStyle(color: Colors.white, fontSize: 16);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SubMenuItem> subListOfMainMenuItem = <SubMenuItem>[];
  AnimationController? controller;
  List<int> targetUserIdList = [];
  bool loading = true;
  // SEARCT PARAMS
  bool searchTile = false;
  TextEditingController _searchController = TextEditingController();
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  ControllerSocial _controllerSocial = Get.put(ControllerSocial());
  SocialResult _socialResult = SocialResult(hasError: false);
  bool isSocialSelected = false;
  bool isFiltred = false;
  ListOfCommonGroup? commonGroupList;
  int? selectedCommonGroupId;
  int? selectedCommonGroupIdForMove;
  List<CommonGroup> _commonGroup = <CommonGroup>[];
  PageController? pageController;
  PageController? pageControllerForBoard;
  bool isPrivate = false;

  List<DropdownMenuItem> cboTodoFilters = [];
  final int perPage = 5;
  int page = 0;
  TextEditingController _titleText = TextEditingController();
  TextEditingController _descriptionText = TextEditingController();
  TextEditingController _groupText = TextEditingController();
  TextEditingController _projectNumber = TextEditingController();
  TextEditingController _streetTextController = TextEditingController();
  TextEditingController _postalCodeTextController = TextEditingController();
  TextEditingController _cityTextController = TextEditingController();
  TextEditingController _stateTextController = TextEditingController();
  TextEditingController _groupStartDateController = TextEditingController();
  TextEditingController _groupEndDateController = TextEditingController();
  TextEditingController _groupStartDateControllerForText =
      TextEditingController();
  TextEditingController _groupEndDateControllerForText =
      TextEditingController();
  TextEditingController _groupId = TextEditingController();
  TextEditingController _createDate = TextEditingController();
  int? selectedInvoiceIndex;
  int? selectedUserIndex;
  InvoiceDetail? _selectedInvoice;
  List<InvoiceDetail> invoiceList = <InvoiceDetail>[];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  int initialBoard = 0;
  int? changedInitalBoard;
  //insert
  //new group controller
  TextEditingController _InsertCommonTodosText = TextEditingController();
  bool hasMore = false;
  int? selectedMenuItemIncommons;
  List<int> SelectedMenuItemsCopy = [];
  String lastSearchText = "";

  // search
  String SearchKey = "";
  // background pic
  bool backGround = true;
  // update board
  String? Base64Image;
  TextEditingController updateBoardController = TextEditingController();
  final List<DropdownMenuItem> cboLabelsList = [];
  ControllerChatNew _chatDb = new ControllerChatNew();
  List<UserLabel> labelsList = <UserLabel>[];

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
  GetCommonGroupBackgroundResult _getCommonGroupBackgroundResult =
      GetCommonGroupBackgroundResult(hasError: false);
  GetAllCommonsResult _commons = GetAllCommonsResult(hasError: false);
  int _selectedFilterId = 99;
  int _selectedCarouselIndex = 0;
  CommonTodo? boardTodo;
  CommonBoardListItem? commonBoardListItemm;
  //! final dropDownKey = GlobalKey<DropdownSearchState<PopupMode>>();

  ScrollController _scrollController = ScrollController();
  final double _scrollAmount = 100; // Amount to scroll each time

  bool _isSheetOpen = false;
  void _toggleSheet() {
    setState(() {
      _isSheetOpen = !_isSheetOpen;
      if (_isSheetOpen) {
        _draggableScrollableController!.animateTo(
          1.5,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _draggableScrollableController!.animateTo(
          0.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _toggleSheetClose() {
    setState(() {
      _isSheetOpen = false;
      _draggableScrollableController!.animateTo(
        0.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  double _getViewportFraction(double screenWidth) {
    if (screenWidth > 1000) {
      return 0.4;
    } else if (screenWidth > 600) {
      return 0.6;
    } else {
      return 1.0;
    }
  }

  double _getViewportFractionForBoard(double screenWidth) {
    return 1;
  }

  final CarouselController? _carouselController = CarouselController();
  final CarouselSliderController? _carouselSliderController =
      CarouselSliderController(); //! Slidercontroller eklendi
  void _changePage(int index) {
    setState(() {
      _selectedCarouselIndex = index;

//! _AssertionError ('package:flutter/src/widgets/scroll_controller.dart': Failed assertion: line 234 pos 12: '_positions.isNotEmpty': ScrollController not attached to any scroll views.)
      //   _carouselController!.jumpTo(double.parse(index.toString()));
//! _carouselController?.animateTo(double.parse(index.toString()), duration: Duration(),
//! curve: Curves.easeInOut);
      _carouselSliderController?.jumpToPage(index);

      //!  animateTo(index); yada bunu kullan
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

  int get _currentPage {
    print("_currentPage = " + ((initialBoard) ~/ perPage).ceil().toString());
    return ((initialBoard) ~/ perPage).ceil();
  }

  int get _currentPageItemCount {
    print("totalCount : " + _commons.result!.totalCount.toString());
    if (_commons.result!.totalCount! < 5) {
      return _commons.result!.totalCount!;
    } else if ((_currentPage + 1) * perPage > _commons.result!.totalCount!) {
      return _commons.result!.totalCount! % perPage;
    } else {
      return 5;
    }
  }

  Future<void> loadPage(int page) async {
    print('/*-home page load page-*/');
    lastSearchText = SearchKey;
    await _controllerCommon.GetCommons(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id!,
      page: page,
      take: 10,
      groupId: widget.commonGroupSelected!.id, //! 119
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
        print(" HOMEPAGE iterateCountForPage : " +
            _currentPageItemCount.toString());

        for (int i = 0; i < iterateCountForPage; i++) {
          _commons.result!.commonBoardList![(page * perPage) + i].users.clear();
          _commons.result!.commonBoardList![(page * perPage) + i].todos.clear();

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
          _commons.result!.commonBoardList?.removeAt((perPage * page) + i);
          _commons.result!.commonBoardList
              ?.insert((perPage * page) + i, value.result!.commonBoardList![i]);
        }
      });

      for (var i = 0; i < value.result!.commonBoardList!.length; i++) {
        await _controllerCommon.GetCommonUserList(
          _controllerDB.headers(),
          UserId: _controllerDB.user.value!.result!.id!,
          CommonId: value.result!.commonBoardList![i].id!,
        ).then((commonUserList) async {
          if (!commonUserList.hasError!) {
            /*
            _commons.result.commonBoardList
                .firstWhere((e) => e.id == value.result.commonBoardList[i].id,
                    orElse: () => null)
                .users
                .clear();*/
            _commons.result!.commonBoardList!
                .firstWhere((e) => e.id == value.result!.commonBoardList![i].id,
                    orElse: () =>
                        CommonBoardListItem() // Return empty CommonBoardListItem instead of null
                    )
                .users
                .addAll(commonUserList.result!);

            /* Kullanıcı boardun ownerı değil permission liste bak */
            if (value.result!.commonBoardList![i].userId !=
                _controllerDB.user.value!.result!.id!) {
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
              // _controllerCommon.MyPermissionsOnBoards.add(new CommonPermission(
              //     new List<PermissionList>(), value.result.commonBoardList[i].id));
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

        print(value.result!.commonBoardList![i].id);
        print(value.result!.commonBoardList![i].isSearchResultTodo);

        await _controllerTodo.GetCommonTodos(_controllerDB.headers(),
                userId: _controllerDB.user.value!.result!.id!,
                commonId: value.result!.commonBoardList![i].id!,
                search: value.result!.commonBoardList![i].isSearchResultTodo!
                    ? SearchKey
                    : null)
            .then((todoResult) {
          print(
              'publicCommonBoardList:  todoResult: ${todoResult.listOfCommonTodo!.first.content}');
          _commons.result!.commonBoardList!
              .firstWhere((e) => e.id == value.result!.commonBoardList![i].id,
                  orElse: () => throw Exception("Board not found"))
              .todos
              .clear();
          _commons.result!.commonBoardList!
              .firstWhere((e) => e.id == value.result!.commonBoardList![i].id)
              .todos
              .addAll(todoResult.listOfCommonTodo!);

          for (var k = 0; k < todoResult.listOfCommonTodo!.length; k++) {
            _controllerTodo.GetTodoComments(
              _controllerDB.headers(),
              TodoId: todoResult.listOfCommonTodo![k].id!,
              UserId: _controllerDB.user.value!.result!.id!,
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

            /* Kullanıcı todonun ownerı değil permission liste bak */
            if (todoResult.listOfCommonTodo![k].userId !=
                _controllerDB.user.value!.result!.id!) {
              _controllerCommon.GetPermissionList(_controllerDB.headers(),
                      DefinedRoleId:
                          todoResult.listOfCommonTodo![k].definedRoleId)
                  .then((permissionListResult) {
                if (!permissionListResult.hasError!) {
                  _controllerTodo.MyPermissionsOnTodos.add(new TodoPermission(
                      permissionListResult.permissionList!,
                      todoResult.listOfCommonTodo![k].id!,
                      value.result!.commonBoardList![i].id!));
                  _controllerTodo.update();
                }
              });
            }
            /* Kullanıcı todonun ownerı boş atalım*/
            else {
              // _controllerTodo.MyPermissionsOnTodos.add(new TodoPermission(
              //     new List<Permission>(),
              //     todoResult.listOfCommonTodo[k].id,
              //     value.result.commonBoardList[i].id));
              _controllerTodo.update();
            }
            /* Kullanıcı todonun ownerı değil permission liste bak */
          }
        });
      }

      await _controllerTodo.GetCommonTodosTreeView(_controllerDB.headers(),
              userId: _controllerDB.user.value!.result!.id!,
              commonId: widget.commonGroupSelected!.id,
              search: widget.commonBoardListItem![0].isSearchResultTodo!
                  ? SearchKey
                  : null)
          .then((todoResult) {
        timePeriod = todoResult;
      });
    });
  }

  GetCommonGroupBackground(int CommonId, int UserId) async {
    setState(() {
      isLoading = true;
    });
    await _controllerCommon.GetCommonGroupBackground(
      _controllerDB.headers(),
      CommonId: CommonId,
      UserId: UserId,
    ).then((value) {
      setState(() {
        _getCommonGroupBackgroundResult = value;
        backGround = false;
      });
    });
  }

  Future<void> getAllCommans() async {
    await _controllerCommon.GetAllCommons(
      //! Burada hata veriyor
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id!, //! 2715
      groupId: selectedCommonGroupId, //! 31 -- 119 oldu
      search: SearchKey, //! Bos
      UserIds: selectedUserIds, //!  Liste bos
      LabelList: selectedLabelsId, //!  Liste bos
      TypeWho: selectedTypeWhoId, //! 0
      WhichSection: selectedWhichSectionId, //! 0
      IncludeElement: selectedIncludeElementId, //! 0
      ReminderInclude: selectedReminderIncludeId, //! 0
      StartDate:
          StartDate == null ? null : StartDate!.toIso8601String(), //! null
      EndDate: EndDate == null ? null : EndDate!.toIso8601String(), //! null
    );
    try {
      selectedMenuItemIncommons = _controllerCommon
          .getAllCommons.value!.result!.commonBoardList!.first.id!;
    } catch (e) {
      selectedMenuItemIncommons = 0;
    }

    _commons = _controllerCommon.getAllCommons.value!;

    _commons.result!.totalCount =
        _controllerCommon.getAllCommons.value!.result!.commonBoardList!.length;
  }

  void initController() {
    controller = BottomSheet.createAnimationController(this);
    controller!.duration = const Duration(milliseconds: 100);
    controller!.reverseDuration = const Duration(milliseconds: 100);
    pageControllerForBoard = PageController();
  }

  StreamSubscription? _subscription;
  GetDetailAndSendNotificationResult _detailAndSendNotificationResult =
      GetDetailAndSendNotificationResult(hasError: false);
  String storedValue = '';

  DraggableScrollableController? _draggableScrollableController;
  DraggableSheetController? _draggableSheetController;

  @override
  void initState() {
    _draggableScrollableController = DraggableScrollableController();
    _draggableSheetController = DraggableSheetController();
    super.initState();
    initController();
    setState(() {
      isLoading = true;
      loading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
        loading = true;
      });

      double screenWidth = MediaQuery.of(context).size.width;
      pageController = PageController(
        viewportFraction: _getViewportFraction(screenWidth),
      );
      pageControllerForBoard = PageController(
          viewportFraction: _getViewportFractionForBoard(screenWidth));
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
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          value: 4,
          key: Key(AppLocalizations.of(context)!.completed),
        ),
      ];
      //!(Invalid argument(s) (onError): The error handler of Future.catchError
      //must return a value of the future's type)
      commonGroupList = await _controllerCommon.GetListCommonGroup(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
      ).then((value) async {
        // common gruplar çekildikten sonra önyüze yansıtır
        _commonGroup = await value.listOfCommonGroup!;
        final prefs = await SharedPreferences.getInstance();
        storedValue = prefs.getString('searchDropdownValue') ?? '';
        if (storedValue != '') {
          // If there is a stored value, find the matching CommonGroup
          CommonGroup commonGroup = _commonGroup.firstWhere(
              (group) => group.groupName == storedValue,
              orElse: () =>
                  _commonGroup.first // Fallback to the first group if not found
              );
          print('storedValue: $storedValue');
          setState(() {
            selectedCommonGroupId = commonGroup.id;
            selectedCommonGroupIdForMove = commonGroup.id;
          });
        }

        await changeGroup();
        await GetCommonGroupBackground(
            0, _controllerDB.user.value!.result!.id!);

        return value;
      }).catchError((e) {
        print("HATA : res GetGroupById error " + e.toString());
        return ListOfCommonGroup(hasError: true); //!eklendi
      });

      _detailAndSendNotificationResult =
          await userDB.GetDetailAndSendNotification(_controllerDB.headers(),
              userId: _controllerDB.user.value!.result!.id!,
              language: AppLocalizations.of(context)!.date);
      await userDB.GetAdminCustomer(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
        administrationId: _controllerDB.user.value!.result!.administrationId!,
      ).then((value) {
        adminCustomer = value;
      });

      await _controllerCommon.GetPublicMeetings(_controllerDB.headers(),
          page: 0, take: 1000);
      _socialResult = await _controllerSocial.GetSocialList(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
      );

      // commonGroupList = await _controllerCommon.GetListCommonGroup(
      //     _controllerDB.headers(),
      //     userId: _controllerDB.user.value.result.id);

      var commonBoard = _commons.result?.commonBoardList!.toList();

      // if (commonBoard.length > 0) {
      //   _selectedCarouselIndex = 1;
      //   _carouselController.animateToPage(1);
      // }
      setState(() {
        isLoading = false;
      });
    });

    UpdateNotification(String Url, int NotificationId, bool IsAccept) {
      _controllerNotification.UpdateInviteProcess(_controllerDB.headers(),
          UserId: _controllerDB.user.value!.result!.id!,
          Url: Url,
          NotificationId: NotificationId,
          IsAccept: IsAccept);
    }

/* 
    Future<void> getAllCommans() async {
      await _controllerCommon.GetAllCommons(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
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
            .getAllCommons.value!.result!.commonBoardList!.first.id!;
      } catch (e) {
        selectedMenuItemIncommons = 0;
      }

      _commons = _controllerCommon.getAllCommons.value!;
      _commons.result!.totalCount = _controllerCommon
          .getAllCommons.value!.result!.commonBoardList!.length;
    }
 */

//! TODO!:

    /*    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notificationsActionStreamSubscription =


 */

/*     Future<void> onActionReceivedMethod(ReceivedAction recivedAction) async {
      debugPrint("On Action Recived +++++++++++++++++++++++++++");
      final payload = recivedAction.payload ?? {};
      recivedAction.channelKey == 'high_importance_channel'
          ? debugPrint('onActionReceivedMethod')
          : debugPrint('Custom channel');
      print(recivedAction);
      print(recivedAction.buttonKeyPressed);
      if (recivedAction.channelKey.toString() == "download_channel") {
        //  OpenFile.open(notification.summary);
      }
      if (recivedAction.channelKey.toString() == "notificationType9") {
        print(recivedAction.channelKey.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationPage(),
          ),
        );
      }
      if (recivedAction.channelKey.toString() == "CommonInvate") {
        print(recivedAction.channelKey.toString());
        AwesomeDialog(
          context: context,
          btnCancelIcon: Icons.close,
          btnOkIcon: Icons.done,
          btnCancelText: AppLocalizations.of(context)!.decline,
          btnOkText: AppLocalizations.of(context)!.accept,
          customHeader: CircleAvatar(
            backgroundColor: Get.theme.primaryColor,
            child: Icon(
              Icons.notifications,
              size: 40,
              color: Colors.black,
            ),
            radius: 40,
          ),
          animType: AnimType.bottomSlide,
          title: recivedAction.body,
          desc: AppLocalizations.of(context)!.calling,
          btnCancelOnPress: () {
            UpdateNotification(recivedAction.id.toString(),
                int.parse(recivedAction.summary.toString()), false);
          },
          btnOkOnPress: () {
            UpdateNotification(recivedAction.id.toString(),
                int.parse(recivedAction.summary.toString()), true);
            _controllerCommon.commobReloadforNotification = true;
            _controllerCommon.update();
            _controllerCommon.commonRefreshCurrentPage = true;
            _controllerCommon.update();
            _controllerChatNew.loadChatUsers = true;
            _controllerChatNew.update();

            // showAsBottomSheet(message.data["meetingUrl"]);
          },
        )..show().whenComplete(() {});
      }
      if (recivedAction.channelKey.toString() == "notificationType8") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationPage(),
          ),
        );
      }
      if (recivedAction.channelKey.toString() == "basic_channel") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(),
          ),
        );
      }
      if (recivedAction.channelKey.toString() == "custom_sound" &&
          recivedAction.buttonKeyPressed.toString() == "open") {
        AwesomeDialog(
          context: context,
          btnCancelIcon: Icons.call_end,
          btnOkIcon: Icons.phone_in_talk,
          btnCancelText: AppLocalizations.of(context)!.decline,
          btnOkText: AppLocalizations.of(context)!.accept,
          customHeader: CircleAvatar(
            backgroundColor: Get.theme.primaryColor,
            child: Icon(
              Icons.wifi_calling_3,
              size: 40,
              color: Colors.red,
            ),
            radius: 40,
          ),
          animType: AnimType.bottomSlide,
          title: recivedAction.body,
          desc: AppLocalizations.of(context)!.calling,
          btnCancelOnPress: () {},
          btnOkOnPress: () async {
            await permissions.Permission.camera.request();
            await permissions.Permission.microphone.request();
            //    notificationsActionStreamSubscription?.cancel();
            //! kaldirildi // AwesomeNotifications().actionSink.close();
            /*   AwesomeNotifications().actionSink.close();
              AwesomeNotifications().createdSink.close(); */
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => CallWeSlide(
                          url: recivedAction.summary.toString(),
                        )),
                (Route<dynamic> route) => false);
            // showAsBottomSheet(message.data["meetingUrl"]);
          },
        )..show().whenComplete(() {});
      }

/*   if (payload['navigate'] == 'true') {
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => DemoPage(),
    ));
  } */
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      // onNotificationCreatedMethod: onNotificationCreatedMethod,
      // onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      // onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    ); */

/* notest.onActionReceivedMethod2((ReceivedAction recev) {
      print("onActionReceivedMethod");
      print(recev.buttonKeyPressed);
      print(recev.channelKey);
      print(recev.id);
      print(recev.summary);
      print(recev.title);
      print(recev.body);
      print(recev.icon);
      print(recev.payload);
      print(recev.createdDate);
      print(recev.displayedDate);
      print(recev.buttonKeyPressed);
    
  
} as ReceivedAction); */
/* 
AwesomeNotifications()
           .actionStream.listen
           ((notification) async {
        print(notification);
        print(notification.buttonKeyPressed);
        if (notification.channelKey.toString() == "download_channel") {
          //  OpenFile.open(notification.summary);
        }
        if (notification.channelKey.toString() == "notificationType9") {
          print(notification.channelKey.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationPage(),
            ),
          );
        }
        if (notification.channelKey.toString() == "CommonInvate") {
          print(notification.channelKey.toString());
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.close,
            btnOkIcon: Icons.done,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.notifications,
                size: 40,
                color: Colors.black,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: notification.body,
            desc: AppLocalizations.of(context)!.calling,
            btnCancelOnPress: () {
              UpdateNotification(notification.id.toString(),
                  int.parse(notification.summary.toString()), false);
            },
            btnOkOnPress: () {
              UpdateNotification(notification.id.toString(),
                  int.parse(notification.summary.toString()), true);
              _controllerCommon.commobReloadforNotification = true;
              _controllerCommon.update();
              _controllerCommon.commonRefreshCurrentPage = true;
              _controllerCommon.update();
              _controllerChatNew.loadChatUsers = true;
              _controllerChatNew.update();

              // showAsBottomSheet(message.data["meetingUrl"]);
            },
          )..show().whenComplete(() {});
        }
        if (notification.channelKey.toString() == "notificationType8") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationPage(),
            ),
          );
        }
        if (notification.channelKey.toString() == "basic_channel") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(),
            ),
          );
        }
        if (notification.channelKey.toString() == "custom_sound" &&
            notification.buttonKeyPressed.toString() == "open") {
          AwesomeDialog(
            context: context,
            btnCancelIcon: Icons.call_end,
            btnOkIcon: Icons.phone_in_talk,
            btnCancelText: AppLocalizations.of(context)!.decline,
            btnOkText: AppLocalizations.of(context)!.accept,
            customHeader: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.wifi_calling_3,
                size: 40,
                color: Colors.red,
              ),
              radius: 40,
            ),
            animType: AnimType.bottomSlide,
            title: notification.body,
            desc: AppLocalizations.of(context)!.calling,
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              await permissions.Permission.camera.request();
              await permissions.Permission.microphone.request();
          //    notificationsActionStreamSubscription?.cancel();
              //! kaldirildi // AwesomeNotifications().actionSink.close();
           /*   AwesomeNotifications().actionSink.close();
              AwesomeNotifications().createdSink.close(); */
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => CallWeSlide(
                            url: notification.summary.toString(),
                          )),
                  (Route<dynamic> route) => false);
              // showAsBottomSheet(message.data["meetingUrl"]);
            },
          )
          ..show().whenComplete(() {});
        }
      });




*/
    _controllerTodo.GetGenericTodos(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id,
            ModuleType: 35,
            search: "")
        .then((value) {
      final currentTime = DateTime.now();
      for (int i = 0; i < value.genericTodo!.length; i++) {
        if (value.genericTodo![i].remindDate != null) {
          final diff_hr = currentTime
              .difference(DateTime.parse(value.genericTodo![i].remindDate!))
              .inHours;
          print("diff_hr: " + diff_hr.toString());
          if (diff_hr < 24 && diff_hr > 0) {
            AwesomeDialog(
              context: context,
              customHeader: CircleAvatar(
                backgroundColor: Get.theme.primaryColor,
                child: Icon(
                  Icons.notification_important,
                  size: 40,
                  color: Colors.black,
                ),
                radius: 40,
              ),
              animType: AnimType.bottomSlide,
              title: value.genericTodo![i].content,
              showCloseIcon: true,
              desc: AppLocalizations.of(context)!.reminderModal,
            )..show();
          }
        }
      }
    });

    //  });

    setState(() {
      isLoading = false;
      loading = false;
    });
  }

  //!StreamSubscription<ReceivedAction>? notificationsActionStreamSubscription;
  ConfirmInviteUsersCommonTask(int UserCommonOrderId, bool IsAccept) {
    _controllerTodo.ConfirmInviteUsersCommonTask(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        UserCommonOrderId: UserCommonOrderId,
        IsAccept: IsAccept);
  }

  @override
  void didChangeDependencies() {
    setState(() {
      setSubMenuItems();
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller?.dispose();
    _scrollController.dispose();
    pageControllerForBoard?.dispose();
    pageController?.dispose();
    _carouselController?.dispose();
    _draggableScrollableController!.dispose();
    //! notificationsActionStreamSubscription?.cancel();
    // AwesomeNotifications().actionSink.close(); // Bu satırı kaldır
    // AwesomeNotifications().createdSink.close(); // Bu satırı kaldır
    print("dispose");
    super.dispose();
  }

  Future<void> CareateOrJoinMetting(List<int> TargetUserIdList) async {
    await commonDB.CareateOrJoinMetting(_controllerDB.headers(),
            OwnerId: _controllerDB.user.value!.result!.id,
            UserId: _controllerDB.user.value!.result!.id,
            TargetUserIdList: TargetUserIdList,
            ModuleType: 20)
        .then((value) {
      setState(() {
        _careateOrJoinMettingResult = value;
        loading = false;
        MeetingUrl = value.result!.meetingUrl!;
      });
    });
  }

  PanelController _pc = new PanelController();
  double _panelMinSize = 0.0;
  bool panelType = true;
  String MeetingUrl = "";

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    final draggableSheetController =
        Provider.of<DraggableSheetController>(context);
    final ControllerCommon controller = Get.put(ControllerCommon());
    var orientation = MediaQuery.of(context).orientation;

    return GetBuilder<ControllerCommon>(builder: (c) {
      if (isLoading) {
        return Center(child: CustomLoadingCircle());
      }
      return SlidingUpPanel(
        defaultPanelState: PanelState.CLOSED,
        controller: _pc,
        onPanelClosed: () {
          setState(() {
            panelType = _pc.isPanelClosed;
            _panelMinSize = 0.0;
            print(_panelMinSize);
          });
        },
        onPanelOpened: () {
          setState(() {
            panelType = false;
          });
        },
        panel: loading
            ? Container(
                color: Colors.yellow,
              )
            : Container(
                color: Colors.blue,
                child: Stack(
                  children: [
                    InAppWebView(
                        onPermissionRequest: (controller, request) async {
                          return PermissionResponse(
                              resources: request.resources,
                              action: PermissionResponseAction.GRANT);
                        },
                        /*   androidOnPermissionRequest:
                            (InAppWebViewController controller, String origin,
                                List<String> resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT); 
                        }, */
                        //   initialOptinss : InAppWebViewSettings(isInspectable: kDebugMode),
                        initialSettings: InAppWebViewSettings(
                          useHybridComposition: true,
                          allowsInlineMediaPlayback: true,
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: false,
                          userAgent:
                              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36 OPR/84.0.4316.21",
                        ),

                        /*   android: AndroidInAppWebViewOptions(
                            useHybridComposition: true,
                          ),
                          ios: IOSInAppWebViewOptions(
                            allowsInlineMediaPlayback: true,
                          ), */

                        initialUrlRequest: URLRequest(
                          url: WebUri.uri(
                              Uri.parse(MeetingUrl)) //! Weburi eklendi
                          ,
                        )),
                    Positioned(
                      right: 13,
                      bottom: 9,
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            _controllerCommon.EndMeeting(
                                _controllerDB.headers(),
                                UserId: _controllerDB.user.value!.result!.id!,
                                MeetingId: _careateOrJoinMettingResult
                                    .result!.meetingId!);
                            setState(() {
                              _panelMinSize = 0.0;
                            });
                            _pc.close();
                            loading = true;
                          } catch (e) {
                            setState(() {
                              _panelMinSize = 0.0;
                            });
                            _pc.close();
                            loading = true;
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
        maxHeight: Get.height,
        minHeight: _panelMinSize,
        margin: EdgeInsets.only(bottom: 20),
        body: Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              backgroundColor: Colors.white,
              title: Text(
                widget.commonGroupSelected!.groupName.toString(),
                style: TextStyle(
                  //  backgroundColor: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            //Get.theme.scaffoldBackgroundColor,
            body: Stack(children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.shortestSide / 30,
                  vertical: Get.height / 75,
                ),
                child: Container(
                    //  color: const Color.fromARGB(255, 237, 135, 26),
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //? Ana modül Butonlari

                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                      child: yatayIkonlar(),
                    ),

//? Yatay liste butonlari
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        color: Colors.transparent,
                        height: Get.height / 16,
                        //140,
                        child: buildProjectAndTeamWidget(),
                      ),
                    ),
                    SizedBox(
                      height: 1,
                      //Get.height / 188,
                    ),

                    Expanded(
                      child: Container(
                        //color: const Color.fromARGB(255, 98, 27, 241),
                        // height: context.height / 2.5,
                        child: Row(
                          children: [
                            isPrivate
                                ? Flexible(
                                    //  flex: 4,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: Get.width / 1,
                                          height: isTablet
                                              ? (orientation ==
                                                      Orientation.portrait
                                                  ? Get.height / 1.5
                                                  : Get.height / 1.8)
                                              : Get.height * 0.6,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: isLoading
                                                    ? CustomLoadingCircle()
                                                    : PageView(
                                                        padEnds: false,
                                                        controller:
                                                            pageControllerForBoard,
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        onPageChanged:
                                                            (i) async {
                                                          bool refreshNewPage =
                                                              false;

                                                          if (_currentPage !=
                                                              ((i) ~/ perPage)
                                                                  .ceil()) {
                                                            refreshNewPage =
                                                                true;
                                                          }

                                                          setState(() {
                                                            initialBoard = i;
                                                          });

                                                          if (refreshNewPage) {
                                                            await loadPage(
                                                                _currentPage);
                                                          }
                                                        },
                                                        children:
                                                            buildCommons(),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _commons.result!.commonBoardList!
                                                    .length !=
                                                0
                                            ? Text('')
                                            : Center(
                                                child: Text(
                                                AppLocalizations.of(context)!
                                                    .thereIsNoBoard,
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            isPrivate
                                ? SizedBox(
                                    child: Container(
                                      width: 1,
                                      color: const Color.fromARGB(
                                          255, 62, 18, 222),
                                    ),
                                  )
                                : Expanded(
                                    //flex: 2,
                                    child: _commons.result == null
                                        ? CustomLoadingCircle()
                                        : caruzel(orientation),

                                    //caruzel(orientation),
                                  ),
                          ],
                        ),
                      ),
                    )

                    //: SizedBox(),
                  ],
                )),
              ),

              //!

              Consumer<DraggableSheetController>(
                builder: (context, controller, child) {
                  // if (!controller.isSheetOpen ||
                  //     controller.boardTodo == null ||
                  //     controller.commonBoardListItem == null) {
                  //   return SizedBox.shrink();
                  // }

                  return NotificationListener<DraggableScrollableNotification>(
                      onNotification: (notification) {
                        if (notification.extent == 0.0) {
                          controller.setSheetAttached(false);
                        }
                        return true;
                      },
                      child: Positioned(
                        bottom: Get.height > 850
                            ? Get.height * 0.1
                            : Get.height * 0.15,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: Get.height > 850
                              ? Get.height * 0.80
                              : Get.height * 0.85,
                          child: controller.boardTodo.id == null
                              ? SizedBox.shrink()
                              : DraggableScrollableSheet(
                                  controller: _draggableScrollableController,
                                  //_draggableScrollableController,
                                  initialChildSize: 0.8,
                                  minChildSize: 0.0,
                                  maxChildSize: 1.0,
                                  builder: (BuildContext context,
                                      ScrollController scrollController) {
                                    // controller.setSheetAttached(true);
                                    //  _toggleSheet();
                                    /*              _draggableScrollableController!.animateTo(
          0.8,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ); */
                                    final draggableSheetController =
                                        Provider.of<DraggableSheetController>(
                                            context);
                                    draggableSheetController.ownerId =
                                        controller.boardTodo.id!;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16.0)),
                                      ),
                                      child: CommonDetailsPage(
                                        todoId: controller.boardTodo
                                            .id!, // Use  to assert non-null
                                        commonBoardId: controller
                                            .commonBoardListItem
                                            .id!, // Use  to assert non-null
                                        selectedTab: 0,
                                        commonTodo: controller.boardTodo,
                                        commonBoardTitle: controller
                                            .commonBoardListItem.title!,
                                        cloudPerm: (_controllerTodo
                                                    .hasFileManagerTodoPerm(
                                                        controller
                                                            .commonBoardListItem
                                                            .id!,
                                                        controller
                                                            .boardTodo.id!)) ==
                                                true ||
                                            _controllerCommon
                                                .hasFileManagerCommonPerm(
                                              controller
                                                  .commonBoardListItem.id!,
                                            ),
                                        toggleSheetClose: controller.closeSheet,
                                        togglePlay: true,
                                        isPrivate: isPrivate,
                                        refreshPage: true,
                                        refreshPageFunction: () {
                                          loadPage(0);
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ));
                },
              ),
            ])),
      );
    });
  }

  CarouselSlider caruzel(Orientation orientation) {
    return CarouselSlider.builder(
      itemBuilder: (ctx, index, xx) //! xx degeri eklendi
          {
        List<CommonBoardListItem> publicCommonBoardList =
            _commons.result!.commonBoardList!;

        if (publicCommonBoardList.isEmpty) {
          return Container(
              //  color: const Color.fromARGB(255, 39, 8, 212),
              );
        }
        CommonBoardListItem commonBoardListItem = publicCommonBoardList[index];

        return _commons.result!.commonBoardList!.isEmpty
            ? Container(
                color: const Color.fromARGB(255, 2, 1, 18),
              )
            : buildBoardForTasksList(
                commonBoardListItem, commonBoardListItem.isPublic!);
      },
      itemCount: _commons.result!.commonBoardList!.length,
      carouselController: _carouselSliderController!,
      options: CarouselOptions(
        onPageChanged: (i, reason) {
          setState(() {
            if (_selectedCarouselIndex > i) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.offset - _scrollAmount,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            } else {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.offset + _scrollAmount,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            }
            _selectedCarouselIndex = i;
          });
        },
        pageSnapping: true,
        /* height: Get.size.longestSide > 800
            ? (orientation == Orientation.portrait
                ? Get.height / 1.4
                : Get.height / 2.4)
            : Get.height / 2.5, */
        height: context.height,
        aspectRatio: 16 / 9,
        viewportFraction: 1,
        autoPlayInterval: Duration(seconds: 5),
        autoPlayAnimationDuration: Duration(seconds: 1),
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: false,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget buildBoardForTasksList(
      CommonBoardListItem commonBoardListItem, bool isPublic) {
    final draggableSheetController =
        Provider.of<DraggableSheetController>(context);
    var shortestSize = Get.size.width;
    var orientation = MediaQuery.of(context).orientation;
    var isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Container(

        //  height: context.height,
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          //Get.theme.scaffoldBackgroundColor,
          //Colors.white, //Color.fromRGBO(249, 249, 249, 1),

          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white,
              offset: Offset(0, 5),
              blurRadius: 20,
              spreadRadius: -15,
            )
          ],
        ),
        child: Column(
          children: [
            // Text(
            //   commonBoardListItem.title,
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            // ),
            isPublic
                ? Container(
                    //color: const Color.fromARGB(255, 226, 47, 181),
                    width: Get.width,
                    height: orientation == Orientation.portrait
                        ? Get.height / 1.82
                        : Get.height / 2.5,

                    //  height: context.height - 500,
                    child: Row(
                      children: [
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 0,
                            child: isLoading
                                ? CustomLoadingCircle()
                                : PageView(
                                    padEnds: false,
                                    controller: pageControllerForBoard,
                                    physics: BouncingScrollPhysics(),
                                    onPageChanged: (i) async {
                                      bool refreshNewPage = false;
                                      if (_currentPage !=
                                          ((i) ~/ perPage).ceil()) {
                                        refreshNewPage = true;
                                      }

                                      setState(() {
                                        initialBoard = i;
                                      });

                                      if (refreshNewPage) {
                                        await loadPage(_currentPage);
                                      }
                                    },
                                    children: buildCommons(),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemExtent: 55,
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      itemCount: commonBoardListItem.todos.length,
                      itemBuilder: (context, index) {
                        boardTodo = commonBoardListItem.todos[index];
                        Color boardColor = boardTodo!.color != ""
                            ? Color(int.parse(
                                boardTodo!.color!.replaceFirst('#', '0xFF')))
                            : Colors.transparent;

                        return GestureDetector(
                          onTap: () {
                            /*
                            draggableSheetController.updateBoardTodoAndListItem(
                                commonBoardListItem.todos[index],
                                commonBoardListItem);
                            draggableSheetController.toggleSheet();
                        */
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommonDetailsPage(
                                  todoId: commonBoardListItem.todos.first
                                      .id!, // Use  to assert non-null

                                  commonBoardId: commonBoardListItem
                                      .todos[index]
                                      .id!, // Use  to assert non-null
                                  selectedTab: 0,
                                  commonTodo: commonBoardListItem.todos.first,
                                  commonBoardTitle: commonBoardListItem.title!,
                                  cloudPerm:
                                      (_controllerTodo.hasFileManagerTodoPerm(
                                                  commonBoardListItem.id!,
                                                  commonBoardListItem
                                                      .todos.first.id!)) ==
                                              true ||
                                          _controllerCommon
                                              .hasFileManagerCommonPerm(
                                            commonBoardListItem.id!,
                                          ),
                                  //  toggleSheetClose: commonBoardListItem.closeSheet,
                                  togglePlay: true,
                                  isPrivate: false,
                                  refreshPage: true,
                                  /*  refreshPageFunction: () {
                                          loadPage(0);
                                        }, */
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Tooltip(
                              message: boardTodo!.content,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: boardColor,
                                        /*  boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              // color: Colors.grey,
                                              offset: Offset(0, 5),
                                              blurRadius: 20,
                                              spreadRadius: -15,
                                            )
                                          ] */
                                      ),
                                      width: 40,
                                      height: 40,
                                      //color: boardColor,
                                      child: boardTodo!.iconPath == ""
                                          ? Image.asset(
                                              'assets/images/create.png')
                                          : Image.network(
                                              boardTodo!.iconPath!,
                                              // width: 20,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        style: TextStyle(color: Colors.black),
                                        //  color: boardColor,
                                        boardTodo!.content!,

                                        overflow: TextOverflow
                                            .ellipsis, // Avoid text overflow
                                        maxLines:
                                            1, // Limit the text to one line
                                      ),
                                    ),

                                    /* 
                                    TextButton.icon(
                                     
                                      icon: boardTodo!.iconPath == ""
                                          ? Image.asset('assets/images/create.png')
                                          : Image.network(boardTodo!.iconPath!,
                                              width: 20),
                                      onPressed: () {
                                        draggableSheetController
                                            .updateBoardTodoAndListItem(
                                                commonBoardListItem.todos[index],
                                                commonBoardListItem);
                                        draggableSheetController.toggleSheet();
                                      },
                                      label: 
                                      
                                      Text(
                                        style: TextStyle(color: Colors.black),
                                        //  color: boardColor,
                                        boardTodo!.content!,
                                        overflow: TextOverflow
                                            .ellipsis, // Avoid text overflow
                                        maxLines: 1, // Limit the text to one line
                                      ),
                                    ),
                                   */
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(
                child: Container(
              color: Colors.white,
              width: Get.width,
              height: 100,
            )),
          ],
        ));
  }

  Widget buildProjectAndTeamWidget() {
    final draggableSheetController =
        Provider.of<DraggableSheetController>(context);
    if (isLoading) {
      return Center(child: CustomLoadingCircle()); // Or any other fallback UI
    }
    var shortestSize = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSize > 600;
    return Container(
        //color: Colors.purpleAccent,
        child: Column(
      //  crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        //  children: [
        //! Dropdown
        /*  
        Expanded(
          //   flex: 1,
          // flex: 10,
          child:
              /* CustomSearchDropDownMenu(
                fillColor: Colors.white,
                labelHeader: _commonGroup
                    .firstWhere(
                        (commonGroup) =>
                            commonGroup.id == selectedCommonGroupId,
                        orElse: () => CommonGroup(
                            id: 0,
                            groupName: AppLocalizations.of(context)!.search))
                    .groupName,
                list: _commonGroup
                    .map((commonGroup) => commonGroup.groupName!)
                    .toList(),
                onChanged: (newValue) async {
                  draggableSheetController.closeSheet();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('searchDropdownValue', newValue);
                  CommonGroup commonGroup = _commonGroup.firstWhere(
                      (commonGroup) => commonGroup.groupName == newValue);
                  setState(() {
                    selectedCommonGroupId = commonGroup.id;
                    changeGroup();
                    pageController!.jumpToPage(0);
                    // Add your custom logic here
                  });
                },
                error: 'Error',
                labelIcon: Icons.info,
                labelIconExist: true,
              ), */


//? DropDownProject

              DropdownSearch<String>(
            decoratorProps: DropDownDecoratorProps(
              expands: false,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                fillColor: const Color.fromARGB(255, 16, 40, 219),
                hoverColor: const Color.fromARGB(255, 206, 255, 99),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Köşe yuvarlaklık değeri
                  borderSide: BorderSide(color: Colors.grey), // Kenarlık rengi
                ),
              ),
            ),
            selectedItem: storedValue,
            items: (f, cs) => _commonGroup
                .map((commonGroup) => commonGroup.groupName!)
                .toList(),
            suffixProps: DropdownSuffixProps(
                clearButtonProps: ClearButtonProps(isVisible: false)),
            compareFn: (item, selectedItem) => item == selectedItem,
            dropdownBuilder: (context, selectedItem) {
              selectedItem = selectedItem;
              print("selectedItem  : " + selectedItem.toString());

              return ListTile(
                contentPadding: EdgeInsets.only(left: 0),
                title: Text(selectedItem!),
              );
            },
            popupProps: PopupProps.menu(
              menuProps: MenuProps(
                  backgroundColor: const Color.fromARGB(255, 233, 231, 224)),
              disableFilter: true, //data will be filtered by the backend
              showSearchBox: true,
              showSelectedItems: true,
              itemBuilder: (ctx, item, isDisabled, isSelected) {
                print("item  : " + item);
                return ListTile(
                  /*  leading: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 16, 223, 37),
                          child: Text(item)), */
                  selected: isSelected,
                  title: Text(item),
                );
              },
            ),
            onChanged: (newValue) async {
              draggableSheetController.closeSheet();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('searchDropdownValue', newValue!);
              CommonGroup commonGroup = _commonGroup.firstWhere(
                  (commonGroup) => commonGroup.groupName == newValue);

              setState(() {
                storedValue = newValue;
                selectedCommonGroupId = commonGroup.id;
                DateTime now = DateTime.now();
                // İstenen formatta tarih-saat bilgisini oluştur
                String formattedDate =
                    DateFormat("yyyy-MM-ddThh:mm").format(now);
                print(formattedDate);
                changeGroup();
                print(pageControllerForBoard!.hasClients);
                if (pageControllerForBoard!.hasClients) {
                  pageControllerForBoard!.jumpToPage(0);
                }
              });
            },
      
      
          ),
       
       
       
        ),
        */

        /*    Expanded(
              flex: 1,
              child: SizedBox(),
            ), */

/* 
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new CollaborationPage()));
                },
                child: Container(
                  child: ImageIcon(
                    AssetImage('assets/images/icon/housePlus.png'),
                    size: isTablet ? 35 : 25,
                  ),
                ),
              ),
            ),
        
         */
        // ],
        // ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _commons.result == null
                    ? CircularProgressIndicator()
                    : ListView.builder(
                        // padding: EdgeInsets.only(top: 0),
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            _commons.result!.commonBoardList!.toList().length +
                                1,
                        itemBuilder: (context, index) {
                          var commonBoard =
                              _commons.result!.commonBoardList!.toList();
                          return Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    // Correct comparison: compare index as an integer, not as a string
                                    if (index == commonBoard.length) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              InvoiceWithDocumentPage(
                                            invoiceWithDocumentType:
                                                InvoiceWithDocumentType
                                                    .IncomePaid,
                                          ),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        isPrivate = _commons.result!
                                            .commonBoardList![index].isPublic!;
                                      });
                                      _changePage(index);
                                    }
                                  },
                                  child: _chipCard(index, 'refresh-data')),
                              SizedBox(width: 10), // Add spacing between chips
                            ],
                          );
                        },
                      ),
              ),
              //_chipCard(100, 'budget')
            ],
          ),
        ),
      ],
    ));
  }

  Widget yatayIkonlar() {
    double buttonWidth = Get.width / 4.5;
    Color ikoncolors = Colors.black;
    //? Yatay Ikonlar
    return Container(
      color: Colors.white,
      //height: 70,
      width: 440,
      child: Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        //controller: _scrollController,
        //scrollDirection: Axis.horizontal,
        children: [
          //? Invoice Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                //color: Colors.pink,
                width: buttonWidth,
                // flex: 3,
                child: DetailModuleButton(
                  text: "Buchhaltung",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InvoiceWithDocumentPage(
                          invoiceWithDocumentType:
                              InvoiceWithDocumentType.IncomePaid,
                        ),
                      ),
                    );
                  },
                  ikon: Ionicons.receipt_outline,
                  kolorIkon: ikoncolors,
                  kolorCevre: Colors.white, // Colors.blue[100],
                ),
              ),
              SizedBox(
                width: Get.width / 40,
              ),
              //? Ariza Takip
              Container(
                width: buttonWidth,
                // flex: 3,
                child: DetailModuleButton(
                  onTap: () {
                    if (timePeriod != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => BauzeienplanPage(
                                title: widget.commonGroupSelected!.groupName
                                    .toString(),
                                timePeriod: timePeriod,
                                commonGroupSelected: widget.commonGroupSelected,
                                customerId:
                                    widget.commonBoardListItem![0].customerId)),
                      );
                    }
                  },
                  text: "Bauzeitenplan",
                  ikon: Ionicons.timer_outline,
                  kolorIkon: ikoncolors,
                  kolorCevre: Colors.white, //Colors.yellow[100],
                ),
              ),
              SizedBox(
                width: Get.width / 40,
              ),
              Expanded(
                child: Container(
                  //width: 50,
                  child: DetailModuleButton(
                    text: "Kalkulation",
                    ikon: Ionicons.calculator_outline,
                    kolorIkon: ikoncolors,
                    kolorCevre: Colors.white, //Colors.yellow[100],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          //? Document Analyz
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: buttonWidth,
                child: DetailModuleButton(
                    text: "Mängeln",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MangelPage(
                            ownerId: widget.commonGroupSelected!.id,
                          ),
                        ),
                      );
                    },
                    ikon: Ionicons.construct_outline,
                    kolorIkon: ikoncolors,
                    kolorCevre: Colors.white // Colors.green[100],
                    ),
              ),
              SizedBox(
                width: Get.width / 40,
              ),
              Container(
                width: buttonWidth,
                child: DetailModuleButton(
                  text: "Assistent",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GeneralSearchPage(),
                      ),
                    );
                  },
                  ikon: Icons.assistant_direction_outlined,
                  kolorIkon: ikoncolors,
                  kolorCevre: Colors.white,
                  // Colors.purple[100],
                ),
              ),
              SizedBox(
                width: Get.width / 40,
              ),
              Container(
                width: Get.width / 5.3,
                child: DetailModuleButton(
                  text: "Anfrage",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GeneralSearchPage(),
                      ),
                    );
                  },
                  ikon: Ionicons.reader_outline,
                  kolorIkon: ikoncolors,
                  kolorCevre: Colors.white,
                  // Colors.purple[100],
                ),
              ),
              SizedBox(
                width: Get.width / 30,
              ),
              Container(
                width: Get.width / 5.3,
                child: DetailModuleButton(
                  text: "Angebot",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GeneralSearchPage(),
                      ),
                    );
                  },
                  ikon: Ionicons.newspaper,
                  kolorIkon: ikoncolors,
                  kolorCevre: Colors.white,
                  // Colors.purple[100],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipCard(int index, String icon) {
    var commonBoard = _commons.result!.commonBoardList!.toList();

    return Container(
        height: 40,
        padding: EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: _selectedCarouselIndex != index
              ? const Color.fromARGB(255, 81, 80, 80)
              : const Color(0xfff1d26c),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: standartCardShadow(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Align(
                alignment: Alignment.center,
                child: ImageIcon(
                  color: _selectedCarouselIndex != index
                      ? Colors.white
                      : Colors.black,
                  AssetImage(index == commonBoard.length
                      ? 'assets/images/icon/budget.png'
                      : 'assets/images/icon/${icon}.png'),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                index == commonBoard.length
                    ? AppLocalizations.of(context)!.invoice
                    : commonBoard[index].title!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedCarouselIndex != index
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              // Add spacing between chips
            ],
          ),
        ));
  }

  Container _customAvatar(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => ProfilePage()));
                  },
                  child: AvatarWithUsername(
                    imagePath: _controllerDB.user.value!.result!.photo!,
                    username: _controllerDB.user.value!.result!.name! +
                        "  " +
                        _controllerDB.user.value!.result!.surname!,
                    title: AppLocalizations.of(context)!.hello,
                    usernameStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    titlestyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    avatarRadius: 40,
                  ),
                ),
                Row(
                  children: [
                    //isTablet ?

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new CollaborationPage()));
                      },
                      child: Container(
                        child: ImageIcon(
                          AssetImage('assets/images/icon/housePlus.png'),
                          size: isTablet ? 35 : 25,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    //? CustomerPAge Button
                    /*   IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new CustomerPage()));
                      },
                      icon: ImageIcon(
                        AssetImage('assets/images/icon/people.png'),
                        size: 30,
                      ),
                    ), */
//? OCRPage Button
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new CustomerPage()));
                      },
                      icon: ImageIcon(
                        AssetImage('assets/images/icon/research-icon.png'),
                        size: 30,
                      ),
                    ),
                    //? NotePAge Button
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new CustomerPage()));
                      },
                      icon: ImageIcon(
                        AssetImage('assets/images/icon/notebook.png'),
                        size: 30,
                      ),
                    ),
                    //? AnalyzePage Button
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new CustomerPage()));
                      },
                      icon: ImageIcon(
                        AssetImage('assets/images/icon/search-document.png'),
                        size: 30,
                      ),
                    ),
                    //: SizedBox(),
                    // isTablet
                    //     ? IconButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //               context,
                    //               new MaterialPageRoute(
                    //                   builder: (BuildContext context) =>
                    //                       GeneralSearchPage()));
                    //         },
                    //         icon: ImageIcon(
                    //           AssetImage(
                    //               'assets/images/icon/magnifying-glass.png'),
                    //           size: 30,
                    //         ),
                    //       )
                    //     : SizedBox(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    NotificationPage()));
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            child: IconButton(
                              onPressed: () {},
                              icon: ImageIcon(
                                AssetImage(
                                    'assets/images/icon/notification3.png'),
                                size: 25,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: HexColor('27d1df'),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      _controllerDB.notificationUnreadCount
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  )))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _searchWidget(BuildContext context) {
    return GestureDetector(
      child: Container(
          height: Get.height / 16,
          decoration: BoxDecoration(
              boxShadow: standartCardShadow(),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       searchTile = false;
              //     });
              //   },
              //   child: Icon(
              //     Icons.search,
              //     color: Colors.black,
              //     size: 20,
              //   ),
              // ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new CustomerPage()));
                  },
                  child: TextField(
                    controller: _searchController,
                    onChanged: (s) {
                      FilterCustomer();
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.partnerSearch,
                      hintStyle: TextStyle(
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    enabled: false,
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    child: IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                        AssetImage('assets/images/icon/magnifying-glass.png'),
                      ),
                      color: Colors.black,
                    ),
                  ),
                  // Positioned(
                  //     top: 0,
                  //     right: 0,
                  //     child: Container(
                  //         padding: EdgeInsets.all(5),
                  //         decoration: BoxDecoration(
                  //             color: Get.theme.primaryColor,
                  //             shape: BoxShape.circle),
                  //         child: Center(
                  //           child: Text(
                  //             _controllerDB.notificationUnreadCount.toString(),
                  //             style:
                  //                 TextStyle(fontSize: 12, color: Colors.white),
                  //           ),
                  //         )))
                ],
              ),
            ],
          )),
    );
  }

  List<Customer> FilterCustomer() {
    List<Customer> cstmr;
    if (!searchTile) {
      cstmr = adminCustomer.result!;
      return cstmr;
    }
    if (!_searchController.text.isBlank!) {
      cstmr = adminCustomer.result!
          .where((c) =>
              c.title!
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              c.customerAdminName!
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              c.customerAdminSurname!
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    } else {
      cstmr = adminCustomer.result!;
    }
    return cstmr;
  }

  Widget buildBoardForTasks(
      CommonBoardListItem commonBoardListItem, bool isPublic) {
    final draggableSheetController =
        Provider.of<DraggableSheetController>(context);
    var shortestSize = Get.size.width;
    var orientation = MediaQuery.of(context).orientation;
    var isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Container(

        //  height: context.height,
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Get.theme.scaffoldBackgroundColor,
          //Colors.white, //Color.fromRGBO(249, 249, 249, 1),

          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 5),
              blurRadius: 20,
              spreadRadius: -15,
            )
          ],
        ),
        child: Column(
          children: [
            // Text(
            //   commonBoardListItem.title,
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            // ),
            isPublic
                ? Container(
                    //color: const Color.fromARGB(255, 226, 47, 181),
                    width: Get.width,
                    height: orientation == Orientation.portrait
                        ? Get.height / 1.82
                        : Get.height / 2.5,

                    //  height: context.height - 500,
                    child: Row(
                      children: [
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 0,
                            child: isLoading
                                ? CustomLoadingCircle()
                                : PageView(
                                    padEnds: false,
                                    controller: pageControllerForBoard,
                                    physics: BouncingScrollPhysics(),
                                    onPageChanged: (i) async {
                                      bool refreshNewPage = false;
                                      if (_currentPage !=
                                          ((i) ~/ perPage).ceil()) {
                                        refreshNewPage = true;
                                      }

                                      setState(() {
                                        initialBoard = i;
                                      });

                                      if (refreshNewPage) {
                                        await loadPage(_currentPage);
                                      }
                                    },
                                    children: buildCommons(),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet
                            ? (orientation == Orientation.portrait ? 6 : 9)
                            : 4,
                        childAspectRatio:
                            isTablet ? 0.9 : 0.85, // Keeps items square
                        crossAxisSpacing:
                            orientation == Orientation.portrait ? 15 : 30,
                        mainAxisSpacing: Get.height > 850 ? 15 : 10,
                      ),
                      itemCount: commonBoardListItem.todos.length,
                      itemBuilder: (context, index) {
                        boardTodo = commonBoardListItem.todos[index];
                        Color boardColor = boardTodo!.color != ""
                            ? Color(int.parse(
                                boardTodo!.color!.replaceFirst('#', '0xFF')))
                            : Colors.transparent;

                        return Tooltip(
                          message: boardTodo!.content,
                          child: GestureDetector(
                            onTap: () {
                              draggableSheetController
                                  .updateBoardTodoAndListItem(
                                      commonBoardListItem.todos[index],
                                      commonBoardListItem);
                              draggableSheetController.toggleSheet();
                            },
                            child: Column(
                              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  // Use Expanded or Flexible to prevent overflow
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[500]!),
                                      borderRadius: BorderRadius.circular(10),
                                      color: boardColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          20.0), // Adjust padding as needed
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: boardTodo!.iconPath == ""
                                                ? AssetImage(
                                                    'assets/images/create.png')
                                                : NetworkImage(boardTodo!
                                                    .iconPath!), // Ensure valid URL

                                            fit: BoxFit
                                                .cover, // Ensures the image covers the container
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    boardTodo!.content!,
                                    overflow: TextOverflow
                                        .ellipsis, // Avoid text overflow
                                    maxLines: 1, // Limit the text to one line
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ));
  }

  Widget buildBoards(CommonGroup pb, ControllerCommon c) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, 5),
            blurRadius: 20,
            spreadRadius: -15,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => CollaborationPage(
                commonGroupId: pb.id,
              ),
            ),
          );
        },
        child: SingleChildScrollView(
          primary: false,
          controller: _scrollController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/icon/design.png',
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pb.groupName.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            AppLocalizations.of(context)!.constructionNumber +
                                ' : ' +
                                pb.projectNumber.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          // Uncomment if needed
                          // Text(
                          //   DateFormat('dd MMM yyyy').format(DateTime.parse(pb.createDate.toString())),
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(fontSize: 12),
                          // ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        'assets/images/icon/arrow.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.projectStart,
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          Text(
                            DateFormat('dd MMM yyyy').format(
                                DateTime.parse(pb.groupStartDate.toString())),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.projectEnd,
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          Text(
                            DateFormat('dd MMM yyyy').format(
                                DateTime.parse(pb.groupEndDate.toString())),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //if (isTablet)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.constructionmanager,
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          Text(
                            pb.personalName.toString(),
                            style: TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.customerinformation,
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          Text(
                            pb.customerTitle ?? '',
                            style: TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildCommons() {
    List<Widget> boards = [];

    if (_commons.result!.commonBoardList!.isNotEmpty) {
      List<CommonBoardListItem> publicCommonBoardList = _commons
          .result!.commonBoardList!
          .where((item) => item.isPublic == true)
          .toList();
      for (int i = 0; i < publicCommonBoardList.length; i++) {
        boards.add(BuildBoards(
          changeCommon: () => loadPage(0),
          commonBoardListItem: publicCommonBoardList[i],
          gridBuilder: true,
        ));
      }
    }
    return boards;
  }

  Widget buildSocial(Social social) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new SocialPage(
                      social: social,
                    )));
      },
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(
              0xFFd2e2e2), //Colors.white, //Color.fromRGBO(249, 249, 249, 1),
          boxShadow: standartCardShadow(),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.network(
                        social.ownerPicture!,
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      )),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            social.ownerName!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            removeAllHtmlTags(social.categoryName!),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: textSplitter(removeAllHtmlTags(social.feed!)))),
            Container(
              width: Get.width,
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Get.theme.secondaryHeaderColor.withOpacity(0.75),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  buildSocialBoardIconWidget(
                      Icons.comment, social.commentCount.toString()),
                  SizedBox(
                    width: 10,
                  ),
                  buildSocialBoardIconWidget(
                      Icons.favorite_outlined, social.likeCount.toString()),
                  Spacer(),
                  social.userId == _controllerDB.user.value!.result!.id
                      ? GestureDetector(
                          onTap: () async {
                            bool? confirm = await showModalDeleteYesOrNo(
                                context,
                                AppLocalizations.of(context)!.wantToDelete);
                            if (confirm!) {
                              _controllerSocial.DeleteSocial(
                                      _controllerDB.headers(),
                                      Id: social.id)
                                  .then((value) {
                                if (value) {
                                  setState(() {
                                    _controllerSocial.socialData.removeWhere(
                                        (element) => element.id == social.id);
                                    _controllerSocial.update();
                                  });
                                }
                              });
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Container(
                              width: 40,
                              height: 30,
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              color: Color(0xFFd2e2e2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 19,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textSplitter(String input) {
    List<TextSpan> textSpans = [];
    if (input.contains("http")) {
      for (var i = 0; i <= 'http'.allMatches(input).length; i++) {
        String part = input.substring(0,
            input.indexOf('http') == -1 ? input.length : input.indexOf('http'));
        textSpans
            .add(TextSpan(text: part, style: TextStyle(color: Colors.black)));

        input = input.substring(input.indexOf('http'));
        String clickable = input.substring(
            0, input.indexOf(' ') == -1 ? input.length : input.indexOf(' '));
        textSpans.add(
          TextSpan(
            text: clickable,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch(clickable);
              },
          ),
        );
        input = input.substring(
            input.indexOf(' ') == -1 ? input.length : input.indexOf(' '));
      }
    }

    if (textSpans.length == 0) {
      textSpans
          .add(TextSpan(text: input, style: TextStyle(color: Colors.black)));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }

  ClipRRect buildPublicBoardIconWidget(IconData iconData) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(45),
      child: Container(
        width: 30,
        height: 30,
        color: Color(0xFFd2e2e2),
        child: Icon(
          iconData,
          color: Get.theme.secondaryHeaderColor,
          size: 19,
        ),
      ),
    );
  }

  ClipRRect buildSocialBoardIconWidget(IconData iconData, String Count) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(45),
      child: Container(
        width: 40,
        height: 30,
        padding: EdgeInsets.symmetric(horizontal: 3),
        color: Color(0xFFd2e2e2),
        child: Row(
          children: [
            Icon(
              iconData,
              color: Get.theme.secondaryHeaderColor,
              size: 19,
            ),
            SizedBox(
              width: 5,
            ),
            Text(Count)
          ],
        ),
      ),
    );
  }

  Widget HomePageCards() {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        isTablet
            ? SizedBox()
            : Expanded(
                child: _pageCardFourRowBg(7, 4, 0, 5, HexColor('#f4f5f7'))),
      ],
    );
  }

  Container _pageCardFourRow(
      int index1, int index2, int index3, int index4, Color bg) {
    return Container(
      height: Get.width / 2,
      width: Get.width / 2,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)), color: bg),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PageCard(index1, bg: Colors.white),
                    ),
                    SizedBox(
                      width: Get.width / 18,
                    ),
                    Expanded(child: PageCard(index2, bg: Colors.white)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: PageCard(index3, bg: Colors.white)),
                    SizedBox(
                      width: Get.width / 18,
                    ),
                    Expanded(child: PageCard(index4, bg: Colors.white)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align _pageCardFourRowBgForTabletHorizontal(
      int index1, int index2, int index3, int index4, Color bg) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: Get.height / 3.2,
                      decoration: BoxDecoration(
                          boxShadow: standartCardShadow(),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text('Materialwirtschaft',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _customDashboardIconWithTextForTablet(
                                          subListOfMainMenuItem[3].desc!,
                                          subListOfMainMenuItem[3].icon!,
                                          HexColor('#27d1df')),
                                      SizedBox(
                                        height: Get.width / 60,
                                      ),
                                      _customDashboardIconWithTextForTablet(
                                          subListOfMainMenuItem[1].desc!,
                                          subListOfMainMenuItem[1].icon!,
                                          Get.theme.colorScheme
                                              .onPrimaryContainer),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _customDashboardIconWithTextForTablet(
                                          subListOfMainMenuItem[2].desc!,
                                          subListOfMainMenuItem[2].icon!,
                                          Get.theme.colorScheme
                                              .onSecondaryContainer),
                                      SizedBox(
                                        height: Get.width / 60,
                                      ),
                                      _customDashboardIconWithTextForTablet(
                                          subListOfMainMenuItem[6].desc!,
                                          'assets/images/icon/budget.png',
                                          Get.theme.colorScheme
                                              .onTertiaryContainer),
                                    ],
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ),
                  // isTablet
                  //     ? SizedBox()
                  //     : Expanded(
                  //         child: GetBuilder<ControllerCommon>(builder: (c) {
                  //         return CarouselSlider.builder(
                  //           itemBuilder: (ctx, index) {
                  //             var filteredList = commonGroupList
                  //                 .listOfCommonGroup
                  //                 .where((group) => group.groupName != 'Alle')
                  //                 .toList();
                  //             return filteredList.length == 0
                  //                 ? Container()
                  //                 : buildBoards(filteredList[index], c);
                  //           },
                  //           itemCount: commonGroupList.listOfCommonGroup
                  //               .where((group) => group.groupName != 'Alle')
                  //               .toList()
                  //               .length,
                  //           options: CarouselOptions(
                  //             onPageChanged: (i, reason) {
                  //               setState(() {});
                  //             },
                  //             pageSnapping: true,
                  //             height: Get.height / 3.2,
                  //             aspectRatio: 16 / 9,
                  //             viewportFraction: 0.9,
                  //             autoPlayInterval: Duration(seconds: 5),
                  //             autoPlayAnimationDuration: Duration(seconds: 1),
                  //             enableInfiniteScroll: true,
                  //             reverse: false,
                  //             autoPlay: true,
                  //             enlargeCenterPage: true,
                  //             scrollDirection: Axis.horizontal,
                  //           ),
                  //         );
                  //       })),
                ],
              ),
              SizedBox(
                height: Get.width / 30,
              ),
            ],
          ),
          SizedBox(
            height: Get.width / 100,
          ),
          Row(
            children: [
              Expanded(child: PageCardRow(index3, bg: Colors.white)),
              SizedBox(
                width: Get.width / 18,
              ),
              Expanded(child: PageCardRow(index4, bg: Colors.white)),
            ],
          ),
          SizedBox(
            height: Get.width / 50,
          ),
          Row(children: [
            Expanded(
              child: PageCardRow(index1, bg: Colors.white),
            ),
            SizedBox(
              width: Get.width / 18,
            ),
            Expanded(child: PageCardRow(index2, bg: Colors.white)),
          ]),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Expanded(
          //       child: Container(
          //         height: Get.height / 11,
          //         decoration: BoxDecoration(
          //             borderRadius:
          //                 BorderRadius.all(Radius.elliptical(10, 15)),
          //             border: Border.all(width: 1, color: Colors.red)),
          //       ),
          //     ),
          //     SizedBox(
          //       width: Get.width / 18,
          //     ),
          //     Expanded(
          //       child: Container(
          //         height: Get.height / 11,
          //         decoration: BoxDecoration(
          //           borderRadius:
          //               BorderRadius.all(Radius.elliptical(10, 15)),
          //           border: Border.all(width: 1, color: Colors.red),
          //         ),
          //         child: Padding(
          //           padding: EdgeInsets.all(5),
          //           child: Column(children: [
          //             Align(
          //               alignment: Alignment.topLeft,
          //               child: Row(
          //                 children: [
          //                   Text('test'),
          //                   Image.asset('assets/images/icon/arrowleft.png',
          //                       width: 30, height: 30, color: Colors.black)
          //                 ],
          //               ),
          //             ),
          //           ]),
          //         ),
          //       ),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }

  Align _pageCardFourRowBg(
      int index1, int index2, int index3, int index4, Color bg) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Get.width / 1.1,
        color: bg ?? Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  boxShadow: standartCardShadow(),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Align(
                    //     alignment: Alignment.topLeft,
                    //     child: Text('Materialwirtschaft',
                    //         style: TextStyle(
                    //             fontSize: 16, fontWeight: FontWeight.bold))),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _customDashboardIconWithText(
                            subListOfMainMenuItem[3].desc!,
                            subListOfMainMenuItem[3].icon!,
                            HexColor('#27d1df'),
                            subListOfMainMenuItem[3].loadPage!),
                        _customDashboardIconWithText(
                            subListOfMainMenuItem[1].desc!,
                            subListOfMainMenuItem[1].icon!,
                            Get.theme.colorScheme.onPrimaryContainer,
                            subListOfMainMenuItem[1].loadPage!),
                        _customDashboardIconWithText(
                            subListOfMainMenuItem[2].desc!,
                            subListOfMainMenuItem[2].icon!,
                            Get.theme.colorScheme.onSecondaryContainer,
                            subListOfMainMenuItem[2].loadPage!),
                        _customDashboardIconWithText(
                            subListOfMainMenuItem[6].desc!,
                            'assets/images/icon/budget.png',
                            Get.theme.colorScheme.onTertiaryContainer,
                            subListOfMainMenuItem[6].loadPage!),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: Get.width / 30,
            ),
            Row(
              children: [
                Expanded(child: PageCardRow(index3, bg: Colors.white)),
                SizedBox(
                  width: Get.width / 18,
                ),
                Expanded(child: PageCardRow(index4, bg: Colors.white)),
              ],
            ),
            SizedBox(
              height: Get.width / 30,
            ),
            Row(children: [
              Expanded(
                child: PageCardRow(index1, bg: Colors.white),
              ),
              SizedBox(
                width: Get.width / 18,
              ),
              Expanded(child: PageCardRow(index2, bg: Colors.white)),
            ]),
          ],
        ),
      ),
    );
  }

  Align _pageCardFourRowBgForTabletVertical(
      int index1, int index2, int index3, int index4, Color bg) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        color: bg ?? Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  boxShadow: standartCardShadow(),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _customDashboardIconWithText(
      String text, String icon, Color color, Function onPress) {
    return GestureDetector(
      onTap: onPress(),
      child: Column(
        children: [
          _customDashboardIcons(icon, color),
          SizedBox(
            height: 5,
          ),
          Text(text)
        ],
      ),
    );
  }

  Row _customDashboardIconWithTextForTablet(
      String text, String icon, Color color) {
    return Row(
      children: [
        _customDashboardIcons(icon, color),
        SizedBox(
          width: 10,
        ),
        Text(text)
      ],
    );
  }

  Container _customDashboardIcons(String icon, Color color) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    print('icon: ' + icon);
    return Container(
        height: isTablet ? Get.height / 12 : Get.height / 13,
        width: isTablet ? Get.height / 12 : Get.height / 13,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(10, 15)),
            border: Border.all(width: 1, color: color)),
        child: Center(
          child: Container(
            height: isTablet ? Get.height / 14 : Get.height / 15,
            width: isTablet ? Get.height / 14 : Get.height / 15,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.elliptical(10, 15)),
                border: Border.all(width: 1, color: color)),
            child: Align(
              alignment: Alignment.center,
              child:
                  Image.asset(icon, width: 30, height: 30, color: Colors.white),
            ),
          ),
        ));
  }

  Container _pageCardTwoRow(int index1, int index2) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Container(
        width: Get.width / 2.2,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PageCard(index1),
                ),
                SizedBox(
                  width: Get.width / 18,
                ),
                Expanded(child: PageCard(index2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container PageCard(int index,
      {Color bg = const Color(0xFFFAF6F3),
      //Color bg = Colors.red,
      Color? icon,
      bool horizontal = false,
      bool shadow = true}) {
    return Container(
      decoration: BoxDecoration(boxShadow: standartCardShadow()),
      height: Get.height / 11,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                subListOfMainMenuItem[index].loadPage!();
              },
              child: Container(
                decoration: BoxDecoration(
                    //border: Border.all(width: 1, color: border ?? Get.theme.secondaryHeaderColor),
                    boxShadow: shadow ? standartCardShadow() : null,
                    color: bg,
                    borderRadius: BorderRadius.circular(10)),
                child: horizontal
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Image.asset(
                                subListOfMainMenuItem[index].icon ?? '',
                                height: Get.height / 18,
                                width: Get.height / 18),
                          ),
                          horizontal
                              ? SizedBox(
                                  width: 10,
                                )
                              : SizedBox(
                                  width: 0,
                                ),
                          Text(
                            subListOfMainMenuItem[index].desc!,
                            maxLines: 6,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: horizontal ? 13 : 11,
                                fontWeight: FontWeight.w500,
                                color: icon),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              child: Image.asset(
                                  subListOfMainMenuItem[index].icon ?? '',
                                  height: Get.height / 25,
                                  width: Get.height / 25),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              subListOfMainMenuItem[index].desc!,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          )
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container PageCardRow(int index,
      {Color bg = const Color(0xFFFAF6F3),
      //Color bg = Colors.red,
      Color? icon,
      bool horizontal = false,
      bool shadow = true}) {
    return Container(
      decoration: BoxDecoration(boxShadow: standartCardShadow()),
      height: Get.height / 11,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                subListOfMainMenuItem[index].loadPage!();
              },
              child: Container(
                width: Get.width,
                decoration: BoxDecoration(
                    //border: Border.all(width: 1, color: border ?? Get.theme.secondaryHeaderColor),
                    boxShadow: shadow ? standartCardShadow() : null,
                    color: bg,
                    borderRadius: BorderRadius.circular(10)),
                child: horizontal
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Image.asset(
                                subListOfMainMenuItem[index].icon ?? '',
                                height: Get.height / 18,
                                width: Get.height / 18),
                          ),
                          horizontal
                              ? SizedBox(
                                  width: 10,
                                )
                              : SizedBox(
                                  width: 0,
                                ),
                          Text(
                            subListOfMainMenuItem[index].desc!,
                            maxLines: 6,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: horizontal ? 13 : 11,
                                fontWeight: FontWeight.w500,
                                color: icon),
                          )
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    child: Image.asset(
                                        subListOfMainMenuItem[index].icon ?? '',
                                        height: Get.height / 30,
                                        width: Get.height / 30),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    subListOfMainMenuItem[index].desc!,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  child: Image.asset(
                                      'assets/images/icon/arrow.png',
                                      height: Get.height / 35,
                                      width: Get.height / 35),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setSubMenuItems() {
    if (true) {
      subListOfMainMenuItem = [
        new SubMenuItem(
            icon: 'assets/images/icon/budget.png',
            desc: AppLocalizations.of(context)!.invoiceWithDocument,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new InvoiceWithDocumentPage(
                            invoiceWithDocumentType:
                                InvoiceWithDocumentType.IncomePaid,
                          )));
            }),
        new SubMenuItem(
            icon: 'assets/images/icon/calculator.png',
            desc: AppLocalizations.of(context)!.calculation,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new InvoiceWithDocumentPage(
                            invoiceWithDocumentType:
                                InvoiceWithDocumentType.IncomePaid,
                          )));
            }),
        new SubMenuItem(
            icon: 'assets/images/icon/version-control.png',
            desc: AppLocalizations.of(context)!.inquiry,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new InvoiceWithDocumentPage(
                            invoiceWithDocumentType:
                                InvoiceWithDocumentType.IncomePaid,
                            invoiceType: 3,
                          )));
            }),
        new SubMenuItem(
            icon: 'assets/images/icon/flash-sale.png',
            desc: AppLocalizations.of(context)!.offer,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new InvoiceWithDocumentPage(
                            invoiceWithDocumentType:
                                InvoiceWithDocumentType.IncomePaid,
                            invoiceType: 2,
                          )));
            }),
        new SubMenuItem(
            icon: 'assets/images/icon/audit.png',
            desc: AppLocalizations.of(context)!.ocrSearch,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => GeneralSearchPage()));
            }),
        new SubMenuItem(
            icon: 'assets/images/icon/research-icon.png',
            desc: AppLocalizations.of(context)!.analyzeDocument,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => DocumentAnalysis()));
            }),
        new SubMenuItem(
            icon: 'assets/images/icon/calculatorpage.jpeg',
            desc: AppLocalizations.of(context)!.reckoning,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new PrivatePage(
                            fileManagerType: FileManagerType.PrivateDocument,
                          )));
            }),

        /*new SubMenuItem(
            icon: Icons.today,
            desc: AppLocalizations.of(context).calendar,
            loadPage: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Get.to(() => BuildBottomNavigationBar(
                    page: 3,
                  ));
            }),
        new SubMenuItem(
            icon: Icons.assessment,
            desc: AppLocalizations.of(context).collaboration,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new CollaborationPage()));
            }),
        new SubMenuItem(
            icon: Icons.email, desc: AppLocalizations.of(context).message,
        loadPage: (){
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new InvoiceWithDocumentPage(
                    invoiceWithDocumentType:
                    InvoiceWithDocumentType.OutgoingPaid,
                  )));
        }
        ),
        new SubMenuItem(
            icon: Icons.chat,
            desc: AppLocalizations.of(context).chat,
            loadPage: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Get.to(() => BuildBottomNavigationBar(
                    page: 0,
                  ));
            }),*/

        new SubMenuItem(
            icon: 'assets/images/icon/property.png',
            desc: AppLocalizations.of(context)!.collaboration,
            loadPage: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new CollaborationPage()));
            }),
        new SubMenuItem(
            icon: 'assets/images/icon/cargo.png',
            desc: AppLocalizations.of(context)!.logistik,
            loadPage: () {}),
        new SubMenuItem(
            icon: 'assets/images/icon/warehouse.png',
            desc: AppLocalizations.of(context)!.lager,
            loadPage: () {}),
      ];
    }

    // else {
    //   subListOfMainMenuItem = [
    //     new SubMenuItem(
    //         icon: Icons.receipt,
    //         desc: AppLocalizations.of(context).invoiceFordDocument),
    //     new SubMenuItem(
    //         icon: Icons.fact_check,
    //         desc: AppLocalizations.of(context).reportCloud,
    //         loadPage: () {
    //           Navigator.push(
    //               context,
    //               new MaterialPageRoute(
    //                   builder: (BuildContext context) => new PrivatePage(
    //                         fileManagerType: FileManagerType.Report,
    //                       )));
    //         }),
    //     new SubMenuItem(
    //         icon: Icons.account_balance_wallet,
    //         desc: AppLocalizations.of(context).salary,
    //         loadPage: () {
    //           Navigator.push(
    //               context,
    //               new MaterialPageRoute(
    //                   builder: (BuildContext context) => new PrivatePage(
    //                         fileManagerType: FileManagerType.Salary,
    //                       )));
    //         }),
    //     new SubMenuItem(
    //         icon: Icons.account_box,
    //         desc: AppLocalizations.of(context).customer),
    //     new SubMenuItem(
    //         icon: Icons.equalizer,
    //         desc: AppLocalizations.of(context).statistics),
    //     new SubMenuItem(
    //         icon: Icons.help, desc: AppLocalizations.of(context).help),
    //     new SubMenuItem(
    //         icon: Icons.add, desc: AppLocalizations.of(context).add),
    //   ];
    // }
  }

  buildBadgeClickable(String text, bool selected) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: selected ? Get.theme.primaryColor : Colors.grey,
        //color: selected ? Get.theme.backgroundColor.withOpacity(0.19) : Colors.transparent,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget CustomerCard(Customer cstmr) {
    return Container(
      width: Get.width,
      height: Get.height < 800 ? 110 : 140,
      padding: Get.height < 800
          ? EdgeInsets.symmetric(horizontal: 15, vertical: 10)
          : EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
          color: Color(0xFFf6f6f6), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cstmr.title ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cstmr.customerAdminName! +
                          ' ' +
                          cstmr.customerAdminSurname!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      cstmr.photo != null
                          ? "https://onlinefiles.dsplc.net//Content/UploadPhoto/User/" +
                              cstmr.photo!
                          : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                      fit: BoxFit.cover,
                    ),
                  ))
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              cstmr.phone ?? "",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Get.height < 800 ? SizedBox() : SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              contactMoreIcon(() async {
                targetUserIdList.add(cstmr.customerAdminId!);
                await CareateOrJoinMetting(targetUserIdList);
                await permissions.Permission.camera.request();
                await permissions.Permission.microphone.request();
                await permissions.Permission.camera.request();
                await permissions.Permission.microphone.request();
                print(loading);
                setState(() {
                  _pc.open();
                  _panelMinSize = 170.0;
                });
              }, Icons.phone),
              contactMoreIcon(() {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new ContactCRMPage(
                              index: 0,
                              customerId: cstmr.id,
                            )));
              }, Icons.cloud),
              contactMoreIcon(() {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new ContactCRMPage(
                            index: 1, customerId: cstmr.id)));
              }, Icons.message),
              contactMoreIcon(() {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new ContactCRMPage(
                            index: 2, customerId: cstmr.id)));
              }, Icons.mail),
              contactMoreIcon(() {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new ContactCRMPage(
                            index: 3, customerId: cstmr.id)));
              }, Icons.note),
              /*contactMoreIcon((){},Icons.emoji_people, index),
                    contactMoreIcon((){},Icons.group_add_rounded, index),
                    contactMoreIcon((){},Icons.person_remove, index),*/
              contactMoreIcon(() {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new ContactCRMPage(
                            index: 0, customerId: cstmr.id)));
              }, Icons.arrow_forward_ios_outlined),
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector contactMoreIcon(Function runOnTap, IconData iconData) {
    return GestureDetector(
      onTap: () {
        runOnTap();
      },
      child: AnimatedOpacity(
        opacity: 1,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black,
            boxShadow: standartCardShadow(),
          ),
          padding: EdgeInsets.all(7),
          child: AnimatedOpacity(
            opacity: 1,
            duration: Duration(milliseconds: 200),
            child: Icon(iconData, size: 19, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<File?> _imgFromCamera() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      return File(pickedFile!.path);
    } catch (e) {
      print(e);
      return null;
    }
  }
}

class SubMenuItem {
  String? icon;
  String? desc;
  Function? loadPage;

  SubMenuItem({this.icon, this.desc, this.loadPage});
}

class ShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    Rect rect = Rect.fromLTWH(0, 0.0, size.width, size.height);
    path.addOval(rect);
    return path;
  }

  @override
  bool shouldReclip(ShapeClipper oldClipper) => false;
}

class DetailModuleButton extends StatelessWidget {
  final IconData? ikon;
  final Color? kolorIkon;
  final Color? kolorCevre;
  final VoidCallback? onTap;
  final String? text;

  DetailModuleButton({
    this.ikon,
    this.kolorCevre,
    this.kolorIkon,
    this.onTap,
    this.text,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 70,
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          //width: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            //kolorCevre,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white)),
                icon: Icon(ikon), color: kolorIkon, iconSize: 20,
                // iconSize: 10,
                onPressed: onTap,
              ),
              Expanded(
                child: Text(
                  text!,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          )

              /*  Icon(
              
              ikon,
              color: kolorIkon,
              size: 40,
            ), */
              ),
        ),
      ),
    );
  }
}
