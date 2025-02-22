/* import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';

import 'package:undede/WidgetsV2/TabNavigator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/widgets/CallWeSlide.dart';
import 'package:sliding_sheet2/sliding_sheet2.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../Pages/Chat/ChatDetailPage.dart';
import '../WidgetsV2/Helper.dart';

@immutable
class BuildBottomNavigationBar2 extends StatefulWidget {
  int? page;
  int? subDashboardPage;
  bool? goAccounPage;
  bool directChatDetail;
  int id;
  String photoString;

  BuildBottomNavigationBar2(
      {this.page,
      this.subDashboardPage,
      this.goAccounPage,
      this.id = 0,
      this.photoString = '',
      this.directChatDetail = false});

  @override
  _BuildBottomNavigationBar2State createState() =>
      _BuildBottomNavigationBar2State();
}

class _BuildBottomNavigationBar2State extends State<BuildBottomNavigationBar2>
    with TickerProviderStateMixin {
  List<Widget> _tabPage = [
    //FavoritePage(),
    Container(),
  ];

  PersistentTabController? _controller;
  int currentTab = 2;
  String _currentPage = "HomePage";

  List<String> pageKeys = [
    "ChatPage",
    "MessagePage",
    "HomePage",
    "CalendarPage",
    "NotePage",
    "SearchPage",
    "DocumentAnalyz"
  ];

  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "ChatPage": GlobalKey<NavigatorState>(),
    "MessagePage": GlobalKey<NavigatorState>(),
    "HomePage": GlobalKey<NavigatorState>(),
    "CalendarPage": GlobalKey<NavigatorState>(),
    "NotePage": GlobalKey<NavigatorState>(),
    "SearchPage": GlobalKey<NavigatorState>(),
    "DocumentAnalyz": GlobalKey<NavigatorState>(),
  };

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        currentTab = index;
      });
    }
  }

  GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');
  final ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());

  final ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());

  //MySharedPreferencesForNotification _countDB = MySharedPreferencesForNotification.instance;
  var _countDB = null;
  String? count;
  Color theme = Get.theme.colorScheme.secondary;
  Color background = Get.theme.colorScheme.surface;
  int Counter = 1;
  PageController pageController = new PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_controller = PersistentTabController(initialIndex: widget.page ?? 0);
    //! _selectTab(null widget.page ?? 2); den degistirildi
    _selectTab(pageKeys[widget.page ?? 2], widget.page ?? 2);

    Future.delayed(Duration(seconds: 2));
    widget.directChatDetail
        ? Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(
                Id: widget.id,
                image: widget.photoString,
                diffentPage: 0,
                isGroup: 0,
                blocked: false,
                online: false,
                directLink: true,
              ),
            ),
          )
        : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  AnimationController? controller;
  List<int> targetUserIdList = [];
  bool loading = true;
  void initController() {
    controller = BottomSheet.createAnimationController(this);
    controller!.duration = const Duration(milliseconds: 100);
    controller!.reverseDuration = const Duration(milliseconds: 100);
  }
/*
  @override
  void didChangeDependencies() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("homepage içi");
      print(Counter);
      if (message.data["notificationTemplateType"].toString() == "16" &&
          Counter == 1) {
        Counter++;
        await Permission.camera.request();
        await Permission.microphone.request();
        AwesomeDialog(
          context: context,
          btnCancelIcon: Icons.call_end,
          btnOkIcon: Icons.phone_in_talk,
          btnCancelText: AppLocalizations.of(context).decline,
          btnOkText: AppLocalizations.of(context).accept,
          customHeader: CircleAvatar(
            backgroundColor: Get.theme.primaryColor,
            child: Icon(
              Icons.wifi_calling_3,
              size: 40,
              color: Colors.black,
            ),
            radius: 40,
          ),
          animType: AnimType.BOTTOMSLIDE,
          title: message.data["message"],
          desc: AppLocalizations.of(context).calling,
          btnCancelOnPress: () {
            Counter == 1;
          },
          btnOkOnPress: () {
            Counter == 1;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CallWeSlide(
                    url: message.data["meetingUrl"],
                  ),
                ));
          },
        )..show().whenComplete(() {
            Counter == 1;
          });
      }
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    super.didChangeDependencies();
  }

 */

