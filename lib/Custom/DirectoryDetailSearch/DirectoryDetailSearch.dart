import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/ControllerDB.dart';
import '../../Controller/ControllerFiles.dart';
import '../../Services/Common/CommonDB.dart';
import '../../Services/TodoService/TodoDB.dart';
import '../../WidgetsV2/customCardShadow.dart';
import '../../WidgetsV2/searchableDropDown.dart';
import '../../model/Common/CommonGroup.dart';
import '../../model/Common/Commons.dart';
import '../../model/Todo/CommonTodo.dart';
import '../dropdownSearchFn.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DirectoryDetailSearch extends StatefulWidget {
  const DirectoryDetailSearch({Key? key}) : super(key: key);

  @override
  State<DirectoryDetailSearch> createState() => _DirectoryDetailSearchState();
}

class _DirectoryDetailSearchState extends State<DirectoryDetailSearch> {
  CommonDB _commonDB = new CommonDB();
  TodoDB _todoDB = new TodoDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<CommonGroup> commonGroupList = [];
  final List<DropdownMenuItem> cboCommonGroups = [];
  int? selectedCommonGroup;
  List<CommonBoardListItem> commonBoardList = [];
  final List<DropdownMenuItem> cboCommons = [];
  int? selectedcommonBoard;
  List<CommonTodo> boardTaskList =[];
  final List<DropdownMenuItem> cboTasks = [];
  int? selectedBoardTask;

  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
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
    setState(() {});
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
    setState(() {});
  }

  Future<void> loadCommonGroup() async {
    await _commonDB.GetListCommonGroup(_controllerDB.headers(),
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
    setState(() {});
  }

  int selectedManager = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 45,
          decoration: BoxDecoration(
              boxShadow: standartCardShadow(),
              borderRadius: BorderRadius.circular(15)),
          child: SearchableDropdown.single(
            color: Colors.white,
            height: 45,
            displayClearIcon: false,
            menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
            items: [
              DropdownMenuItem(
                child: Text(
                  AppLocalizations.of(context)!.privateCloud,
                ),
                value: 0,
              ),
              DropdownMenuItem(
                child: Text(
                  AppLocalizations.of(context)!.collaborationTask,
                ),
                value: 1,
              ),
              DropdownMenuItem(
                child: Text(
                  AppLocalizations.of(context)!.collaboration,
                ),
                value: 2,
              ),
            ],
            value: selectedManager,
            icon: Icon(Icons.expand_more),
            hint: AppLocalizations.of(context)!.selectgroup,
            searchHint: AppLocalizations.of(context)!.selectgroup,
            onChanged: (value) async {
              setState(() {
                selectedManager = value;
              });
              if (selectedManager != 0) {
                loadCommonGroup();
              }
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
        if (selectedManager == 1 || selectedManager == 2)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 45,
              decoration: BoxDecoration(
                  boxShadow: standartCardShadow(),
                  borderRadius: BorderRadius.circular(15)),
              child: SearchableDropdown.single(
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
            ),
          ),
        if ((selectedManager == 1 || selectedManager == 2) &&
            !cboCommons.isBlank!)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  boxShadow: standartCardShadow(),
                  borderRadius: BorderRadius.circular(15)),
              child: SearchableDropdown.single(
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
                  if (selectedManager == 1) {
                    setState(() {
                      cboTasks.clear();
                    });
                    await loadTasks(value);
                  }
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
            ),
          ),
        if (selectedManager == 1 && !cboTasks.isBlank!)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 45,
              decoration: BoxDecoration(
                  boxShadow: standartCardShadow(),
                  borderRadius: BorderRadius.circular(15)),
              child: SearchableDropdown.single(
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
            ),
          ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _controllerFiles.searchModuleType = selectedManager;
                    _controllerFiles.searchCommonId = selectedcommonBoard!;
                    _controllerFiles.searchCommonTaskId = selectedBoardTask!;
                    _controllerFiles.searchRefresh = true;
                    _controllerFiles.update();
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.search)),
            ],
          ),
        )
      ],
    );
  }
}
