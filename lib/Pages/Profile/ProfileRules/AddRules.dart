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
import 'package:undede/Custom/showToast.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Common/GetDefinedRoleListResult.dart';
import 'package:undede/model/Common/GetPermissionListByCategoryIdResult.dart';
import 'package:undede/model/Common/GetPermissionListResult.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

class AddRules extends StatefulWidget {
  final int? Id;
  final String? Name;
  final int? ModuleType;
  const AddRules({Key? key, this.Id, this.Name, this.ModuleType})
      : super(key: key);

  @override
  _AddRulesState createState() => _AddRulesState();
}

class _AddRulesState extends State<AddRules> with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  GetDefinedRoleListResult _getDefinedRoleListResult =
      GetDefinedRoleListResult(hasError: false);
  GetPermissionListByCategoryIdResult _categoryIdResult =
      GetPermissionListByCategoryIdResult(hasError: false);

  bool loading = true;
  List<bool> listExpand = <bool>[];
  final List<DropdownMenuItem> dmiRules = [];
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getDefinedRoleList();
      await GetPermissionList(widget.Id!, widget.ModuleType!);
      _textEditingController = TextEditingController(text: widget.Name);
      SelectedRule = widget.ModuleType!;

      setState(() {});
    });
  }

//! void kaldirildi
  getDefinedRoleList() async {
    _results = {
      AppLocalizations.of(context)!.board: 14,
      AppLocalizations.of(context)!.task: 31,
      AppLocalizations.of(context)!.calendar: 33,
    };
    for (var entry in _results.entries) {
      dmiRules.add(DropdownMenuItem(
        child: Text(entry.key),
        value: entry.value,
      ));
      print(entry.key);
      print(entry.value);
    }
  }

  GetPermissionListByCategoryId(int ModuleCategoryId) async {
    await _controllerCommon.GetPermissionListByCategoryId(
            _controllerDB.headers(),
            ModuleCategoryId: ModuleCategoryId,
            Language: AppLocalizations.of(context)!.date)
        .then((value) {
      _categoryIdResult = value;
    });
    setState(() {});
  }

  GetPermissionList(int DefinedRoleId, int ModuleCategoryId) async {
    await _controllerCommon.GetPermissionListByCategoryId(
            _controllerDB.headers(),
            ModuleCategoryId: ModuleCategoryId,
            Language: AppLocalizations.of(context)!.date)
        .then((value) {
      _categoryIdResult = value;
    });
    await _controllerCommon.GetPermissionList(_controllerDB.headers(),
            DefinedRoleId: DefinedRoleId)
        .then((value) {
      for (int i = 0; i < value.permissionList!.length; i++) {
        PermissionIdList.add(_categoryIdResult.result!
            .firstWhere((element) =>
                element.permissionTypeId ==
                    value.permissionList![i].permissionTypeId &&
                element.moduleSubCategoryId ==
                    value.permissionList![i].moduleSubCategoryId)
            .id!);
      }
    });
  }

  InsertOrUpdateDefinedRole(
      int Id, String Name, int ModuleType, List<int> PermissionIdList) async {
    await _controllerCommon.InsertOrUpdateDefinedRole(_controllerDB.headers(),
        Id: Id,
        Name: Name,
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: 20,
        ModuleType: ModuleType,
        PermissionIdList: PermissionIdList);
  }

  int SelectedRule = 14;
  var _results = {};
  List<int> PermissionIdList = [];
  bool selectAll = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.addRule,
        showNotification: false,
      ),
      body: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            child: Column(children: [
              Expanded(
                child: Container(
                  width: Get.width,
                  color: Get.theme.scaffoldBackgroundColor,
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Get.theme.scaffoldBackgroundColor,
                    ),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                                height: 45,
                                child: CustomTextField(
                                  controller: _textEditingController,
                                  hint: AppLocalizations.of(context)!.title,
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                                height: 45,
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          boxShadow: standartCardShadow(),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 11),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: Get.width,
                                              height: 23,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  menuMaxHeight: 350,
                                                  value: SelectedRule,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontFamily: 'TTNorms',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  icon: Icon(
                                                    Icons.expand_more,
                                                    color: Colors.black,
                                                  ),
                                                  items: this.dmiRules,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      SelectedRule = value;
                                                      GetPermissionListByCategoryId(
                                                          value);
                                                      PermissionIdList.clear();
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
                            Divider(
                              color: Colors.black,
                              thickness: 0.3,
                            ),
                            Container(
                              height: _categoryIdResult.result!.length == null
                                  ? 0.0
                                  : 53.0 * _categoryIdResult.result!.length,
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _categoryIdResult.result!.length == null
                                          ? 0
                                          : _categoryIdResult.result!.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 15),
                                      child: Column(
                                        children: [
                                          index == 0
                                              ? TitleWidget(index)
                                              : _categoryIdResult.result![index]
                                                          .moduleSubCategoryId !=
                                                      _categoryIdResult
                                                          .result![index - 1]
                                                          .moduleSubCategoryId
                                                  ? TitleWidget(index)
                                                  : Container(),
                                          Row(
                                            children: [
                                              Text(
                                                _categoryIdResult.result![index]
                                                            .permissionTypeTranslate ==
                                                        null
                                                    ? ""
                                                    : _categoryIdResult
                                                        .result![index]
                                                        .permissionTypeTranslate!,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                onTap: () {
                                                  if (PermissionIdList.any(
                                                      (element) =>
                                                          element ==
                                                          _categoryIdResult
                                                              .result![index]
                                                              .id)) {
                                                    PermissionIdList.remove(
                                                        _categoryIdResult
                                                            .result![index].id);
                                                    setState(() {});
                                                  } else {
                                                    PermissionIdList.add(
                                                        _categoryIdResult
                                                            .result![index]
                                                            .id!);
                                                    setState(() {});
                                                  }
                                                },
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: PermissionIdList.any(
                                                          (element) =>
                                                              element ==
                                                              _categoryIdResult
                                                                  .result![
                                                                      index]
                                                                  .id)
                                                      ? Icon(
                                                          Icons.check,
                                                          color: Get.theme
                                                              .secondaryHeaderColor,
                                                        )
                                                      : Container(),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(
                              height: 100,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                heroTag: "addRules",
                onPressed: () async {
                  if (_textEditingController.text.isBlank!) {
                    showErrorToast(AppLocalizations.of(context)!.cannotbeblank);
                    return;
                  }
                  await InsertOrUpdateDefinedRole(
                      widget.Id != null ? widget.Id! : 0,
                      _textEditingController.text,
                      SelectedRule,
                      PermissionIdList);
                  _controllerCommon.GetDefinedRoleList(_controllerDB.headers());

                  Navigator.pop(context);
                },
                backgroundColor: Get.theme.colorScheme.primary,
                child: Icon(Icons.save),
              ))
        ],
      ),
    );
  }

  Widget TitleWidget(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          index == 0
              ? Container()
              : Divider(
                  thickness: 0.3,
                  color: Colors.grey,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                ModuleSubCategoryIcon(
                    _categoryIdResult.result![index].moduleCategoryId!,
                    _categoryIdResult.result![index].moduleSubCategoryId!),
                color: Get.theme.secondaryHeaderColor,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                ModuleSubCategoryTitle(
                    _categoryIdResult.result![index].moduleCategoryId!,
                    _categoryIdResult.result![index].moduleSubCategoryId!)!,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.secondaryHeaderColor),
              ),
              Spacer(),
              index == 0
                  ? GestureDetector(
                      onTap: () {
                        if (selectAll) {
                          for (int i = 0;
                              i < _categoryIdResult.result!.length;
                              i++) {
                            PermissionIdList.add(
                                _categoryIdResult.result![i].id!);
                          }
                          selectAll = !selectAll;
                          setState(() {});
                          print("add");
                        } else if (!selectAll) {
                          for (int i = 0;
                              i < _categoryIdResult.result!.length;
                              i++) {
                            PermissionIdList.remove(
                                _categoryIdResult.result![i].id!);
                          }
                          selectAll = !selectAll;
                          setState(() {});
                          print("remove");
                        }
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        child: Icon(Icons.select_all),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)),
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
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
    return null;
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
    return null;
  }
}
