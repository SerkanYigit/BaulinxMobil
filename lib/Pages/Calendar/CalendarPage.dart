import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showModalCalendarUser.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Calendar/AddCalendarResult.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';
import 'event-calender.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage();

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  List<int> selectedItems = [];
  final List<DropdownMenuItem> items = [];
  final String loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor";
  String wordPair = "";
  String _calendar = "Calendar";
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  GetCalendarByUserIdResult _getCalendarByUserIdResult =
      GetCalendarByUserIdResult(hasError: false);
  AddCalendarResult _addCalendarResult = AddCalendarResult();
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  List<String> a = ["a", "ab"];
  bool isLoading = false;
  bool isLoading2 = false;
  final List<DropdownMenuItem> cboUsersList = [];
  List<int> selectedUserIndexes = [];
  List<int> selectedUsers = [];
  GetUserListResult _getUserListResult = GetUserListResult(hasError: false);

  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());

  Color asd = Colors.black;
// Selected Calendar
  int? Id;
  String? Name;
  bool IsTodo = true;
  bool ShowOnlyMy = true;
  //new Calendar
  @override
  void initState() {
    super.initState();
    getCalenderByUserId();
  }

  getUserList(List<int> alreadyInside) async {}
  getCalenderDetail(int Year, int Month, int CalendarId, bool IsTodo) async {
    setState(() {
      selectedItems.clear();
      items.clear();
      cboUsersList.clear();
      selectedUserIndexes.clear();
    });
    try {
      await _controllerCalendar.GetCalendarDetail(_controllerDB.headers(),
              UserId: _controllerDB.user.value!.result!.id,
              CalendarId: CalendarId,
              Year: Year,
              Month: Month,
              IsTodo: IsTodo)
          .then((value) async {
        await _controllerChatNew.GetUserList(
                _controllerDB.headers(), _controllerDB.user.value!.result!.id!)
            .then((value) {
          _getUserListResult = value;

          List.generate(value.result!.length, (index) {
            if (value.result![index].isGroup == 0)
              cboUsersList.add(DropdownMenuItem(
                  child: Row(
                    children: [
                      Text(value.result![index].fullName!),
                      SizedBox(
                        width: 5,
                      ),
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(value.result![index].photo!),
                        radius: 8,
                      )
                    ],
                  ),
                  key: Key(value.result![index].id.toString()),
                  value: value.result![index].fullName! +
                      "+" +
                      value.result![index].photo!));
          });
        });
        for (int i = 0; i < value.result!.userCalendarUsers!.length; i++) {
          print(value.result!.userCalendarUsers![i].id.toString());
          for (int k = 0; k < cboUsersList.length; k++) {
            print(cboUsersList[k].key.toString());
            if (cboUsersList[k]
                .key
                .toString()
                .contains(value.result!.userCalendarUsers![i].id.toString())) {
              selectedUserIndexes.add(k);
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        isLoading2 = true;
      });
    }

    setState(() {
      isLoading2 = true;
    });
  }

  getCalenderByUserId() async {
    await _controllerCalendar.GetCalendarByUserId(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id!)
        .then((value) => {_getCalendarByUserIdResult = value});
    setState(() {
      a = List.generate(_getCalendarByUserIdResult.result!.length,
          (index) => _getCalendarByUserIdResult.result![index].title!.trim());
      _calendar = _getCalendarByUserIdResult.result![0].title!.trim();
      Id = _getCalendarByUserIdResult.result![0].id!;
      Name = _getCalendarByUserIdResult.result![0].title;

      isLoading = true;
      getCalenderDetail(
          int.parse(DateFormat('yyyy').format(DateTime.now())),
          int.parse(DateFormat('M').format(DateTime.now())),
          _getCalendarByUserIdResult.result![0].id!,
          true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerCalendar>(builder: (c) {
      if (c.refreshCalendar) {
        getCalenderByUserId();
        c.refreshCalendar = false;
        c.update();
      }
      return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: AppLocalizations.of(context)!.calendar,
            isHomePage: true,
          ),
          body: isLoading && isLoading2
              ? SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: Get.height,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                color: Get.theme.secondaryHeaderColor,
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Get.theme.scaffoldBackgroundColor,
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 5),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    height: 45,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(45),
                                                        boxShadow:
                                                            standartCardShadow()),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: DropdownButton(
                                                        isExpanded: true,
                                                        menuMaxHeight: 350,
                                                        value: _calendar,
                                                        style: Get
                                                            .theme
                                                            .inputDecorationTheme
                                                            .hintStyle,
                                                        icon: Icon(
                                                          Icons.expand_more,
                                                          color: Get
                                                              .theme
                                                              .colorScheme
                                                              .surface,
                                                        ),
                                                        items:
                                                            a.map((String val) {
                                                          return DropdownMenuItem(
                                                            value: val,
                                                            child: Text(
                                                              val,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _calendar = value!;
                                                            int i = 0;
                                                            for (i;
                                                                i <
                                                                    _getCalendarByUserIdResult
                                                                        .result!
                                                                        .length;
                                                                i++)
                                                              if (_getCalendarByUserIdResult
                                                                      .result![
                                                                          i]
                                                                      .title ==
                                                                  value) {
                                                                Id = _getCalendarByUserIdResult
                                                                    .result![i]
                                                                    .id!;
                                                                Name =
                                                                    _getCalendarByUserIdResult
                                                                        .result![
                                                                            i]
                                                                        .title;
                                                                setState(() {});
                                                                getCalenderDetail(
                                                                    int.parse(DateFormat(
                                                                            'yyyy')
                                                                        .format(DateTime
                                                                            .now())),
                                                                    int.parse(DateFormat(
                                                                            'M')
                                                                        .format(
                                                                            DateTime.now())),
                                                                    Id!,
                                                                    true);
                                                                _controllerCalendar
                                                                        .refreshCalendarDetail =
                                                                    true;
                                                                _controllerCalendar
                                                                    .update();
                                                              }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                cboUsersList.length == 0
                                                    ? Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .6,
                                                        height: 45,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            18.0),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .members,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .expand_more,
                                                                  size: 31,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .6,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            var InviteUsersCommonBoardType =
                                                                jsonDecode(await showModalCalendarUsers(
                                                                    context,
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .calendarUsers,
                                                                    '',
                                                                    0,
                                                                    selectedUserIndexes));
                                                            if (InviteUsersCommonBoardType !=
                                                                null) {
                                                              _controllerCalendar.AddUserToCalendar(
                                                                  _controllerDB
                                                                      .headers(),
                                                                  UserId:
                                                                      _controllerDB
                                                                          .user
                                                                          .value!
                                                                          .result!
                                                                          .id!,
                                                                  CalendarId:
                                                                      Id!,
                                                                  RoleId: InviteUsersCommonBoardType[
                                                                      "RoleId"],
                                                                  TargetUserIdList:
                                                                      InviteUsersCommonBoardType[
                                                                              "TargetUserIdList"]
                                                                          .cast<
                                                                              int>());
                                                            }
                                                          },
                                                          child:
                                                              SearchableDropdown
                                                                  .multiple(
                                                            readOnly: true,
                                                            items: cboUsersList,
                                                            selectedItems:
                                                                selectedUserIndexes,
                                                            hint: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .members),
                                                            ),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedUsers
                                                                    .clear();
                                                                selectedUserIndexes =
                                                                    value;
                                                                _getUserListResult
                                                                    .result!
                                                                    .asMap()
                                                                    .forEach((index,
                                                                        value) {
                                                                  selectedUserIndexes
                                                                      .forEach(
                                                                          (selectedUserIndex) {
                                                                    if (selectedUserIndex ==
                                                                        index) {
                                                                      selectedUsers
                                                                          .add(value
                                                                              .id!);
                                                                    }
                                                                  });
                                                                });
                                                                print(
                                                                    selectedUserIndexes);
                                                                print("selectedUsers:" +
                                                                    selectedUsers
                                                                        .toString());
                                                              });
                                                            },
                                                            displayItem: (item,
                                                                selected) {
                                                              return (Row(
                                                                  children: [
                                                                    selected
                                                                        ? Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.green,
                                                                          )
                                                                        : Icon(
                                                                            Icons.check_box_outline_blank,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                    SizedBox(
                                                                        width:
                                                                            7),
                                                                    Expanded(
                                                                      child:
                                                                          item,
                                                                    ),
                                                                  ]));
                                                            },
                                                            selectedValueWidgetFn:
                                                                (item) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xFFdedede),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30)),
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            5),
                                                                child:
                                                                    (CircleAvatar(
                                                                  radius: 15,
                                                                  backgroundImage:
                                                                      NetworkImage(item
                                                                          .toString()
                                                                          .split(
                                                                              "+")
                                                                          .last),
                                                                )),
                                                              );
                                                            },
                                                            doneButton:
                                                                (selectedItemsDone,
                                                                    doneContext) {
                                                              return (ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      doneContext);
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .save),
                                                              ));
                                                            },
                                                            closeButton: null,
                                                            style: Get
                                                                .theme
                                                                .inputDecorationTheme
                                                                .hintStyle,
                                                            searchFn:
                                                                (String keyword,
                                                                    items) {
                                                              List<int> ret =
                                                                  <int>[];
                                                              if (items !=
                                                                      null &&
                                                                  keyword
                                                                      .isNotEmpty) {
                                                                keyword
                                                                    .split(" ")
                                                                    .forEach(
                                                                        (k) {
                                                                  int i = 0;
                                                                  items.forEach(
                                                                      (item) {
                                                                    if (k.isNotEmpty &&
                                                                        (item
                                                                            .value
                                                                            .toString()
                                                                            .split("+")
                                                                            .first
                                                                            .toLowerCase()
                                                                            .contains(k.toLowerCase()))) {
                                                                      ret.add(
                                                                          i);
                                                                    }
                                                                    i++;
                                                                  });
                                                                });
                                                              }
                                                              if (keyword
                                                                  .isEmpty) {
                                                                ret = Iterable<
                                                                            int>.generate(
                                                                        items
                                                                            .length)
                                                                    .toList();
                                                              }
                                                              return (ret);
                                                            },
                                                            clearIcon: Icon(
                                                              Icons.expand_more,
                                                              size: 31,
                                                            ),
                                                            icon: Icon(null),
                                                            underline:
                                                                Container(
                                                              height: 0.0,
                                                              decoration: BoxDecoration(
                                                                  border: Border(
                                                                      bottom: BorderSide(
                                                                          color: Colors
                                                                              .teal,
                                                                          width:
                                                                              0.0))),
                                                            ),
                                                            iconDisabledColor:
                                                                Colors.grey,
                                                            iconEnabledColor:
                                                                Get
                                                                    .theme
                                                                    .colorScheme
                                                                    .surface,
                                                            isExpanded: true,
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            // Row(
                                            //   children: [
                                            //     SizedBox(
                                            //       width: 20,
                                            //     ),
                                            //     Row(
                                            //       children: [
                                            //         Switch(
                                            //           value: IsTodo,
                                            //           activeColor: Get
                                            //               .theme.primaryColor,
                                            //           onChanged: (bool value) {
                                            //             print(IsTodo);
                                            //             setState(() {
                                            //               IsTodo = value;
                                            //             });
                                            //             _controllerCalendar
                                            //                     .refreshCalendarDetail =
                                            //                 true;
                                            //             _controllerCalendar
                                            //                 .update();
                                            //           },
                                            //         ),
                                            //         SizedBox(
                                            //           width: 15,
                                            //         ),
                                            //         Text(AppLocalizations.of(
                                            //                 context)
                                            //             .showTask)
                                            //       ],
                                            //     ),
                                            //     Spacer(),
                                            //     Row(
                                            //       children: [
                                            //         Switch(
                                            //           value: ShowOnlyMy,
                                            //           activeColor: Get
                                            //               .theme.primaryColor,
                                            //           onChanged: (bool value) {
                                            //             print(IsTodo);
                                            //             setState(() {
                                            //               ShowOnlyMy = value;
                                            //             });
                                            //             _controllerCalendar
                                            //                     .refreshCalendarDetail =
                                            //                 true;
                                            //             _controllerCalendar
                                            //                 .update();
                                            //           },
                                            //         ),
                                            //         SizedBox(
                                            //           width: 15,
                                            //         ),
                                            //         Text(AppLocalizations.of(
                                            //                 context)
                                            //             .showOnlyMy)
                                            //       ],
                                            //     ),
                                            //     SizedBox(
                                            //       width: 20,
                                            //     ),
                                            //   ],
                                            // ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              child: EventCalendar(
                                                Id: Id!,
                                                Name: Name!,
                                                IsTodo: IsTodo,
                                                ShowOnlyMy: ShowOnlyMy,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 100,
                                            )
                                          ],
                                        ))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : CustomLoadingCircle());
    });
  }
}
