import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/model/Common/GetDefinedRoleListResult.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Label/GetTodoLabelListResult.dart';
import 'package:undede/model/Label/uploadLabels.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

class CommonDetailEditPage extends StatefulWidget {
  final int? todoId;
  final int? commonBoardId;
  final CommonTodo? commonTodo;
  final bool isPrivate;
  final bool isDraggable;
  final Function? toggleSheetClose;

  const CommonDetailEditPage(
      {Key? key,
      this.todoId,
      this.commonBoardId,
      this.commonTodo,
      this.isPrivate = false,
      this.isDraggable = false,
      this.toggleSheetClose})
      : super(key: key);

  @override
  _CommonDetailEditPageState createState() => _CommonDetailEditPageState();
}

class _CommonDetailEditPageState extends State<CommonDetailEditPage> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  ControllerLabel controllerLabel = Get.put(ControllerLabel());
  GetLabelByUserIdResult _getLabelByUserIdResult =
      GetLabelByUserIdResult(hasError: false);
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  GetUserListResult _getUserListResult = GetUserListResult(hasError: false);
  ControllerTodo _controllerTodo = ControllerTodo();
  ControllerCommon _controllerCommon = ControllerCommon();
  bool loading = true;
  bool isLoading = true;
  bool isLoading2 = true;
  TextEditingController startDateTextController = new TextEditingController();
  TextEditingController endDateTextController = new TextEditingController();
  List<UserLabel> labelsList = <UserLabel>[];
  final List<DropdownMenuItem> cboLabelsList = [];
  List<int> selectedLabelIndexes = [];
  final List<DropdownMenuItem> cboUsersList = [];
  List<int> selectedUserIndexes = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<Color> _colorCollection = <Color>[];
  List<String> _colorNames = <String>[];
  String? _selectedColorforAPI;
  String _selectedColor = "";
  DateTime? startDate;
  DateTime? endDate;
  int SelectedLabel = 0;
  // for status
  int? SelectedStatus;
  int? SelectedStatusValue;
  List<DropdownMenuItem>? StatusItems;
  // remender
  String? SelectedReminder;
  int? SelectedReminderValue;
  List<String>? ReminderItems;
  DateTime? RemindDate;
  TimeOfDay? RemindDatetime;
  TimeOfDay? endDatetime;
  TimeOfDay? startDatetime;
  TextEditingController _reminderController = TextEditingController(text: "0");

  // label add
  List<int> selectedLabels = [];
  List<int> selectedUsers = [];
  List<int> selectedUsersId = [];

  int selectedUser = 0;
  //RoleList
  GetDefinedRoleListResult _getDefinedRoleListResult =
      GetDefinedRoleListResult(hasError: false);
  List<DropdownMenuItem> items = [];
  bool isloading = true;
  int? SelectedRole;
  //! void kaldirildi

  getDefinedRoleList() async {
    await _controllerCommon.GetDefinedRoleList(_controllerDB.headers())
        .then((value) {
      _getDefinedRoleListResult = value;
      /*  SelectedRole = value.result!
          .firstWhere((element) => element.moduleType == value.result)
          .id; */
      if (value.result != null && value.result!.isNotEmpty) {
        final foundElement = value.result!.firstWhereOrNull((element) =>
            element.moduleType ==
            14); // firstWhereOrNull kullanın veya kendiniz kontrol edin
        if (foundElement != null) {
          SelectedRole = foundElement.id;
        } else {
          // Aranan eleman bulunamadıysa ne yapılacağını burada belirleyin (örneğin, varsayılan bir değer atayın veya bir hata mesajı gösterin).
          print("Hata: moduleType 31 olan eleman bulunamadı.");
        }
      }

      for (int i = 0;
          i < _getDefinedRoleListResult.result!.length //! ?? 0 silindi
          ;
          i++) {
        if (_getDefinedRoleListResult.result?[i].moduleType == 31)
          items.add(DropdownMenuItem(
            child: Text(_getDefinedRoleListResult.result![i].name!),
            value: _getDefinedRoleListResult.result![i].id,
            key: Key(_getDefinedRoleListResult.result![i].name!),
          ));
      }
    });
    setState(() {
      isloading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    _titleController = TextEditingController(text: widget.commonTodo!.content);
    _descriptionController =
        TextEditingController(text: widget.commonTodo!.description);
    timecolor();
    _selectedColorforAPI = "#0F8644";
    startDate = widget.commonTodo!.startDateTime;
    endDate = widget.commonTodo!.endDateTime;

    RemindDate = DateTime.now();
    RemindDatetime = TimeOfDay.now();
    startDatetime = TimeOfDay.now();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        SelectedStatusValue = widget.commonTodo!.status;
        StatusItems = [
          DropdownMenuItem(
            child: Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration:
                      BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(AppLocalizations.of(context)!.waiting)
              ],
            ),
            value: 0,
            key: Key(AppLocalizations.of(context)!.waiting),
          ),
          DropdownMenuItem(
            child: Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      color: Colors.amber, shape: BoxShape.circle),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(AppLocalizations.of(context)!.inProgress)
              ],
            ),
            value: 1,
            key: Key(AppLocalizations.of(context)!.inProgress),
          ),
          DropdownMenuItem(
            child: Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration:
                      BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(AppLocalizations.of(context)!.approwed)
              ],
            ),
            value: 2,
            key: Key(AppLocalizations.of(context)!.approwed),
          ),
          DropdownMenuItem(
            child: Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(AppLocalizations.of(context)!.completed)
              ],
            ),
            value: 4,
            key: Key(AppLocalizations.of(context)!.completed),
          ),
        ];
        SelectedStatus = widget.commonTodo!.status;
        SelectedReminder = AppLocalizations.of(context)!.minute;
        SelectedReminderValue = 0;
        ReminderItems = [
          AppLocalizations.of(context)!.minute,
          AppLocalizations.of(context)!.hour,
          AppLocalizations.of(context)!.day,
          AppLocalizations.of(context)!.customdate
        ];
      });
      if (mounted) {
        await getLabelByUserId();
        await getUserList();
        await getDefinedRoleList();
      }
    });
    super.initState();
  }

  void timecolor() {
    _colorCollection = <Color>[];
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF85461E));
    _colorCollection.add(const Color(0xFFFF00FF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF40606F));

    _colorNames = <String>[];
    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Magenta');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');
    _colorNames.add('Deep BLUE');
  }

  //! void kaldirildi
  getLabelByUserId() async {
    setState(() {
      loading = true;
    });
    await controllerLabel.GetLabelByUserId(_controllerDB.headers(),
            Id: 0, UserId: _controllerDB.user.value!.result!.id, CustomerId: 0)
        .then((value) {
      labelsList = value.result!;
      List.generate(controllerLabel.getLabel.value!.result!.length, (index) {
        cboLabelsList.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(controllerLabel.getLabel.value!.result![index].title!),
                Icon(
                  Icons.lens,
                  color: Color(int.parse(
                      controllerLabel.getLabel.value!.result![index].color!
                          .replaceFirst('#', "FF"),
                      radix: 16)),
                )
              ],
            ),
            key: Key(
                controllerLabel.getLabel.value!.result![index].id.toString()),
            value: controllerLabel.getLabel.value!.result![index].title! +
                "+" +
                controllerLabel.getLabel.value!.result![index].color!));
      });
    });

    await controllerLabel.GetTodoLabelList(
      _controllerDB.headers(),
      TodoId: widget.todoId,
      UserId: _controllerDB.user.value!.result!.id,
    ).then((value) {
      setState(() {
        selectedLabelIndexes.clear();
        selectedLabels.clear();
        value.result!.forEach((label) {
          cboLabelsList.asMap().forEach((index, availableLabel) {
            String cleanedKey = availableLabel.key
                .toString()
                .replaceAll(RegExp(r"[<'\>\[\]]"), '');
            int keyInt = int.tryParse(cleanedKey) ?? -1;
            int labelIdInt = label.labelId!;
            if (keyInt == labelIdInt) {
              if (!selectedLabelIndexes.contains(index)) {
                selectedLabelIndexes.add(index);
                print('Selected Indexes: $selectedLabelIndexes');
              }
            }
          });
        });
      });
    });

    setState(() {
      loading = false;
    });
  }

  getUserList() async {
    // Fetching user list
    await _controllerChatNew.GetUserList(
            _controllerDB.headers(), _controllerDB.user.value!.result!.id!)
        .then((value) {
      _getUserListResult = value;

      // Clear existing items
      cboUsersList.clear();

      // Populating cboUsersList with DropdownMenuItems
      List.generate(_getUserListResult.result!.length, (index) {
        if (_getUserListResult.result![index].isGroup == 0) {
          cboUsersList.add(
            DropdownMenuItem(
              child: Row(
                children: [
                  Text(_getUserListResult.result![index].fullName!),
                  SizedBox(width: 5),
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(_getUserListResult.result![index].photo!),
                    radius: 8,
                  ),
                ],
              ),
              key: Key(_getUserListResult.result![index].id.toString()),
              value: _getUserListResult.result![index].fullName! +
                  "+" +
                  _getUserListResult.result![index].photo!,
            ),
          );
        }
      });

      // Matching selected users with the populated list
      for (int i = 0; i < widget.commonTodo!.userList!.length; i++) {
        for (int k = 0; k < cboUsersList.length; k++) {
          // Ensure that the key comparison is valid
          if (cboUsersList[k]
              .key
              .toString()
              .contains(widget.commonTodo!.userList![i].id.toString())) {
            selectedUserIndexes.add(k);
            selectedUsers.add(widget.commonTodo!.userList![i].id!);
          }
        }
      }

      // Debugging print statements
    });

    // Updating state after the list has been fetched and processed
    setState(() {
      isLoading2 = false;
    });
  }

  UpdateCommonTodos(String TodoName, String StartDate, String EndTime,
      int Status, String RemindDate) {
    _controllerTodo.UpdateCommonTodos(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        CommonBoardId: widget.commonBoardId,
        TodoName: TodoName,
        TodoId: widget.todoId,
        Status: Status,
        StartDate: StartDate,
        EndDate: EndTime,
        RemindDate: RemindDate);
  }

  InsertTodoLabel(int LabelId) {
    controllerLabel.InsertTodoLabel(_controllerDB.headers(),
            TodoId: widget.todoId,
            LabelId: LabelId,
            UserId: _controllerDB.user.value!.result!.id!)
        .then((value) {
      if (value) {}
    });
  }

  InsertTodoLabelList(List<int> LabelIds) {
    controllerLabel.InsertTodoLabelList(_controllerDB.headers(),
            TodoId: widget.todoId,
            LabelIds: LabelIds,
            UserId: _controllerDB.user.value!.result!.id!)
        .then((value) {
      if (value) {
        print(value);
      }
    });
  }

  InviteUsersCommonTask(List<int> TargetUserIdList, int RoleId) {
    _controllerTodo.InviteUsersCommonTask(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        TodoId: widget.todoId,
        RoleId: RoleId,
        TargetUserIdList: TargetUserIdList);
  }

  @override
  Widget build(BuildContext context) {
    return loading && isLoading && isLoading2
        ? CustomLoadingCircle()
        : Container(
            width: Get.width,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  widget.isPrivate
                      ? CustomTextField(
                          controller: _titleController,
                          hint: AppLocalizations.of(context)!.title,
                        )
                      : SizedBox(),
                  widget.isPrivate
                      ? Container(
                          margin: EdgeInsets.only(top: 15),
                          child: CustomTextField(
                            controller: _descriptionController,
                            hint: AppLocalizations.of(context)!.description,
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15,
                  ),
                  SearchableDropdown.multiple(
                    items: cboLabelsList,
                    selectedItems: selectedLabelIndexes,
                    hint: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(AppLocalizations.of(context)!.labels),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedLabels.clear();
                        selectedLabelIndexes = value;
                        /*for (int i = 0; i < value.length; i++) {
                          String aStr = items
                              .elementAt(i)
                              .key
                              .toString()
                              .replaceAll(new RegExp(r'[^0-9]'), '');
                          SelectedLabel = int.parse(aStr);
                          selectedLabels.add(SelectedLabel);
                        }*/
                        labelsList.asMap().forEach((index, value) {
                          selectedLabelIndexes.forEach((selectedLabelIndex) {
                            if (selectedLabelIndex == index) {
                              selectedLabels.add(value.id!);
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
                    closeButton: Navigator.of(context).pop,
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
                    height: 15,
                  ),
                  widget.isPrivate
                      ? SearchableDropdown.multiple(
                          items: cboUsersList,
                          selectedItems: selectedUserIndexes,
                          hint: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(AppLocalizations.of(context)!.members),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedUsers.clear();
                              selectedUserIndexes = value;
                              _getUserListResult.result!
                                  .asMap()
                                  .forEach((index, value) {
                                selectedUserIndexes
                                    .forEach((selectedUserIndex) {
                                  if (selectedUserIndex == index) {
                                    selectedUsers.add(value.id!);
                                  }
                                });
                              });
                              print(selectedUserIndexes);
                              print(
                                  "selectedUsers:" + selectedUsers.toString());
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
                              child: (Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          item.toString().split("+").last),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(item.toString().split("+").first),
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
                              child: Text(AppLocalizations.of(context)!.save),
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
                              ret =
                                  Iterable<int>.generate(items.length).toList();
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
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15,
                  ),
                  widget.isPrivate
                      ? Visibility(
                          visible: !selectedUsers.isBlank!,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SearchableDropdown.single(
                              color: Colors.white,
                              height: 40,
                              displayClearIcon: false,
                              menuBackgroundColor:
                                  Get.theme.scaffoldBackgroundColor,
                              items: items,
                              value: SelectedRole,
                              icon: Icon(Icons.expand_more),
                              hint: AppLocalizations.of(context)!.selectTask,
                              searchHint:
                                  AppLocalizations.of(context)!.selectTask,
                              onChanged: (value) {
                                setState(() {
                                  SelectedRole = value;
                                  print(SelectedRole);
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
                        )
                      : SizedBox(),
                  widget.isPrivate
                      ? Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(45),
                                    boxShadow: standartCardShadow()),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    menuMaxHeight: 350,
                                    value: SelectedStatus,
                                    style: Get
                                        .theme.inputDecorationTheme.hintStyle,
                                    icon: Icon(
                                      Icons.expand_more,
                                      color: Colors.black,
                                    ),
                                    items: StatusItems,
                                    onChanged: (value) {
                                      setState(() {
                                        SelectedStatus = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(45),
                                    boxShadow: standartCardShadow()),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog<Widget>(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return _colorPicker(context);
                                      },
                                    ).then((dynamic value) => setState(() {}));
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.colors,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.lens,
                                        color: _selectedColor.isEmpty
                                            ? _colorCollection[0]
                                            : Color(int.parse(_selectedColor)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15,
                  ),
                  widget.isPrivate
                      ? Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 7,
                                        child: GestureDetector(
                                            child: Text(
                                                DateFormat(
                                                        'dd.MM.yyyy',
                                                        AppLocalizations.of(
                                                                context)!
                                                            .date)
                                                    .format(startDate == null
                                                        ? DateTime.now()
                                                        : startDate!),
                                                textAlign: TextAlign.left),
                                            onTap: () async {
                                              DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: startDate == null
                                                    ? DateTime.now()
                                                    : startDate,
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2100),
                                              );
                                              if (picked != startDate) {
                                                setState(() {
                                                  startDate = picked;
                                                });
                                              }
                                            }),
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            final TimeOfDay? time =
                                                await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay(
                                                        hour: 10, minute: 0));
                                          },
                                          child: Text("10:25"))
                                    ]),
                              ),
                            ),
                            SizedBox(
                              width: 15,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 7,
                                        child: GestureDetector(
                                            child: Text(
                                                DateFormat(
                                                        'dd.MM.yyyy',
                                                        AppLocalizations.of(
                                                                context)!
                                                            .date)
                                                    .format(endDate == null
                                                        ? DateTime.now()
                                                        : endDate!),
                                                textAlign: TextAlign.left),
                                            onTap: () async {
                                              DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: endDate == null
                                                    ? DateTime.now()
                                                    : endDate,
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2100),
                                              );
                                              if (picked != endDate) {
                                                setState(() {
                                                  endDate = picked;
                                                });
                                              }
                                            }),
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            final TimeOfDay? time =
                                                await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay(
                                                        hour: 0, minute: 0));
                                          },
                                          child: Text("00:00"))
                                    ]),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15,
                  ),
                  widget.isPrivate
                      ? Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(45),
                                    boxShadow: standartCardShadow()),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    menuMaxHeight: 350,
                                    value: SelectedReminder,
                                    style: Get
                                        .theme.inputDecorationTheme.hintStyle,
                                    icon: Icon(
                                      Icons.expand_more,
                                      color: Colors.black,
                                    ),
                                    items: ReminderItems?.map((String val) {
                                      return DropdownMenuItem(
                                        value: val,
                                        child: Text(val),
                                        key: Key(val),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        SelectedReminder = value.toString();
                                        SelectedReminderValue = ReminderItems!
                                            .indexWhere((element) =>
                                                element == value.toString());
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            SelectedReminderValue == 3
                                ? Expanded(
                                    child: Container(
                                      height: 45,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(45),
                                          boxShadow: standartCardShadow()),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 7,
                                              child: GestureDetector(
                                                  child: Text(
                                                      DateFormat(
                                                              'EEE, MMM dd yyyy',
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .date)
                                                          .format(RemindDate!),
                                                      textAlign:
                                                          TextAlign.left),
                                                  onTap: () async {
                                                    final DateTime? picked =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate: RemindDate,
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime(2100),
                                                    );
                                                    if (picked != RemindDate) {
                                                      setState(() {
                                                        RemindDate = picked;
                                                      });
                                                    }
                                                  }),
                                            ),
                                          ]),
                                    ),
                                  )
                                : Expanded(
                                    child: CustomTextField(
                                      controller: _reminderController,
                                      inputType: TextInputType.number,
                                      onChanged: (a) {
                                        RemindDate = DateTime.now();
                                      },
                                    ),
                                  ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () async {
                      SelectedReminderValue == 0
                          ? RemindDate = RemindDate!.add(Duration(
                              minutes: int.parse(_reminderController.text),
                            ))
                          : SelectedReminderValue == 1
                              ? RemindDate = RemindDate!.add(Duration(
                                  hours: int.parse(_reminderController.text),
                                ))
                              : SelectedReminderValue == 2
                                  ? RemindDate = RemindDate!.add(Duration(
                                      days: int.parse(_reminderController.text),
                                    ))
                                  : RemindDate = RemindDate!.add(Duration());

                      await UpdateCommonTodos(
                          _titleController.text,
                          startDate.toString(),
                          endDate.toString(),
                          SelectedStatus!,
                          RemindDate.toString());
                      await InsertTodoLabelList(selectedLabels);
                      await InviteUsersCommonTask(selectedUsers, SelectedRole!);
                      _controllerCalendar.refreshCalendar = true;
                      _controllerCalendar.update();
                      /*  widget.isDraggable
                          ? Navigator.pop(context)
                          : widget.toggleSheetClose!(); */
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 45,
                        width: Get.width / 3,
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: standartCardShadow(),
                        ),
                        child: Center(
                            child: Text(
                          AppLocalizations.of(context)!.save,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w500),
                        )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget _colorPicker(context) {
    return AlertDialog(
      content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: _colorCollection.length - 1,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Icon(
                    index == _selectedColor.isEmpty
                        ? Icons.lens
                        : Icons.trip_origin,
                    color: _colorCollection[index]),
                title: Text(_colorNames[index]),
                onTap: () {
                  setState(() {
                    _selectedColor =
                        _colorCollection[index].value.toRadixString(10);
                    _selectedColorforAPI = _colorCollection[index]
                        .value
                        .toRadixString(16)
                        .replaceFirst("ff", "#");
                    print(_selectedColorforAPI);
                  });

                  // ignore: always_specify_types
                  Future.delayed(const Duration(milliseconds: 200), () {
                    // When task is over, close the dialog
                    Navigator.pop(context);
                  });
                },
              );
            },
          )),
    );
  }
}
