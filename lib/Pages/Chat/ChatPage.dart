import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/DebouncerForSearch.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Pages/Chat/ChatDetailPage.dart';
import 'package:undede/Pages/Chat/ChatDetailPageForTablet.dart';
import 'package:undede/Pages/Chat/GroupChat/ChatGroupDetailPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/Services/Chat/ChatDB.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/model/Chat/GetPublicChatListResult.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/User/GetAllActiveUserResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../Custom/CustomLoadingCircle.dart';
import '../../WidgetsV2/CustomAppBarWithSearch.dart';
import 'package:undede/model/Chat/GetUserListUser.dart' as a;
import 'package:undede/model/Chat/GetPublicChatListResult.dart' as b;
import 'package:undede/model/User/GetAllActiveUserResult.dart' as c;

import '../../WidgetsV2/Helper.dart';

class ChatPage extends StatefulWidget {
  final int? Id;
  final String? image;
  final String? meetingUrl;
  final int? diffentPage;
  final int? isGroup;
  final bool? blocked;
  final bool? online;
  final bool directLink;
  const ChatPage(
      {this.Id,
      this.image,
      this.diffentPage,
      this.isGroup,
      this.blocked,
      this.online,
      this.directLink = false,
      this.meetingUrl = ''});

  @override
  _ChatPageState createState() => _ChatPageState();
}

enum ChatActivity { Online, Offline, All }

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerUser _controllerUser = ControllerUser();
  GetPublicChatListResult _getPublicChatListResult =
      GetPublicChatListResult(hasError: false);
  List<bool> listExpand = <bool>[];
  List<AnimationController> _controller = <AnimationController>[];
  UserDB userDB = new UserDB();
  ChatDB _chatDB = ChatDB();
  AdminCustomerResult adminCustomer = AdminCustomerResult(hasError: false);
  bool isLoading = false;
  bool isLoading1 = false;
  bool twoScreen = false;
  List getOnlineUser = [];
  TextEditingController _search = TextEditingController();
  TextEditingController _searchPublic = TextEditingController();
  TextEditingController _searchAllActive = TextEditingController();
  TextEditingController _commonInvite = TextEditingController();
  TextEditingController _commonInviteMail = TextEditingController();
