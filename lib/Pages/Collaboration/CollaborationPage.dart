import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/DebouncerForSearch.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showModalCommonUsers.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Collaboration/BoardCloudPage.dart';
import 'package:undede/Pages/Collaboration/CommonDetailsPage.dart';
import 'package:undede/Clean_arch/features/collobration_page/detail_page/view/CommonDetailsPage2.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/Services/Label/LabelDb.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/confirmDeleteWidget.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/CareateOrJoinMettingResult.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Chat/GetUserListUser.dart' as user;
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/Common/GetCommonGroupBackgroundResult.dart';
import 'package:undede/model/Common/GetCommonUserListResult.dart';
import 'package:undede/model/Common/GetPermissionListResult.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../Custom/CustomLoadingCircle.dart';
import '../../WidgetsV2/CustomAppBarWithSearch.dart';
import '../../model/Chat/GetUserListUser.dart';
import '../../model/Label/GetInvoiceModel.dart';
import 'Components/BuildBoards.dart';

class CollaborationPage extends StatefulWidget {
  CollaborationPage({Key? key, this.commonGroupId});
  int? commonGroupId;
  _CollaborationPageState createState() => _CollaborationPageState();
}

class _CollaborationPageState extends State<CollaborationPage> {
  Orientation? _orientation;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  GetUserListResult _getUserListResult = GetUserListResult(hasError: false);
  bool isLoading = true;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerTodo _controllerTodo = ControllerTodo();
  List<CommonGroup> _commonGroup = <CommonGroup>[];
  GetCommonUserListResult _getCommonUserListResult =
      GetCommonUserListResult(hasError: false);
  ControllerLabel _controllerLabel = ControllerLabel();
  GetAllCommonsResult? _commons = new GetAllCommonsResult(hasError: false);
  PageController? pageController;
  int? selectedCommonGroupId;
  int? selectedCommonGroupIdForMove;

  int initialBoard = 0;
  int? changedInitalBoard;
  //insert
  //new group controller
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

  InvoiceDetail? _selectedInvoice;
  int? selectedInvoiceIndex;
  int? selectedUserIndex;

  TextEditingController _InsertCommonTodosText = TextEditingController();
  final int perPage = 10;
  int page = 0;
  bool hasMore = false;
  int? selectedMenuItemIncommons;
  List<int> SelectedMenuItemsCopy = [];
  bool loading = true;
  String lastSearchText = "";
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  // backgroundImage
  GetCommonGroupBackgroundResult _getCommonGroupBackgroundResult =
      GetCommonGroupBackgroundResult(hasError: false);
  // search
  String SearchKey = "";
  // background pic
  bool backGround = true;
  // update board
  String? Base64Image;
  TextEditingController updateBoardController = TextEditingController();
  final _debouncer = DebouncerForSearch();
  final List<DropdownMenuItem> cboLabelsList = [];
  LabelDb _labelDb = new LabelDb();
  ControllerChatNew _chatDb = new ControllerChatNew();
  List<UserLabel> labelsList = <UserLabel>[];
  List<InvoiceDetail> invoiceList = <InvoiceDetail>[];

  List<int> selectedLabelsId = [];
  List<int> selectedLabelIndexes = [];
  final List<DropdownMenuItem> cboUserList = [];
  List<user.Result> userList = [];
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
  int? _selectedProject;

