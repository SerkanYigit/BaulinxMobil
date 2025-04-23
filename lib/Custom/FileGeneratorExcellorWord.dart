import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFileView.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FileGeneratorExcellorWord extends StatefulWidget {
  final bool? isWord;

  const FileGeneratorExcellorWord({
    Key? key,
     this.isWord,
  }) : super(key: key);

  @override
  _FileGeneratorExcellorWordState createState() =>
      _FileGeneratorExcellorWordState();
}

class _FileGeneratorExcellorWordState extends State<FileGeneratorExcellorWord> {
  final GlobalKey webViewKey = GlobalKey();
  ControllerFileView _contFileView = Get.put(ControllerFileView());
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  final ReceivePort _port = ReceivePort();
  static final String baseUrlShareWork = "https://onlinefiles.dsplc.net";

  @override
  void initState() {
    super.initState();

    _prepareSaveDir();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(

  url: WebUri(widget.isWord! 
                    ? "${baseUrlShareWork}/de-DE/${'DocumentManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${0}&moduleType=${"PrivateDocument"}"
                    : "${baseUrlShareWork}/de-DE/${'SpreadsheetManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${0}&moduleType=${"PrivateDocument"}"
                )





              /*   url: Uri.parse
                (widget.isWord
                    ? "${baseUrlShareWork}/de-DE/${'DocumentManagement'}/MobileIndex?userId=${_controllerDB.user.value.result!.id}&moduleId=${0}&moduleType=${"PrivateDocument"}"
                    : "${baseUrlShareWork}/de-DE/${'SpreadsheetManagement'}/MobileIndex?userId=${_controllerDB.user.value.result!.id}&moduleId=${0}&moduleType=${"PrivateDocument"}"
                    ) */
                    ),
         
         
          );
        }
      },
    );
  }

  String? _localPath;
  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());
    final savedDir = Directory(_localPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        final directory = "/storage/emulated/0/Download/";
        externalStorageDirPath = directory;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("Official InAppWebView website")),
      body: Container(
        height: Get.height,
        child: Column(children: <Widget>[
          Container(
            width: Get.width,
            height: 100,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: 10, right: 20),
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                      )),
                ),
                Spacer(),
                InkWell(
                    onTap: () async {},
                    child: Icon(Icons.share, color: Colors.black)),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                    onTap: () async {},
                    child: Icon(Icons.file_download, color: Colors.black)),
                SizedBox(
                  width: 15,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(



 url: WebUri(widget.isWord! 
                 //     url: Uri.parse(widget.isWord
                          ? "${baseUrlShareWork}/de-DE/${'DocumentManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${0}&moduleType=${"PrivateDocument"}"
                          : "${baseUrlShareWork}/de-DE/${'SpreadsheetManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${0}&moduleType=${"PrivateDocument"}"
                          )



                          ),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                      print("onloaded :" + urlController.text);
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController!.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController!.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController!.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          /*ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      webViewController?.goBack();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      webViewController?.goForward();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      webViewController?.reload();
                    },
                  ),
                ],
              ),*/
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _controllerFiles.refreshPrivate = true;
    _controllerFiles.update();
    super.dispose();
  }
}