//  GetUserListResult _getUserListResultSearch = GetUserListResult();
  List<a.Result> _getUserListResultSearch = [];
  List<b.Result> _getPublicChatResultSearch = [];
  List<c.Result> _getAllActiveUserSearch = [];
  // Tabview
  List<Tab> tabs = <Tab>[];
  TabController? _tabController;
  // selectUser
  GetAllActiveUserResult _getAllActiveUserResult =
      GetAllActiveUserResult(hasError: false);
  List<c.Result> SelectedUsers = [];
  List<int> SelectedUsersId = [];
  bool loading3 = false;
  int initialIndex = 0;
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  // Scroll controller
  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  bool refreshing = true;
  int id = 0;
  String? image;
  int isGroup = 0;
  bool blocked = false;

  // ONLINE OFLINE USER
  ChatActivity _chatActivity = ChatActivity.All;
  final _debouncer = DebouncerForSearch();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connection();
    getUserList();
    getPublicChatList();
    GetAllActiveUser();
    widget.directLink ? setForMeeting() : null;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels < -125 && refreshing) {
        getUserList();
        setState(() {
          refreshing = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controllerChatNew.GetUnreadCountByUserId(_controllerDB.headers());

      _commonInvite = TextEditingController(
          text: AppLocalizations.of(context)!.baseMessage);
    });
  }

  void setForMeeting() async {
    setState(() {
      id = widget.Id!;
      image = widget.image;
      isGroup = widget.isGroup!;
      blocked = widget.blocked!;
      twoScreen = true;
    });
  }

  @override
  void didChangeDependencies() {
    tabs = <Tab>[
      new Tab(text: AppLocalizations.of(context)!.privateChat),
    ];
    _tabController = new TabController(
        vsync: this, length: tabs.length, initialIndex: initialIndex);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController!.dispose();

    super.dispose();
  }

  connection() {
    _controllerDB.socket!.value
        .emit("addUser", _controllerDB.user.value!.result!.id);
    _controllerDB.socket!.value.on("newChatMessage", (data) {
      getUserList(withoutSetState: true);
      _controllerChatNew.refreshDetail = true;
      _controllerChatNew.update();
      _controllerChatNew.GetUnreadCountByUserId(_controllerDB.headers());
    });
    _controllerDB.socket!.value.on("deleteChatMessage", (data) {
      getUserList(withoutSetState: true);
      _controllerChatNew.refreshDetail = true;
      _controllerChatNew.update();
      _controllerChatNew.GetUnreadCountByUserId(_controllerDB.headers());
    });

    _controllerDB.socket!.value.emit("getOnlineUsers");
    _controllerDB.socket!.value.on("getOnlineUsers", (data) {
      setState(() {
        print(data);
        getOnlineUser.addAll(data);
      });
    });
    _controllerDB.socket!.value.on("setUserOnline", (data) {
      var uuid = Uuid();
      setState(() {
        getOnlineUser.add({"id": uuid, "username": data});
      });
    });
    _controllerDB.socket!.value.on("setUserOffline", (data) {
      print(data);
      setState(() {
        getOnlineUser.removeWhere((element) => element["username"] == data);
      });
    });
  }

  getUserList({withoutSetState = false}) async {
    await _controllerChatNew.GetUserList(
        _controllerDB.headers(), _controllerDB.user.value!.result!.id!);
    if (!withoutSetState) {
      setState(() {
        isLoading = true;
        refreshing = true;
      });
    }
    _controllerChatNew.UserListRx != null ? FilterPrivateChat() : null;
    //!FilterPrivateChat();
  }

  setUnread(int SenderUserId) async {
    await _controllerChatNew.SetChatUnread(SenderUserId);
    _controllerChatNew.GetUnreadCountByUserId(_controllerDB.headers());
  }

  getPublicChatList({withoutSetState = false}) async {
    await _controllerChatNew.GetPublicChatList(
      _controllerDB.headers(),
    ).then((value) => {_getPublicChatListResult = value});
    if (!withoutSetState) {
      setState(() {
        isLoading1 = true;
      });
    }
  }

  CommonInvite(List<int> TargetUserIdList, String CommentText, String Email,
      String Language) async {
    await _controllerCommon.CommonInvite(_controllerDB.headers(),
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

  GetAllActiveUser({withoutSetState = false, String search = ""}) async {
    await _controllerUser.GetAllActiveUser(_controllerDB.headers(),
            search: search)
        .then((value) {
      _getAllActiveUserResult = value;
    });
    if (!withoutSetState) {
      setState(() {
        loading3 = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    return GetBuilder<ControllerChatNew>(builder: (c) {
      if (c.loadChatUsers) {
        getUserList(withoutSetState: true);
        getPublicChatList(withoutSetState: true);
        GetAllActiveUser(withoutSetState: true);
        c.loadChatUsers = false;
        c.update();
      }
      return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: CustomAppBarWithSearch(
            openFirstRadioButton: (ChatActivity value) {
              setState(() {
                _chatActivity = value;
                _controllerChatNew.UserListRx != null
                    ? FilterPrivateChat()
                    : null;

                //! FilterPrivateChat();
              });
            },
            title: AppLocalizations.of(context)!.chat,
            isHomePage: true,
            onChanged: (as) async {
              // _search.text = as;
              // setState(() {
              //   FilterPrivateChat();
              //   _getPublicChatResultSearch.clear();
              // });
              // for (int i = 0; i < _getPublicChatListResult.result.length; i++) {
              //   if (_getPublicChatListResult.result[i].groupName
              //       .toLowerCase()
              //       .contains(as.toString().camelCase)) {
              //     _getPublicChatResultSearch
              //         .add(_getPublicChatListResult.result[i]);
              //   }
              // }
              await _debouncer.run(() {
                setState(() {
                  _getAllActiveUserSearch.clear();
                  _searchAllActive.text = as;
                });
                GetAllActiveUser(search: _searchAllActive.text);
              });
            },
            openFilterFunction: () {},
            openBoardFunction: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => NotificationPage()));
            },
            isChatPage: true,
          ),
          body: !isLoading && !isLoading1 && !loading3
              ? Text("ChatPage")
              //CustomLoadingCircle()
              : Container(
                  width: Get.width,
                  height: Get.height,
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        color: Get.theme.scaffoldBackgroundColor,
                        width: Get.width,
                        alignment: Alignment.topCenter,
                        child: buildPrivateChat(context),
                        // child: TabBarView(
                        //     controller: _tabController,
                        //     children: [
                        //       buildPrivateChat(context),
                        //       //buildInvite(context)
                        //       //buildPublicChat(context),
                        //     ]),
                      ),
                    ),
                    useTabletLayout
                        ? (twoScreen
                            ? Expanded(
                                child: ChatDetailPageForTablet(
                                  Id: id,
                                  image: image!,
                                  diffentPage: 0,
                                  isGroup: isGroup,
                                  blocked: blocked,
                                  online: false,
                                  directLink: widget.directLink,
                                  meetingUrl: widget.meetingUrl!,
                                ),
                              )
                            : Expanded(
                                child: Container(
                                width: Get.width / 5,
                                height: Get.height / 2,
                                decoration: BoxDecoration(
                                  color: Get.theme.scaffoldBackgroundColor,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: Get.width /
                                          8, // Adjust these values to position the image
                                      top:
                                          10, // Adjust these values to position the image
                                      child: Image.asset(
                                        'assets/images/chatbg1.png',
                                        width: Get.width /
                                            4, // Adjust the width as needed
                                        height: Get.height /
                                            3, // Adjust the height as needed
                                        fit: BoxFit
                                            .contain, // Choose the appropriate BoxFit
                                      ),
                                    ),
                                  ],
                                ),
                              )))
                        : Container(),
                  ]),
                ));
    });
  }

  Widget buildPrivateChat(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return _buildPrivateChatWidgetForTablet(isTablet, context);
  }

  Row _buildPrivateChatWidgetForTablet(bool isTablet, BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                useTabletLayout
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Container(
                              width: Get.height / 20,
                              height: Get.height / 20,
                              child: ClipRRect(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Image.asset(
                                    'assets/images/icon/message.png',
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(AppLocalizations.of(context)!.chatApp,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                        ],
                      )
                    : SizedBox(),
                !refreshing
                    ? Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                _getAllActiveUserResult.result == null
                    ? CircularProgressIndicator()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            _getAllActiveUserResult.result!.length != null
                                ? _getAllActiveUserResult.result!.length
                                : 0,
                        itemBuilder: (ctx, i) {
                          a.Result emptyPerson = a.Result(
                            id: _getAllActiveUserResult.result![i].id,
                            name: _getAllActiveUserResult.result![i].name,
                            surname: _getAllActiveUserResult.result![i].surname,
                            photo: _getAllActiveUserResult.result![i].photo,
                            customerId: 0,
                            isMyPerson: false,
                            status: "surname",
                            isAdministrationAdmin: false,
                            chatUnreadCount: 0,
                            lastMessageDate: "",
                            lastMessage: "",
                            fullName: _getAllActiveUserResult
                                .result![i].userFullName!,
                            isGroup: 1000,
                            isPublic: 0,
                            blocked: false,
                          );

                          bool result = FilterPrivateChat().any((a) =>
                              a.id == _getAllActiveUserResult.result![i].id);

                          a.Result private = result
                              ? FilterPrivateChat().firstWhere(
                                  (e) =>
                                      e.id ==
                                      _getAllActiveUserResult.result![i].id,
                                  orElse: () => emptyPerson)
                              : emptyPerson;

                          return (_searchAllActive.text == '' &&
                                  private.lastMessage == '')
                              ? Container()
                              : InkWell(
                                  onTap: () {
                                    print('selectedMessageIDNumber' +
                                        private.id.toString() +
                                        ':::' +
                                        private.photo! +
                                        ':::' +
                                        private.isGroup.toString() +
                                        ':::' +
                                        private.blocked.toString());
                                    if (private.isGroup == 1000) {
                                    } else if (private.isGroup == 1) {
                                      !isTablet
                                          ? Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatGroupDetailPage(
                                                        Id: private.id!,
                                                        image: private.photo!,
                                                        diffentPage: 0,
                                                        isGroup:
                                                            private.isGroup!,
                                                        blocked:
                                                            private.blocked!,
                                                      )))
                                          : twoScreen = true;
                                      setState(() {
                                        twoScreen = true;
                                      });
                                    } else {
                                      !isTablet
                                          ? Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatDetailPage(
                                                  Id: private.id!,
                                                  image: private.photo!,
                                                  diffentPage: 0,
                                                  isGroup: private.isGroup!,
                                                  blocked: private.blocked!,
                                                  online: getOnlineUser
                                                      .any((element) {
                                                    if (element["username"]
                                                            .toString() ==
                                                        private.id.toString())
                                                      return true;
                                                    else
                                                      return false;
                                                  }),
                                                ),
                                              ),
                                            )
                                          : twoScreen = true;
                                      setState(() {
                                        print('selectedMessageIDNumber' +
                                            private.id!.toString() +
                                            ':::' +
                                            private.photo! +
                                            ':::' +
                                            private.isGroup!.toString() +
                                            ':::' +
                                            private.blocked.toString());
                                        id = private.id!;
                                        image = private.photo;
                                        isGroup = private.isGroup!;
                                        blocked = private.blocked!;
                                        twoScreen = true;
                                      });
                                    }
                                    setUnread(private.id!);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: isTablet
                                          ? (private.id == id
                                              ? Get
                                                  .theme.colorScheme.onSecondary
                                              : Colors.transparent)
                                          : Colors.transparent,
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              bottom: 15,
                                              right: 5,
                                              left: 5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Container(
                                                      width: Get.height / 18,
                                                      height: Get.height / 18,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[200]!,
                                                              width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        child: Image.network(
                                                          private.photo!,
                                                          fit: BoxFit.fitWidth,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  /*  getOnlineUser.any(
                                                                    (element) =>
                                                                        element ==
                                                                        _getUserListResult
                                                                            .result[
                                                                                i]
                                                                            .id)*/
                                                  /**/
                                                  private.chatUnreadCount != 0
                                                      ? Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Container(
                                                            width: 15,
                                                            height: 15,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Get.theme
                                                                  .primaryColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              private
                                                                  .chatUnreadCount
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                  getOnlineUser.any((element) {
                                                    if (element["username"]
                                                            .toString() ==
                                                        private.id.toString())
                                                      return true;
                                                    else
                                                      return false;
                                                  })
                                                      ? Positioned(
                                                          bottom: 0,
                                                          right: 0,
                                                          child: Container(
                                                            width: 16.0,
                                                            height: 16.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                width: 1.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      width:
                                                                          1.0,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .check,
                                                                      size: 13,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Positioned(
                                                          bottom: 0,
                                                          right: 0,
                                                          child: Container(
                                                            width: 16.0,
                                                            height: 16.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors.grey
                                                                  .shade300,
                                                              border:
                                                                  Border.all(
                                                                width: 1.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                              //?
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 8.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              private.fullName!,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Avenir-Book',
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      -0.41000000190734864,
                                                                  height: 1.29,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Spacer(),
                                                            private.lastMessageDate !=
                                                                    ''
                                                                ? Text(DateFormat.yMMMd(
                                                                        AppLocalizations.of(context)!
                                                                            .date)
                                                                    .format(DateTime
                                                                        .parse(private
                                                                            .lastMessageDate!)))
                                                                : Text(''),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 8.0),
                                                        child: Row(
                                                          children: [
                                                            LastMessageWidget(
                                                                private),
                                                            Spacer(),
                                                            private.isGroup ==
                                                                    1000
                                                                ? GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      await CommonInvite(
                                                                          SelectedUsersId,
                                                                          _commonInvite
                                                                              .text,
                                                                          "",
                                                                          AppLocalizations.of(context)!
                                                                              .date);
                                                                      await _controllerChatNew.GetUserList(
                                                                          _controllerDB
                                                                              .headers(),
                                                                          _controllerDB
                                                                              .user
                                                                              .value!
                                                                              .result!
                                                                              .id!);

                                                                      setState(
                                                                          () {
                                                                        SelectedUsersId
                                                                            .clear();
                                                                        SelectedUsers
                                                                            .clear();
                                                                        _commonInvite
                                                                            .clear();
                                                                      });
                                                                      Get.back();
                                                                    },
                                                                    child:
                                                                        Container(
                                                                            padding: EdgeInsets.all(
                                                                                10),
                                                                            decoration: BoxDecoration(
                                                                                color: Colors
                                                                                    .green,
                                                                                borderRadius: BorderRadius.circular(
                                                                                    15)),
                                                                            child:
                                                                                Text(
                                                                              AppLocalizations.of(context)!.invite,
                                                                              style: TextStyle(color: Colors.white),
                                                                            )))
                                                                : private.isGroup ==
                                                                        1
                                                                    ? Container(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                                4),
                                                                        decoration: BoxDecoration(
                                                                            color: Colors
                                                                                .green,
                                                                            borderRadius: BorderRadius.circular(
                                                                                15)),
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)!
                                                                              .group,
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ))
                                                                    : tags(
                                                                        private),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
        // Expanded(
        //     child: Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
        //   child: ChatDetailPage(
        //     Id: FilterPrivateChat()[5].id,
        //     image: FilterPrivateChat()[5].photo,
        //     diffentPage: 0,
        //     isGroup: FilterPrivateChat()[5].isGroup,
        //     blocked: FilterPrivateChat()[5].blocked,
        //     online: false,
        //   ),
        // )),
      ],
    );
  }

  Column _buildPrivateChatWidget(bool isTablet, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                !refreshing
                    ? Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _getAllActiveUserResult.result!.length != null
                        ? _getAllActiveUserResult.result!.length
                        : 0,
                    itemBuilder: (ctx, i) {
                      a.Result emptyPerson = a.Result(
                        id: _getAllActiveUserResult.result![i].id!,
                        name: _getAllActiveUserResult.result![i].name!,
                        surname: _getAllActiveUserResult.result![i].surname!,
                        photo: _getAllActiveUserResult.result![i].photo!,
                        customerId: 0,
                        isMyPerson: false,
                        status: "surname",
                        isAdministrationAdmin: false,
                        chatUnreadCount: 0,
                        lastMessageDate: "",
                        lastMessage: "",
                        fullName:
                            _getAllActiveUserResult.result![i].userFullName!,
                        isGroup: 1000,
                        isPublic: 0,
                        blocked: false,
                      );

                      bool result = FilterPrivateChat().any(
                          (a) => a.id == _getAllActiveUserResult.result![i].id);

                      a.Result private = result
                          ? FilterPrivateChat().firstWhere(
                              (e) =>
                                  e.id == _getAllActiveUserResult.result![i].id,
                              orElse: () => emptyPerson)
                          : emptyPerson;

                      return (_searchAllActive.text == '' &&
                              private.lastMessage == '')
                          ? Container()
                          : InkWell(
                              onTap: () {
                                if (private.isGroup == 1000) {
                                } else if (private.isGroup == 1) {
                                  !isTablet
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatGroupDetailPage(
                                                    Id: private.id!,
                                                    image: private.photo!,
                                                    diffentPage: 0,
                                                    isGroup: private.isGroup!,
                                                    blocked: private.blocked!,
                                                  )))
                                      : twoScreen = true;
                                  setState(() {
                                    twoScreen = true;
                                  });
                                } else {
                                  !isTablet
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatDetailPage(
                                                      Id: private.id!,
                                                      image: private.photo!,
                                                      diffentPage: 0,
                                                      isGroup: private.isGroup!,
                                                      blocked: private.blocked!,
                                                      online: getOnlineUser
                                                          .any((element) {
                                                        if (element["username"]
                                                                .toString() ==
                                                            private.id
                                                                .toString())
                                                          return true;
                                                        else
                                                          return false;
                                                      }))))
                                      : twoScreen = true;
                                  setState(() {
                                    id = private.id!;
                                    image = private.photo!;
                                    isGroup = private.isGroup!;
                                    blocked = private.blocked!;
                                    twoScreen = true;
                                  });
                                }
                                setUnread(private.id!);
                              },
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              width: Get.height / 18,
                                              height: Get.height / 18,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[200]!,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.network(
                                                  private.photo!,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            ),
                                            /*  getOnlineUser.any(
                                                                  (element) =>
                                                                      element ==
                                                                      _getUserListResult
                                                                          .result[
                                                                              i]
                                                                          .id)*/
                                            /**/
                                            getOnlineUser.any((element) {
                                              if (element["username"]
                                                      .toString() ==
                                                  private.id.toString())
                                                return true;
                                              else
                                                return false;
                                            })
                                                ? Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      width: 16.0,
                                                      height: 16.0,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          width: 1.0,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                width: 1.0,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.check,
                                                                size: 13,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      width: 16.0,
                                                      height: 16.0,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors
                                                            .grey.shade300,
                                                        border: Border.all(
                                                          width: 1.0,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      private.fullName!,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Avenir-Book',
                                                          fontSize: 16.0,
                                                          letterSpacing:
                                                              -0.41000000190734864,
                                                          height: 1.29,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Spacer(),
                                                    private.lastMessageDate !=
                                                            ''
                                                        ? Text(DateFormat.yMMMd(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .date)
                                                            .format(DateTime
                                                                .parse(private
                                                                    .lastMessageDate!)))
                                                        : Text(''),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 0,
                                                ),
                                                Row(
                                                  children: [
                                                    LastMessageWidget(private),
                                                    Spacer(),
                                                    private.chatUnreadCount != 0
                                                        ? Container(
                                                            width: 25,
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .orangeAccent,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              private
                                                                  .chatUnreadCount
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )),
                                                          )
                                                        : Container(),
                                                    private.isGroup == 1000
                                                        ? GestureDetector(
                                                            onTap: () async {
                                                              await CommonInvite(
                                                                  SelectedUsersId,
                                                                  _commonInvite
                                                                      .text,
                                                                  "",
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .date);
                                                              await _controllerChatNew.GetUserList(
                                                                  _controllerDB
                                                                      .headers(),
                                                                  _controllerDB
                                                                      .user
                                                                      .value!
                                                                      .result!
                                                                      .id!);

                                                              setState(() {
                                                                SelectedUsersId
                                                                    .clear();
                                                                SelectedUsers
                                                                    .clear();
                                                                _commonInvite
                                                                    .clear();
                                                              });
                                                              Get.back();
                                                            },
                                                            child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        Colors
                                                                            .green,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                15)),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .invite,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                )))
                                                        : private.isGroup == 1
                                                            ? Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15)),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .group,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ))
                                                            : tags(private),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                    }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget tags(a.Result private) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return PopupMenuButton(
      onSelected: (a) {
        if (a == 1) {
          _controllerUser.AddUsersToAdministration(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id!,
                  TargetUserId: private.id!,
                  TargetCustomerId: private.customerId!)
              .then((value) {
            if (value) {
              setState(() {
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id!)
                    .isMyPerson = true;
              });
            } else {}
          });
        }
        if (a == 2) {
          _controllerUser.AddUsersToCustomer(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id!,
                  TargetUserId: private.id!,
                  TargetCustomerId: private.customerId!)
              .then((value) {
            if (value) {
              setState(() {
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .customerId = _controllerDB.user.value!.result!.id!;
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .isMyPerson = false;
              });
            } else {}
          });
        }
        if (a == 3) {
          _controllerUser.DeleteUsersToCustomer(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id!,
                  TargetUserId: private.id!,
                  TargetCustomerId: private.customerId!)
              .then((value) {
            if (value) {
              setState(() {
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id!)
                    .customerId = 0;
              });
            } else {}
          });
          _controllerUser.DeleteUsersToAdministration(_controllerDB.headers(),
                  UserId: _controllerDB.user.value!.result!.id!,
                  TargetUserId: private.id!,
                  TargetCustomerId: private.customerId!)
              .then((value) {
            if (value)
              setState(() {
                _controllerChatNew.UserListRx?.value!.result!
                    .firstWhere((element) => element.id == private.id)
                    .isMyPerson = false;
              });
          });
        }
      },
      itemBuilder: (context) => (private.isMyPerson!)
          ? [
              PopupMenuItem(
                child: Text(AppLocalizations.of(context)!.customer),
                value: 2,
              ),
              PopupMenuItem(
                child: Text(AppLocalizations.of(context)!.private),
                value: 3,
              ),
            ]
          : (private.customerId == _controllerDB.user.value!.result!.id!)
              ? [
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.personal),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.private),
                    value: 3,
                  ),
                ]
              : [
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.personal),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text(AppLocalizations.of(context)!.customer),
                    value: 2,
                  ),
                ],
      child: Container(
          padding: EdgeInsets.all(3),
          width: Get.width / 6,
          constraints: BoxConstraints(
            maxWidth: isTablet
                ? Get.width / 12
                : Get.width / 5, // Set the maximum width
          ),
          decoration: BoxDecoration(
              color: private.isMyPerson!
                  ? Get.theme.colorScheme.onPrimaryContainer
                  : private.customerId == _controllerDB.user.value!.result!.id!
                      ? Get.theme.colorScheme.onSecondaryContainer
                      : Get.theme.colorScheme.onTertiaryContainer,
              borderRadius: BorderRadius.circular(15)),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              private.isMyPerson!
                  ? AppLocalizations.of(context)!.personal
                  : private.customerId == _controllerDB.user.value!.result!.id!
                      ? AppLocalizations.of(context)!.customer
                      : AppLocalizations.of(context)!.private,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          )),
    );
  }

  Widget LastMessageWidget(a.Result private) {
    String exten =
        private.lastMessage.toString().split(".").last.split("\"").first;
    switch (exten) {
      case "pdf":
      case 'xls':
      case 'docx':
      case 'xlsx':
      case 'doc':
      case 'jpg':
      case 'png':
      case 'jpeg':
      case 'txt':
      case 'm4a':
      case 'mp4':
      case 'mp3':
        return Expanded(
          child: Row(
            children: [
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(getImagePathByFileExtension(exten)))),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                exten.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Avenir-Book',
                    fontSize: 15.0,
                    letterSpacing: -0.41000000190734864,
                    height: 1.29,
                    color: Colors.grey,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
        );
        break;
      default:
        return Expanded(
          child: Text(
            private.lastMessage ?? ".....",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Avenir-Book',
                fontSize: 15.0,
                letterSpacing: -0.41000000190734864,
                height: 1.29,
                color: Colors.grey,
                fontWeight: FontWeight.w300),
          ),
        );
    }
  }

  List<a.Result> FilterPrivateChat() {
    List<a.Result> userList = <a.Result>[];

    if (_controllerChatNew.UserListRx?.value != null) {
      if (_chatActivity.index == 2) {
        print(_controllerChatNew.UserListRx?.value?.result);
        if (_search.text != '') {
          userList = _controllerChatNew.UserListRx!.value!.result!
              .where((c) => c.fullName!
                  .toLowerCase()
                  .contains(_search.text.toLowerCase()))
              .toList();
        } else {
          if (_controllerChatNew.UserListRx!.value!.result != null) {
            userList = _controllerChatNew.UserListRx!.value!.result!;
          }
          ;
        }
      } else if (_chatActivity.index == 0) {
        if (!_search.text.isBlank!) {
          userList = _controllerChatNew.UserListRx!.value!.result!
              .where((c) => getOnlineUser.any((element) {
                    if (element["username"].toString() == c.id.toString())
                      return true;
                    else
                      return false;
                  }))
              .where((c) => c.fullName!
                  .toLowerCase()
                  .contains(_search.text.toLowerCase()))
              .toList();
        } else {
          userList = _controllerChatNew.UserListRx!.value!.result!
              .where((c) => getOnlineUser.any((element) {
                    if (element["username"].toString() == c.id.toString())
                      return true;
                    else
                      return false;
                  }))
              .toList();
        }
      } else if (_chatActivity.index == 1) {
        if (!_search.text.isBlank!) {
          userList = _controllerChatNew.UserListRx!.value!.result!
              .where((c) => !getOnlineUser.any((element) =>
                  (element["username"].toString() != c.id.toString())))
              .where((c) => c.fullName!
                  .toLowerCase()
                  .contains(_search.text.toLowerCase()))
              .toList();
        } else {
          userList = _controllerChatNew.UserListRx!.value!.result!
              .where((c) => !getOnlineUser.any((element) =>
                  (element["username"].toString() == c.id.toString())))
              .toList();
        }
      }
    }

    return userList;
  }

  Widget buildPublicChat(BuildContext context) {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Expanded(
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(horizontal: 20),
        //         child: Container(
        //           height: 45,
        //           margin: EdgeInsets.only(top: 15),
        //           decoration: BoxDecoration(
        //               boxShadow: standartCardShadow(),
        //               borderRadius: BorderRadius.circular(45)),
        //           child: CustomTextField(
        //             controller: _searchPublic,
        //             prefixIcon: Icon(Icons.search),
        //             hint: AppLocalizations.of(context).search,
        //             onChanged: (changed) {
        //               setState(() {
        //                 _getPublicChatResultSearch.clear();
        //               });

        //               for (int i = 0;
        //                   i < _getPublicChatListResult.result.length;
        //                   i++) {
        //                 if (_getPublicChatListResult.result[i].groupName
        //                     .toLowerCase()
        //                     .contains(changed.toString().camelCase)) {
        //                   _getPublicChatResultSearch
        //                       .add(_getPublicChatListResult.result[i]);
        //                 }
        //               }
        //             },
        //           ),
        //         ),
        //       ),
        //     ),
        //     Container(
        //       margin: EdgeInsets.only(top: 15, right: 20),
        //       child: PopupMenuButton(
        //           onSelected: (a) {
        //             if (a == 1) {
        //               Navigator.of(context).push(MaterialPageRoute(
        //                   builder: (context) => CreateNewGrup()));
        //             }
        //           },
        //           child: Center(
        //               child: Icon(
        //             Icons.more_vert,
        //             color: Colors.black,
        //             size: 27,
        //           )),
        //           itemBuilder: (context) => [
        //                 PopupMenuItem(
        //                   child:
        //                       Text(AppLocalizations.of(context).newPublicGroup),
        //                   value: 1,
        //                 ),
        //                 PopupMenuItem(
        //                   child: Text(AppLocalizations.of(context).settings),
        //                   value: 2,
        //                 )
        //               ]),
        //     )
        //   ],
        // ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Visibility(
                  visible: !_searchPublic.text.isBlank!,
                  child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _getPublicChatResultSearch.length,
                      itemBuilder: (ctx, i) {
                        return InkWell(
                          onTap: () {
                            /*
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatDetailPage(
                                                                Id: _getUserListResult
                                                                    .result[i].id,
                                                                image:
                                                                    _getUserListResult
                                                                        .result[i]
                                                                        .photo,
                                                                diffentPage: 0,
                                                              )));*/
                            /*setUnread(_getUserListResult
                                                      .result[i].id);*/
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
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
                                              "http://test.vir2ell-office.com/Content/UploadPhoto/User/" +
                                                  _getPublicChatResultSearch[i]
                                                      .groupPhoto!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        /*  getOnlineUser.any(
                                                                      (element) =>
                                                                          element ==
                                                                          _getUserListResult
                                                                              .result[
                                                                                  i]
                                                                              .id)*/
                                        /**/
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    _getPublicChatResultSearch[
                                                            i]
                                                        .groupName!,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Avenir-Book',
                                                        fontSize: 17.0,
                                                        letterSpacing:
                                                            -0.41000000190734864,
                                                        height: 1.29,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: Text(DateFormat.yMMMd(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .date)
                                                      .format(DateTime.parse(
                                                          _getPublicChatResultSearch[
                                                                  i]
                                                              .lastMessageDate!))),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 15.0),
                                                    child: Text(
                                                      " .....",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Avenir-Book',
                                                          fontSize: 17.0,
                                                          letterSpacing:
                                                              -0.41000000190734864,
                                                          height: 1.29,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w300),
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                _getPublicChatResultSearch[i]
                                                            .unreadCount !=
                                                        0
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 15.0),
                                                        child: Container(
                                                          width: 25,
                                                          height: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .orangeAccent,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Center(
                                                              child: Text(
                                                            _getPublicChatResultSearch[
                                                                    i]
                                                                .unreadCount
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                Visibility(
                  visible: _searchPublic.text.isBlank!,
                  child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _getPublicChatListResult.result!.length,
                      itemBuilder: (ctx, i) {
                        return InkWell(
                          onTap: () {
                            /*
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatDetailPage(
                                                                Id: _getUserListResult
                                                                    .result[i].id,
                                                                image:
                                                                    _getUserListResult
                                                                        .result[i]
                                                                        .photo,
                                                                diffentPage: 0,
                                                              )));*/
                            /*setUnread(_getUserListResult
                                                      .result[i].id);*/
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
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
                                              _getPublicChatListResult
                                                  .result![i].groupPhoto!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        /*  getOnlineUser.any(
                                                                      (element) =>
                                                                          element ==
                                                                          _getUserListResult
                                                                              .result[
                                                                                  i]
                                                                              .id)*/
                                        /**/
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    _getPublicChatListResult
                                                        .result![i].groupName!,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Avenir-Book',
                                                        fontSize: 17.0,
                                                        letterSpacing:
                                                            -0.41000000190734864,
                                                        height: 1.29,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: Text(DateFormat.yMMMd(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .date)
                                                      .format(DateTime.parse(
                                                          _getPublicChatListResult
                                                              .result![i]
                                                              .lastMessageDate!))),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 15.0),
                                                    child: Text(
                                                      ".....",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Avenir-Book',
                                                          fontSize: 17.0,
                                                          letterSpacing:
                                                              -0.41000000190734864,
                                                          height: 1.29,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w300),
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                _getPublicChatListResult
                                                            .result![i]
                                                            .unreadCount !=
                                                        0
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 15.0),
                                                        child: Container(
                                                          width: 25,
                                                          height: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .orangeAccent,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Center(
                                                              child: Text(
                                                            _getPublicChatListResult
                                                                .result![i]
                                                                .unreadCount
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
        ),
      ],
    );
  }

  Widget buildInvite(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
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
                        onChanged: (asd) async {
                          await _debouncer.run(() {
                            setState(() {
                              _getAllActiveUserSearch.clear();
                            });
                            GetAllActiveUser(search: _searchAllActive.text);
                          });
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
                              child: Text(
                                  AppLocalizations.of(context)!.externalInvite),
                              value: 1,
                            ),
                          ]),
                )
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _getAllActiveUserResult.result!.length,
                        itemBuilder: (ctx, i) {
                          return InkWell(
                            onTap: () {
                              if (_controllerChatNew.UserListRx!.value!.result!
                                  .any((a) =>
                                      a.id ==
                                      _getAllActiveUserResult.result![i].id)) {
                                return;
                              }
                              if (SelectedUsers.any((element) =>
                                  element.id ==
                                  _getAllActiveUserResult.result![i].id)) {
                                SelectedUsersId.remove(
                                    _getAllActiveUserResult.result![i].id);
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
                                          _getAllActiveUserResult.result![i].id)
                                      ? Get.theme.secondaryHeaderColor
                                          .withOpacity(0.2)
                                      : Colors.transparent,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  boxShadow:
                                                      standartCardShadow(),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
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
                                                      margin: EdgeInsets.only(
                                                          top: 12),
                                                      decoration: BoxDecoration(
                                                          color: Get.theme
                                                              .primaryColor,
                                                          shape:
                                                              BoxShape.circle),
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
                                                      margin: EdgeInsets.only(
                                                          top: 12),
                                                      decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          shape:
                                                              BoxShape.circle),
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
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  _getAllActiveUserResult
                                                      .result![i].userFullName!,
                                                  style: TextStyle(
                                                      fontFamily: 'Avenir-Book',
                                                      fontSize: 17.0,
                                                      letterSpacing:
                                                          -0.41000000190734864,
                                                      height: 1.29,
                                                      fontWeight:
                                                          FontWeight.w500),
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
                    SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
            bottom: 100,
            right: 5,
            child: FloatingActionButton(
              heroTag: "chatPageInvite",
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
                      await _controllerChatNew.GetUserList(
                          _controllerDB.headers(),
                          _controllerDB.user.value!.result!.id!);

                      setState(() {
                        SelectedUsersId.clear();
                        SelectedUsers.clear();
                        _commonInvite.clear();
                      });
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.invite,
                      style: TextStyle(color: Colors.red, fontSize: 20),
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
                      await _controllerChatNew.GetUserList(
                          _controllerDB.headers(),
                          _controllerDB.user.value!.result!.id!);
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
}