  final List<DropdownMenuItem> cboUsersList = [];

//**
  int _selectedFilterId = 99;
  List<DropdownMenuItem> cboTodoFilters = [];
  void cboData() {
    cboTypeWhoList = [
      DropdownMenuItem(
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.all),
            ],
          ),
          key: Key(AppLocalizations.of(context)!.all),
          value: 0),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Benim"),
            ],
          ),
          key: Key("Benim"),
          value: 1),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Davet Edilen"),
            ],
          ),
          key: Key("Davet Edilen"),
          value: 1)
    ];
    cboWhichSectionList = [
      DropdownMenuItem(
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.all),
            ],
          ),
          key: Key(AppLocalizations.of(context)!.all),
          value: 0),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Board"),
            ],
          ),
          key: Key("Board"),
          value: 1),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Task"),
            ],
          ),
          key: Key("Task"),
          value: 2)
    ];
    cboIncludeElementList = [
      DropdownMenuItem(
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.all),
            ],
          ),
          key: Key(AppLocalizations.of(context)!.all),
          value: 0),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Yorum"),
            ],
          ),
          key: Key("Yorum"),
          value: 2),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Kontrol Listesi"),
            ],
          ),
          key: Key("Kontrol Listesi"),
          value: 3)
    ];
    cboReminderIncludeList = [
      DropdownMenuItem(
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.all),
            ],
          ),
          key: Key(AppLocalizations.of(context)!.all),
          value: 0),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Reminderlı"),
            ],
          ),
          key: Key("Reminderlı"),
          value: 1),
      DropdownMenuItem(
          child: Row(
            children: [
              Text("Remindersız"),
            ],
          ),
          key: Key("Remindersız"),
          value: 2)
    ];
  }

  void getUserListByUserId() async {
    await _chatDb.GetUserList(
      _controllerDB.headers(),
      _controllerDB.user.value!.result!.id!,
    ).then((value) {
      value.result;
      if (!value.hasError!) {
        value.result!.forEach((user) {
          userList = value.result!;
          cboUserList.add(DropdownMenuItem(
              child: Row(
                children: [
                  Text(user.fullName!),
                  Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(user.photo!))))
                ],
              ),
              key: Key(user.fullName!),
              value: user.id));
        });
      }
    });

    setState(() {});
  }

  void getLabelByUserId() async {
    await _labelDb.GetLabelByUserId(_controllerDB.headers(),
            Id: 0, UserId: _controllerDB.user.value!.result!.id!, CustomerId: 0)
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

  void getInvoiceCompany() async {
    await _labelDb.GetInvoiceCompany(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id!,
    ).then((value) {
      invoiceList = value.result!;
      print('responseData :::: ' + invoiceList.toString());
    });

    setState(() {});
  }

  Widget buildFilter() {
    return Column(
      children: [
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
                                DateFormat('MMM dd yyyy').format(
                                    StartDate == null
                                        ? DateTime.now()
                                        : StartDate!),
                                textAlign: TextAlign.left),
                            onTap: () async {
                              StartDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
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
                                DateFormat('MMM dd yyyy').format(EndDate == null
                                    ? DateTime.now()
                                    : EndDate!),
                                //! EndDate == null ? DateTime.now() : null), degistirildi

                                textAlign: TextAlign.left),
                            onTap: () async {
                              EndDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
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
          items: cboUserList,
          selectedItems: selectedUserIndexes,
          hint: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(AppLocalizations.of(context)!.users),
          ),
          onChanged: (value) {
            selectedUserIndexes = value;
            userList.asMap().forEach((index, value) {
              selectedUserIndexes.forEach((selectedUserIndexe) {
                if (selectedUserIndexe == index) {
                  selectedUserIds.add(value.id!);
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
                border:
                    Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
          ),
          iconDisabledColor: Colors.grey,
          iconEnabledColor: Get.theme.colorScheme.surface,
          isExpanded: true,
        ),
        SizedBox(
          height: 10,
        ),
        SearchableDropdown.single(
          items: cboTypeWhoList,
          value: selectedTypeWhoId,
          hint: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(AppLocalizations.of(context)!.chooseFileManagerType),
          ),
          onChanged: (value) {
            print(value);
            setState(() {
              selectedTypeWhoId = value;
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
                border:
                    Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
          ),
          iconDisabledColor: Colors.grey,
          iconEnabledColor: Get.theme.colorScheme.surface,
          isExpanded: true,
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
            selectedLabelsId = [];
            selectedLabelIndexes = value;
            labelsList.asMap().forEach((index, value) {
              selectedLabelIndexes.forEach((selectedLabelIndex) {
                if (selectedLabelIndex == index) {
                  selectedLabelsId.add(value.id!);
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
                        item.toString().split("+").last.replaceFirst('#', "FF"),
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
                border:
                    Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
          ),
          iconDisabledColor: Colors.grey,
          iconEnabledColor: Get.theme.colorScheme.surface,
          isExpanded: true,
        ),
        SizedBox(
          height: 10,
        ),
        SearchableDropdown.single(
          items: cboWhichSectionList,
          value: selectedWhichSectionId,
          hint: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(AppLocalizations.of(context)!.chooseFileManagerType),
          ),
          onChanged: (value) {
            print(value);
            setState(() {
              selectedWhichSectionId = value;
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
                border:
                    Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
          ),
          iconDisabledColor: Colors.grey,
          iconEnabledColor: Get.theme.colorScheme.surface,
          isExpanded: true,
        ),
        SizedBox(
          height: 10,
        ),
        SearchableDropdown.single(
          items: cboIncludeElementList,
          value: selectedIncludeElementId,
          hint: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(AppLocalizations.of(context)!.chooseFileManagerType),
          ),
          onChanged: (value) {
            print(value);
            setState(() {
              selectedIncludeElementId = value;
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
                border:
                    Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
          ),
          iconDisabledColor: Colors.grey,
          iconEnabledColor: Get.theme.colorScheme.surface,
          isExpanded: true,
        ),
        SizedBox(
          height: 10,
        ),
        SearchableDropdown.single(
          items: cboReminderIncludeList,
          value: selectedReminderIncludeId,
          hint: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(AppLocalizations.of(context)!.chooseFileManagerType),
          ),
          onChanged: (value) {
            print(value);
            setState(() {
              selectedReminderIncludeId = value;
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
                border:
                    Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
          ),
          iconDisabledColor: Colors.grey,
          iconEnabledColor: Get.theme.colorScheme.surface,
          isExpanded: true,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
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
              _commons!.result!.commonBoardList![initialBoard].id!);
        }
        break;

      case MenuItem.public:
        await _controllerCommon.UpdateCommon(_controllerDB.headers(),
            Id: commonId,
            UserId: _controllerDB.user.value!.result!.id!,
            IsPublic: true);
        await changeGroup();
        break;

      case MenuItem.notifications:
        await _controllerCommon.UpdateCommon(_controllerDB.headers(),
            Id: commonId,
            UserId: _controllerDB.user.value!.result!.id!,
            IsPublic: !(_commons!.result!.commonBoardList!
                .firstWhere((element) => element.id == commonId)
                .isPublic!));
        await changeGroup();
        break;

      case MenuItem.settings:
        // Add settings related functionality here
        break;
    }
  }

  bool DeleteCommonPermission(Permission perm) =>
      (perm.moduleCategoryId == 14 &&
          perm.moduleSubCategoryId == 23 &&
          perm.permissionTypeId == 2);

  void _updateViewportFraction(double screenWidth) {
    setState(() {
      if (pageController!.hasClients) {
        pageController =
            PageController(viewportFraction: _getViewportFraction(screenWidth));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadSelectedProject();

      double screenWidth = MediaQuery.of(context).size.width;
      pageController =
          PageController(viewportFraction: _getViewportFraction(screenWidth));
      setState(() {
        loading = true;
      });
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
        userId: _controllerDB.user.value!.result!.id!,
      ).then((value) async {
        print("res GetGroupByIdddd = " + jsonEncode(value.listOfCommonGroup));
        // common gruplar çekildikten sonra önyüze yansıtır
        _commonGroup = value.listOfCommonGroup!;

        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _selectedProject = prefs.getInt('selectedProject') ??
              _commonGroup.first.id; // default value
        });

        selectedCommonGroupId =
            prefs.getInt('selectedProject') ?? _commonGroup.first.id;
        selectedCommonGroupIdForMove =
            prefs.getInt('selectedProject') ?? _commonGroup.first.id;
        await changeGroup();
        await GetCommonGroupBackground(0);
      }).catchError((e) {
        print("res GetGroupById error " + e.toString());
      });
      getLabelByUserId();
      getInvoiceCompany();
      getUserListByUserId();
      cboData();
      getUserList();

      setState(() {
        changeGroup();
        if (pageController!.hasClients) {
          pageController!.jumpToPage(0);
        }
      });
      _projectNumber = TextEditingController(text: generateProjectNumber());
      setState(() {
        loading = false;
      });
    });

    print('Selected project: $selectedCommonGroupId');
  }

  Future<void> _loadSelectedProject() async {
    // Get the saved project from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedProject = prefs.getInt('selectedProject') ?? 0; // default value
    });

    print('Selected project: ${prefs.getInt('selectedProject')}');

    // Now you can load your commonGroups or any data necessary
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

  getUserList() async {
    await _controllerChatNew.GetUserList(
            _controllerDB.headers(), _controllerDB.user.value!.result!.id!)
        .then((value) {
      _getUserListResult = value;
      List.generate(_getUserListResult.result!.length, (index) {
        if (_getUserListResult.result![index].isGroup == 0)
          cboUsersList.add(DropdownMenuItem(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(_getUserListResult.result![index].photo!),
                    radius: 8,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(_getUserListResult.result![index].fullName!),
                ],
              ),
              key: Key(_getUserListResult.result![index].id.toString()),
              value: _getUserListResult.result![index].id));
      });
      _getUserListResult = value;
    });
    print(selectedUserIndexes);
  }

  @override
  void dispose() {
    _projectNumber.dispose();
    super.dispose();
  }

  String generateProjectNumber() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String randomString = String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
    return 'P0$randomString';
  }

  InsertCommon(String Title, String Description, int CommonGroupId) async {
    await _controllerCommon.InsertCommon(_controllerDB.headers(),
            CustomerId: _controllerDB.user.value!.result!.customerId!,
            UserId: _controllerDB.user.value!.result!.id!,
            State: true,
            Title: Title,
            Description: Description,
            CommonGroupId: CommonGroupId)
        .then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.create,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  InsertCommonGroup(
      String groupName,
      String projectNumber,
      String streetText,
      String postalCode,
      String cityText,
      String stateText,
      String groupStartDate,
      String groupEndDate,
      int selectedInvoiceIndex,
      int selectedUser) async {
    await _controllerCommon.InsertCommonGroup(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            GroupName: groupName,
            ProjectNumber: projectNumber,
            StreetText: streetText,
            PostalCode: postalCode,
            CityText: cityText,
            StateText: stateText,
            GroupStartDate: groupStartDate,
            GroupEndDate: groupEndDate,
            selectedCustomerId: selectedInvoiceIndex,
            SelectedUser: selectedUser)
        .then((value) async {
      if (value) {
        print('valueeeee' + value.toString());
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.create,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
        await _controllerCommon.GetGroupById(_controllerDB.headers(),
                userId: _controllerDB.user.value!.result!.id!,
                id: _commonGroup.first.id)
            .then((value) async {
          print("res GetGroupById = " + jsonEncode(value.listOfCommonGroup));

          // common gruplar çekildikten sonra önyüze yansıtır
          _commonGroup = value.listOfCommonGroup!;
          selectedCommonGroupId = _commonGroup.first.id;
          selectedCommonGroupIdForMove = _commonGroup.first.id;
          Navigator.pushReplacement(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new CollaborationPage()));
        });

        // setState(() {
        //   isLoading = false;
        // });
      }
    });
  }

  UpdateCommonGroup(
      int groupId,
      int UserId,
      String CreateDate,
      String groupName,
      String projectNumber,
      String streetText,
      String postalCode,
      String cityText,
      String stateText,
      String groupStartDate,
      String groupEndDate,
      int selectedInvoiceIndex,
      int selectedUser) async {
    await _controllerCommon.UpdateCommonGroup(_controllerDB.headers(),
            Id: groupId,
            CreateDate: CreateDate,
            UserId: UserId,
            GroupName: groupName,
            ProjectNumber: projectNumber,
            Street: streetText,
            PostalCode: postalCode,
            City: cityText,
            State: stateText,
            StartDate: groupStartDate,
            EndDate: groupEndDate,
            CustomerId: selectedInvoiceIndex,
            PersonnelId: selectedUser)
        .then((value) async {
      if (!value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.create,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
        await _controllerCommon.GetGroupById(_controllerDB.headers(),
                userId: _controllerDB.user.value!.result!.id!,
                id: _commonGroup.first.id)
            .then((value) async {
          Navigator.pushReplacement(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new CollaborationPage()));
        });
        // setState(() {
        //   isLoading = false;
        // });
      }
    });
  }

  CareateOrJoinMettingResult _careateOrJoinMettingResult =
      CareateOrJoinMettingResult(hasError: false);

  InsertCommonTodos(int CommonBoardId, String TodoName) async {
    await _controllerTodo.InsertCommonTodos(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            CommonBoardId: CommonBoardId,
            TodoName: TodoName,
            ModuleType: 14)
        .then((value) {
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

  Future<void> CareateOrJoinMetting(int OwnerId, int ModuleType) async {
    await _controllerCommon.CareateOrJoinMetting(_controllerDB.headers(),
            OwnerId: OwnerId,
            UserId: _controllerDB.user.value!.result!.id!,
            TargetUserIdList: [],
            ModuleType: ModuleType)
        .then((value) {
      setState(() {
        _careateOrJoinMettingResult = value;
        loading = false;
      });
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

  refreshPage(int page, {int a = 0}) async {
    await getAllCommans();
    await loadPage(page);
    await Future.delayed(Duration(seconds: 2));
    _controllerBottomNavigationBar.lockUI = false;
    _controllerBottomNavigationBar.update();
    if (a > 0) {
      if (pageController!.hasClients) {
        pageController!.jumpToPage(_commons!.result!.commonBoardList!
            .indexWhere((element) => element.id == a));
      }
    }
  }

  refreshPageAndGoTask(int page, int todoId, {int a = 0}) async {
    await getAllCommans();
    await loadPage(page);

    if (a > 0) {
      print("todoId: " + todoId.toString());
      print("commonBoardId: " + a.toString());
      await Future.delayed(Duration(seconds: 5));
      if (pageController!.hasClients) {
        pageController!.jumpToPage(_commons!.result!.commonBoardList!
            .indexWhere((element) => element.id == a));
      }

      _controllerBottomNavigationBar.lockUI = false;
      _controllerBottomNavigationBar.update();
      await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new CommonDetailsPage(
            todoId: todoId,
            commonBoardId: a,
            selectedTab: 0,
            commonTodo: (_commons!.result!.commonBoardList!
                .firstWhere((element) => element.id == a)
                .todos
                .firstWhere((element) => element.id == todoId)),
            commonBoardTitle: _commons!.result!.commonBoardList!
                .firstWhere((element) => element.id == a)
                .title!,
            cloudPerm:
                (_controllerTodo.hasFileManagerTodoPerm(a, todoId)) == true ||
                    _controllerCommon.hasFileManagerCommonPerm(
                      a,
                    ),
          ),
        ),
      );
    }
  }

  Future<void> loadPage(int page) async {
    setState(() {
      isLoading = true;
    });
    lastSearchText = SearchKey;
    await _controllerCommon.GetCommons(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id!,
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
        print("COLLABORATIONPAGE iterateCountForPage : " +
            _currentPageItemCount.toString());

        for (int i = 0; i < iterateCountForPage; i++) {
          _commons!.result!.commonBoardList![(page * perPage) + i].users
              .clear();
          _commons!.result!.commonBoardList![(page * perPage) + i].todos
              .clear();

          _controllerCommon.MyPermissionsOnBoards.removeWhere((e) =>
              e.commonId ==
              _commons!.result!.commonBoardList![(page * perPage) + i].id);
          _controllerTodo.MyPermissionsOnTodos.removeWhere((e) =>
              e.commonId ==
              _commons!.result!.commonBoardList![(page * perPage) + i].id);
        }

        _commons!.result!.totalCount = value.result!.totalCount!;
        _commons!.result!.totalPage = value.result!.totalPage!;

        for (int i = 0; i < iterateCountForPage; i++) {
          _commons!.result!.commonBoardList!.removeAt((perPage * page) + i);
          _commons!.result!.commonBoardList!
              .insert((perPage * page) + i, value.result!.commonBoardList![i]);
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
            _commons!.result!.commonBoardList!
                .firstWhere(
                  (e) => e.id == value.result!.commonBoardList![i].id,
                  //!   orElse: () => null
                )
                .users
                .addAll(commonUserList.result!);

            /* Kullanıcı boardun ownerı değil permission liste bak */
            if (value.result!.commonBoardList![i].userId !=
                _controllerDB.user.value!.result!.id!) {
              await _controllerCommon.GetPermissionList(_controllerDB.headers(),
                      DefinedRoleId:
                          value.result!.commonBoardList![i].definedRoleId!)
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
                  <Permission>[], value.result!.commonBoardList![i].id!));
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
                userId: _controllerDB.user.value!.result!.id!,
                commonId: value.result!.commonBoardList![i].id!,
                search: value.result!.commonBoardList![i].isSearchResultTodo!
                    ? SearchKey
                    : null)
            .then((todoResult) {
          _commons!.result!.commonBoardList!
              .firstWhere(
                (e) => e.id == value.result!.commonBoardList![i].id,
                //!  orElse: () => null
              )
              .todos
              .clear();
          _commons!.result!.commonBoardList!
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
                    _commons!.result!.commonBoardList!
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
                          todoResult.listOfCommonTodo![k].definedRoleId!)
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
              _controllerTodo.MyPermissionsOnTodos.add(new TodoPermission(
                  <Permission>[],
                  todoResult.listOfCommonTodo![k].id!,
                  value.result!.commonBoardList![i].id!));
              _controllerTodo.update();
            }
            /* Kullanıcı todonun ownerı değil permission liste bak */
          }
        });
      }
    });
    setState(() {
      isLoading = true;
    });
  }

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
    _commons!.result!.totalCount =
        _controllerCommon.getAllCommons.value!.result!.commonBoardList!.length;
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  PanelController _pc = new PanelController();
  double _panelMinSize = 0.0;
  bool panelType = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return GetBuilder<ControllerCommon>(builder: (c) {
      if (c.commonRefreshCurrentPage && c.commonNotificationId == 0) {
        loadPage(_currentPage);
        c.commonRefreshCurrentPage = false;
        c.commonNotificationId = 0;
        c.update();
      } else if (c.commonReload) {
        isLoading = true;
        page = 0;
        refreshPage(_currentPage);
        isLoading = false;
        c.commonReload = false;
        c.update();
      } else if (c.commobReloadforNotification) {
        refreshPageAndGoTask(_currentPage, c.todoNotificationId,
            a: c.commonNotificationId);
        c.commobReloadforNotification = false;
      } else if (c.commonRefreshCurrentPage && c.commonNotificationId != 0) {
        refreshPage(_currentPage, a: c.commonNotificationId);
        c.commonRefreshCurrentPage = false;
        c.commonNotificationId = 0;
      }
      return LayoutBuilder(builder: (context, constraints) {
        // Update viewportFraction when screen width changes
        double screenWidth = constraints.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController!.viewportFraction !=
              _getViewportFraction(screenWidth)) {
            _updateViewportFraction(screenWidth);
          }
        });
        return Scaffold(
          backgroundColor: Colors.purple,
          key: _scaffoldKey,
          endDrawerEnableOpenDragGesture: false,
          endDrawer: Drawer(
            child: Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.filter,
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Column(
                  children: [
                    buildFilter(),
                    GestureDetector(
                      onTap: () async {
                        if (pageController!.hasClients) {
                          pageController!.jumpToPage(0);
                        }

                        await changeGroup();
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
                  ],
                ),
              ),
            ),
          ),
          appBar: CustomAppBarWithSearch(
            totalCount: _commons!.result == null
                ? ''
                : _commons!.result!.totalCount.toString(),
            initialBoardNumber: initialBoard,
            commonResult: _commons!.result != null ? true : false,
            title: AppLocalizations.of(context)!.collaboration,
            isHomePage: false,
            isNotificationsOpen: false,
            onChanged: (as) async {
              _debouncer.run(() {
                Future.delayed(const Duration(milliseconds: 700), () async {
                  if (SearchKey == as && lastSearchText != SearchKey) {
                    if (pageController!.hasClients) {
                      pageController!.jumpToPage(0);
                    }
                    await changeGroup();
                  }
                });
                setState(() {
                  SearchKey = as.toString().trim();
                });
              });
            },
            openFilterFunction: () {
              _openEndDrawer();
            },
            openBoardFunction: () {
              String? notValid;
              return showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                        builder: (context, StateSetter setState) {
                      return AlertDialog(
                        title: Text('Type board number you want to go'),
                        content: TextField(
                          onChanged: (value) {
                            setState(() {
                              if (int.parse(value) >
                                  _commons!.result!.totalCount!)
                                notValid = "More than board count";
                              else
                                notValid = ""; //! null yerine "" koyuldu
                            });
                          },
                          onSubmitted: (value) {
                            if (pageController!.hasClients) {
                              pageController!.jumpToPage(int.parse(value) - 1);
                            }

                            Navigator.of(context).pop();
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            errorText: notValid,
                          ),
                        ),
                      );
                    });
                  });
            },
          ),
          body: (backGround && loading)
              ? CustomLoadingCircle()
              : SlidingUpPanel(
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
                          color: Colors.pink,
                        )
                      : Container(
                          child: Stack(
                            children: [
                              InAppWebView(
                                androidOnPermissionRequest:
                                    (InAppWebViewController controller,
                                        String origin,
                                        List<String> resources) async {
                                  return PermissionRequestResponse(
                                      resources: resources,
                                      action: PermissionRequestResponseAction
                                          .GRANT);
                                },
                                initialOptions: InAppWebViewGroupOptions(
                                  crossPlatform: InAppWebViewOptions(
                                    useShouldOverrideUrlLoading: true,
                                    mediaPlaybackRequiresUserGesture: false,
                                    userAgent:
                                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36 OPR/84.0.4316.21",
                                  ),
                                  android: AndroidInAppWebViewOptions(
                                    useHybridComposition: true,
                                  ),
                                  ios: IOSInAppWebViewOptions(
                                    allowsInlineMediaPlayback: true,
                                  ),
                                ),
                                // initialUrlRequest: URLRequest(
                                //   url: Uri.parse(_careateOrJoinMettingResult
                                //           .result.meetingUrl ??
                                //       ''),
                                // )),
                              ),
                              Positioned(
                                right: 13,
                                bottom: 9,
                                child: GestureDetector(
                                  onTap: () async {
                                    _controllerCommon.EndMeeting(
                                        _controllerDB.headers(),
                                        UserId: _controllerDB
                                            .user.value!.result!.id!,
                                        MeetingId: _careateOrJoinMettingResult
                                            .result!.meetingId!);
                                    setState(() {
                                      _panelMinSize = 0.0;
                                    });
                                    _pc.close();
                                    loading = true;
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red),
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
                  maxHeight: Get.height - 200,
                  minHeight: _panelMinSize,
                  margin: EdgeInsets.only(bottom: 100),
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                            ),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Container(
                                child: isTablet
                                    ? IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 0, 10, 0),
                                              child: Column(
                                                children: [
                                                  _customIconButtonWithBackground(
                                                      'assets/images/icon/add.png',
                                                      Colors.black, () {
                                                    addGroup();
                                                  },
                                                      AppLocalizations.of(
                                                              context)!
                                                          .addProject),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  _customIconButtonWithBackground(
                                                      'assets/images/icon/addboard.png',
                                                      Colors.black, () {
                                                    addBoard();
                                                  },
                                                      AppLocalizations.of(
                                                              context)!
                                                          .addBoard),
                                                  // SizedBox(
                                                  //   height: 20,
                                                  // ),
                                                  // _customIconButtonWithBackground(
                                                  //     'assets/images/icon/protocols.png',
                                                  //     Colors.black,
                                                  //     () {},
                                                  //     AppLocalizations.of(
                                                  //             context)
                                                  //         .addLog),
                                                  // SizedBox(
                                                  //   height: 20,
                                                  // ),
                                                  // _customIconButtonWithBackground(
                                                  //     'assets/images/icon/schedule.png',
                                                  //     Colors.black,
                                                  //     () {},
                                                  //     AppLocalizations.of(
                                                  //             context)
                                                  //         .constructionSchedule),
                                                  // SizedBox(
                                                  //   height: 20,
                                                  // ),
                                                  // _customIconButtonWithBackground(
                                                  //     'assets/images/icon/3d-printer.png',
                                                  //     Colors.black,
                                                  //     () {},
                                                  //     AppLocalizations.of(
                                                  //             context)
                                                  //         .measurement),
                                                  // SizedBox(
                                                  //   height: 20,
                                                  // ),
                                                  // _customIconButtonWithBackground(
                                                  //     'assets/images/icon/sketch.png',
                                                  //     Colors.black,
                                                  //     () {},
                                                  //     AppLocalizations.of(
                                                  //             context)
                                                  //         .constructionDiary),
                                                  // SizedBox(
                                                  //   height: 20,
                                                  // ),
                                                  // _customIconButtonWithBackground(
                                                  //     'assets/images/icon/blueprint.png',
                                                  //     Colors.black,
                                                  //     () {},
                                                  //     AppLocalizations.of(
                                                  //             context)
                                                  //         .drawings),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 0.5,
                                                width: 1,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        left: 20),
                                                    height: 45,
                                                    width:
                                                        constraints.maxWidth >
                                                                1000
                                                            ? Get.width / 1.1
                                                            : Get.width / 1.4,
                                                    child:
                                                        buildProjectAndTeamWidget()),
                                                SizedBox(height: 10),
                                                // Padding(
                                                //   padding: EdgeInsets.all(20),
                                                //   child: Row(
                                                //     mainAxisAlignment:
                                                //         MainAxisAlignment
                                                //             .center,
                                                //     crossAxisAlignment:
                                                //         CrossAxisAlignment
                                                //             .center,
                                                //     children: [
                                                //       Expanded(
                                                //         child: Container(
                                                //             height: 45,
                                                //             padding:
                                                //                 EdgeInsets.only(
                                                //                     left: 6),
                                                //             child:
                                                //                 buildProjectAndTeamWidget()),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                                Stack(
                                                  children: [
                                                    Container(
                                                      width:
                                                          constraints.maxWidth >
                                                                  1000
                                                              ? Get.width / 1.1
                                                              : Get.width / 1.2,
                                                      height: Get.height / 1.4,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: RotatedBox(
                                                              quarterTurns: 0,
                                                              child: isLoading
                                                                  ? CustomLoadingCircle()
                                                                  : PageView(
                                                                      padEnds:
                                                                          false,
                                                                      controller:
                                                                          pageController,
                                                                      physics:
                                                                          BouncingScrollPhysics(),
                                                                      onPageChanged:
                                                                          (i) async {
                                                                        bool
                                                                            refreshNewPage =
                                                                            false;

                                                                        // if (_currentPage !=
                                                                        //     ((i) ~/ perPage).ceil()) {
                                                                        //   refreshNewPage =
                                                                        //       true;
                                                                        // }

                                                                        setState(
                                                                            () {
                                                                          initialBoard =
                                                                              i;
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
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    _commons!
                                                                .result!
                                                                .commonBoardList!
                                                                .length !=
                                                            0
                                                        ? Text('')
                                                        : Center(
                                                            child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .thereIsNoBoard,
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _customIconButtonWithBackground(
                                                    'assets/images/icon/add.png',
                                                    Colors.black, () {
                                                  //! burasi 1

                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    addGroup();
                                                  });
                                                },
                                                    AppLocalizations.of(
                                                            context)!
                                                        .addGroup),
                                                _customIconButtonWithBackground(
                                                    'assets/images/icon/addboard.png',
                                                    Colors.black, () {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    addBoard();
                                                  });
                                                },
                                                    AppLocalizations.of(
                                                            context)!
                                                        .addBoard),
                                                // _customIconButtonWithBackground(
                                                //     'assets/images/icon/protocols.png',
                                                //     Colors.black,
                                                //     () {},
                                                //     AppLocalizations.of(context)
                                                //         .addLog),
                                                // _customIconButtonWithBackground(
                                                //     'assets/images/icon/schedule.png',
                                                //     Colors.black,
                                                //     () {},
                                                //     AppLocalizations.of(context)
                                                //         .constructionSchedule),
                                                // _customIconButtonWithBackground(
                                                //     'assets/images/icon/3d-printer.png',
                                                //     Colors.black,
                                                //     () {},
                                                //     AppLocalizations.of(context)
                                                //         .measurement),
                                                // _customIconButtonWithBackground(
                                                //     'assets/images/icon/sketch.png',
                                                //     Colors.black,
                                                //     () {},
                                                //     AppLocalizations.of(context)
                                                //         .constructionDiary),
                                                // _customIconButtonWithBackground(
                                                //     'assets/images/icon/blueprint.png',
                                                //     Colors.black,
                                                //     () {},
                                                //     AppLocalizations.of(context)
                                                //         .drawings),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                      height: 45,
                                                      width: Get.width / 1.1,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20),
                                                      child:
                                                          buildProjectAndTeamWidget()),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Stack(
                                            children: [
                                              Container(
                                                width: Get.width,
                                                height: Get.height - 330,
                                                child: RotatedBox(
                                                  quarterTurns: 0,
                                                  child: isLoading
                                                      ? CustomLoadingCircle()
                                                      : PageView(
                                                          controller:
                                                              pageController,
                                                          physics:
                                                              BouncingScrollPhysics(),
                                                          onPageChanged:
                                                              (i) async {
                                                            bool
                                                                refreshNewPage =
                                                                false;

                                                            if (_currentPage !=
                                                                ((i) ~/ perPage)
                                                                    .ceil())
                                                              refreshNewPage =
                                                                  true;

                                                            setState(() {
                                                              initialBoard = i;
                                                            });

                                                            /*if (i > _commons.result.commonBoardList.length - 2 && hasMore) {
                                                      page += 1;
                                                      loadPage(page);
                                                    } else */
                                                            if (refreshNewPage) {
                                                              await loadPage(
                                                                  _currentPage);
                                                            }
                                                          },
                                                          children:
                                                              buildCommons(),
                                                        ),
                                                ),
                                              ),
                                              _commons!.result!.commonBoardList!
                                                          .length !=
                                                      0
                                                  ? Text('')
                                                  : Center(
                                                      child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .thereIsNoBoard,
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                            ],
                                          ),
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
                      //_speedDial(context),
                    ],
                  ),
                ),
        );
      });
    });
  }

  Positioned _speedDial(BuildContext context) {
    return Positioned(
      height: Get.height,
      width: Get.width,
      bottom: 200,
      right: 5,
      child: SpeedDial(
        childMargin: EdgeInsets.fromLTRB(0, 18, 0, 20),
        //!   marginEnd: 18,
        //!    marginBottom: 20,
        icon: Icons.add,
        iconTheme: IconThemeData(color: Colors.black),
        activeIcon: Icons.remove,
        heroTag: "CollaborationPage3",
        backgroundColor: Get.theme.primaryColor,
        visible: true,
        elevation: 8.0,
        shape: CircleBorder(),
        closeManually: false,
        buttonSize: Size(56.0, 56.0),

        /// If true overlay will render no matter what.
        renderOverlay: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.transparent,
        overlayOpacity: 0.01,
        children: [
          SpeedDialChild(
              child: Icon(
                Icons.dashboard_customize,
                color: Colors.white,
              ),
              backgroundColor: Get.theme.secondaryHeaderColor,
              label: AppLocalizations.of(context)!.board,
              labelStyle: TextStyle(fontSize: 18.0, color: Colors.white),
              labelBackgroundColor: Colors.black45,
              onTap: () => addBoard()),
          SpeedDialChild(
            child: Icon(
              Icons.library_add,
              color: Colors.white,
            ),
            backgroundColor: Get.theme.primaryColor,
            label: AppLocalizations.of(context)!.group,
            labelStyle: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
            labelBackgroundColor: Colors.black45,
            onTap: () => addGroup(),
          ),
        ],
      ),
    );
  }

  Container buildProjectAndTeamWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: standartCardShadow(),
      ),
      child: Container(
        height: 23,
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            menuMaxHeight: 350,
            value: selectedCommonGroupId,
            style: TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontFamily: 'TTNorms',
                fontWeight: FontWeight.w500),
            icon: Row(
              children: [
                Icon(
                  Icons.expand_more,
                  color: Colors.black,
                ),
              ],
            ),
            items: _commonGroup.map((CommonGroup commonGroup) {
              return DropdownMenuItem(
                value: commonGroup.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(commonGroup.groupName!),
                    commonGroup.groupName == 'Alle'
                        ? Container()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                  onTap: () async {
                                    await _controllerCommon.GetGroupById(
                                            _controllerDB.headers(),
                                            userId: _controllerDB
                                                .user.value!.result!.id!,
                                            id: commonGroup.id)
                                        .then((value) async {
                                      _groupId.text = commonGroup.id.toString();
                                      _createDate.text = value
                                          .listOfCommonGroup!.first.createDate!;
                                      _groupText.text = value
                                          .listOfCommonGroup!.first.groupName!;
                                      _projectNumber.text = value
                                          .listOfCommonGroup!
                                          .first
                                          .projectNumber
                                          .toString();
                                      _streetTextController.text = value
                                          .listOfCommonGroup!.first.street!;
                                      _postalCodeTextController.text = value
                                          .listOfCommonGroup!.first.postalCode!;
                                      _cityTextController.text =
                                          value.listOfCommonGroup!.first.city!;
                                      _stateTextController.text =
                                          value.listOfCommonGroup!.first.state!;
                                      _groupStartDateController.text = value
                                          .listOfCommonGroup!
                                          .first
                                          .groupStartDate!;
                                      _groupEndDateController.text = value
                                          .listOfCommonGroup!
                                          .first
                                          .groupEndDate!;
                                      _groupStartDateControllerForText.text =
                                          DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(value
                                                      .listOfCommonGroup!
                                                      .first
                                                      .groupStartDate!) ??
                                                  DateTime.now());
                                      _groupEndDateControllerForText.text =
                                          DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(value
                                                      .listOfCommonGroup!
                                                      .first
                                                      .groupEndDate!) ??
                                                  DateTime.now());
                                      selectedInvoiceIndex = value
                                          .listOfCommonGroup!
                                          .first
                                          .selectedCustomerId;
                                      print("selectedUserIndex2222" +
                                          value.listOfCommonGroup!.first
                                              .personalId!
                                              .toString());
                                      setState(() {
                                        selectedUserIndex = value
                                            .listOfCommonGroup!
                                            .first
                                            .personalId!;
                                        _selectedInvoice =
                                            invoiceList.firstWhere(
                                          (InvoiceDetail invoice) =>
                                              invoice.id ==
                                              value.listOfCommonGroup!.first
                                                  .selectedCustomerId,
                                          //!   orElse: () =>
                                          //!     null, // Handle the case where no match is found
                                        );
                                        selectedInvoiceIndex = value
                                            .listOfCommonGroup!
                                            .first
                                            .selectedCustomerId!;
                                      });

                                      updateGroup();
                                    });
                                  },
                                  child: Image.asset(
                                      'assets/images/icon/history.png',
                                      width: 20)),
                              SizedBox(width: 15),
                              GestureDetector(
                                  onTap: () {
                                    deleteGroup(commonGroup.id!);
                                  },
                                  child: Image.asset(
                                    'assets/images/icon/delete.png',
                                    width: 25,
                                  )),
                            ],
                          ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                selectedCommonGroupId = value;
                changeGroup();
                if (pageController!.hasClients) {
                  pageController!.jumpToPage(0);
                }
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('selectedProject', value!);
              print("Selected project: 222" + value.toString());
            },
          ),
        ),
      ),
    );
  }

  Widget buildBoards(CommonBoardListItem commonBoardListItem) {
    return Container(
      width: Get.width,
      margin: EdgeInsets.only(bottom: 15, right: 20, left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(
            0xFFeef8f9), //Colors.white, //Color.fromRGBO(249, 249, 249, 1),
        boxShadow: standartCardShadow(),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 13, 20, 5),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () async {
                      int? fileUploadType;
                      await selectUploadType(context)
                          .then((value) => fileUploadType = value);
                      if (fileUploadType == 0) {
                        await _imgFromCamera(commonBoardListItem.id!,
                            commonBoardListItem.title!);
                      } else if (fileUploadType == 1) {
                        await openFile(commonBoardListItem.id!,
                            commonBoardListItem.title!);
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
                        updateTitle(commonBoardListItem.id!);
                      },
                      child: Text(
                        commonBoardListItem.title == null
                            ? ""
                            : commonBoardListItem.title!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                ButtonTheme(
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
                PopupMenuButton<MenuItem>(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                    size: 27,
                  ),
                  onSelected: (MenuItem item) {
                    onClickMenu(
                        item,
                        commonBoardListItem
                            .id!); // Call the onClickMenu function when an item is selected
                  },
                  itemBuilder: (context) => [
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
                      child: (_commons!.result!.commonBoardList!
                              .firstWhere((element) =>
                                  element.id == commonBoardListItem.id)
                              .isPublic!)
                          ? Text(AppLocalizations.of(context)!
                              .defineAListOfDefects)
                          : Text(AppLocalizations.of(context)!.setModule),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 30,
            margin: EdgeInsets.only(bottom: 5),
            child: ListView.builder(
                itemCount: commonBoardListItem.users.length,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (contex, index) {
                  return Container(
                    height: 22,
                    width: 22,
                    margin: EdgeInsets.only(right: 3),
                    child: CircleAvatar(
                      radius: 15.0,
                      backgroundImage:
                          commonBoardListItem.users[index].photo != null
                              ? NetworkImage(
                                  commonBoardListItem.users[index].photo!,
                                )
                              : null,
                      backgroundColor: Colors.transparent,
                    ),
                  );
                }),
          ),
          Expanded(
            child: commonBoardListItem.todos != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ListView.builder(
                          itemCount: commonBoardListItem.todos
                              .where((element) => _selectedFilterId == 99
                                  ? true
                                  : element.status == _selectedFilterId)
                              .length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            CommonTodo boardTodo =
                                commonBoardListItem.todos[index];
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
                                              commonBoardId:
                                                  commonBoardListItem.id!,
                                              selectedTab: 0,
                                              commonTodo: boardTodo,
                                              commonBoardTitle:
                                                  commonBoardListItem.title!,
                                              cloudPerm: (_controllerTodo
                                                          .hasFileManagerTodoPerm(
                                                              commonBoardListItem
                                                                  .id!,
                                                              boardTodo.id!)) !=
                                                      false ||
                                                  _controllerCommon
                                                      .hasFileManagerCommonPerm(
                                                    commonBoardListItem.id!,
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
                                                bottom: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.grey))),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: ListView.builder(
                                                        itemCount: boardTodo
                                                            .labelList!.length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, i) {
                                                          return Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0),
                                                                child:
                                                                    Container(
                                                                  width: 55,
                                                                  height: 7,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: HexColor(boardTodo
                                                                        .labelList![
                                                                            i]
                                                                        .labelColor!),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
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
                                                        itemCount: boardTodo
                                                            .userList!.length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, i) {
                                                          print('length' +
                                                              boardTodo
                                                                  .userList!
                                                                  .length
                                                                  .toString());
                                                          return CachedNetworkImage(
                                                            imageUrl: boardTodo
                                                                .userList![i]
                                                                .photo!,
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          8.0),
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image: DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .fitHeight),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              boardTodo.content!,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: Get.width,
                                        height: 55,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                _controllerTodo
                                                        .hasCreateCallTodoPerm(
                                                            commonBoardListItem
                                                                .id!,
                                                            boardTodo.id!)
                                                    ? Get.theme
                                                        .secondaryHeaderColor
                                                    : noPermissionColor,
                                                () async {
                                              if (!_controllerTodo
                                                  .hasCreateCallTodoPerm(
                                                      commonBoardListItem.id!,
                                                      boardTodo.id!)) {
                                                return;
                                              }

                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                setState(() {
                                                  _pc.open();
                                                  _panelMinSize = 170.0;
                                                });
                                              });

                                              CareateOrJoinMetting(
                                                  boardTodo.id!, 21);
                                            }),

                                            _customIconButton(
                                              'assets/images/icon/cloud4.png',
                                              (_controllerTodo.hasFileManagerTodoPerm(
                                                              commonBoardListItem
                                                                  .id!,
                                                              boardTodo.id!)) ==
                                                          true ||
                                                      _controllerCommon
                                                          .hasFileManagerCommonPerm(
                                                        commonBoardListItem.id!,
                                                      )
                                                  ? Get.theme
                                                      .secondaryHeaderColor
                                                  : noPermissionColor,
                                              () {
                                                _controllerTodo.update();
                                                _controllerCommon.update();
                                                if ((_controllerTodo
                                                            .hasFileManagerTodoPerm(
                                                                commonBoardListItem
                                                                    .id!,
                                                                boardTodo
                                                                    .id!)) ==
                                                        true &&
                                                    !_controllerCommon
                                                        .hasFileManagerCommonPerm(
                                                      commonBoardListItem.id!,
                                                    )) {
                                                  return;
                                                }
                                                Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        new CommonDetailsPage(
                                                      todoId: boardTodo.id!,
                                                      commonBoardId:
                                                          commonBoardListItem
                                                              .id!,
                                                      selectedTab: 0,
                                                      commonTodo: boardTodo,
                                                      commonBoardTitle:
                                                          commonBoardListItem
                                                              .title!,
                                                      cloudPerm: (_controllerTodo
                                                                  .hasFileManagerTodoPerm(
                                                                      commonBoardListItem
                                                                          .id!,
                                                                      boardTodo
                                                                          .id!)) ==
                                                              true ||
                                                          _controllerCommon
                                                              .hasFileManagerCommonPerm(
                                                            commonBoardListItem
                                                                .id!,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            _customIconButton(
                                              'assets/images/icon/move.png',
                                              _controllerTodo.hasMoveTodoPerm(
                                                      commonBoardListItem.id!,
                                                      boardTodo.id!)
                                                  ? Get.theme
                                                      .secondaryHeaderColor
                                                  : noPermissionColor,
                                              () {
                                                if (!_controllerTodo
                                                    .hasMoveTodoPerm(
                                                        commonBoardListItem.id!,
                                                        boardTodo.id!)) {
                                                  return;
                                                }

                                                MoveTodo(
                                                    context, boardTodo.id!);
                                              },
                                            ),
                                            _customIconButton(
                                              'assets/images/icon/copy3.png',
                                              _controllerTodo.hasCopyTodoPerm(
                                                          commonBoardListItem
                                                              .id!,
                                                          boardTodo.id!) !=
                                                      null
                                                  ? Get.theme
                                                      .secondaryHeaderColor
                                                  : noPermissionColor,
                                              () {
                                                //! return; iptal edildi

                                                CopyTodo(boardTodo.id!);
                                              },
                                            ),
                                            _customIconButton(
                                              'assets/images/icon/edit.png',
                                              _controllerTodo.hasEditTodoPerm(
                                                          commonBoardListItem
                                                              .id!,
                                                          boardTodo.id!) ==
                                                      true
                                                  ? Get.theme
                                                      .secondaryHeaderColor
                                                  : noPermissionColor,
                                              () {
                                                if (_controllerTodo
                                                        .hasEditTodoPerm(
                                                            commonBoardListItem
                                                                .id!,
                                                            boardTodo.id!) ==
                                                    true) {
                                                  return;
                                                }
                                                Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        new CommonDetailsPage(
                                                      todoId: boardTodo.id!,
                                                      commonBoardId:
                                                          commonBoardListItem
                                                              .id!,
                                                      selectedTab: 4,
                                                      commonTodo: boardTodo,
                                                      commonBoardTitle:
                                                          commonBoardListItem
                                                              .title!,
                                                      cloudPerm: (_controllerTodo
                                                                  .hasFileManagerTodoPerm(
                                                                      commonBoardListItem
                                                                          .id!,
                                                                      boardTodo
                                                                          .id!)) ==
                                                              true ||
                                                          _controllerCommon
                                                              .hasFileManagerCommonPerm(
                                                            commonBoardListItem
                                                                .id!,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            _customIconButton(
                                              'assets/images/icon/delete.png',
                                              _controllerTodo.hasDeleteTodoPerm(
                                                      commonBoardListItem.id!,
                                                      boardTodo.id!)
                                                  ? Get.theme
                                                      .secondaryHeaderColor
                                                  : noPermissionColor,
                                              () async {
                                                if (!_controllerTodo
                                                    .hasDeleteTodoPerm(
                                                        commonBoardListItem.id!,
                                                        boardTodo.id!)) {
                                                  return;
                                                }

                                                bool isAccepted =
                                                    await confirmDeleteWidget(
                                                        context);
                                                if (isAccepted) {
                                                  await deleteTodo(
                                                      boardTodo.id!);

                                                  await loadPage(
                                                      (initialBoard ~/ perPage)
                                                          .ceil());
                                                }
                                              },
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  )
                : Text(AppLocalizations.of(context)!.thereisnotodo),
          ),
          SizedBox(
            height: 0,
          ),
          Container(
            width: Get.width,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      if (!_controllerCommon
                          .hasInsertCommonPerm(commonBoardListItem.id!)) {
                        return;
                        //! false; kaldirildi
                      }
                      _onAlertWithCustomContentPressed2(
                          commonBoardListItem.id!, context);
                    },
                    child: boardBottomButton('assets/images/icon/addtask1.png',
                        iconColor: _controllerCommon
                                .hasInsertCommonPerm(commonBoardListItem.id!)
                            ? Colors
                                .transparent //! null yerine transparent koyuldu
                            : noPermissionColor)),

                InkWell(
                    onTap: () {
                      if (!_controllerCommon
                          .hasFileManagerCommonPerm(commonBoardListItem.id!)) {
                        return;
                        //! false; kaldirildi
                      }
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => BoardCloudPage(
                                  boardId: commonBoardListItem.id,
                                  boardTitle: commonBoardListItem.title)));
                    },
                    child: boardBottomButton('assets/images/icon/cloud4.png',
                        iconColor: _controllerCommon.hasFileManagerCommonPerm(
                                commonBoardListItem.id!)
                            ? Colors
                                .transparent //! null yerine transparent koyuldu
                            : noPermissionColor)),
                GestureDetector(
                  onTap: () {
                    if (!_controllerCommon
                        .hasMoveCommonPerm(commonBoardListItem.id!)) {
                      return;
                    }
                    MoveBoard(commonBoardListItem.id!);
                    //  ChangeCommonGroup(CommonId, CommonGroupId);
                  },
                  child: boardBottomButton('assets/images/icon/move.png',
                      iconColor: _controllerCommon
                              .hasMoveCommonPerm(commonBoardListItem.id!)
                          ? Colors
                              .transparent //! null yerine transparent koyuldu
                          : noPermissionColor),
                ),
                GestureDetector(
                  onTap: () async {
                    if (!_controllerCommon
                        .hasCopyCommonPerm(commonBoardListItem.id!)) {
                      return;
                    }
                    print(commonBoardListItem.id);
                    await CopyCommon(commonBoardListItem.id!);
                    await changeGroup();
                  },
                  child: boardBottomButton('assets/images/icon/copy3.png',
                      iconColor: _controllerCommon
                              .hasCopyCommonPerm(commonBoardListItem.id!)
                          ? Colors
                              .transparent //! null yerine transparent koyuldu
                          : noPermissionColor),
                ),
                Container(
                  height: 30,
                  width: 30,
                  margin: EdgeInsets.only(right: 3),
                  child: CachedNetworkImage(
                      imageUrl: commonBoardListItem.ownerUserPhoto!,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
                ),
                GestureDetector(
                    onTap: () async {
                      if (!_controllerCommon
                          .hasUserInvitePerm(commonBoardListItem.id!)) {
                        return;
                      }
                      var InviteUsersCommonBoardType = jsonDecode(
                          await showModalCommonUsers(
                              context,
                              'Common Users',
                              '',
                              _commons!
                                  .result!.commonBoardList![initialBoard].id!,
                              _commons!.result!.commonBoardList![initialBoard]
                                  .users));

                      if (InviteUsersCommonBoardType != null) {
                        _controllerCommon.InviteUsersCommonBoard(
                            _controllerDB.headers(),
                            CommonId: commonBoardListItem.id,
                            RoleId: InviteUsersCommonBoardType["RoleId"],
                            TargetUserIdList:
                                InviteUsersCommonBoardType["TargetUserIdList"]
                                    .cast<int>());
                      }
                    },
                    child: boardBottomButton('assets/images/icon/users.png',
                        iconColor: _controllerCommon
                                .hasUserMovePerm(commonBoardListItem.id!)
                            ? Colors
                                .transparent //! null yerine transparent koyuldu
                            : noPermissionColor)),
                Tooltip(
                    message: _commonGroup
                            .firstWhere(
                                (element) =>
                                    element.id ==
                                    commonBoardListItem.commonGroupId,
                                orElse: () {
                              return CommonGroup(groupName: "");
                            })
                            .groupName
                            .isNullOrBlank!
                        ? ""
                        : _commonGroup
                            .firstWhere(
                              (element) =>
                                  element.id ==
                                  commonBoardListItem.commonGroupId,
                              //!      orElse: () {}
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
                      border: Border.all(width: 1, color: Colors.grey),
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
        onPressed: () => onPressed,
      ),
    );
  }

  Tooltip _customIconButtonWithBackground(
      String iconPath, Color color, Function onPressed, String tooltip) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return Tooltip(
      message: tooltip ?? "",
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          width: isTablet ? 50 : 40,
          height: isTablet ? 50 : 35,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.theme.colorScheme.primary),
          child: IconButton(
            icon: ImageIcon(
              AssetImage(iconPath),
            ),
            color: color,
            onPressed: () => onPressed(),
          ),
        ),
      ),
    );
  }

  Widget buildUnloadedBoards() {
    return Container(
      width: Get.width,
      margin: EdgeInsets.only(bottom: 15, right: 20, left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(
            0xFFd2e2e2), //Colors.white, //Color.fromRGBO(249, 249, 249, 1),
        boxShadow: standartCardShadow(),
      ),
      child: Column(
        children: [],
      ),
    );
  }

  Color get noPermissionColor => Color(0xFFd3d3d3);

  //#region  NEW POPUP MENU SECTION

  // Widget _buildCommonMenu(int commonId) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(5),
  //     child: Container(
  //       width: (60 * 2.0) * 1.4,
  //       height: 120,
  //       color: Colors.white30,
  //       child: GridView.count(
  //         padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  //         crossAxisCount: 2,
  //         crossAxisSpacing: 0.5,
  //         mainAxisSpacing: 0.5,
  //         childAspectRatio: (1.4 / 1),
  //         shrinkWrap: true,
  //         physics: NeverScrollableScrollPhysics(),
  //         children: menuItems.map((item) {
  //           return Material(
  //             color: getMenuItemBGColor(item.icon, commonId),
  //             child: InkWell(
  //               onTap: () {
  //                 onClickMenu(item, commonId);
  //               },
  //               child: Center(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: <Widget>[
  //                     Icon(
  //                       item.icon,
  //                       size: 20,
  //                       color: Colors.white,
  //                     ),
  //                     Container(
  //                       margin: EdgeInsets.only(top: 2),
  //                       child: Text(
  //                         item.title,
  //                         style: TextStyle(color: Colors.white, fontSize: 12),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  Color getMenuItemBGColor(IconData icon, int commonId) {
    /* Yetki Kontrol */
    int commonOwnerId = _commons!.result!.commonBoardList!
        .firstWhere((x) => x.id == commonId)
        .userId!;
    /* Yetki Kontrol */
    if (icon == Icons.delete) {
      if (!_controllerCommon.hasDeleteCommonPerm(commonId))
        return Color(0xFF95B1B0);
    } else if (icon == Icons.public) {
      if (commonOwnerId != _controllerDB.user.value!.result!.id!)
        return Color(0xFF95B1B0);
    }
    return Get.theme.secondaryHeaderColor;
  }
  //#endregion  NEW POPUP MENU SECTION

  ClipRRect boardBottomButton(String imagePath, {Color? iconColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 35,
        height: 35,
        color: Get.theme.scaffoldBackgroundColor,
        child: IconButton(
          onPressed: () {},
          icon: ImageIcon(
            AssetImage(imagePath),
          ),
          color: Colors.black54,
        ),
      ),
    );
  }

  void checkState(BuildContext context) {
    final snackBar = new SnackBar(content: new Text('这是一个SnackBar!'));

    //Scaffold.of(context).showSnackBar(snackBar);
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

  String groupOrCommonValue = 'Group';
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
                                    if (pageController!.hasClients) {
                                      pageController!.jumpToPage(0);
                                    }
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
                                    if (pageController!.hasClients) {
                                      pageController!.jumpToPage(0);
                                    }
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

  // update board
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
                          await UpdateBoard(
                              id,
                              updateBoardController.text,
                              //! null
                              "");
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

  void addBoard() {
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
                  height: 430,
                  width: Get.width,
                  child: Column(
                    children: [
                      Container(
                          height: 50,
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.primary,
                          ),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.newBoard,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.white),
                          ))),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          width: Get.width / 1.1,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black38),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: Get.width,
                                        height: 23,
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
                                            items: _commonGroup
                                                .map((CommonGroup commonGroup) {
                                              return DropdownMenuItem(
                                                value: commonGroup.id,
                                                child: Text(
                                                    commonGroup.groupName!),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCommonGroupId = value;
                                                changeGroup();
                                                if (pageController!
                                                    .hasClients) {
                                                  pageController!.jumpToPage(0);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      _customTextFormField(context,
                          AppLocalizations.of(context)!.title, _titleText),
                      SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () async {
                          if (_titleText.text.isBlank! &&
                              _descriptionText.text.isBlank!) {
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
                          await InsertCommon(_titleText.text,
                              _descriptionText.text, selectedCommonGroupId!);

                          changeGroup();
                          _titleText.text = "";
                          _descriptionText.text = "";
                          Navigator.pop(context);
                          print("eklendş");
                        },
                        child: Container(
                          width: 250,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Get.theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(45)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.add,
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

  void addGroup() {
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
                  height: Get.height * 0.8,
                  width: Get.width,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: Get.height * 0.15),
                    child: Column(
                      children: [
                        Container(
                            height: 50,
                            width: Get.width,
                            color: Get.theme.colorScheme.primary,
                            child: Center(
                                child: Text(
                              AppLocalizations.of(context)!.newProject,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.white),
                            ))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              _customTextFormField(
                                  context,
                                  AppLocalizations.of(context)!.groupName,
                                  _groupText),
                              _customTextFormField(
                                  context,
                                  AppLocalizations.of(context)!
                                      .constructionNumber,
                                  _projectNumber,
                                  enabled: false),
                              _searchableDropDown(context, setState),
                              _customTextFormField(
                                  context,
                                  AppLocalizations.of(context)!
                                      .constructionStreet,
                                  _streetTextController),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: _customTextFormFieldForSmallSize(
                                        context,
                                        AppLocalizations.of(context)!
                                            .constructionPostalCode,
                                        _postalCodeTextController),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: _customTextFormFieldForSmallSize(
                                        context,
                                        AppLocalizations.of(context)!
                                            .constructionCity,
                                        _cityTextController),
                                  ),
                                ],
                              ),
                              _customTextFormField(
                                  context,
                                  AppLocalizations.of(context)!
                                      .constructionState,
                                  _stateTextController),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                        child: _customTextFormFieldForSmallSize(
                                            context,
                                            AppLocalizations.of(context)!
                                                .projectStart,
                                            _groupStartDateControllerForText,
                                            enabled: false),
                                        onTap: () async {
                                          StartDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2100),
                                          );
                                          _groupStartDateController.text =
                                              StartDate.toString();
                                          _groupStartDateControllerForText
                                                  .text =
                                              DateFormat('dd MMM yyyy').format(
                                                  StartDate ?? DateTime.now());
                                          setState(() {});
                                        }),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                        child: _customTextFormFieldForSmallSize(
                                            context,
                                            AppLocalizations.of(context)!
                                                .projectEnd,
                                            _groupEndDateControllerForText,
                                            enabled: false),
                                        onTap: () async {
                                          EndDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2100),
                                          );
                                          _groupEndDateController.text =
                                              EndDate.toString();
                                          _groupEndDateControllerForText.text =
                                              DateFormat('dd MMM yyyy').format(
                                                  EndDate ?? DateTime.now());

                                          setState(() {});
                                        }),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: DropdownButton<InvoiceDetail>(
                                  value: _selectedInvoice,
                                  hint: selectedInvoiceIndex == null
                                      ? Text(AppLocalizations.of(context)!
                                          .selectCompanyType)
                                      : Text(_selectedInvoice!.name!),
                                  items:
                                      invoiceList.map((InvoiceDetail invoice) {
                                    return DropdownMenuItem<InvoiceDetail>(
                                      value: invoice,
                                      child: Text(invoice.name!),
                                    );
                                  }).toList(),
                                  onChanged: (InvoiceDetail? newValue) {
                                    setState(() {
                                      selectedInvoiceIndex = newValue!.id;
                                      _selectedInvoice = newValue;
                                    });
                                  },
                                  isExpanded:
                                      true, // Makes the dropdown take the full width
                                ),
                              ),
                              SizedBox(
                                height: 0,
                              ),
                              _addNewGroupButton(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  void deleteGroup(int commonGroup) async {
    bool isAccepted = await confirmDeleteWidget(context);
    if (isAccepted) {
      await DeleteCommonGroup(commonGroup);
    }
  }

  void updateGroup() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
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
                height: Get.height * 0.8,
                width: Get.width,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: Get.height * 0.15),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: Get.width,
                        color: Color(0xFF000000),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.updateProject,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            _customTextFormField(
                              context,
                              AppLocalizations.of(context)!.groupName,
                              _groupText,
                            ),
                            _customTextFormField(
                              context,
                              AppLocalizations.of(context)!.constructionNumber,
                              _projectNumber,
                              enabled: false,
                            ),
                            _searchableDropDown(context, setState),
                            _customTextFormField(
                              context,
                              AppLocalizations.of(context)!.constructionStreet,
                              _streetTextController,
                            ),
                            _customTextFormField(
                              context,
                              AppLocalizations.of(context)!
                                  .constructionPostalCode,
                              _postalCodeTextController,
                            ),
                            _customTextFormField(
                              context,
                              AppLocalizations.of(context)!.constructionCity,
                              _cityTextController,
                            ),
                            _customTextFormField(
                              context,
                              AppLocalizations.of(context)!.constructionState,
                              _stateTextController,
                            ),
                            GestureDetector(
                                child: _customTextFormField(
                                    context,
                                    AppLocalizations.of(context)!.projectStart,
                                    _groupStartDateControllerForText,
                                    enabled: false),
                                onTap: () async {
                                  StartDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  _groupStartDateController.text =
                                      StartDate.toString();
                                  _groupStartDateControllerForText.text =
                                      DateFormat('dd MMM yyyy')
                                          .format(StartDate ?? DateTime.now());
                                  setState(() {});
                                }),
                            GestureDetector(
                                child: _customTextFormField(
                                    context,
                                    AppLocalizations.of(context)!.projectEnd,
                                    _groupEndDateControllerForText,
                                    enabled: false),
                                onTap: () async {
                                  EndDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  _groupEndDateController.text =
                                      EndDate.toString();
                                  _groupEndDateControllerForText.text =
                                      DateFormat('dd MMM yyyy')
                                          .format(EndDate ?? DateTime.now());

                                  setState(() {});
                                }),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: DropdownButton<InvoiceDetail>(
                                value: _selectedInvoice,
                                hint: selectedInvoiceIndex == null
                                    ? Text(AppLocalizations.of(context)!
                                        .selectCompanyType)
                                    : Text(_selectedInvoice!.name!),
                                items: invoiceList.map((InvoiceDetail invoice) {
                                  return DropdownMenuItem<InvoiceDetail>(
                                    value: invoice,
                                    child: Text(invoice.name!),
                                  );
                                }).toList(),
                                onChanged: (InvoiceDetail? newValue) {
                                  setState(() {
                                    selectedInvoiceIndex = newValue!.id;
                                    _selectedInvoice = newValue;
                                  });
                                },
                                isExpanded: true,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            _updateGroupButton(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  SearchableDropdown<dynamic> _searchableDropDown(
    BuildContext context,
    StateSetter setState,
  ) {
    return SearchableDropdown.single(
      items: cboUsersList,
      value: selectedUserIndex,
      hint: Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(AppLocalizations.of(context)!.selectParticipants),
      ),
      searchHint: (AppLocalizations.of(context)!.search),
      onChanged: (value) {
        setState(() {
          selectedUserIndex = value;
          selectedUsers.clear();
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
        var name;
        var photo;
        _getUserListResult.result!.forEach((element) {
          if (element.id == item) {
            photo = element.photo;
            name = element.name! + " " + element.surname!;
          }
        });
        return Container(
          decoration: BoxDecoration(
              color: Color(0xFFdedede),
              borderRadius: BorderRadius.circular(30)),
          margin: EdgeInsets.only(right: 5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(photo),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(name),
            ],
          ),
        );
      },
      doneButton: (selectedItemDone, doneContext) {
        return ElevatedButton(
          onPressed: () {
            Navigator.pop(doneContext);
            setState(() {});
          },
          child: Text('Save'),
        );
      },
      closeButton: null,
      style: Theme.of(context).inputDecorationTheme.hintStyle,
      searchFn: (String keyword, items) {
        List<int> ret = [];
        if (items != null && keyword.isNotEmpty) {
          keyword.split(" ").forEach((k) {
            int i = 0;
            items.forEach((item) {
              if (k.isNotEmpty &&
                  (item.value
                      .toString()
                      .split("+")
                      .first
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
        return ret;
      },
      icon: Icon(
        Icons.expand_more,
        size: 31,
      ),
      underline: Container(
        height: 0.0,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
      ),
      iconDisabledColor: Colors.grey,
      iconEnabledColor: Theme.of(context).colorScheme.surface,
      isExpanded: true,
    );
  }

  InkWell _addNewGroupButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_groupText.text.isBlank! ||
            _projectNumber.text.isBlank! ||
            _streetTextController.text.isBlank! ||
            _postalCodeTextController.text.isBlank! ||
            _cityTextController.text.isBlank! ||
            _stateTextController.text.isBlank! ||
            _groupStartDateController.text.isBlank! ||
            _groupEndDateController.text.isBlank!) {
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
        InsertCommonGroup(
            _groupText.text,
            _projectNumber.text,
            _streetTextController.text,
            _postalCodeTextController.text,
            _cityTextController.text,
            _stateTextController.text,
            _groupStartDateController.text,
            _groupEndDateController.text,
            selectedInvoiceIndex!,
            selectedUserIndex!);
        _groupText.clear();
        _projectNumber.clear();
        _streetTextController.clear();
        _postalCodeTextController.clear();
        _cityTextController.clear();
        _stateTextController.clear();
        _groupStartDateController.clear();
        _groupEndDateController.clear();
        // selectedInvoiceIndex = null;
        // selectedUserIndex = null;
        Navigator.pop(context);
      },
      child: Container(
        width: 250,
        height: 45,
        decoration: BoxDecoration(
            boxShadow: standartCardShadow(),
            color: HexColor('27d1df'),
            borderRadius: BorderRadius.circular(45)),
        child: Center(
            child: Text(
          AppLocalizations.of(context)!.add,
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white),
        )),
      ),
    );
  }

  InkWell _updateGroupButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_groupText.text.isBlank! ||
            _projectNumber.text.isBlank! ||
            _streetTextController.text.isBlank! ||
            _postalCodeTextController.text.isBlank! ||
            _cityTextController.text.isBlank! ||
            _stateTextController.text.isBlank! ||
            _groupStartDateController.text.isBlank! ||
            _groupEndDateController.text.isBlank!) {
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
        UpdateCommonGroup(
            int.parse(_groupId.text),
            _controllerDB.user.value!.result!.id!,
            _createDate.text,
            _groupText.text,
            _projectNumber.text,
            _streetTextController.text,
            _postalCodeTextController.text,
            _cityTextController.text,
            _stateTextController.text,
            _groupStartDateController.text,
            _groupEndDateController.text,
            selectedInvoiceIndex!,
            selectedUserIndex!);
        _groupText.clear();
        _projectNumber.clear();
        _streetTextController.clear();
        _postalCodeTextController.clear();
        _cityTextController.clear();
        _stateTextController.clear();
        _groupStartDateController.clear();
        _groupEndDateController.clear();
        selectedInvoiceIndex = null;
        selectedUserIndex = null;
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
          AppLocalizations.of(context)!.update,
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white),
        )),
      ),
    );
  }

  Container _customTextFormField(
      BuildContext context, String hintText, TextEditingController controller,
      {bool enabled = true}) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        height: 45,
        decoration: BoxDecoration(
            color: Color(0xFFfaf6f3),
            boxShadow: standartCardShadow(),
            borderRadius: BorderRadius.circular(15)),
        child: TextFormField(
          enabled: enabled,
          controller: controller,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey), // Default border color
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black54), // Focused border color
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey), // Enabled border color
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red), // Error border color
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey), // Disabled border color
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.only(
              left: 15,
              bottom: 11,
              top: 11,
              right: 15,
            ),
            hintText: hintText,
            fillColor: Colors.white,
            filled: true,
          ),
        ));
  }

  Container _customTextFormFieldForSmallSize(
      BuildContext context, String hintText, TextEditingController controller,
      {bool enabled = true}) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: Get.width / 2.4,
        height: 45,
        decoration: BoxDecoration(
            color: Color(0xFFfaf6f3),
            boxShadow: standartCardShadow(),
            borderRadius: BorderRadius.circular(15)),
        child: TextFormField(
          enabled: enabled,
          controller: controller,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey), // Default border color
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black54), // Focused border color
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey), // Enabled border color
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red), // Error border color
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey), // Disabled border color
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.only(
              left: 15,
              bottom: 11,
              top: 11,
              right: 15,
            ),
            hintText: hintText,
            fillColor: Colors.white,
            filled: true,
          ),
        ));
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
                      await loadPage((_currentPage).ceil());
                      changeGroup();
                      // await pageController.jumpToPage(changedInitalBoard);

                      Navigator.pop(context);
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

  //! void kaldirildi
  _imgFromCamera(int id, String Title) async {
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

  buildCommons() {
    List<Widget> boards = [];

    if (_commons!.result!.commonBoardList!.isNotEmpty) {
      for (int i = 0; i < _commons!.result!.commonBoardList!.length; i++) {
        boards.add(buildBoards(_commons!.result!.commonBoardList![i]));

        // boards.add(BuildBoards(
        //     commonBoardListItem: _commons.result.commonBoardList[i]));
        // BuildBoards(
        //   commonBoardListItem: _commons.result.commonBoardList[i]));
      }
    }
    return boards;
  }

  String getTodoCount() {
    if (initialBoard > _commons!.result!.commonBoardList!.length - 1) return "";

    return _commons!.result!.commonBoardList!.length == 0
        ? "0"
        : (_commons!.result!.commonBoardList![initialBoard].todos.length ?? 0)
            .toString();
  }

  int get _currentPage {
    print("_currentPage = " + ((initialBoard) ~/ perPage).ceil().toString());
    return ((initialBoard) ~/ perPage).ceil();
  }

  int get _currentPageItemCount {
    print("totalCount : " + _commons!.result!.totalCount.toString());
    if (_commons!.result!.totalCount! < 5) {
      return _commons!.result!.totalCount!;
    } else if ((_currentPage + 1) * perPage > _commons!.result!.totalCount!) {
      return _commons!.result!.totalCount! % perPage;
    } else {
      return 5;
    }
  }

  moveTodo(int TodoId, int TargetCommonId) async {
    await _controllerTodo.MoveTodo(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
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

  copyTodo(int TodoId, List<int> TargetCommonIdList) async {
    await _controllerTodo.CopyTodo(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
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

  deleteTodo(int TodoId) async {
    await _controllerTodo.DeleteTodo(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id!,
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

  GetCommonUserList(int CommonId) async {
    await _controllerCommon.GetCommonUserList(_controllerDB.headers(),
            CommonId: CommonId, UserId: _controllerDB.user.value!.result!.id!)
        .then((value) {
      _getCommonUserListResult = value;
      setState(() {
        loading = false;
      });
    });
  }

  CopyCommon(int CommonId) async {
    await _controllerCommon.CopyCommon(_controllerDB.headers(),
            CommonId: CommonId, UserId: _controllerDB.user.value!.result!.id!)
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

  ChangeCommonGroup(int CommonId, int CommonGroupId) async {
    await _controllerCommon.ChangeCommonGroup(_controllerDB.headers(),
            CommonId: CommonId,
            UserId: _controllerDB.user.value!.result!.id!,
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

  GetCommonGroupBackground(int CommonId) async {
    await _controllerCommon.GetCommonGroupBackground(
      _controllerDB.headers(),
      CommonId: CommonId,
      UserId: _controllerDB.user.value!.result!.id!,
    ).then((value) {
      setState(() {
        _getCommonGroupBackgroundResult = value;
        backGround = false;
      });
    });
  }

  DeleteCommon(int CommonId) async {
    await _controllerCommon.DeleteCommon(
      _controllerDB.headers(),
      CommonId: CommonId,
      UserId: _controllerDB.user.value!.result!.id!,
    ).then((hasError) async {
      if (!hasError) {
        String? deletedCommonTitle = _commons!.result!.commonBoardList!
            .firstWhere((x) => x.id == CommonId)
            .title;
        showSuccessToast(
            "${deletedCommonTitle} ${AppLocalizations.of(context)!.deletedSuccesfully}");

        setState(() {
          _commons!.result!.commonBoardList!
              .removeWhere((e) => e.id == CommonId);

          _commons!.result!.totalCount = 1; //! -=1 yerine 1 yapildi

          _commons!.result!.totalPage =
              (_commons!.result!.commonBoardList!.length / 5).ceil();
          _controllerCommon.MyPermissionsOnBoards.removeWhere(
              (e) => e.commonId == CommonId);
          _controllerTodo.MyPermissionsOnTodos.removeWhere(
              (e) => e.commonId == CommonId);

          if (initialBoard + 1 > _commons!.result!.commonBoardList!.length) {
            if (pageController!.hasClients) {
              pageController!.jumpToPage(initialBoard - 1);
            }
          }
        });

        //await loadPage(_currentPage);
      } else {
        showSuccessToast("${AppLocalizations.of(context)!.anErrorHasOccured}");
      }
    });
  }

  DeleteCommonGroup(int CommonId) async {
    await _controllerCommon.DeleteCommonGroup(
      _controllerDB.headers(),
      CommonId: CommonId,
      UserId: _controllerDB.user.value!.result!.id!,
    ).then((hasError) async {
      if (!hasError) {
        String? deletedCommonTitle = _commons!.result!.commonBoardList!
            .firstWhere((x) => x.id == CommonId)
            .title;
        showSuccessToast(
            "${deletedCommonTitle} ${AppLocalizations.of(context)!.deletedSuccesfully}");

        //await loadPage(_currentPage);
      } else {
        showSuccessToast("${AppLocalizations.of(context)!.anErrorHasOccured}");
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new CollaborationPage()));
      }
    });
  }

  UpdateBoard(int Id, String Title, String Photo) async {
    await _controllerCommon.UpdateCommon(_controllerDB.headers(),
            Id: Id,
            UserId: _controllerDB.user.value!.result!.id!,
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
}

enum MenuItem { call, delete, public, notifications, settings }
