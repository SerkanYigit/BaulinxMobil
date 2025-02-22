import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHomePage;
  final bool showNotification;
  final Widget? actionWidget;
  final Function? onBackPress;
  final bool isCollabDetail;
  CustomAppBar(
      {Key? key,
      required this.title,
      this.isHomePage = false,
      this.showNotification = true,
      this.actionWidget,
      this.onBackPress,
      this.isCollabDetail = false})
      : super(key: key);

  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  ControllerDB _controllerDB = Get.put(ControllerDB());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: isCollabDetail
              ? Icon(Icons.close)
              : Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (isCollabDetail == true) {
              onBackPress != null ? onBackPress!() : null;
            } else if (isHomePage) {
              _controllerBottomNavigationBar.goHomePage = true;
              _controllerBottomNavigationBar.update();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        /*       actions: [
          actionWidget.isNull ? Container() : actionWidget,
          showNotification
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                NotificationPage()));
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 45,
                        width: 45,
                        padding: EdgeInsets.all(5), // Add padding here
                        child: IconButton(
                          icon: ImageIcon(
                            AssetImage('assets/images/icon/notification.png'),
                          ),
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                          top: 0,
                          right: 2,
                          child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Get.theme.primaryColor,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  _controllerDB.notificationUnreadCount
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              )))
                    ],
                  ),
                )
              : Container(),
        ], */
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(60);
}
