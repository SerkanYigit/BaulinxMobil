import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Clean_arch/features/collobration_page/detail_page/view/common_detail_page.dart';
import 'package:undede/Clean_arch/features/detail_page/view/widgets/custom_circle_avatar.dart';
import 'package:undede/Clean_arch/features/detail_page/view/widgets/horizantal_card.dart';
import 'package:undede/Clean_arch/features/detail_page/view/widgets/task_card.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerNotification.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Common/GetPermissionListResult.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:flutter/cupertino.dart';

/* 
class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return
    
     MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: primaryColor2,
        // const Color(0xFFF5F7FA),
        primaryColor: Colors.amberAccent,
        // const Color(0xFFCED5E0),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3A4B),
          ),
        ),
      ),
      home: HomePage2(),
    );
  }
}
 */
class HomePage2 extends StatefulWidget {
  List<CommonBoardListItem>? commonBoardListItem = [];
  CommonBoardListItem? commonBoardListItem2;
  CommonGroup? commonGroupSelected = CommonGroup();
  HomePage2({
    super.key,
    this.commonBoardListItem,
    this.commonGroupSelected,
    this.commonBoardListItem2,
  });

  @override
  State<HomePage2> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage2> {
  GetAllCommonsResult _commons = GetAllCommonsResult(hasError: false);

  ControllerDB _controllerDB = Get.put(ControllerDB());

  ControllerTodo _controllerTodo = ControllerTodo();

  ControllerNotification _controllerNotification = ControllerNotification();

  ControllerCommon _controllerCommon = Get.put(ControllerCommon());

  ScrollController _scrollController = ScrollController();
  final double _scrollAmount = 100; //
  ListOfCommonGroup? commonGroupList;
  int? selectedCommonGroupId;
  int? selectedCommonGroupIdForMove;
  List<CommonGroup> _commonGroup = <CommonGroup>[];
  String storedValue = '';
  String SearchKey = "";
  List<int> selectedLabelsId = [];
  List<int> selectedLabelIndexes = [];
  final List<DropdownMenuItem> cboUserList = [];
  List<int> selectedUserIds = [];
  List<int> selectedUserIndexes = [];
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
  bool isLoading = true;
  int selectedIndex = 0;
  // CommonBoardListItem commonBoardListItem = CommonBoardListItem();
  bool isFxIconStart = false;
  int page = 0;
  bool hasMore = false;
  //CommonGroup? commonGroup;

  void scrollToIndex(int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 200.0; // Card genişliği (örnek olarak)
    double targetScrollX =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      targetScrollX,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  changeGroup() async {
    setState(() {
      isLoading = true;
    });
    page = 0;
    await getAllCommans();
    await loadPage(page: 0);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      commonGroupList = await _controllerCommon.GetListCommonGroup(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
      ).then((value) async {
        // common gruplar çekildikten sonra önyüze yansıtır
        // _commonGroup = await value.listOfCommonGroup!;
        final prefs = await SharedPreferences.getInstance();
        storedValue = prefs.getString('searchDropdownValue') ?? '';
        if (storedValue != '') {
          // If there is a stored value, find the matching CommonGroup
          /*   commonGroup = _commonGroup.firstWhere(
              (group) => group.groupName == storedValue,
              orElse: () =>
                  _commonGroup.first // Fallback to the first group if not found
              ); */
          print('storedValue: $storedValue');
          setState(() {
            selectedCommonGroupId = widget.commonGroupSelected!.id;
            selectedCommonGroupIdForMove = widget.commonGroupSelected!.id;
          });
          await changeGroup();
          //  getAllCommans();
        }

        /*      await changeGroup();
        await GetCommonGroupBackground(
            0, _controllerDB.user.value!.result!.id!);
 */
        return value;
      }).catchError((e) {
        print("HATA : res GetGroupById error " + e.toString());
        return ListOfCommonGroup(hasError: true); //!eklendi
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadPage({int? page}) async {
    setState(() {
      isLoading = true;
    });

    await _controllerCommon.GetCommons(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id, //! 2715
      page: page, //! 0
      take: 0,
      groupId: selectedCommonGroupId, //! 119
      search: SearchKey, //! ""
      UserIds: selectedUserIds, //! []
      LabelList: selectedLabelsId, //! []
      TypeWho: selectedTypeWhoId, //! 0
      WhichSection: selectedWhichSectionId, //! 0
      IncludeElement: selectedIncludeElementId, //! 0
      ReminderInclude: selectedReminderIncludeId, //! 0
      StartDate: StartDate == null ? null : StartDate!.toIso8601String(),
      EndDate: EndDate == null ? null : EndDate!.toIso8601String(),
    ).then((value) async {
      hasMore = value.result!.totalPage! > page!;

      setState(() {
        _commons.result!.totalCount = value.result!.totalCount!;
        _commons.result!.totalPage = value.result!.totalPage!;
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

        await _controllerTodo.GetCommonTodos(
          _controllerDB.headers(),
          userId: _controllerDB.user.value!.result!.id,
          commonId: value.result!.commonBoardList![i].id!,
          search: value.result!.commonBoardList![i].isSearchResultTodo!
              ? SearchKey
              : null,
        ).then((todoResult) {
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

    _commons.result != null
        ? setState(() {
            isLoading = false;
          })
        : isLoading = true;

    for (var i = 0; i < _commons.result!.commonBoardList!.length; i++) {
      String todoSearchKey = _commons.result!.commonBoardList![i].title!
              .toLowerCase()
              .contains(SearchKey.toLowerCase())
          ? ""
          : SearchKey;
      print("*/*///*/*/*");
      print(_commons.result!.commonBoardList![i].id);
      print(_commons.result!.commonBoardList![i].isSearchResultTodo);
      print("*/*///*/*/*");

      await _controllerTodo.GetCommonTodos(_controllerDB.headers(),
              userId: _controllerDB.user.value!.result!.id!,
              commonId: _commons.result!.commonBoardList![i].id!,
              search: _commons.result!.commonBoardList![i].isSearchResultTodo!
                  ? SearchKey
                  : null)
          .then((todoResult) {
        print(
            'publicCommonBoardList:  todoResult: ${todoResult.listOfCommonTodo!.first.content}');
        _commons.result!.commonBoardList!
            .firstWhere((e) => e.id == _commons.result!.commonBoardList![i].id,
                orElse: () => throw Exception("Board not found"))
            .todos
            .clear();
        _commons.result!.commonBoardList!
            .firstWhere((e) => e.id == _commons.result!.commonBoardList![i].id)
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
                      .firstWhere((e) =>
                          e.id == _commons.result!.commonBoardList![i].id)
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
                    _commons.result!.commonBoardList![i].id!));
                _controllerTodo.update();
              }
            });

            print(_commons);
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

    for (var i = 0; i < _commons.result!.commonBoardList!.length; i++) {
      await _controllerCommon.GetCommonUserList(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        CommonId: _commons.result!.commonBoardList![i].id!,
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
                  (e) => e.id == _commons.result!.commonBoardList![i].id,
                  orElse: () =>
                      CommonBoardListItem() // Return empty CommonBoardListItem instead of null
                  )
              .users
              .addAll(commonUserList.result!);

          /* Kullanıcı boardun ownerı değil permission liste bak */
          if (_commons.result!.commonBoardList![i].userId !=
              _controllerDB.user.value!.result!.id!) {
            await _controllerCommon.GetPermissionList(_controllerDB.headers(),
                    DefinedRoleId:
                        _commons.result!.commonBoardList![i].definedRoleId)
                .then((permissionListResult) {
              if (!permissionListResult.hasError!) {
                _controllerCommon.MyPermissionsOnBoards.add(
                    new CommonPermission(permissionListResult.permissionList!,
                        _commons.result!.commonBoardList![i].id!));
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
  }

  final FixedExtentScrollController _cupertinoController =
      FixedExtentScrollController();
  int _selectedCupertinoIndex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: primaryColor2,
        // const Color(0xFFF5F7FA),
        primaryColor: Colors.amberAccent,
        // const Color(0xFFCED5E0),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3A4B),
          ),
        ),
      ),
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: Colors.white,
            // const Color(0xFFF5F7FA),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircleAvatar(
                backgroundColor: primaryBlackColor,
                // const Color.fromARGB(255, 109, 135, 178),

                radius: 28,
                child: IconButton(
                  // padding: EdgeInsets.all(22),
                  highlightColor: const Color.fromARGB(255, 237, 205, 26),
                  color: primaryYellowColor,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            /*    IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {},
            ), */
            actions: [
              //?  Yatay butonlar

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /*   widget.commonGroupSelected != null
                      ? Center(
                          child:
                              Text(widget.commonGroupSelected!.groupName ?? ""))
                      : Container(), */
                  Center(
                    child: SizedBox(
                        width: Get.width - 50,
                        height: 40,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : HorizontalCupertinoPicker(
                                items: [],
                                commonBoardListItem:
                                    _commons.result!.commonBoardList!,
                                controller: _cupertinoController,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedCupertinoIndex = index;

                                    scrollToIndex(index);
                                    selectedIndex = index;

                                    isFxIconStart = true;
                                  });
                                },
                              )
                        /*     
                          ListView.builder(
                              padding: EdgeInsets.only(left: 10),
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: _commons.result!.commonBoardList!
                                  .toList()
                                  .length,
                              itemBuilder: (context, index) {
                                var commonBoard =
                                    _commons.result!.commonBoardList!.toList();

                                return HorizontalCard(
                                  selectedCarouselIndex: selectedIndex,
                                  index: index,
                                  title: index == commonBoard.length
                                      ? AppLocalizations.of(context)!.invoice
                                      :
                                      //("$index" + "." +
                                      commonBoard[index].title!,
                                  //),
                                  backgroundColor: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      scrollToIndex(index);
                                      selectedIndex = index;

                                      isFxIconStart = true;
                                    });
                                  },
                                );
                              }),
                  
                   */

                        ),
                  ),
                ],
              ),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //? Yatay User AVATAR Widget

                      SizedBox(
                        height: 40,
                        child: isLoading == true
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                //   controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: _commons
                                    .result!
                                    .commonBoardList![selectedIndex]
                                    .users
                                    .length,
                                itemBuilder: (context, index) {
                                  var commonBoard = _commons
                                      .result!.commonBoardList!
                                      .toList();

                                  if (_commons
                                          .result!
                                          .commonBoardList![selectedIndex]
                                          .users
                                          .length >
                                      0) {
                                    print("user var");
                                  }

                                  return _commons
                                          .result!
                                          .commonBoardList![selectedIndex]
                                          .users
                                          .isEmpty
                                      ? const SizedBox()
                                      : CustomCircleAvatar(
                                          urlImage: _commons
                                                  .result!
                                                  .commonBoardList![
                                                      selectedIndex]
                                                  .users[index]
                                                  .photo ??
                                              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                                          title: "title $index",
                                          backgroundColor: Colors.white,
                                          onPressed: () {});
                                }),
                      ),
                      /*    _commons.result != null
                          ? HorizontalCupertinoPicker(
                              items: [],
                              commonBoardListItem:
                                  _commons.result!.commonBoardList!,
                              controller: _cupertinoController,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedCupertinoIndex = index;
                                });
                              },
                            )
                          : Container(), */
                      const SizedBox(height: 40),
                      Text(
                        'Seçilen: ${_selectedCupertinoIndex + 1}',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      const SizedBox(height: 20),
                      //? Dikey Card Widget
                      Expanded(
                        child: ListView(
                          children: [
                            TaskCard(
                              title: 'Allocate Case to User!',
                              userImage:
                                  'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                              backgroundColor: primaryColor2,
                              titleColor: const Color(0xFF2C3A4B),
                            ),
                            const SizedBox(height: 5),
                            TaskCard(
                              title: 'Acknowledge Case receipt to customer!',
                              userImage:
                                  'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                              backgroundColor: const Color(0xFFFFFFFF),
                              titleColor: const Color(0xFF2C3A4B),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //? Dikey Ikonlar
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
                child: _commons.result == null ? const SizedBox() : fxIcon(),
                //  fxIcon(),
              ),
            ],
          )),
    );
  }

  SizedBox fxIcon() {
    print(selectedIndex);

    List<CommonBoardListItem> publicCommonBoardList =
        _commons.result!.commonBoardList!;

    var commonBoardListItem = publicCommonBoardList[selectedIndex];

    return commonBoardListItem.todos.length == 0
        ? const SizedBox()
        : SizedBox(
            width: 50,
            child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                itemCount: commonBoardListItem.todos.length,
                itemBuilder: (context, index) {
                  var listCommonTodo = commonBoardListItem.todos;

                  return _buildCircularIcon(
                      listCommonTodo, index, commonBoardListItem);
                }),
          );
  }

  Widget _buildCircularIcon(
    //String icon
    List<CommonTodo> commonTodo,
    int index,
    CommonBoardListItem commonBoardListItemIcon,
  ) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: primaryBlackColor,
          // const Color.fromARGB(255, 109, 135, 178),

          radius: 28,
          child: IconButton(
            padding: EdgeInsets.all(11),
            focusColor: const Color.fromARGB(255, 204, 34, 34),
            hoverColor: const Color.fromARGB(255, 30, 182, 71),
            splashColor: const Color.fromARGB(255, 95, 24, 228),
            highlightColor: const Color.fromARGB(255, 237, 205, 26),

            color: Colors.black,
            icon: Image.network(commonTodo[index].iconPath! == ""
                ? 'https://files.baulinx.de/Content/Icons/employment.png'
                : commonTodo[index].iconPath!),

            // ImageIcon(AssetImage(icon)),
            //  image: AssetImage('assets/icons/plus.png')),
            //Icon(icon, color: Colors.black),

            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CommonDetailsPageNeu2(
                    todoId: commonBoardListItemIcon
                        .todos.first.id!, // Use  to assert non-null
                    commonBoardId: commonBoardListItemIcon
                        .todos[index].id!, // Use  to assert non-null
                    selectedTab: 0,
                    commonTodo: commonBoardListItemIcon.todos.first,
                    commonBoardTitle: commonBoardListItemIcon.title!,
                    cloudPerm: (_controllerTodo.hasFileManagerTodoPerm(
                                commonBoardListItemIcon.id!,
                                commonBoardListItemIcon.todos.first.id!)) ==
                            true ||
                        _controllerCommon.hasFileManagerCommonPerm(
                          commonBoardListItemIcon.id!,
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
          ),
        ),
        SizedBox(height: 6),
      ],
    );
  }
}

class HorizontalCupertinoPicker extends StatelessWidget {
  final List<String> items;
  final FixedExtentScrollController controller;
  final ValueChanged<int>? onSelectedItemChanged;
  List<CommonBoardListItem>? commonBoardListItem = [];

  HorizontalCupertinoPicker({
    Key? key,
    required this.items,
    required this.controller,
    this.onSelectedItemChanged,
    this.commonBoardListItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width, // Yatay genişlik
      height: 70, // Yükseklik
      child: RotatedBox(
        quarterTurns: -1, // 90 derece sola döndür (yatay)
        child: CupertinoPicker(
          useMagnifier: true,
          magnification: 1.2,
          scrollController: controller,
          itemExtent: 130, // Öğe yüksekliği (döndürüldüğü için genişlik olur)
          onSelectedItemChanged: onSelectedItemChanged,
          children:

              //  items.map((item)
              commonBoardListItem!.map((item) {
            return RotatedBox(
              quarterTurns: 1, // Metni düzeltmek için 90 derece sağa döndür
              child: Center(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  item.title!,
                  style: const TextStyle(
                    fontSize: 20,
                    color: CupertinoColors.label, // iOS tarzı renk
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