/*
  void showAsBottomSheet(String url) async {
    final result = await showSlidingBottomSheet(context, builder: (context) {
      return SlidingSheetDialog(
        extendBody: true,
        avoidStatusBar: true,
        isBackdropInteractable: true,
        elevation: 8,
        cornerRadius: 16,
        margin: EdgeInsets.only(bottom: 100),
        minHeight: 127,
        isDismissable: false,
        snapSpec: const SnapSpec(
          snap: true,
          snappings: [0.4, 0.7, 1.0],
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        builder: (context, state) {
          return Container(
            height: Get.height - 200,
            child: Stack(
              children: [
                InAppWebView(
                    androidOnPermissionRequest:
                        (InAppWebViewController controller, String origin,
                            List<String> resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                      userAgent:
                          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 OPR/81.0.4196.60",
                    )),
                    initialUrl: url),
                Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Get.theme.primaryColor),
                      child: Icon(Icons.close),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    });

    print(result); // This is the result.
  }

 */
  @override
  Widget build(BuildContext context) {
    /*return PersistentTabView.custom(
        context,
        controller: _controller,
        itemCount: 5, // This is required in case of custom style! Pass the number of items for the nav bar.
        screens: _tabPage,
        hideNavigationBarWhenKeyboardShows: true,
        confineInSafeArea: false,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        customWidget: CustomNavBarWidget( // Your custom widget goes here
          items: _navBarsItems(),
          size: MediaQuery.of(context).size,
          selectedIndex: _controller.index,
          onItemSelected: (index) {
            setState(() {
              _controller.index = index; // NOTE: THIS IS CRITICAL!! Don't miss it!
            });
          },
        ),
    );*/

    void _onPageChanged(index) {
      setState(() {
        currentTab = index;
      });
    }

    final PageStorageBucket bucket = new PageStorageBucket();

    Widget buildOffstageNavigator(String tabItem) {
      return Offstage(
        offstage: _currentPage != tabItem,
        child: TabNavigator(
          navigatorKey: _navigatorKeys[tabItem]!,
          tabItem: tabItem,
        ),
      );
    }

    final Size size = MediaQuery.of(context).size;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<ControllerBottomNavigationBar>(builder: (c) {
      var shortestSize = Get.size.shortestSide;
      var isTablet = shortestSize > 600;
      if (c.goHomePage) {
        _currentPage = pageKeys[2];
        currentTab = 2;
        c.goHomePage = false;
      }
      if (c.goCollabPage) {
        _currentPage = pageKeys[1];
        currentTab = 1;
        c.goCollabPage = false;
      }
      return WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
          if (isFirstRouteInCurrentTab) {
            if (_currentPage != "HomePage") {
              _selectTab("HomePage", 2);

              return false;
            }
          }
          return isFirstRouteInCurrentTab;
        },
        child: ModalProgressHUD(
            child: Scaffold(
              extendBody: true,
              key: globalKey,
              body: Stack(children: <Widget>[
                buildOffstageNavigator("ChatPage"),
                buildOffstageNavigator("MessagePage"),
                buildOffstageNavigator("HomePage"),
                buildOffstageNavigator("NotePage"),
                buildOffstageNavigator("CalendarPage"),
                buildOffstageNavigator("SearchPage"),
                buildOffstageNavigator("DocumentAnalyz"),
              ]),
              bottomNavigationBar: Container(
                width: size.width,
                height: MediaQuery.of(context).size.shortestSide > 600
                    ? (Get.height > 800 ? Get.height * 0.09 : Get.height * 0.15)
                    : Get.height * 0.08,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // isTablet
                    //     ? SizedBox()
                    //     : CustomPaint(
                    //         size: Size(size.width, 80),
                    //         painter: BNBCustomPainter(context: context),
                    //       ),
                    Center(
                      heightFactor: isTablet ? 0.2 : 0.0,
                      child: isTablet
                          ? FloatingActionButton.large(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0))),
                              heroTag: "buildbottomnavigaTablet",
                              backgroundColor: Get.theme.secondaryHeaderColor,
                              child: Image.asset(
                                'assets/images/app_logo/logobeyaz.png',
                                width: 50,
                                height: 50,
                              ),
                              elevation: 0.1,
                              onPressed: () {
                                /*Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomePage()
                              ));*/
                                setBottomBarIndex(2);
                              })
                          : SizedBox(
                              width: Get.width / 8, // Customize this width
                              height: Get.width / 8, // Customize this height
                              child: FloatingActionButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                heroTag: "buildbottomnaviga",
                                backgroundColor: Get.theme.secondaryHeaderColor,
                                child: Image.asset(
                                  'assets/images/app_logo/logobeyaz.png',
                                  width: 35,
                                  height: 35,
                                ),
                                elevation: 0.1,
                                onPressed: () {
                                  setBottomBarIndex(2);
                                },
                              ),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _bottomBarButtonForTablet(
                                  context,
                                  3,
                                  'assets/images/icon/calendar.png',
                                  AppLocalizations.of(context)!.calendar,
                                  Get.theme.colorScheme.onTertiaryContainer),
                              Stack(alignment: Alignment.center, children: [
                                _bottomBarButtonForTablet(
                                    context,
                                    0,
                                    'assets/images/icon/chat.png',
                                    AppLocalizations.of(context)!.chat,
                                    HexColor('#27d1df')),
                                GetBuilder<ControllerChatNew>(
                                    builder: (_) => _controllerChatNew
                                                .TotalCount ==
                                            0
                                        ? Container()
                                        : Positioned(
                                            top: 14,
                                            right: 3,
                                            child: Container(
                                              height: 15,
                                              width: 15,
                                              decoration: BoxDecoration(
                                                  color: Get.theme.primaryColor,
                                                  shape: BoxShape.circle),
                                              child: Center(
                                                child: Text(
                                                  _controllerChatNew.TotalCount
                                                      .toString(),
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              ),
                                            ),
                                          ))
                              ]),
                              _bottomBarButtonForTablet(
                                context,
                                5,
                                'assets/images/icon/documents.png',
                                AppLocalizations.of(context)!.search,
                                Get.theme.colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: size.width * 0.18,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _bottomBarButtonForTablet(
                                context,
                                4,
                                'assets/images/icon/sticky-notes.png',
                                AppLocalizations.of(context)!.note,
                                HexColor('#5be676'),
                              ),
                              _bottomBarButtonForTablet(
                                context,
                                6,
                                'assets/images/icon/search-document.png',
                                AppLocalizations.of(context)!.analyzeDocument,
                                Get.theme.colorScheme.onSecondaryContainer,
                              ),
                              _bottomBarButtonForTablet(
                                context,
                                1,
                                'assets/images/icon/inbox-mail.png',
                                AppLocalizations.of(context)!.digiPost,
                                HexColor('#3c7e73'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )

                    // : Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //     children: [
                    //       Stack(alignment: Alignment.center, children: [
                    //         _bottomBarButton(
                    //             context,
                    //             0,
                    //             'assets/images/icon/message.png',
                    //             AppLocalizations.of(context).chat),
                    //         GetBuilder<ControllerChatNew>(
                    //             builder: (_) => _controllerChatNew
                    //                         .TotalCount ==
                    //                     0
                    //                 ? Container()
                    //                 : Positioned(
                    //                     top: 14,
                    //                     right: 3,
                    //                     child: Container(
                    //                       height: 15,
                    //                       width: 15,
                    //                       decoration: BoxDecoration(
                    //                           color: Get.theme.primaryColor,
                    //                           shape: BoxShape.circle),
                    //                       child: Center(
                    //                         child: Text(
                    //                           _controllerChatNew.TotalCount
                    //                               .toString(),
                    //                           style:
                    //                               TextStyle(fontSize: 10),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ))
                    //       ]),
                    //       _bottomBarButton(
                    //           context,
                    //           1,
                    //           'assets/images/icon/postoffice.png',
                    //           AppLocalizations.of(context).officeBox),
                    //       Container(
                    //         width: size.width * 0.20,
                    //       ),
                    //       _bottomBarButton(
                    //           context,
                    //           3,
                    //           'assets/images/icon/calendar.png',
                    //           AppLocalizations.of(context).calendar),
                    //       _bottomBarButton(
                    //           context,
                    //           4,
                    //           'assets/images/icon/notebook.png',
                    //           AppLocalizations.of(context).note),
                    //     ],
                    //   )
                  ],
                ),
              ),
            ),
            inAsyncCall: c.lockUI),
      );
    });
  }

  Column _bottomBarButton(BuildContext context, int currentTabNumber,
      String imagePath, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(.0),
          child: Container(
            width: 55,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all((Radius.elliptical(20, 20))),
              color: currentTab == currentTabNumber
                  ? Get.theme.colorScheme.secondary
                  : Colors.white,
            ),
            child: IconButton(
                autofocus: true,
                icon: ImageIcon(
                  AssetImage(imagePath),
                  color: Colors.black54,
                ),
                onPressed: () {
                  setBottomBarIndex(currentTabNumber);
                }),
          ),
        ),
        Text(title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: currentTab == currentTabNumber
                  ? Colors.black87
                  : Colors.black54,
            ))
      ],
    );
  }

  Widget _bottomBarButtonForTablet(
    BuildContext context,
    int currentTabNumber,
    String imagePath,
    String title,
    Color backgroundColor,
  ) {
    return _customDashboardIconWithTextForTablet(
        text: title,
        icon: imagePath,
        color: backgroundColor,
        currentTabNumber: currentTabNumber);
  }

  _navBarsItems() {
    double scale = 0.8;
    return [
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.business),
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.business),
          ),
        ),
        title: AppLocalizations.of(context)!.bottomNavbarBusiness,
        textStyle: TextStyle(fontSize: 11),
        activeColorPrimary: theme,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.business_center),
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.business_center),
          ),
        ),
        title: AppLocalizations.of(context)!.bottomNavbarPrivate,
        activeColorPrimary: theme,
        textStyle: TextStyle(fontSize: 11),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.business_center),
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.business_center),
          ),
        ),
        title: AppLocalizations.of(context)!.bottomNavbarPrivate,
        activeColorPrimary: theme,
        textStyle: TextStyle(fontSize: 11),
        inactiveColorPrimary: Colors.grey,
      ),
      /*PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: 1,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Get.theme.backgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(2, 2), // changes position of shadow
                ),
              ],
            ),
            child: Center(
                child: Image.asset(
              'assets/images/app_logo/vir2ell-logo.png',
              width: 40,
              height: 40,
            )),
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: 1,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Get.theme.backgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(2, 2), // changes position of shadow
                ),
              ],
            ),
            child: Center(
                child: Image.asset(
              'assets/images/app_logo/vir2ell-logo.png',
              width: 35,
              height: 35,
            )),
          ),
        ),
        activeColorPrimary: Get.theme.backgroundColor,
        inactiveColorPrimary: Get.theme.backgroundColor,
      ),*/
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.chat),
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.chat),
          ),
        ),
        title: AppLocalizations.of(context)!.bottomNavbarChat,
        activeColorPrimary: theme,
        textStyle: TextStyle(fontSize: 11),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.grid_view),
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Icon(Icons.grid_view),
          ),
        ),
        title: AppLocalizations.of(context)!.bottomNavbarCollaboration,
        activeColorPrimary: theme,
        textStyle: TextStyle(fontSize: 11),
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  getPage(int currentTab) {
    return _tabPage[currentTab];
  }

  void setBottomBarIndex(int i) {
    setState(() {
      _selectTab(pageKeys[i], i);
    });
  }

  Widget _customDashboardIconWithTextForTablet(
      {String? text, String? icon, Color? color, int? currentTabNumber}) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;

    return GestureDetector(
      onTap: () {
        setBottomBarIndex(currentTabNumber!);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _customDashboardIcons(icon!, color!),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: Get.width > 800 ? shortestSide / 10 : shortestSide / 12,
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    text!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 7,
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Container _customDashboardIcons(String icon, Color color) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return Container(
      height: Get.width > 800 ? shortestSide / 8 : shortestSide / 9,
      width: Get.width > 800 ? shortestSide / 8 : shortestSide / 9,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(
              isTablet ? Radius.elliptical(10, 15) : Radius.elliptical(8, 10)),
          border: Border.all(width: 1, color: color)),
      child: Align(
        alignment: Alignment.center,
        child: Image.asset(icon,
            width: isTablet ? 35 : 20, height: 35, color: Colors.white),
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final BuildContext context;
  BNBCustomPainter({required this.context});
  @override
  void paint(Canvas canvas, Size size) {
    var shortestSize = MediaQuery.of(context).size.shortestSide;
    var isTablet = shortestSize > 600;
    var height = Get.size.height;
    print('height: $height');

    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 5); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0,
        size.width * (isTablet ? (height > 750 ? 0.42 : 0.45) : 0.40), 20);
    path.arcToPoint(
        Offset(
            size.width * (isTablet ? (height > 750 ? 0.58 : 0.55) : 0.60), 20),
        radius: Radius.circular(20.0),
        clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
 */
