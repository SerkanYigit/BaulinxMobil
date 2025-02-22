import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';

class headerWidget extends StatefulWidget {
  final String? headerTitle;
  final int? notHomePage;
  final bool? showNotifications;

  const headerWidget(
      {Key? key,
      @required this.headerTitle,
      this.notHomePage,
      this.showNotifications = true})
      : super(key: key);
  @override
  _headerWidgetState createState() => _headerWidgetState();
}

class _headerWidgetState extends State<headerWidget> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: 105,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: BoxDecoration(
        color: Get.theme.secondaryHeaderColor,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                                                    },
                          child: Icon(
                            Icons.arrow_back,
                            color: Get.theme.primaryColor,
                          )),
                      SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: Text(
                          widget.headerTitle!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
                widget.showNotifications!
                    ? Row(
                        children: [
                          InkWell(
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
                                  height: 40,
                                  width: 40,
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: Get.theme.primaryColor,
                                    size: 27,
                                  ),
                                ),
                                Positioned(
                                    top: 1,
                                    right: 1,
                                    child: Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: Get.theme.primaryColor,
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: Text(
                                            _controllerDB
                                                .notificationUnreadCount
                                                .toString(),
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        )))
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
