import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerGeneralSearch.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/DebouncerForSearch.dart';
import 'package:undede/Custom/DioDownloader.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseCommon.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseFileManagerType.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/FileViewers/openFileFn.dart';
import 'package:undede/Pages/PdfApi.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/Services/Label/LabelDb.dart';
import 'package:undede/Services/TodoService/TodoDB.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/confirmDeleteWidget.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Label/uploadLabels.dart';
import 'package:undede/model/Search/SearchResult.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:undede/model/Search/SearchResult.dart' as a;

import 'dart:ui' as ui;

import '../../Custom/CustomLoadingCircle.dart';
import '../JpgView.dart';
import '../PDFView.dart';

class GeneralSearchPage extends StatefulWidget {
  GeneralSearchPage();

  @override
  _GeneralSearchPageState createState() => _GeneralSearchPageState();
}

class _GeneralSearchPageState extends State<GeneralSearchPage>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  final List<DropdownMenuItem> cboFileTypes = [];
  final List<DropdownMenuItem> cboLabelsList = [];
  final List<DropdownMenuItem> cboModuleType = [];

  LabelDb _labelDb = new LabelDb();
  ControllerGeneralSearch _searchController =
      Get.put(ControllerGeneralSearch());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  TextEditingController _searchTextFieldController = TextEditingController();
  // load more
  ScrollController _scrollController = new ScrollController();
  bool isUploadingNewPage = false;

  // Select
  bool selectionModeActive = false;
  List<int> selectedFileIdList = [];

  // Mail
  ControllerUser _controllerUser = Get.put(ControllerUser());

  String? selectedMail;
  int? selectedMailId;

  TextEditingController _password = TextEditingController();
  TextEditingController _message = TextEditingController();
  TextEditingController _receiver = TextEditingController();
  TextEditingController _subject = TextEditingController();
  List<DropdownMenuItem> cmbEmails = [];
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  int? ModulType;
  int? CustomerId;
  final _debouncer = DebouncerForSearch();
  CommonDB _commonDB = new CommonDB();
  TodoDB _todoDB = new TodoDB();
  List<CommonGroup> commonGroupList = <CommonGroup>[];
  final List<DropdownMenuItem> cboCommonGroups = [];
  int? selectedCommonGroup;
  List<CommonBoardListItem> commonBoardList = <CommonBoardListItem>[];
  final List<DropdownMenuItem> cboCommons = [];
  int? selectedcommonBoard;
  List<CommonTodo> boardTaskList = <CommonTodo>[];
  final List<DropdownMenuItem> cboTasks = [];
  int? selectedBoardTask;

  Future<void> loadBoards(groupId) async {
    await _commonDB.GetAllCommons(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id, groupId: groupId)
        .then((value) {
      commonBoardList = value.result!.commonBoardList!;

      commonBoardList.asMap().forEach((index, commonBoard) {
        cboCommons.add(
          DropdownMenuItem(
              child: Row(
                children: [
                  Text(commonBoard.title!),
                ],
              ),
              value: commonBoard.id,
              key: Key(commonBoard.title!)),
        );
      });
    });
  }

  Future<void> loadTasks(commonId) async {
    await _todoDB.GetCommonTodos(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id,
            commonId: commonId,
            search: "")
        .then((value) {
      boardTaskList = value.listOfCommonTodo!;

      boardTaskList.asMap().forEach((index, boardTask) {
        cboTasks.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(boardTask.content!),
            ],
          ),
          value: boardTask.id,
          key: Key(boardTask.content!),
        ));
      });
    });
  }

  SendEMail(String Receivers, String Subject, String Message,
      List<int> Attachtments, int Type, int UserEmailId, String Password) {
    _controllerFiles.SendEMail(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        Receivers: Receivers,
        Subject: Subject,
        Message: Message,
        Attachtments: Attachtments,
        Type: Type,
        UserEmailId: UserEmailId,
        Password: Password);
  }

