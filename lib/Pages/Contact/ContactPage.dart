import 'dart:math';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Pages/Contact/ContactCRMPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Common/CareateOrJoinMettingResult.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/User/GetAllActiveUserResult.dart';
import 'package:undede/widgets/CallWeSlide.dart';
import 'package:undede/model/Contact/AdminCustomer.dart' as a;
import 'package:undede/model/User/GetAllActiveUserResult.dart' as c;
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

class ContactPage extends StatefulWidget {
  ContactPage();

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<bool> listExpand = <bool>[];
  List<AnimationController> _controller = <AnimationController>[];

  UserDB userDB = new UserDB();
  AdminCustomerResult adminCustomer = new AdminCustomerResult(hasError: false);
  List<a.Customer> adminCustomerSearch = [];
  TextEditingController _textEditingController = TextEditingController();
  List<Tab> tabs = <Tab>[];
  TabController? _tabController;
  int initialIndex = 0;

  // İNVİTE USER PARAMS
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerUser _controllerUser = ControllerUser();
  bool loading3 = true;
  GetAllActiveUserResult _getAllActiveUserResult =
      GetAllActiveUserResult(hasError: false);
  List<c.Result> SelectedUsers = [];
  TextEditingController _searchAllActive = TextEditingController();
  List<c.Result> _getAllActiveUserSearch = [];
  List<int> SelectedUsersId = [];
  TextEditingController _commonInvite = TextEditingController();
  TextEditingController _commonInviteMail = TextEditingController();

  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetAllActiveUser();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userDB.GetAdminCustomer(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id,
        administrationId: _controllerDB.user.value!.result!.administrationId!,
      ).then((value) {
        adminCustomer = value;
      });

      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    tabs = <Tab>[
      new Tab(text: AppLocalizations.of(context)!.contact),
      new Tab(text: AppLocalizations.of(context)!.invite),
    ];
    _tabController = new TabController(
        vsync: this, length: tabs.length, initialIndex: initialIndex);

