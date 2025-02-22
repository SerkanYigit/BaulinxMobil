import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Custom/CustomLoadingCircle.dart';

class AnimatedCourierSearch extends StatefulWidget {
  String text;

  AnimatedCourierSearch({required this.text});

  @override
  State<AnimatedCourierSearch> createState() => _AnimatedCourierSearchState();
}

class _AnimatedCourierSearchState extends State<AnimatedCourierSearch>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _animation;
  bool isLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      buildAnimate();

      setState(() {
        isLoading = false;
      });
    });
  }

  void buildAnimate() {
    setState(() {
      _animationController =
          AnimationController(vsync: this, duration: Duration(seconds: 3));
      _animation = Tween<Offset>(begin: Offset(1, 0), end: Offset(-1, 0))
          .animate(_animationController!);
      _animationController!.forward().whenComplete(() {
        /*print("tamamlandi");
        buildAnimate();*/
        // when animation completes, put your code here
      });
      _animationController!.repeat();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController!.dispose();
    // _animation.removeListener(() { });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CustomLoadingCircle()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
/*      alignment: Alignment.center,
      fit: StackFit.loose,*/
            children: <Widget>[
              // left = x value, top = y value;
              // to set last position (50,10) top:50, left:10, end _animation Offset.zero
              SlideTransition(
                position: _animation!,
                child: AnimatedContainer(
                  height: 150,
                  width: Get.width,
                  alignment: Alignment.center,
                  duration: Duration(seconds: 0),
                  child: Center(
                    child: Image(
                      height: 150,
                      width: 150,
                      image: AssetImage(''),
                    ),
                  ),
                ),
              ),
              widget.text == null
                  ? Container()
                  : Text(
                      widget.text,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
            ],
          );
  }
}
