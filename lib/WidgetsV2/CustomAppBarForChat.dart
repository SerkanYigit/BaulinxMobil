import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';

class CustomAppBarForChat extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool? isHomePage;
  final bool? showNotification;
  final Widget? actionWidget;
  final Function(String)? onChanged; // Add this prop for onChanged callback
  final Function()? openFilterFunction;
  final Function()? openBoardFunction;
  final String? totalCount;
  final bool? commonResult;

  CustomAppBarForChat({
    Key? key,
      required this.title,
    this.isHomePage = false,
    this.showNotification = true,
    this.actionWidget,
    this.totalCount,
    this.commonResult,
    this.onChanged, // Add this prop to constructor
    this.openFilterFunction,
    this.openBoardFunction,
  }) : super(key: key);

  @override
  _CustomAppBarForChatState createState() => _CustomAppBarForChatState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomAppBarForChatState extends State<CustomAppBarForChat> {
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  ControllerDB _controllerDB = Get.put(ControllerDB());

  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  widget.onChanged != null ? widget.onChanged!(value) : null; // Trigger the onChanged callback
                },              )
            : Text(widget.title!),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (widget.isHomePage != null && widget.isHomePage!) {
              _controllerBottomNavigationBar.goHomePage = true;
              _controllerBottomNavigationBar.update();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          widget.actionWidget == null ? Container() : widget.actionWidget!,
          Padding(
            padding: const EdgeInsets.only(bottom:8.0),
            child: Stack(
                    children: [
                      Container(
                        height: 45,
                        width: 45,
                        padding: EdgeInsets.all(5), // Add padding here
                        child: IconButton(
                          //! Onpress butonu boj
                          onPressed: (){},
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:8.0),
            child: IconButton(
              icon: ImageIcon(AssetImage('assets/images/icon/filter.png')),
              onPressed: () {
                widget.openFilterFunction != null ? widget.openFilterFunction!() : null;
              },
              color: Colors.black54,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
            child: Stack(
              children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Get
                            .theme.primaryColor,
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                              widget.commonResult == true
                                  ? '${1} / ${widget.totalCount}'
                                  : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                  fontWeight:
                                      FontWeight.bold),
                            )
                    )),),
              ]
            ),
          ),
          
        ],
      ),
    );
  }
}