    super.didChangeDependencies();
  }

  CommonDB commonDB = new CommonDB();
  CareateOrJoinMettingResult _careateOrJoinMettingResult =
      CareateOrJoinMettingResult(hasError: false);
  List<int> targetUserIdList = [];

  Future<void> CareateOrJoinMetting(List<int> TargetUserIdList) async {
    await commonDB.CareateOrJoinMetting(_controllerDB.headers(),
            OwnerId: _controllerDB.user.value!.result!.id!,
            UserId: _controllerDB.user.value!.result!.id!,
            TargetUserIdList: TargetUserIdList,
            ModuleType: 20)
        .then((value) {
      setState(() {
        _careateOrJoinMettingResult = value;
      });
    });
  }

  CommonInvite(List<int> TargetUserIdList, String CommentText, String Email,
      String Language) {
    _controllerCommon.CommonInvite(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            TargetUserIdList: TargetUserIdList,
            CommentText: CommentText,
            Email: Email,
            Language: Language)
        .then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.invitationSent,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  GetAllActiveUser() async {
    await _controllerUser.GetAllActiveUser(
      _controllerDB.headers(),
    ).then((value) {
      _getAllActiveUserResult = value;
    });
    setState(() {
      loading3 = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: AppLocalizations.of(context)!.contact),
        body: loading3
            ? Text("contactpage") //CustomLoadingCircle()
            : Container(
                width: Get.width,
                height: Get.height,
                child: Column(children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: TabBar(
                          onTap: (i) {
                            initialIndex = i;
                          },
                          isScrollable: true,
                          unselectedLabelColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Get.theme.secondaryHeaderColor,
                          physics: NeverScrollableScrollPhysics(),
                          indicator: new BubbleTabIndicator(
                            indicatorHeight: 35.0,
                            indicatorColor: Colors.white,
                            tabBarIndicatorSize: TabBarIndicatorSize.label,
                            // Other flags
                            //  indicatorRadius: 1,
                            //insets: EdgeInsets.all(1),
                            padding: EdgeInsets.all(1),
                          ),
                          tabs: tabs,
                          controller: _tabController,
                        ),
                      ),
                      Spacer()
                    ],
                  ),
                  Expanded(
                    child: Container(
                      width: Get.width,
                      child: Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F7F7),
                        ),
                        child: TabBarView(
                            controller: _tabController,
                            children: [Contact(context), buildInvite(context)]),
                      ),
                    ),
                  ),
                ]),
              ));
  }

  SingleChildScrollView Contact(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                  boxShadow: standartCardShadow(),
                  borderRadius: BorderRadius.circular(45)),
              child: CustomTextField(
                prefixIcon: Icon(Icons.search),
                hint: AppLocalizations.of(context)!.search,
                controller: _textEditingController,
                onChanged: (c) {
                  setState(() {
                    adminCustomerSearch.clear();
                  });

                  for (int i = 0; i < adminCustomer.result!.length; i++) {
                    if (adminCustomer.result![i].title!
                        .toLowerCase()
                        .contains(c.toString().camelCase!)) {
                      adminCustomerSearch.add(adminCustomer.result![i]);
                    }
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          /*GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: (Get.width / 2 - 14),
                                  childAspectRatio: 3 / 3,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14),
                          itemCount: 6,
                          itemBuilder: (BuildContext ctx, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                decoration: BoxDecoration(
                                    boxShadow: standartCardShadow(),
                                    color: Color(0xFFd2e2e2)),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(7),
                                        child: Column(children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.amberAccent,
                                                  borderRadius: BorderRadius.circular(30)
                                                ),
                                              ),
                                              Icon(Icons.more_horiz),
                                            ],
                                          ),
                                          SizedBox(height: 5,),
                                          Center(
                                            child: Column(
                                              children: [
                                                Text("Ertuğrul Karababa", style: TextStyle(fontWeight: FontWeight.w500),),
                                                SizedBox(height: 3,),
                                                Text("+90 553 456 84 86", style: TextStyle(fontSize: 11),),
                                                Text("ek@gmail.com", style: TextStyle(fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    Container(
                                      width: Get.width,
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 9),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFe3d5a4),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(Icons.add,
                                              size: 19,
                                              color: Get.theme
                                                  .secondaryHeaderColor),
                                          Icon(Icons.emoji_people,
                                              size: 19,
                                              color: Get.theme
                                                  .secondaryHeaderColor),
                                          Icon(Icons.group_add_rounded,
                                              size: 19,
                                              color: Get.theme
                                                  .secondaryHeaderColor),
                                          Icon(
                                              Icons
                                                  .arrow_forward_ios_outlined,
                                              size: 17,
                                              color: Get.theme
                                                  .secondaryHeaderColor),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),*/
          Visibility(
            visible: !_textEditingController.text.isBlank!,
            child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: adminCustomerSearch != null
                    ? adminCustomerSearch.length
                    : 0,
                itemBuilder: (ctx, index) {
                  listExpand.add(false);

                  _controller.add(new AnimationController(
                    vsync: this,
                    duration: Duration(milliseconds: 300),
                    upperBound: 0.5,
                  ));

                  return buildContactCardSearch(index, context);
                }),
          ),
          Visibility(
            visible: _textEditingController.text.isBlank!,
            child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: adminCustomer.result != null
                    ? adminCustomer.result!.length
                    : 0,
                itemBuilder: (ctx, index) {
                  listExpand.add(false);

                  _controller.add(new AnimationController(
                    vsync: this,
                    duration: Duration(milliseconds: 300),
                    upperBound: 0.5,
                  ));

                  return buildContactCard(index, context);
                }),
          ),
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  Widget buildInvite(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 45,
                        margin: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                            boxShadow: standartCardShadow(),
                            borderRadius: BorderRadius.circular(45)),
                        child: CustomTextField(
                          controller: _searchAllActive,
                          prefixIcon: Icon(Icons.search),
                          hint: AppLocalizations.of(context)!.search,
                          onChanged: (asd) {
                            setState(() {
                              _getAllActiveUserSearch.clear();
                            });

                            for (int i = 0;
                                i < _getAllActiveUserResult.result!.length;
                                i++) {
                              if (_getAllActiveUserResult
                                  .result![i].userFullName!
                                  .toLowerCase()
                                  .contains(asd.toString().camelCase!)) {
                                _getAllActiveUserSearch
                                    .add(_getAllActiveUserResult.result![i]);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15, right: 20),
                    child: PopupMenuButton(
                        onSelected: (i) {
                          _onAlertExternalIntive(context);
                        },
                        child: Center(
                            child: Icon(
                          Icons.more_vert,
                          color: Colors.black,
                          size: 27,
                        )),
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text(AppLocalizations.of(context)!
                                    .externalInvite),
                                value: 1,
                              ),
                            ]),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Visibility(
                visible: !_searchAllActive.text.isBlank!,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _getAllActiveUserSearch.length,
                    itemBuilder: (ctx, i) {
                      return InkWell(
                        onTap: () {
                          if (_controllerChatNew.UserListRx!.value!.result!.any(
                              (a) => a.id == _getAllActiveUserSearch[i].id)) {
                            return;
                          }
                          if (SelectedUsers.any((element) =>
                              element.id == _getAllActiveUserSearch[i].id)) {
                            SelectedUsersId.remove(
                                _getAllActiveUserSearch[i].id);
                            SelectedUsers.removeWhere((element) =>
                                element.id == _getAllActiveUserSearch[i].id);

                            setState(() {});
                          } else {
                            SelectedUsersId.add(_getAllActiveUserSearch[i].id!);
                            SelectedUsers.add(_getAllActiveUserSearch[i]);
                            setState(() {});
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              color: SelectedUsers.any((element) =>
                                      element.id ==
                                      _getAllActiveUserSearch[i].id)
                                  ? Get.theme.secondaryHeaderColor
                                      .withOpacity(0.2)
                                  : Colors.transparent,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Image.network(
                                              _getAllActiveUserSearch[i].photo!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SelectedUsers.any((element) =>
                                                element.id ==
                                                _getAllActiveUserSearch[i].id)
                                            ? Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  margin:
                                                      EdgeInsets.only(top: 12),
                                                  decoration: BoxDecoration(
                                                      color: Get
                                                          .theme.primaryColor,
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        _controllerChatNew
                                                .UserListRx!.value!.result!
                                                .any((a) =>
                                                    a.id ==
                                                    _getAllActiveUserResult
                                                        .result![i].id)
                                            ? Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  margin:
                                                      EdgeInsets.only(top: 12),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              _getAllActiveUserSearch[i]
                                                  .userFullName!,
                                              style: TextStyle(
                                                  fontFamily: 'Avenir-Book',
                                                  fontSize: 17.0,
                                                  letterSpacing:
                                                      -0.41000000190734864,
                                                  height: 1.29,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              Visibility(
                visible: _searchAllActive.text.isBlank!,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _getAllActiveUserResult.result!.length,
                    itemBuilder: (ctx, i) {
                      return InkWell(
                        onTap: () {
                          if (_controllerChatNew.UserListRx!.value!.result!.any(
                              (a) =>
                                  a.id ==
                                  _getAllActiveUserResult.result![i].id)) {
                            return;
                          }
                          if (SelectedUsers.any((element) =>
                              element.id ==
                              _getAllActiveUserResult.result![i].id!)) {
                            SelectedUsersId.remove(
                                _getAllActiveUserResult.result![i].id!);
                            SelectedUsers.removeWhere((element) =>
                                element.id ==
                                _getAllActiveUserResult.result![i].id!);

                            setState(() {});
                          } else {
                            SelectedUsersId.add(
                                _getAllActiveUserResult.result![i].id!);
                            SelectedUsers.add(
                                _getAllActiveUserResult.result![i]);
                            setState(() {});
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              color: SelectedUsers.any((element) =>
                                      element.id ==
                                      _getAllActiveUserResult.result![i].id!)
                                  ? Get.theme.secondaryHeaderColor
                                      .withOpacity(0.2)
                                  : Colors.transparent,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Image.network(
                                              _getAllActiveUserResult
                                                  .result![i].photo!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SelectedUsers.any((element) =>
                                                element.id ==
                                                _getAllActiveUserResult
                                                    .result![i].id!)
                                            ? Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  margin:
                                                      EdgeInsets.only(top: 12),
                                                  decoration: BoxDecoration(
                                                      color: Get
                                                          .theme.primaryColor,
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        _controllerChatNew
                                                .UserListRx!.value!.result!
                                                .any((a) =>
                                                    a.id ==
                                                    _getAllActiveUserResult
                                                        .result![i].id!)
                                            ? Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  margin:
                                                      EdgeInsets.only(top: 12),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              _getAllActiveUserResult
                                                  .result![i].userFullName!,
                                              style: TextStyle(
                                                  fontFamily: 'Avenir-Book',
                                                  fontSize: 17.0,
                                                  letterSpacing:
                                                      -0.41000000190734864,
                                                  height: 1.29,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        Positioned(
            bottom: 100,
            right: 5,
            child: FloatingActionButton(
              heroTag: "contactPageAdd",
              onPressed: () {
                if (SelectedUsers.isNotEmpty) {
                  _onAlertWithCustomContentPressed2(context);
                } else {
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!
                          .atleast1personmustbeselected,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      //backgroundColor: Colors.red,
                      //textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ))
      ],
    );
  }

  Widget buildContactCardSearch(int index, BuildContext context) {
    Customer c = adminCustomerSearch[index];

    return Material(
      color: Color(0xFFF0F7F7),
      child: InkWell(
        onTap: () {
          setState(() {
            if (listExpand[index]) {
              _controller[index]..reverse(from: 0.5);
            } else {
              _controller[index]..forward(from: 0.0);
            }
            listExpand[index] = !listExpand[index];
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                //boxShadow: standartCardShadow(),
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      boxShadow: standartCardShadow(),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.network(
                                      c.photo != null
                                          ? c.photo!
                                          : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      c.title ?? "",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      c.customerAdminName! +
                                          " " +
                                          c.customerAdminSurname!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    c.phone != null
                                        ? Text(
                                            c.phone!,
                                            style: TextStyle(fontSize: 11),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ],
                            ),
                            RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_controller[index]),
                              child: Icon(Icons.expand_more),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: listExpand[index] ? 40 : 0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: listExpand[index] ? 3 : 0),
              decoration: BoxDecoration(
                  //color: Color(0xFFe3d5a4),
                  ),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    contactMoreIcon(() async {
                      targetUserIdList.add(c.customerAdminId!);
                      await CareateOrJoinMetting(targetUserIdList);
                      await Permission.camera.request();
                      await Permission.microphone.request();
                      print(_careateOrJoinMettingResult.result!.meetingUrl!);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallWeSlide(
                              url: _careateOrJoinMettingResult
                                  .result!.meetingUrl!,
                            ),
                          ),
                          (Route<dynamic> route) => false);
                    }, Icons.phone, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 0,
                                    customerId: c.id,
                                  )));
                    }, Icons.cloud, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 1,
                                    customerId: c.id,
                                  )));
                    }, Icons.message, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 2,
                                    customerId: c.id,
                                  )));
                    }, Icons.mail, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 3,
                                    customerId: c.id,
                                  )));
                    }, Icons.note, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 0,
                                    customerId: c.id,
                                  )));
                    }, Icons.arrow_forward_ios_outlined, index),
                  ],
                ),
              ),
            ),
            Container(
              width: Get.width,
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactCard(int index, BuildContext context) {
    Customer c = adminCustomer.result![index];

    return Material(
      color: Color(0xFFF0F7F7),
      child: InkWell(
        onTap: () {
          setState(() {
            if (listExpand[index]) {
              _controller[index]..reverse(from: 0.5);
            } else {
              _controller[index]..forward(from: 0.0);
            }
            listExpand[index] = !listExpand[index];
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                //boxShadow: standartCardShadow(),
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      boxShadow: standartCardShadow(),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.network(
                                      c.photo != null
                                          ? c.photo!
                                          : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      c.title ?? "",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      c.customerAdminName! +
                                          " " +
                                          c.customerAdminSurname!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    c.phone != null
                                        ? Text(
                                            c.phone!,
                                            style: TextStyle(fontSize: 11),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ],
                            ),
                            RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_controller[index]),
                              child: Icon(Icons.expand_more),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: listExpand[index] ? 40 : 0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: listExpand[index] ? 3 : 0),
              decoration: BoxDecoration(
                  //color: Color(0xFFe3d5a4),
                  ),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    contactMoreIcon(() async {
                      targetUserIdList.add(c.customerAdminId!);
                      await CareateOrJoinMetting(targetUserIdList);
                      await Permission.camera.request();
                      await Permission.microphone.request();
                      print(_careateOrJoinMettingResult.result!.meetingUrl!);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallWeSlide(
                              url: _careateOrJoinMettingResult
                                  .result!.meetingUrl!,
                            ),
                          ),
                          (Route<dynamic> route) => false);
                    }, Icons.phone, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 0,
                                    customerId: c.id,
                                  )));
                    }, Icons.cloud, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 1,
                                    customerId: c.id,
                                  )));
                    }, Icons.message, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 2,
                                    customerId: c.id,
                                  )));
                    }, Icons.mail, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 3,
                                    customerId: c.id,
                                  )));
                    }, Icons.note, index),
                    contactMoreIcon(() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ContactCRMPage(
                                    index: 0,
                                    customerId: c.id,
                                  )));
                    }, Icons.arrow_forward_ios_outlined, index),
                  ],
                ),
              ),
            ),
            Container(
              width: Get.width,
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector contactMoreIcon(
      Function runOnTap, IconData iconData, int index) {
    return GestureDetector(
      onTap: () {
        runOnTap();
      },
      child: AnimatedOpacity(
        opacity: listExpand[index] ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Get.theme.primaryColor,
            boxShadow: standartCardShadow(),
          ),
          padding: EdgeInsets.all(7),
          child: AnimatedOpacity(
            opacity: listExpand[index] ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child:
                Icon(iconData, size: 19, color: Get.theme.secondaryHeaderColor),
          ),
        ),
      ),
    );
  }

  List<BoxShadow> standartCardShadow() {
    return <BoxShadow>[
      BoxShadow(
        color: Colors.grey,
        offset: Offset(0, 0),
        blurRadius: 15,
        spreadRadius: -11,
      )
    ];
  }

  _onAlertWithCustomContentPressed2(context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.inviteUsers,
                ),
                content: Container(
                  height: Get.height * 0.15,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemCount: SelectedUsers.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                        SelectedUsers[index].photo!),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    SelectedUsers[index].userFullName!,
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      TextField(
                        controller: _commonInvite,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.inviteMessage,
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      await CommonInvite(SelectedUsersId, _commonInvite.text,
                          "", AppLocalizations.of(context)!.date);

                      _commonInvite.clear();
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.invite,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }

  _onAlertExternalIntive(context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.inviteUsers,
                ),
                content: Container(
                  height: Get.height * 0.15,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _commonInviteMail,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.signInEmailLabel,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _commonInvite,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.inviteMessage,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      await CommonInvite([],
                          _commonInvite.text,
                          _commonInviteMail.text,
                          AppLocalizations.of(context)!.date);
                      _commonInvite.clear();
                      _commonInviteMail.clear();
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.invite,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }
}
