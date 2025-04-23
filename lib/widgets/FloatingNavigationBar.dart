import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:ionicons/ionicons.dart';
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
class FloatingNavigationBar extends StatefulWidget {
  int? page;
  int? subDashboardPage;
  bool? goAccounPage;
  bool directChatDetail;
  int id;
  String photoString;

  FloatingNavigationBar(
      {this.page,
      this.subDashboardPage,
      this.goAccounPage,
      this.id = 0,
      this.photoString = '',
      this.directChatDetail = false});

  @override
  _FloatingNavigationBarState createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar>
    with TickerProviderStateMixin {
  List<Widget> _tabPage = [
    //FavoritePage(),
    Container(),
  ];
  MotionTabBarController? _motionTabBarController;
  PersistentTabController? _controller;
  int currentTab = 4;
  String _currentPage = "HomePage";

  List<String> pageKeys = [
    // "HomePage3",
    "ChatPage", "MessagePage", "CalendarPage", "SearchPage",
    "DashBoardNew",

    // "SearchPage",
    // "DocumentAnalyz",
    //  "HomePage2",
  ];

  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    //  "HomePage3": GlobalKey<NavigatorState>(),

    "ChatPage": GlobalKey<NavigatorState>(),
    "MessagePage": GlobalKey<NavigatorState>(),
    "CalendarPage": GlobalKey<NavigatorState>(),
    "SearchPage": GlobalKey<NavigatorState>(),
    "DashBoardNew": GlobalKey<NavigatorState>(),

    //"DocumentAnalyz": GlobalKey<NavigatorState>(),
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
    _selectTab(pageKeys[widget.page ?? 4], widget.page ?? 4);

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
        _currentPage = pageKeys[4];
        currentTab = 4;
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
              _selectTab("HomePage", 4);

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
                buildOffstageNavigator("ChatPage"),
                buildOffstageNavigator("MessagePage"),

                buildOffstageNavigator("CalendarPage"),
                buildOffstageNavigator("SearchPage"),
                buildOffstageNavigator("DashBoardNew"),
                //   buildOffstageNavigator("DocumentAnalyz"),
              ]),

              /*        bottomNavigationBar:
                
                
                
                 BottomNavigationBar(
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
                
                 */
              bottomNavigationBar: Container(
                height: 70.0,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.black,
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(36.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Ionicons.chatbubble_ellipses_outline),
                          onPressed: () => setBottomBarIndex(0),
                          //_onItemTapped(0),
                          color: currentTab == 0
                              ? primaryYellowColor
                              : Colors.grey,
                        ),
                        IconButton(
                          icon: Icon(Ionicons.mail_open_outline),
                          onPressed: () => setBottomBarIndex(1),
                          color: currentTab == 1
                              ? primaryYellowColor
                              : Colors.grey,
                        ),
                        SizedBox(width: 48.0),
                        IconButton(
                          icon: Icon(Ionicons.calendar_outline),
                          onPressed: () => setBottomBarIndex(2),
                          color: currentTab == 2
                              ? primaryYellowColor
                              : Colors.grey,
                        ),
                        IconButton(
                          icon: Icon(Ionicons.search_outline),
                          onPressed: () => setBottomBarIndex(3),
                          color: currentTab == 3
                              ? primaryYellowColor
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                isExtended: false,
                onPressed: () {
                  setBottomBarIndex(4);
                  // Ortadaki butona tıklanınca yapılacak işlemler
                },
                child: Image.asset("assets/images/app_logo/news9.png"),
                // Icon(Icons.add),
                backgroundColor: primaryYellowColor,
                // Colors.orange,
                shape: CircleBorder(),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            ),
            inAsyncCall: c.lockUI),
      );
    });
  }

  getPage(int currentTab) {
    return _tabPage[currentTab];
  }

  void setBottomBarIndex(int i) {
    setState(() {
      _selectTab(pageKeys[i], i);
    });
  }
}
