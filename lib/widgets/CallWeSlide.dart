import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:undede/landingPage.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:we_slide/we_slide.dart';

class CallWeSlide extends StatefulWidget {
  final String url;
  CallWeSlide({Key? key, required this.url}) : super(key: key);

  @override
  _CallWeSlideState createState() => _CallWeSlideState();
}

PanelController _pc = new PanelController();
double _panelMinSize = 127.0;

class _CallWeSlideState extends State<CallWeSlide> {
  bool panelType = false;
  double _panelMaxSize = 0;

  @override
  void initState() {
    _panelMinSize = 127.0;
    _panelMaxSize = Get.height;
    super.initState();
  }

  bool closeCall = false;

  @override
  Widget build(BuildContext context) {
    final WeSlideController _controller = WeSlideController();
    return Scaffold(
      body: SlidingUpPanel(
        controller: _pc,
        defaultPanelState: PanelState.OPEN,
        onPanelClosed: () {
          setState(() {
            panelType = _pc.isPanelClosed;
            _panelMinSize = 0.0;
            print(_panelMinSize);
          });
        },
        onPanelOpened: () {
          setState(() {
            panelType = false;
          });
        },
        panel: closeCall
            ? Container()
            : Container(
                child: Stack(
                  children: [
                    InAppWebView(
                      androidOnPermissionRequest:
                          (InAppWebViewController controller, String origin,
                              List<String> resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: false,
                          userAgent:
                              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36 OPR/84.0.4316.21",
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                        ),
                      ),
                      initialUrlRequest: URLRequest(

                        //! url: Uri.parse(widget.url),  den degistirildi
                        url: WebUri.uri(Uri.parse(widget.url)),
                      ),
                    ),
                    Positioned(
                      right: 13,
                      bottom: 9,
                      child: GestureDetector(
                        onTap: () async {
                          _panelMinSize = 0.0;
                          await _pc.close();
                          setState(() {
                            panelType = false;
                            closeCall = true;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        body: Stack(
          children: [
            LandingPage(),
            Positioned(
              bottom: 100,
              left: 0,
              child: panelType
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _pc.open();
                          _panelMinSize = 170.0;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                            color: Get.theme.secondaryHeaderColor,
                            shape: BoxShape.circle),
                        child: Center(
                            child: Icon(
                          Icons.phone_in_talk,
                          color: Colors.white,
                        )),
                      ),
                    )
                  : Container(),
            )
          ],
        ),
        maxHeight: _panelMaxSize - 200,
        minHeight: _panelMinSize,
        margin: EdgeInsets.only(bottom: 100),
      ),
    );
  }
}
