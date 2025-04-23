/* import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:undede/Animation/ScaleRoute.dart';

class CustomNavBarWidget extends StatelessWidget {
  final int? selectedIndex;
  final List<PersistentBottomNavBarItem>?
      items; // NOTE: You CAN declare your own model here instead of `PersistentBottomNavBarItem`.
  final ValueChanged<int>? onItemSelected;
  final Size size;

  CustomNavBarWidget(
      {Key? key,
      this.selectedIndex,
      required this.items,
      this.onItemSelected,
      required this.size});

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      height: 80.0,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                  size: 26.0,
                  color: isSelected
                      ? (item.activeColorSecondary == null
                          ? item.activeColorPrimary
                          : item.activeColorSecondary)
                      : item.inactiveColorPrimary == null
                          ? item.activeColorPrimary
                          : item.inactiveColorPrimary),
              child: item.icon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Material(
              type: MaterialType.transparency,
              child: FittedBox(
                  child: Text(
                item.title ?? '',
                style: TextStyle(
                    color: isSelected
                        ? (item.activeColorSecondary == null
                            ? item.activeColorPrimary
                            : item.activeColorSecondary)
                        : item.inactiveColorPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0),
              )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: size.width,
        height: 80,
        color: Colors.transparent,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(size.width, 80),
              painter: BNBCustomPainter(),
            ),
            Center(
              heightFactor: 0.6,
              child: FloatingActionButton(
                heroTag: "custombottomnavbar",
                backgroundColor: Get.theme.secondaryHeaderColor,
                child: Image.asset(
                  'assets/images/app_logo/logobeyaz.png',
                  width: 35,
                  height: 35,
                ),
                elevation: 0.1, onPressed: () {  },
                /*onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomePage()
                      ));
                    }*/
              ),
            ),
            Container(
              width: size.width,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chat,
                          color: selectedIndex == 0
                              ? Get.theme.colorScheme.surface
                              : Colors.grey.shade400,
                        ),
                        onPressed: () {
                          //setBottomBarIndex(0);
                        },
                        splashColor: Colors.white,
                      ),
                      Text(AppLocalizations.of(context)!.bottomNavbarBusiness,
                          style: TextStyle(
                            fontSize: 11,
                            color: selectedIndex == 0
                                ? Get.theme.colorScheme.surface
                                : Colors.grey.shade400,
                          ))
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.business_center,
                          color: selectedIndex == 1
                              ? Get.theme.colorScheme.surface
                              : Colors.grey.shade400,
                        ),
                        onPressed: () {
                          //setBottomBarIndex(1);
                        },
                        splashColor: Colors.white,
                      ),
                      Text(AppLocalizations.of(context)!.bottomNavbarPrivate,
                          style: TextStyle(
                            fontSize: 11,
                            color: selectedIndex == 1
                                ? Get.theme.colorScheme.surface
                                : Colors.grey.shade400,
                          ))
                    ],
                  ),
                  Container(
                    width: size.width * 0.20,
                  ),
                  Column(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.chat,
                            color: selectedIndex == 2
                                ? Get.theme.colorScheme.surface
                                : Colors.grey.shade400,
                          ),
                          onPressed: () {
                            //setBottomBarIndex(2);
                          }),
                      Text(AppLocalizations.of(context)!.bottomNavbarPrivate,
                          style: TextStyle(
                            fontSize: 11,
                            color: selectedIndex == 2
                                ? Get.theme.colorScheme.surface
                                : Colors.grey.shade400,
                          ))
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.grid_view,
                            color: selectedIndex == 3
                                ? Get.theme.colorScheme.surface
                                : Colors.grey.shade400,
                          ),
                          onPressed: () {
                            //setBottomBarIndex(3);
                          }),
                      Text(AppLocalizations.of(context)!.bottomNavbarPrivate,
                          style: TextStyle(
                            fontSize: 11,
                            color: selectedIndex == 3
                                ? Get.theme.colorScheme.surface
                                : Colors.grey.shade400,
                          ))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

/*Container(
      width: double.infinity,
      height: 80.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          int index = items.indexOf(item);
          return Flexible(
            child: GestureDetector(
              onTap: () {
                this.onItemSelected(index);
              },
              child: _buildItem(item, selectedIndex == index),
            ),
          );
        }).toList(),
      ),
    );*/
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 5); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
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