// inserLabelList
  ControllerLabel controllerLabel = Get.put(ControllerLabel());
  GetLabelByUserIdResult _getLabelByUserIdResult =
      GetLabelByUserIdResult(hasError: false);
  List<UserLabel> labelsList = <UserLabel>[];
  List<int> selectedLabelsId = [];
  List<int> selectedLabelIndexes = [];

  InsertFileListLabelList(List<int> FilesIds, List<int> LabelIds) async {
    await controllerLabel.InsertFileListLabelList(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        FilesIds: FilesIds,
        LabelIds: LabelIds);
  }

  DeleteMultiFileAndDirectory(List<int> FileIdList) async {
    await _controllerFiles.DeleteMultiFileAndDirectory(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id,
      CustomerId: CustomerId,
      ModuleTypeId: ModulType,
      FileIdList: FileIdList,
      SourceOwnerId: _controllerDB.user.value!.result!.id,
    );
  }

  final ReceivePort _port = ReceivePort();
  final List<DropdownMenuItem> dmiCustomer = [];
  int? selectedCustomer;
  @override
  void initState() {
    _prepareSaveDir();

    _controller = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );
    _scrollController.addListener(() async {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        print("morePageExist" + _searchController.morePageExist.toString());
        if (_searchController.morePageExist) {
          _searchController.page += 1;
          _searchController.searchText = _searchTextFieldController.text;
          _searchController.GetSearchResult(
              searchText: _searchTextFieldController.text);
        }
      }
    });
    _commonDB.GetListCommonGroup(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id)
        .then((value) {
      commonGroupList = value.listOfCommonGroup!;
      commonGroupList.asMap().forEach((index, commonGroup) {
        cboCommonGroups.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(commonGroup.groupName!),
            ],
          ),
          value: commonGroup.id,
          key: Key(commonGroup.groupName!),
        ));
      });
    });

    for (var value in FileTypes.values) {
      cboFileTypes.add(DropdownMenuItem(
          child: Row(
            children: [
              Image.asset(
                value.icon,
                height: 35,
                width: 35,
              ),
              SizedBox(
                width: 3,
              ),
              Text(value.string.toUpperCase()),
            ],
          ),
          key: Key(value.string),
          value: value.string));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
/*  await _controllerDB.user.value!.result!.userCustomers!.userCustomerList!
          .forEach(
            (element) 
          {
         dmiCustomer.add(DropdownMenuItem(
          child:  Text(

 */ //! unlarin yerine yeni kod asssagida

      for (var element in _controllerDB
          .user.value!.result!.userCustomers!.userCustomerList!) {
        dmiCustomer.add(DropdownMenuItem(
          child: Text(
              element.customerAdminName! + " " + element.customerAdminSurname!),
          value: element.id,
          key: Key(
              element.customerAdminName! + " " + element.customerAdminSurname!),
        ));
      }

      for (var value in FileManagerTypeForSearch.values) {
        cboModuleType.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(value.headerSearch(context)),
              ],
            ),
            key: Key(value.headerSearch(context)),
            value: value.typeSearchId));
      }
    });

    _searchTextFieldController.text = _searchController.searchText ?? "";
    getLabelByUserId();
    getUserEmailList();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
  }

  void getLabelByUserId() async {
    await _labelDb.GetLabelByUserId(_controllerDB.headers(),
            Id: 0, UserId: _controllerDB.user.value!.result!.id, CustomerId: 0)
        .then((value) {
      labelsList = value.result!;

      if (!value.hasError!) {
        value.result!.forEach((label) {
          cboLabelsList.add(DropdownMenuItem(
              child: Row(
                children: [
                  Text(label.title!),
                  Icon(
                    Icons.lens,
                    color: Color(int.parse(label.color!.replaceFirst('#', "FF"),
                        radix: 16)),
                  )
                ],
              ),
              key: Key(label.id.toString()),
              value: label.title! + "+" + label.color!));
        });
      }
    });

    setState(() {});
  }

  String _localPath = "";

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        final directory = "/storage/emulated/0/Download/";
        externalStorageDirPath = directory;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerGeneralSearch>(builder: (controllerSearch) {
      return Scaffold(
        endDrawerEnableOpenDragGesture: false,
        key: _scaffoldKey,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.ocrSearch,
          isHomePage: true,
        ),
        endDrawer: Drawer(
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.filter),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            controller: _searchTextFieldController,
                            height: 45,
                            prefixIcon: Icon(Icons.search),
                            hint: AppLocalizations.of(context)!.ocrSearch,
                            onChanged: (val) async {
                              _debouncer.run(() async {
                                _searchController.searchText = val;
                              });
                            },
                            //autofocus: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 45,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(15)),
                              child: SearchableDropdown.single(
                                color: Colors.white,
                                height: 45,
                                displayClearIcon: true,
                                menuBackgroundColor:
                                    Get.theme.scaffoldBackgroundColor,
                                value: selectedCustomer,
                                items: dmiCustomer,
                                icon: Icon(Icons.expand_more),
                                hint: AppLocalizations.of(context)!
                                    .selectCustomer,
                                searchHint: AppLocalizations.of(context)!
                                    .selectCustomer,
                                onChanged: (value) async {
                                  setState(() {
                                    print(value);
                                    selectedCustomer = value;
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
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  SearchableDropdown.single(
                    items: selectedCustomer == null
                        ? cboModuleType
                        : cboModuleType
                            .where((element) =>
                                element.value == 10 || element.value == 13)
                            .toList(),
                    value: _searchController.ModuleType,
                    hint: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                          AppLocalizations.of(context)!.chooseFileManagerType),
                    ),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        _searchController.ModuleType = value;
                        _searchController.update();
                      });
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
                    doneButton: (selectedItemsDone, doneContext) {
                      return (ElevatedButton(
                          onPressed: () {
                            Navigator.pop(doneContext);
                            setState(() {});
                          },
                          child: Text(AppLocalizations.of(context)!.save)));
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
                        ret = Iterable<int>.generate(items.length).toList();
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
                              bottom:
                                  BorderSide(color: Colors.teal, width: 0.0))),
                    ),
                    iconDisabledColor: Colors.grey,
                    iconEnabledColor: Get.theme.colorScheme.surface,
                    isExpanded: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _searchController.ModuleType == 14 ||
                          _searchController.ModuleType == 31
                      ? buildCommons(context)
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(45),
                              boxShadow: standartCardShadow()),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 7,
                                  child: GestureDetector(
                                      child: Text(
                                          DateFormat('EEE, MMM dd yyyy').format(
                                              _searchController.startDate ==
                                                      null
                                                  ? DateTime.now()
                                                  : _searchController
                                                      .startDate!),
                                          textAlign: TextAlign.left),
                                      onTap: () async {
                                        _searchController.startDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2100),
                                        );
                                        _searchController.update();

                                        setState(() {});
                                      }),
                                ),
                              ]),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Container(
                          height: 45,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(45),
                              boxShadow: standartCardShadow()),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 7,
                                  child: GestureDetector(
                                      child: Text(
                                          DateFormat('EEE, MMM dd yyyy').format(
                                              _searchController.endDate == null
                                                  ? DateTime.now()
                                                  : _searchController.endDate!),
                                          textAlign: TextAlign.left),
                                      onTap: () async {
                                        _searchController.endDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2100),
                                        );
                                        _searchController.update();
                                        setState(() {});
                                      }),
                                ),
                              ]),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SearchableDropdown.multiple(
                    items: cboLabelsList,
                    selectedItems: selectedLabelIndexes,
                    hint: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(AppLocalizations.of(context)!.labels),
                    ),
                    onChanged: (value) {
                      _searchController.selectedLabels = [];
                      selectedLabelIndexes = value;
                      labelsList.asMap().forEach((index, value) {
                        selectedLabelIndexes.forEach((selectedLabelIndex) {
                          if (selectedLabelIndex == index) {
                            _searchController.selectedLabels.add(value.id!);
                          }
                        });
                      });
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
                        padding: EdgeInsets.symmetric(horizontal: 9),
                        child: (Row(
                          children: [
                            Text(item.toString().split("+").first),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.lens,
                              color: Color(int.parse(
                                  item
                                      .toString()
                                      .split("+")
                                      .last
                                      .replaceFirst('#', "FF"),
                                  radix: 16)),
                            ),
                          ],
                        )),
                      );
                    },
                    doneButton: (selectedItemsDone, doneContext) {
                      return (ElevatedButton(
                          onPressed: () {
                            Navigator.pop(doneContext);
                            setState(() {});
                          },
                          child: Text(AppLocalizations.of(context)!.save)));
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
                        ret = Iterable<int>.generate(items.length).toList();
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
                              bottom:
                                  BorderSide(color: Colors.teal, width: 0.0))),
                    ),
                    iconDisabledColor: Colors.grey,
                    iconEnabledColor: Get.theme.colorScheme.surface,
                    isExpanded: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SearchableDropdown.single(
                    items: cboFileTypes,
                    value: _searchController.selectedFileTypes,
                    hint: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(AppLocalizations.of(context)!.documentType),
                    ),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        _searchController.selectedFileTypes = value;
                      });
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
                        padding: EdgeInsets.symmetric(horizontal: 9),
                        child: (Row(
                          children: [
                            Image.asset(
                              getImagePathByFileExtension(item.toString()),
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(item.toString().toUpperCase()),
                          ],
                        )),
                      );
                    },
                    doneButton: (selectedItemsDone, doneContext) {
                      return (ElevatedButton(
                          onPressed: () {
                            Navigator.pop(doneContext);
                            setState(() {});
                          },
                          child: Text(AppLocalizations.of(context)!.save)));
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
                        ret = Iterable<int>.generate(items.length).toList();
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
                              bottom:
                                  BorderSide(color: Colors.teal, width: 0.0))),
                    ),
                    iconDisabledColor: Colors.grey,
                    iconEnabledColor: Get.theme.colorScheme.surface,
                    isExpanded: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controllerSearch.update();
                            _searchController.update();

                            controllerSearch.GetSearchResult(
                                searchText: _searchTextFieldController.text,
                                StartDate: controllerSearch.startDate == null
                                    ? null
                                    : controllerSearch.startDate!
                                        .toIso8601String(),
                                EndDate: controllerSearch.endDate == null
                                    ? null
                                    : controllerSearch.endDate!
                                        .toIso8601String(),
                                LabelIds: controllerSearch.selectedLabels,
                                Extension: controllerSearch.selectedFileTypes,
                                ModuleType: selectedBoardTask != null
                                    ? 31
                                    : _searchController.ModuleType,
                                OwnerId: _searchController.ModuleType != 14
                                    ? null
                                    : selectedBoardTask != null
                                        ? selectedBoardTask
                                        : selectedcommonBoard != null
                                            ? selectedcommonBoard
                                            : selectedCommonGroup,
                                CustomerId: selectedCustomer);
                            _closeEndDrawer();
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(45),
                              boxShadow: standartCardShadow(),
                            ),
                            child: Center(
                                child: Text(
                              AppLocalizations.of(context)!.search,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500),
                            )),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: Get.height,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 5, right: 10, left: 10),
                child: Row(
                  children: [
                    Flexible(
                      child: CustomTextField(
                        controller: _searchTextFieldController,
                        height: 45,
                        prefixIcon: Icon(Icons.search),
                        hint: AppLocalizations.of(context)!.ocrSearch,
                        onChanged: (val) async {
                          if (val.toString().isBlank!)
                            await Future.delayed(
                                const Duration(seconds: 1, milliseconds: 500),
                                () {
                              _searchController.searchResult = new a.Result();
                              _searchController.searchResult!.result =
                                  <SearchResultItem>[];
                              _searchController.update();
                            });
                          else {
                            _debouncer.run(() async {
                              _scrollController.jumpTo(0);
                              _searchController.page = 0;
                              _searchController.searchText = val;
                              controllerSearch.GetSearchResult(
                                  searchText: val,
                                  StartDate: controllerSearch.startDate == null
                                      ? null
                                      : controllerSearch.startDate!
                                          .toIso8601String(),
                                  EndDate: controllerSearch.endDate == null
                                      ? null
                                      : controllerSearch.endDate!
                                          .toIso8601String(),
                                  LabelIds: controllerSearch.selectedLabels,
                                  Extension: controllerSearch.selectedFileTypes,
                                  ModuleType: selectedBoardTask != null
                                      ? 31
                                      : _searchController.ModuleType,
                                  OwnerId: _searchController.ModuleType != 14
                                      ? null
                                      : selectedBoardTask != null
                                          ? selectedBoardTask
                                          : selectedcommonBoard != null
                                              ? selectedcommonBoard
                                              : selectedCommonGroup);
                              setState(() {
                                selectedFileIdList.clear();
                                selectionModeActive = false;
                              });
                            });
                          }
                        },
                        //autofocus: true,
                      ),
                    ),
                    SizedBox(
                      width: 11,
                    ),
                    Container(
                      height: 45,
                      width: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10.0), // Adjust the radius as needed
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                10.0), // Ensure this matches the ClipRRect radius
                            color:
                                primaryYellowColor, // Matching the background color
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                                5.0), // Adjust the padding as needed
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_controller!),
                              child: FloatingActionButton(
                                heroTag: "generalSearchFilter",
                                onPressed: () {
                                  _openEndDrawer();
                                },
                                backgroundColor: Colors
                                    .transparent, // Make the FAB background transparent
                                elevation:
                                    0, // Remove elevation to prevent shadow
                                child: Image.asset(
                                  'assets/images/icon/filter.png',
                                  fit: BoxFit.contain,
                                  height: 24, // Adjust size if necessary
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              selectionModeActive
                  ? Container(
                      padding: EdgeInsets.only(top: 10, right: 20),
                      child: Row(
                        children: [
                          Spacer(),
                          GestureDetector(
                            onTap: () async {
                              for (var selectedItemId in selectedFileIdList) {
                                SearchResultItem selectedItem =
                                    _searchController.searchResult!.result!
                                        .firstWhere(
                                  (x) => x.id == selectedItemId,
                                  //!     orElse: () => null,
                                );
                                DioDownloader(
                                    [selectedItem.thumbnailUrl!], context);
                              }
                              //todo: dosya indirme işlemi durum bilgisine göre mesaj verdiricez
                              showToast(AppLocalizations.of(context)!
                                  .fileDownloadStarted);
                              setState(() {
                                selectionModeActive = false;
                                selectedFileIdList.clear();
                              });
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.surface,
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8.0), // Adjust the padding if needed
                                child: Image.asset(
                                  'assets/images/icon/downloadInvoice.png', // Replace with your asset path
                                  fit: BoxFit.contain,
                                  color: Colors
                                      .black, // Apply color if your asset supports it
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _onAlertExternalLabelInsert(context);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.surface,
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8.0), // Adjust the padding if needed
                                child: Image.asset(
                                  'assets/images/icon/label.png', // Replace with your asset path
                                  fit: BoxFit.contain,
                                  color: Colors
                                      .black, // Apply color if your asset supports it
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          GestureDetector(
                            onTap: () {
                              _onAlertExternalIntive(context);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.surface,
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8.0), // Adjust the padding if needed
                                child: Image.asset(
                                  'assets/images/icon/mail.png', // Replace with your asset path
                                  fit: BoxFit.contain,
                                  color: Colors
                                      .black, // Apply color if your asset supports it
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          GestureDetector(
                            onTap: () async {
                              bool isAccepted =
                                  await confirmDeleteWidget(context);
                              if (isAccepted) {
                                await DeleteMultiFileAndDirectory(
                                    selectedFileIdList);
                                _searchController.searchText =
                                    _searchTextFieldController.text;
                                controllerSearch.GetSearchResult(
                                    searchText:
                                        _searchTextFieldController.text);
                                setState(() {
                                  selectionModeActive = false;
                                  selectedFileIdList.clear();
                                });
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.surface,
                                boxShadow: standartCardShadow(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8.0), // Adjust the padding if needed
                                child: Image.asset(
                                  'assets/images/icon/delete.png', // Replace with your asset path
                                  fit: BoxFit.contain,
                                  color: Colors
                                      .black, // Apply color if your asset supports it
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(top: 10, right: 20, left: 20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 7,
                          ),
                          Container(
                              child: Text(
                            AppLocalizations.of(context)!.directoryDetailItems +
                                " " +
                                " ${_searchController.searchResult?.totalCount != null ? _searchController.searchResult!.totalCount : 0} ",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          )),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.isListView =
                                    !_searchController.isListView;
                              });
                            },
                            child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: _searchController.isListView
                                      ? primaryYellowColor
                                      //Get.theme.colorScheme.surface
                                      : Colors.white,
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.format_list_bulleted,
                                  size: 19,
                                  color: _searchController.isListView
                                      ? Colors.white
                                      : Color(0xFF5c5c5c),
                                )),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.isListView =
                                    !_searchController.isListView;
                              });
                            },
                            child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: !_searchController.isListView
                                      ? primaryYellowColor
                                      //Get.theme.colorScheme.surface
                                      : Colors.white,
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  size: 19,
                                  color: !_searchController.isListView
                                      ? Colors.white
                                      : Color(0xFF5c5c5c),
                                )),
                          ),
                        ],
                      ),
                    ),
              Expanded(
                  child: SingleChildScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 5),
                    child: Column(
                      children: [
                        _searchController.isListView
                            ? buildListviewMode()
                            : buildPreviewMode(),
                        _searchController.loadMore
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Get.theme.secondaryHeaderColor),
                              )
                            : Container(),
                        SizedBox(
                          height: 100,
                        )
                      ],
                    )),
              )),
            ],
          ),
        ),
      );
    });
  }

  Column buildCommons(BuildContext context) {
    return Column(
      children: [
        SearchableDropdown.single(
          color: Colors.white,
          height: 45,
          displayClearIcon: false,
          menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
          items: cboCommonGroups,
          value: selectedCommonGroup,
          icon: Icon(Icons.expand_more),
          hint: AppLocalizations.of(context)!.selectgroup,
          searchHint: AppLocalizations.of(context)!.selectgroup,
          onChanged: (value) async {
            setState(() {
              cboCommons.clear();
            });
            await loadBoards(value);
            setState(() {
              selectedCommonGroup = value;
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
        SizedBox(
          height: 10,
        ),
        selectedCommonGroup == null
            ? Container()
            : SearchableDropdown.single(
                color: Colors.white,
                height: 45,
                displayClearIcon: false,
                menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
                items: cboCommons,
                value: selectedcommonBoard,
                icon: Icon(Icons.expand_more),
                hint: AppLocalizations.of(context)!.selectboard,
                searchHint: AppLocalizations.of(context)!.selectboard,
                onChanged: (value) async {
                  setState(() {
                    cboTasks.clear();
                  });
                  await loadTasks(value);

                  setState(() {
                    selectedcommonBoard = value;
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
        SizedBox(
          height: 10,
        ),
        selectedcommonBoard == null
            ? Container()
            : Column(children: [
                SearchableDropdown.single(
                  color: Colors.white,
                  height: 45,
                  displayClearIcon: false,
                  menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
                  items: cboTasks,
                  value: selectedBoardTask,
                  icon: Icon(Icons.expand_more),
                  hint: AppLocalizations.of(context)!.selectTask,
                  searchHint: AppLocalizations.of(context)!.selectTask,
                  onChanged: (value) {
                    setState(() {
                      selectedBoardTask = value;
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
                SizedBox(
                  height: 20,
                ),
              ]),
      ],
    );
  }

  //#region listView
  buildListviewMode() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchController.searchResult?.result?.length ?? 0,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          SearchResultItem searchResultItem =
              _searchController.searchResult!.result![index];
          return FileViewInListView(searchResultItem, index);
        });
  }

  Widget FileViewInListView(SearchResultItem item, int index) {
    DateFormat format = DateFormat("yyyy-MM-ddThh:mm:ss");
    var dateFormatter =
        new DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName);
    var hourFormatter =
        new DateFormat.jm(AppLocalizations.of(context)!.localeName);

    return GestureDetector(
      onTap: () async {},
      onLongPress: () {},
      child: Container(
        color: null,
        width: MediaQuery.of(context).size.width,
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      getImagePathByFileExtension(
                          item.extension!.replaceAll('.', '')),
                      width: 27,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  /*if (details.primaryVelocity > 0) {
                    setState(() {
                      openMenuAnimateValue[index] = false;
                    });
                  }*/
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.fileName!.length > 17
                                  ? item.fileName!.substring(0, 17)
                                  : item.fileName!,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              dateFormatter
                                      .format(format.parse(item.createDate!)) +
                                  " " +
                                  hourFormatter
                                      .format(format.parse(item.createDate!)),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  //#endregion

  //#region preView
  buildPreviewMode() {
    return _searchController.searchResult == null
        ? Container()
        /*   CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Get.theme.secondaryHeaderColor),
          ) */
        : GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            shrinkWrap: true,
            cacheExtent: 100,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: 250,
                maxCrossAxisExtent:
                    (MediaQuery.of(context).size.width / 2 - 14),
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 15,
                mainAxisSpacing: 8),
            itemCount: _searchController.searchResult!.result!.length,
            itemBuilder: (BuildContext ctx, index) {
              SearchResultItem item =
                  _searchController.searchResult!.result![index];
              bool isSelected = selectedFileIdList.contains(item.id);
              CustomerId = item.customerId;
              ModulType = item.moduleType;

              return GestureDetector(
                onTap: () async {
                  if (selectionModeActive) {
                    setState(() {
                      if (isSelected)
                        selectedFileIdList.remove(item.id);
                      else
                        selectedFileIdList.add(item.id!);
                    });
                    selectionModeActive = selectedFileIdList.length > 0;
                  } else {
                    DirectoryItem directoryItem =
                        new DirectoryItem(hasError: false);
                    directoryItem.fileName = item.fileName;
                    directoryItem.path = item.path;
                    directoryItem.id = item.ownerId;
                    directoryItem.customerId = item.ownerId;
                    directoryItem.moduleType = item.moduleType;
                    await openFile(directoryItem);
                  }
                },
                onLongPress: () {
                  setState(() {
                    if (isSelected)
                      selectedFileIdList.remove(item.id);
                    else
                      selectedFileIdList.add(item.id!);
                    selectionModeActive = selectedFileIdList.length > 0;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              isSelected
                                  ? Get.theme.primaryColor.withOpacity(0.2)
                                  : Colors.transparent,
                              isSelected
                                  ? Get.theme.primaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                              isSelected
                                  ? Get.theme.primaryColor.withOpacity(0.2)
                                  : Colors.transparent,
                            ],
                            stops: [
                              0.0,
                              0.5,
                              1.0
                            ]),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 250,
                                  width:
                                      (MediaQuery.of(context).size.width / 2 -
                                          14),
                                  child: CachedNetworkImage(
                                      imageUrl: item.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            getImagePathByFileExtension(
                                                item.fileName!.split('.').last),
                                            width: 35,
                                            height: 35,
                                            fit: BoxFit.fitWidth,
                                          ),
                                      placeholder: (context, url) => new Text(
                                          "customloadingcircle") //CustomLoadingCircle(),
                                      ),
                                ),
                                Positioned(
                                  bottom: 40,
                                  right: 5,
                                  child: Image.asset(
                                    getImagePathByFileExtension(
                                        item.fileName!.split('.').last),
                                    width: 27,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 25,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                27,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5),
                                              bottomRight: Radius.circular(5)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                                padding:
                                                    EdgeInsets.only(left: 3),
                                                child: Text(
                                                  item.createDateTime!.day
                                                          .toString() +
                                                      "." +
                                                      item.createDateTime!.month
                                                          .toString() +
                                                      "." +
                                                      item.createDateTime!.year
                                                          .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 25,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                27,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5),
                                              bottomRight: Radius.circular(5)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                  reverse: true,
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  itemCount:
                                                      item.labelList!.length ??
                                                          0,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, a) {
                                                    return Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            right: 4, left: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: Icon(
                                                          Icons.label,
                                                          size: 18,
                                                          color: HexColor(item
                                                              .labelList![a]
                                                              .color!),
                                                        ));
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
  }

  //#endregion

  //Label Insert
  _onAlertExternalLabelInsert(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.selectLabel,
                ),
                content: Container(
                  height: Get.height * 0.15,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      SearchableDropdown.multiple(
                        items: cboLabelsList,
                        hint: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(AppLocalizations.of(context)!.labels),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (!selectedLabelsId.isBlank!) {
                              selectedLabelsId.clear();
                            }

                            selectedLabelIndexes = value;
                            labelsList.asMap().forEach((index, value) {
                              selectedLabelIndexes
                                  .forEach((selectedLabelIndex) {
                                if (selectedLabelIndex == index) {
                                  selectedLabelsId.add(value.id!);
                                }
                              });
                            });
                          });
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
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: (Row(
                              children: [
                                Text(item.toString().split("+").first),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.lens,
                                  color: Color(int.parse(
                                      item
                                          .toString()
                                          .split("+")
                                          .last
                                          .replaceFirst('#', "FF"),
                                      radix: 16)),
                                ),
                              ],
                            )),
                          );
                        },
                        doneButton: (selectedItemsDone, doneContext) {
                          return (ElevatedButton(
                              onPressed: () {
                                Navigator.pop(doneContext);
                                setState(() {});
                              },
                              child: Text(AppLocalizations.of(context)!.save)));
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
                            ret = Iterable<int>.generate(items.length).toList();
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
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      await InsertFileListLabelList(
                          selectedFileIdList, selectedLabelsId);
                      _searchController.searchText =
                          _searchTextFieldController.text;
                      _searchController.GetSearchResult(
                          searchText: _searchTextFieldController.text);
                      setState(() {
                        selectionModeActive = false;
                        selectedFileIdList.clear();
                      });

                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }
  // Mail Send

  _onAlertExternalIntive(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.sendMail,
                ),
                content: Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Flexible(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(45),
                              boxShadow: standartCardShadow()),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              menuMaxHeight: 350,
                              value: selectedMailId,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontFamily: 'TTNorms',
                                  fontWeight: FontWeight.w500),
                              icon: Icon(
                                Icons.expand_more,
                                color: Colors.black,
                              ),
                              items: cmbEmails,
                              onChanged: (value) {
                                setState(() {
                                  print(value);
                                  if (value == 0) {
                                    selectedMailId = value;
                                    return;
                                  }
                                  selectedMail = _controllerUser
                                      .getUserEmailData.value!.result!
                                      .firstWhere(
                                          (element) => element.id == value)
                                      .userName!;
                                  selectedMailId = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: selectedMailId != 0,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: TextField(
                            controller: _password,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .signInPasswordLabel,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _receiver,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.receiver,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _subject,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.subject,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.signInEmailLabel,
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      SendEMail(
                          _receiver.text,
                          _subject.text,
                          _message.text,
                          selectedFileIdList,
                          0,
                          selectedMailId!,
                          _password.text);
                      setState(() {
                        selectionModeActive = false;
                        selectedFileIdList.clear();
                      });
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.sent,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }

  getUserEmailList() async {
    await _controllerUser.GetUserEmailList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!, UserEmailId: 0)
        .then((value) {
      setState(() {
        try {
          selectedMail = value.result!.first.userName!;
        } catch (e) {
          selectedMail = "Baulinx";
        }

        selectedMailId = 0;
        cmbEmails.add(DropdownMenuItem(
          value: 0,
          child: Text("Baulinx"),
        ));
        for (int i = 0; i < value.result!.length; i++) {
          cmbEmails.add(DropdownMenuItem(
            value: value.result![i].id,
            child: Text(value.result![i].userName!),
          ));
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
