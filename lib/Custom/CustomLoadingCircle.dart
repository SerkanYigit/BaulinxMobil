import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CustomLoadingCircle extends StatefulWidget {
  final bool isLoading;
  final Widget? widget;

  CustomLoadingCircle({Key? key, this.isLoading = true,  this.widget})
      : super(key: key);
  @override
  State<CustomLoadingCircle> createState() => _MyCircularState();
}

class _MyCircularState extends State<CustomLoadingCircle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: ModalProgressHUD(
          color: Colors.white,
          inAsyncCall: widget.isLoading,
          progressIndicator: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 200.0,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        child: new CircularProgressIndicator(
                            strokeWidth: 4, color: Colors.black),
                      ),
                    ),
                    Center(
                      child: Container(
                          width: 85,
                          height: 85,
                          child:
                              Image.asset('assets/images/app_logo/news8.png')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: widget.widget == null ? Container() : widget.widget!,
        ),
      ),
    );
  }
}
