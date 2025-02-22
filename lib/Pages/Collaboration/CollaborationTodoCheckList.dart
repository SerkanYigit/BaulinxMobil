import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/showModalTextInput.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Common/GetDefinedRoleListResult.dart';
import 'package:undede/model/Common/GetPermissionListByCategoryIdResult.dart';
import 'package:undede/model/Common/GetPermissionListResult.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Todo/GetTodoCheckListResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:undede/model/Todo/GetTodoCheckListResult.dart'
    as b;

class CollaborationTodoCheckList extends StatefulWidget {
  final int? todoId;

  const CollaborationTodoCheckList({Key? key, this.todoId}) : super(key: key);
  @override
  _CollaborationTodoCheckListState createState() =>
      _CollaborationTodoCheckListState();
}

class _CollaborationTodoCheckListState extends State<CollaborationTodoCheckList>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
  bool loading = true;
  bool listExpand = false;
  final List<DropdownMenuItem> dmiRules = [];
  TextEditingController _textEditingController = TextEditingController();

  GetTodoCheckListResult _getTodoCheckListResult = GetTodoCheckListResult(hasError: false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      GetTodoCheckList(widget.todoId!);
    });
  }

  Future<void> GetTodoCheckList(int todoId) async {
    await _controllerTodo.GetTodoCheckList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!, TodoId: todoId)
        .then((value) {
      setState(() {
        _getTodoCheckListResult = value;
      });
    });
  }

  Future<void> InsertOrUpdateTodoCheckList(
      int Id, int todoId, String Title, bool IsDone) async {
    await _controllerTodo.InsertOrUpdateTodoCheckList(_controllerDB.headers(),
            Id: Id,
            UserId: _controllerDB.user.value!.result!.id!,
            TodoId: todoId,
            Title: Title,
            IsDone: IsDone)
        .then((value) {
      setState(() {
        if (Id == 0) {
          _getTodoCheckListResult.checkListItem!.insert(
              0,
              CheckListItem(
                  title: value.result!.title,
                  id: value.result!.id,
                  userId: value.result!.userId,
                  isDone: value.result!.isDone,
                  todoId: value.result!.todoId));
        }
      });
    });
  }

  Future<void> DeleteTodoCheckList(int TodoCheckId) async {
    await _controllerTodo.DeleteTodoCheckList(_controllerDB.headers(),
              UserId: _controllerDB.user.value!.result!.id!,
            TodoCheckId: TodoCheckId)
        .then((value) {
      setState(() {
        _getTodoCheckListResult.checkListItem!
            .removeWhere((element) => element.id == TodoCheckId);
      });
    });
  }

  var _results = {};
  List<int> PermissionIdList = [];
  bool selectAll = true;
  FocusNode noteFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textEditingController,
                      focusNode: noteFocus,
                      onTap: () {
                        setState(() {
                          listExpand = !listExpand;
                        });
                        if (!listExpand) {
                          noteFocus.unfocus();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.takeACheckList,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.zero),
                      ),
                      maxLines: null,
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: listExpand ? null : 0,
                      margin:
                          EdgeInsets.symmetric(vertical: listExpand ? 3 : 0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 5,
                              bottom: 15,
                            ),
                            child: Row(
                              children: [
                                Spacer(),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      InsertOrUpdateTodoCheckList(
                                          0,
                                          widget.todoId!,
                                          _textEditingController.text,
                                          false);
                                      setState(() {
                                        listExpand = !listExpand;
                                        _textEditingController.clear();
                                      });
                                      noteFocus.unfocus();
                                    },
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Get.theme.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .done)),
                                    ),
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
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount:
                      _getTodoCheckListResult.checkListItem!.length == null
                          ? 0
                          : _getTodoCheckListResult.checkListItem!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 15, bottom: 100),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    String? newFileName =
                                        await showModalTextInput(
                                            context,
                                            AppLocalizations.of(context)!.title,
                                            AppLocalizations.of(context)!.save,
                                            text: _getTodoCheckListResult
                                                .checkListItem![index].title!);
                                    if (!newFileName!.isNullOrBlank!) {
                                      InsertOrUpdateTodoCheckList(
                                          _getTodoCheckListResult
                                              .checkListItem![index].id!,
                                          _getTodoCheckListResult
                                              .checkListItem![index].todoId!,
                                          newFileName,
                                          _getTodoCheckListResult
                                              .checkListItem![index].isDone!);
                                      _getTodoCheckListResult
                                          .checkListItem![index]
                                          .title = newFileName;
                                      setState(() {});
                                    }
                                  },
                                  child: Text(
                                    _getTodoCheckListResult
                                        .checkListItem![index].title!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      InsertOrUpdateTodoCheckList(
                                          _getTodoCheckListResult
                                              .checkListItem![index].id!,
                                          _getTodoCheckListResult
                                              .checkListItem![index].todoId!,
                                          _getTodoCheckListResult
                                              .checkListItem![index].title!,
                                          !(_getTodoCheckListResult
                                              .checkListItem![index].isDone!));
                                      setState(() {
                                        _getTodoCheckListResult
                                                .checkListItem![index].isDone =
                                            !(_getTodoCheckListResult
                                                .checkListItem![index].isDone!);
                                      });
                                    },
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      margin: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: _getTodoCheckListResult
                                              .checkListItem![index].isDone!
                                          ? Icon(
                                              Icons.check,
                                              color: Get.theme.primaryColor,
                                            )
                                          : Container(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        DeleteTodoCheckList(
                                            _getTodoCheckListResult
                                                .checkListItem![index].id!);
                                      },
                                      child: Icon(
                                        Icons.delete_outlined,
                                        size: 28,
                                      ))
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1.5,
                          )
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  IconData? ModuleSubCategoryIcon(int selectedRule, int ModuleSubCategory) {
    if (selectedRule == 14) {
      if (ModuleSubCategory == 23) {
        return Icons.dashboard_customize;
      }
      if (ModuleSubCategory == 5) {
        return Icons.rule_folder;
      }
      if (ModuleSubCategory == 35) {
        return Icons.task;
      }
      if (ModuleSubCategory == 36) {
        return Icons.rule_folder;
      }
    }
    if (selectedRule == 31) {
      if (ModuleSubCategory == 33) {
        return Icons.task;
      }
      if (ModuleSubCategory == 5) {
        return Icons.rule_folder;
      }
    }
    if (selectedRule == 33) {
      return Icons.calendar_today;
    }
  }

  String? ModuleSubCategoryTitle(int selectedRule, int ModuleSubCategory) {
    if (selectedRule == 14) {
      if (ModuleSubCategory == 23) {
        return AppLocalizations.of(context)!.boardPermission;
      }
      if (ModuleSubCategory == 5) {
        return AppLocalizations.of(context)!.boardDocumentPermission;
      }
      if (ModuleSubCategory == 35) {
        return AppLocalizations.of(context)!.boardTaskPermission;
      }
      if (ModuleSubCategory == 36) {
        return AppLocalizations.of(context)!.boardTaskDocumentPermission;
      }
    }
    if (selectedRule == 31) {
      if (ModuleSubCategory == 33) {
        return AppLocalizations.of(context)!.taskPermission;
      }
      if (ModuleSubCategory == 5) {
        return AppLocalizations.of(context)!.taskDocumentPermission;
      }
    }
    if (selectedRule == 33) {
      return AppLocalizations.of(context)!.calendarPermission;
    }
  }
}
