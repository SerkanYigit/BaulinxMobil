import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFileView.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Custom/DioDownloader.dart';
import 'package:undede/Custom/ExternalFileActions/ExternalInvite.dart';
import 'package:undede/Custom/ExternalFileActions/ExternalLabelInsert.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Search/SearchResult.dart';

class GenericFileWebView extends StatefulWidget {
  final DirectoryItem? file;
  final Invoice? invoice;
  final SearchResultItem? searchItem;
  final String? messageUrl;
  const GenericFileWebView(
      {Key? key,
       this.file,
      this.invoice,
      this.searchItem,
      this.messageUrl})
      : super(key: key);

  @override
  _GenericFileWebViewState createState() => _GenericFileWebViewState();
}

class _GenericFileWebViewState extends State<GenericFileWebView> {
  final GlobalKey webViewKey = GlobalKey();
  ControllerFileView _contFileView = Get.put(ControllerFileView());
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        userAgent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 OPR/81.0.4196.60",
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
  static final String baseUrlShareWork = kDebugMode
      ? "https://onlinefiles.dsplc.net"
      : "https://onlinefiles.dsplc.net";
  //http://v1.vir2ell-office.com
  @override
  void initState() {
    super.initState();

    _contFileView.file = widget.file;
      _contFileView.invoice = widget.invoice;
      _prepareSaveDir();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController!.reload();
        } else if (Platform.isIOS) {
          webViewController!.loadUrl(
              urlRequest: URLRequest(
                  url:
                  
WebUri.uri( Uri.parse(
  
  widget.file != null
                      ? widget.file!.path!.isDocumentFileName
                          ?
               
                           baseUrlShareWork +
                                            "//de-DE/${'DocumentManagement'}/MobileIndex?path=${widget.file!.path!.split("https://v1.vir2ell-office.com").last.split("MobileIndex?path=").last}&userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.file!.customerId}&moduleType=${giveFileManagerEnum(widget.file!.moduleType!).toString().split("FileManagerType.").last}"
                         : widget.file!.path!.isExcelFileName
            
                           ?   baseUrlShareWork +
                                  "//de-DE/${'SpreadsheetManagement'}/MobileIndex?path=${widget.file!.path!.split("https://v1.vir2ell-office.com").last.split("MobileIndex?path=").last}&userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.file!.customerId}&moduleType=${giveFileManagerEnum(widget.file!.moduleType!).toString().split("FileManagerType.").last}"
                          
                              : widget.file!.path!
                      : widget.messageUrl!.isDocumentFileName
                          ? 
                           baseUrlShareWork +
                              "//de-DE/${'DocumentManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.invoice!.id}&moduleType=${""}"
                         : widget.messageUrl!.isExcelFileName
                            
                          ?   baseUrlShareWork +
                                 "//de-DE/${'SpreadsheetManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.invoice!.id}&moduleType=${""}"
                          
                              : widget.messageUrl.toString()
                          
                              ))));



                  
                  /* WebUri.uri( Uri.parse(widget.file != null
                      ? widget.file.path.isDocumentFileName
                          ? baseUrlShareWork +
                              "//de-DE/${'DocumentManagement'}/MobileIndex?path=${widget.file.path.split("https://v1.vir2ell-office.com").last.split("MobileIndex?path=").last}&userId=${_controllerDB.user.value.result.id}&moduleId=${widget.file.customerId}&moduleType=${giveFileManagerEnum(widget.file.moduleType).toString().split("FileManagerType.").last}"
                          : widget.file.path.isExcelFileName
                              ? baseUrlShareWork +
                                  "//de-DE/${'SpreadsheetManagement'}/MobileIndex?path=${widget.file.path.split("https://v1.vir2ell-office.com").last.split("MobileIndex?path=").last}&userId=${_controllerDB.user.value.result.id}&moduleId=${widget.file.customerId}&moduleType=${giveFileManagerEnum(widget.file.moduleType).toString().split("FileManagerType.").last}"
                              : widget.file.path
                      : widget.messageUrl.isDocumentFileName
                          ? baseUrlShareWork +
                              "//de-DE/${'DocumentManagement'}/MobileIndex?userId=${_controllerDB.user.value.result.id}&moduleId=${widget.invoice.id}&moduleType=${""}"
                          : widget.messageUrl.isExcelFileName
                              ? baseUrlShareWork +
                                  "//de-DE/${'SpreadsheetManagement'}/MobileIndex?userId=${_controllerDB.user.value.result.id}&moduleId=${widget.invoice.id}&moduleType=${""}"
                              : widget.messageUrl))); */
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
    print(widget.file!.toJson());
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
            child: widget.file != null
                ? Row(
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
                      Expanded(
                        child: Container(
                          child: Text(
                            "",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: () async {
                                  await Permission.storage.request();

                                  DioDownloader(
                                      [widget.file!.path!.replaceAll(" ", "%20")],
                                      context);
                                },
                                child: Icon(Icons.file_download,
                                    color: Colors.black)),
                            InkWell(
                                onTap: () async {
                                  //_onAlertExternalLabelInsert(context);
                                  ExternalLabelInsert(context);
                                },
                                child: Icon(Icons.label, color: Colors.black)),
                            InkWell(
                                onTap: () {
                                  ExternalInvite(
                                      context,
                                      widget.invoice!.customerId ?? widget.file!.customerId!,
                                      widget.invoice!.fileId ?? widget.file!.id!
                                          )
                                          ;
                                },
                                child: Icon(Icons.attach_email,
                                    color: Colors.black)),
                            InkWell(
                                onTap: () async {
                                  bool? res = await showModalYesOrNo(
                                      context,
                                      "",
                                      AppLocalizations.of(context)!
                                          .filewillbedeleted);

                                  if (res == true) {
                                    bool haserror = (widget.file!.id != null
                                        ? await DeleteMultiFileAndDirectory()
                                        : await DeleteMultiFileAndDirectoryForSearch());
                                    if (!haserror) {
                                      _controllerFiles.refreshPrivate = true;
                                      _controllerFiles.update();
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child:
                                      Icon(Icons.delete, color: Colors.black),
                                )),
                          ],
                        ),
                      )
                    ],
                  )
                : Row(
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
                          onTap: () async {
                            await FileShareFn([widget.messageUrl!], context);
                          },
                          child: Icon(Icons.share, color: Colors.black)),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                          onTap: () async {
                            await Permission.storage.request();

                            DioDownloader([widget.messageUrl!], context);
                          },
                          child:
                              Icon(Icons.file_download, color: Colors.black)),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
          ),
          /*TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search)
                ),
                controller: urlController,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  var url = Uri.parse(value);
                  if (url.scheme.isEmpty) {
                    url = Uri.parse("https://www.google.com/search?q=" + value);
                  }
                  webViewController?.loadUrl(
                      urlRequest: URLRequest(url: widget.file.path));
                },
              ),*/
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(widget.file != null
                          ? widget.file!.path!.isDocumentFileName
                              ? baseUrlShareWork +
                                  "//de-DE/${'DocumentManagement'}/MobileIndex?path=${widget.file!.path!.split("https://v1.vir2ell-office.com").last.split("MobileIndex?path=").last}&userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.file!.customerId}&moduleType=${giveFileManagerEnum(widget.file!.moduleType!).toString().split("FileManagerType.").last}"
                              : widget.file!.path!.isExcelFileName
                                  ? baseUrlShareWork +
                                      "//de-DE/${'SpreadsheetManagement'}/MobileIndex?path=${widget.file!.path!.split("https://v1.vir2ell-office.com").last.split("MobileIndex?path=").last}&userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.file!.customerId}&moduleType=${giveFileManagerEnum(widget.file!.moduleType!).toString().split("FileManagerType.").last}"
                                  : widget.file!.path!
                          : widget.messageUrl!.isDocumentFileName
                              ? baseUrlShareWork +
                                  "//de-DE/${'DocumentManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.invoice!.id}&moduleType=${""}"
                              : widget.messageUrl!.isExcelFileName
                                  ? baseUrlShareWork +
                                      "//de-DE/${'SpreadsheetManagement'}/MobileIndex?userId=${_controllerDB.user.value!.result!.id}&moduleId=${widget.invoice!.id}&moduleType=${""}"
                                  : widget.messageUrl.toString()))),
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

  Future<bool> DeleteMultiFileAndDirectory() async {
    int? fileId = widget.file!.id ?? widget.invoice!.fileId;
    return await _controllerFiles.DeleteMultiFileAndDirectory(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id,
      CustomerId: widget.file!.customerId,
      ModuleTypeId: widget.file!.moduleType,
      FileIdList: [fileId!],
      SourceOwnerId:
          widget.file!.customerId ?? _controllerDB.user.value!.result!.id,
    );
  }

  Future<bool> DeleteMultiFileAndDirectoryForSearch() async {
    int? fileId = widget.file!.id ?? widget.invoice!.fileId;
    return await _controllerFiles.DeleteMultiFileAndDirectory(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id,
      CustomerId: widget.searchItem!.customerId,
      ModuleTypeId: widget.searchItem!.moduleType,
      FileIdList: [fileId!],
      SourceOwnerId:
          widget.invoice!.customerId ?? _controllerDB.user.value!.result!.id,
    );
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}
