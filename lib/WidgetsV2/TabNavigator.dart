import 'package:flutter/material.dart';
import 'package:undede/Pages/Calendar/CalendarPage.dart';
import 'package:undede/Pages/Chat/ChatPage.dart';
import 'package:undede/Pages/DocumentAnalysis/DocumentAnalysis.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/HomePage%20copy/HomePage.dart';
import 'package:undede/Pages/HomePage/DashBoardNew.dart';
import 'package:undede/Pages/Message/MessagePage.dart';
import 'package:undede/Pages/Note/DetetcsPage.dart';
import 'package:undede/Pages/Note/NotePage.dart';
import 'package:undede/Clean_arch/features/detail_page/view/detail_page.dart';

class TabNavigatorRoutes {
  //sample data
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? tabItem;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (tabItem == "ChatPage")
      child = ChatPage();
    else if (tabItem == "MessagePage")
      child = MessagePage();
    else if (tabItem == "DashBoardNew")
      child = DashBoardNew();
    // else if (tabItem == "HomePage3")
    //  child = HomePage3();
    else if (tabItem == "CalendarPage")
      child = CalendarPage();
    else if (tabItem == "NotePage")
      child = DetetcsPage();
    else if (tabItem == "SearchPage")
      child = GeneralSearchPage();
    else if (tabItem == "DocumentAnalyz")
      child = DocumentAnalysis();
    else
      child = Container(); //! sonradan eklendi.
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
