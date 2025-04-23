import 'package:flutter/material.dart';

class DraggablePageRoute<T> extends PageRouteBuilder<T> {
  final Widget? widget;

  DraggablePageRoute({this.widget})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget!;
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return Stack(
              children: [
                child,
                DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.2,
                  maxChildSize: 1.0,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      color: Colors.white,
                      child: ListView(
                        controller: scrollController,
                        children: [
                          child,
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
}
