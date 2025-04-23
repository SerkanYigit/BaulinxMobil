/* import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:motion_tab_bar_v2/motion-badge.widget.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
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
import 'package:undede/Clean_arch/features/detail_page/view/detail_page.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

@immutable
class BuildBottomNavigationBar extends StatefulWidget {
  int? page;
  int? subDashboardPage;
  bool? goAccounPage;
  bool directChatDetail;
  int id;
  String photoString;

  BuildBottomNavigationBar(
      {this.page,
      this.subDashboardPage,
      this.goAccounPage,
      this.id = 0,
      this.photoString = '',
      this.directChatDetail = false});

  @override
  _BuildBottomNavigationBarState createState() =>
      _BuildBottomNavigationBarState();
}

class _BuildBottomNavigationBarState extends State<BuildBottomNavigationBar>
    with TickerProviderStateMixin {
  List<Widget> _tabPage = [
    //FavoritePage(),
    Container(),
  ];
  MotionTabBarController? _motionTabBarController;
  PersistentTabController? _controller;
  int currentTab = 0;
  String _currentPage = "HomePage";

  List<String> pageKeys = [
    // "HomePage3",
    "DashBoardNew",
    "MessagePage",
    "ChatPage",
    "CalendarPage",
    // "SearchPage",
    "DocumentAnalyz",
    //  "HomePage2",
  ];

  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    //  "HomePage3": GlobalKey<NavigatorState>(),
    "DashBoardNew": GlobalKey<NavigatorState>(),
    "MessagePage": GlobalKey<NavigatorState>(),
    "ChatPage": GlobalKey<NavigatorState>(),
    "CalendarPage": GlobalKey<NavigatorState>(),
    // "SearchPage": GlobalKey<NavigatorState>(),
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
  //Color theme = Get.theme.colorScheme.secondary;
  //Color background = Get.theme.colorScheme.surface;
  int Counter = 1;
  PageController pageController = new PageController();

  @override
  void initState() {
    // TODO: implement initState

    _motionTabBarController = MotionTabBarController(
      initialIndex: 1,
      length: 8,
      vsync: this,
    );
    super.initState();
    //_controller = PersistentTabController(initialIndex: widget.page ?? 0);
    //! _selectTab(null widget.page ?? 2); den degistirildi
    _selectTab(pageKeys[widget.page ?? 0], widget.page ?? 0);

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

  @override
  void dispose() {
    pageController.dispose();
    controller?.dispose();
    _motionTabBarController?.dispose();
    super.dispose();
  }

  AnimationController? controller;
  List<int> targetUserIdList = [];
  bool loading = true;
  void initController() {
    controller = BottomSheet.createAnimationController(this);
    controller!.duration = const Duration(milliseconds: 100);
    controller!.reverseDuration = const Duration(milliseconds: 100);
  }

  @override
  Widget build(BuildContext context) {
    void _onPageChanged(index) {
      setState(() {
        currentTab = index;
      });
    }

    final PageStorageBucket bucket = new PageStorageBucket();
    double ikonHeights = 15;
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
        _currentPage = pageKeys[0];
        currentTab = 0;
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
              _selectTab("HomePage", 0);

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
                  // buildOffstageNavigator("HomePage3"),
                  buildOffstageNavigator("DashBoardNew"),
                  buildOffstageNavigator("MessagePage"),
                  buildOffstageNavigator("ChatPage"),
                  buildOffstageNavigator("CalendarPage"),

                  //  buildOffstageNavigator("SearchPage"),
                  // buildOffstageNavigator("HomePage2"),
                  buildOffstageNavigator("DocumentAnalyz"),
                  //buildOffstageNavigator("NotePage"),
                  //   buildOffstageNavigator("HomePage2"),
                ]),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  useLegacyColorScheme: false,
                  showUnselectedLabels: true,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
                  selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
                  unselectedItemColor: primaryBlackColor,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color.fromARGB(255, 219, 157, 12),
                  onTap: (int val) {
                    setState(() {
                      //   _motionTabBarController!.index = val;
                      setBottomBarIndex(val);
                    });
                    //  setState(() => _index = val);
                  },
                  currentIndex: currentTab,
                  items: [
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
                    /*    BottomNavigationBarItem(
                        /*   activeIcon: CircleAvatar(
                          backgroundColor: primaryYellowColor,
                          child: Icon(Icons.home_outlined),
                        ), */
                        activeIcon: Container(
                          width: 70,
                          // height: 80,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryYellowColor,
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(30, 40)),
                          ),
                          child: Icon(Icons.home_outlined),
                        ),
                        icon: Icon(Icons.home_outlined)
                        //Icon(Icons.mail_outline_outlined)
                        ,
                        label: 'Home'), */
                    BottomNavigationBarItem(
                      activeIcon: Container(
                        width: 50,
                        // height: 80,
                        padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 240, 220, 170),
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(40, 40)),
                        ),
                        child: Image.asset(
                          'assets/images/icon/warehouse.png',
                          height: ikonHeights,
                        ),
                      ),
                      icon: Image.asset(
                        'assets/images/icon/warehouse.png',
                        height: ikonHeights,
                      )
                      //Icon(Icons.mail_outline_outlined)
                      ,
                      label: 'Home',
                    ),

                    BottomNavigationBarItem(
                        activeIcon: Container(
                          width: 50,
                          // height: 80,
                          padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 220, 170),
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(40, 40)),
                          ),
                          child: Image.asset(
                            'assets/images/icon/inbox-mail.png',
                            height: ikonHeights,
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/icon/inbox-mail.png',
                          height: ikonHeights,
                        )
                        //Icon(Icons.mail_outline_outlined)
                        ,
                        label: 'Mail'),

                    BottomNavigationBarItem(
                        activeIcon: Container(
                          width: 70,
                          // height: 80,
                          padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 220, 170),
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(30, 40)),
                          ),
                          child: Image.asset(
                            'assets/images/icon/chat.png',
                            height: ikonHeights,
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/icon/chat.png',
                          height: ikonHeights,
                        ),
                        label: 'Chat'),
                    BottomNavigationBarItem(
                        activeIcon: Container(
                          width: 70,
                          // height: 80,
                          padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 220, 170),
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(30, 40)),
                          ),
                          child: Image.asset(
                            'assets/images/icon/calendar.png',
                            height: ikonHeights,
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/icon/calendar.png',
                          height: ikonHeights,
                        ),
                        label: 'Calendar'),
                    BottomNavigationBarItem(
                        activeIcon: Container(
                          width: 70,
                          // height: 80,
                          padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 220, 170),
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(30, 40)),
                          ),
                          child: Image.asset(
                            'assets/images/icon/search-document.png',
                            height: ikonHeights,
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/icon/search-document.png',
                          height: ikonHeights,
                        ),
                        label: 'Cloud'),
                  ],
                )
                /*    
              Container(
                width: size.width,
                height: 110,
                child: FloatingNavbar(
                  onTap: (int val) {
                    setState(() {
                      //   _motionTabBarController!.index = val;
                      setBottomBarIndex(val);
                    });
                    //  setState(() => _index = val);
                  },
                  currentIndex: currentTab,
                  items: [
                    FloatingNavbarItem(icon: Icons.home, title: 'Home'),
                    FloatingNavbarItem(
                        icon: Icons.mail_outline_outlined, title: 'Mail'),
                    FloatingNavbarItem(icon: Icons.chat, title: 'Chat'),
                    FloatingNavbarItem(
                        icon: Icons.calendar_month, title: 'Calendar'),
                    FloatingNavbarItem(icon: Icons.search, title: 'Ocr'),
                  ],
                ),
              ),
 */
                /*         
              CrystalNavigationBar(
                outlineBorderColor: primaryYellowColor,
                width: 400,
                curve: Curves.easeInOut,
                currentIndex: currentTab,
                //_SelectedTab.values.indexOf(_selectedTab),
                height: 40,
                enableFloatingNavBar: true,
            
                //  indicatorColor: Colors.blue,
                unselectedItemColor: Colors.white70,
                backgroundColor: primaryBlackColor,
                //Color.fromARGB(254, 225, 228, 234),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 11,
                    spreadRadius: 1,
                    offset: Offset(0, 10),
                  ),
                ],
                onTap: (int value) {
                  setState(() {
                    //  _motionTabBarController!.index = value;
                    setBottomBarIndex(value);
                  });
                },
                //_handleIndexChanged,
                items: [
                  CrystalNavigationBarItem(
                    icon: IconlyBold.home,
                    unselectedIcon: IconlyLight.home,
                    selectedColor: Colors.white,
                    unselectedColor: primaryYellowColor,
                  ),
            
                  /// Add
                  CrystalNavigationBarItem(
                    icon: Icons.mail_outlined,
                    unselectedIcon: Icons.mail_outlined,
                    selectedColor: Colors.white,
                    unselectedColor: primaryYellowColor,
                  ),
            
                  /// Home
                  CrystalNavigationBarItem(
                    icon: IconlyLight.chat,
                    unselectedIcon: IconlyLight.chat,
                    selectedColor: Colors.white,
                    unselectedColor: primaryYellowColor,
                  ),
            
                  /// Favourite
                  CrystalNavigationBarItem(
                    icon: IconlyBold.calendar,
                    unselectedIcon: IconlyLight.calendar,
                    selectedColor: Colors.white,
                    unselectedColor: primaryYellowColor,
                  ),
            
                  /// Add
            
                  /// Search
                  CrystalNavigationBarItem(
                    icon: IconlyBold.search,
                    unselectedIcon: IconlyLight.search,
                    selectedColor: Colors.white,
                    unselectedColor: primaryYellowColor,
                  ),
            
                  /// Profile
                  CrystalNavigationBarItem(
                    icon: IconlyBold.bag_2,
                    unselectedIcon: IconlyLight.bag_2,
                    selectedColor: Colors.white,
                    unselectedColor: primaryYellowColor,
                  ),
                ],
              ),
             */
                /* 
                  MotionTabBar(
               
                controller:
                    _motionTabBarController, // ADD THIS if you need to change your tab programmatically
                initialSelectedTab: "Home",
                useSafeArea: true, // default: true, apply safe area wrapper
            
                    labels: const [
                    "Home",
                  "Post",
                  "Chat",
                  "Calendar",
                  "Search",
                  "Analyz", 
                ],
            
                icons: [
                  Icons.home_outlined,
                  Icons.mail_outline_sharp,
                  Icons.chat_outlined,
                  Icons.calendar_month_outlined,
                  Icons.content_paste_search_sharp,
                  Icons.inventory_sharp,
                ],
            
                badges: [
                  null,
            
               /*    _controllerChatNew.TotalCount == 0
                      ? null
                      : MotionBadgeWidget(
                          text: _controllerChatNew.TotalCount.toString(),
                          textColor:
                              Colors.white, // optional, default to Colors.white
                          color: Colors.red, // optional, default to Colors.red
                          size: 18, // optional, default to 18
                        ) */
            
                  // allow null
                 null ,
                  null,
                  null,
                  null,
                  null,
            
                  // Default Motion Badge Widget with indicator only
                  /*  const MotionBadgeWidget(
                    isIndicator: true,
                    color: Colors.red, // optional, default to Colors.red
                    size: 5, // optional, default to 5,
                    show: true, // true / false
                  ), */
                ],
                tabSize: 50,
                tabBarHeight:
                    Get.height > 800 ? Get.height * 0.07 : Get.height * 0.15,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.yellow,
                  fontWeight: FontWeight.w500,
                ),
                tabIconColor: Colors.yellow,
                tabIconSize: 28.0,
                tabIconSelectedSize: 26.0,
                tabSelectedColor: Colors.yellow,
                tabIconSelectedColor: Colors.black,
                tabBarColor: Colors.black,
                onTabItemSelected: (int value) {
                  setState(() {
                    _motionTabBarController!.index = value;
                    setBottomBarIndex(value);
                  });
                },
              ),
             */
                /*   
              Container(
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
                                          )
                                          )
                              ]
                              ),
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
            
             */
                ),
            inAsyncCall: c.lockUI),
      );
    });
  }

/*   Column _bottomBarButton(BuildContext context, int currentTabNumber,
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
 */
  getPage(int currentTab) {
    return _tabPage[currentTab];
  }

  void setBottomBarIndex(int i) {
    setState(() {
      _selectTab(pageKeys[i], i);
    });
  }

  /*  Widget _customDashboardIconWithTextForTablet(
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
 */

  /* Container _customDashboardIcons(String icon, Color color) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return Container(
      height: Get.width > 800 ? shortestSide / 8 : shortestSide / 9,
      width: Get.width > 800 ? shortestSide / 8 : shortestSide / 9,
      decoration: BoxDecoration(
          color: Colors.pink,
          //color,
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
 */
}
/* 
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
 */
