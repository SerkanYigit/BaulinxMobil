import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/showModalTextInput.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Chat/ForwardChatPage.dart';
import 'package:undede/Pages/Chat/OwnMessage.dart';
import 'package:undede/Pages/Chat/PDFviewChat.dart';
import 'package:undede/Pages/Chat/ReplyMessage.dart';
import 'package:undede/Pages/Chat/TimeMessage.dart';
import 'package:undede/Pages/FileViewers/GenericFileWebView.dart';
import 'package:undede/Pages/Message/imagePage.dart';
import 'package:undede/Services/BlockReport/BlockReportDB.dart';
import 'package:undede/Services/Chat/ChatDB.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/Services/ServiceUrl.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/model/Chat/ChatFileInsert.dart';
import 'package:undede/model/Chat/ChatMessageSaveResult.dart';
import 'package:undede/model/Chat/GetChatResult.dart';
import 'package:undede/model/Common/CareateOrJoinMettingResult.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';
import '../../Custom/CustomLoadingCircle.dart';
import '../../widgets/buildBottomNavigationBar.dart';
import '../PDFView.dart';
import '../PdfApi.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatDetailPage extends StatefulWidget {
  final int Id;
  final String image;
  final String meetingUrl;
  final int? diffentPage;
  final int isGroup;
  final bool blocked;
  final bool? online;
  final bool directLink;
  const ChatDetailPage(
      {required this.Id,
      required this.image,
      this.diffentPage,
      required this.isGroup,
      required this.blocked,
      this.online,
      this.directLink = false,
      this.meetingUrl = ''});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

bool message = true;
ChatDB _chatMessageSaveDB = ChatDB();
PanelController _pc = new PanelController();

class _ChatDetailPageState extends State<ChatDetailPage>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChat = Get.put(ControllerChatNew());
  GetChatResult _getChatResult = GetChatResult(hasError: false);
  CommonDB _commonDB = new CommonDB();
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());

  ChatMessageSaveResult _chatMessageSaveResult =
      ChatMessageSaveResult(hasError: false);
  bool isLoading = false;
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  // Selected Message
  List<int> selectedIndex = [];
  List<int> selectedMessageIDNumber = [];
  int selectedMessage = 0;
  List<String> selectedMessageContant = [];
  bool replyButton = false;
  String? selectedMessagePerson;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllermic = TextEditingController();

  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  // image
  final ImagePicker _imagePicker = ImagePicker();
  XFile? profileImage;
  dynamic _pickImage;
  String base64Image = "";
  // documents
  var _openResult = 'Unknown';
  String base64file = "";
// record
  bool _isRecording = false;
  Random random = new Random();
  AudioPlayer? advancedPlayer;
  bool isPlaying = false;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  String base64Record = "";
  int? messageID;
  //record Icon
  double iconsize = 24;
  Color iconColor = Colors.white;
  String hintmessage = "Type a message";
  Color recordingBackGround = Get.theme.secondaryHeaderColor;
  //Scroll
  bool _firstAutoscrollExecuted = false;
// At the beginning, we fetch the first 20 posts
  int _page = 0;
  int _limit = 30;

  // There is next page or not
  bool _hasNextPage = true;

  // Used to display loading indicators when _firstLoad function is running
  bool _isFirstLoadRunning = false;

  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;

  // This holds the posts fetched from the server
  List _posts = [];

//Controller for animation
  AnimationController? controller;
  List<int> targetUserIdList = [];
  bool loading = true;
  CareateOrJoinMettingResult _careateOrJoinMettingResult =
      CareateOrJoinMettingResult(hasError: false);
  double _panelMinSize = 0.0;
  bool panelType = true;

  /*      FLUTTER SOUND     */
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  String _mPath = 'flutter_sound_example.aac';
  String mesajUrl = "";
  /* ONLINE USER */
  // open progess
  bool _isOpenPross = false;
  void initController() {
    controller = BottomSheet.createAnimationController(this);
    controller!.duration = const Duration(milliseconds: 100);
    controller!.reverseDuration = const Duration(milliseconds: 100);
  }

  int firstMessage = 0;
  BlockReportDB _blockReportDB = BlockReportDB();

  void startMeeting() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    print(loading);
    await CareateOrJoinMetting2(_controllerDB.headers(),
        OwnerId: _controllerDB.user.value!.result!.id!,
        UserId: _controllerDB.user.value!.result!.id!,
        TargetUserIdList: targetUserIdList,
        ModuleType: 20);
    setState(() {
      _pc.open();
      _panelMinSize = 170.0;
      targetUserIdList.add(widget.Id);
    });
  }

  void joinMeeting() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    //await CareateOrJoinMetting(targetUserIdList);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _pc.open();
        _panelMinSize = 170.0;
        targetUserIdList.add(widget.Id);
        loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    advancedPlayer = new AudioPlayer();
    initPlayer();
    getChat(0);
    widget.directLink ? joinMeeting() : false;
    _scrollController = new ScrollController()..addListener(_loadMore);
    _firstAutoscrollExecuted = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controllerChat.GetUnreadCountByUserId(_controllerDB.headers());
      hintmessage = AppLocalizations.of(context)!.typeaMessage;
      if (_firstAutoscrollExecuted == false) {
        _firstAutoscrollExecuted = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.removeListener(_loadMore);
    _mRecorder
        .closeRecorder(); //! closeAudioSession yerine closeRecorder kullanildi
    _mRecorder.isBlank; //!  null yerine isBlank kullanildi
    updareUserList();
    _controllerChat.GetUnreadCountByUserId(_controllerDB.headers());
  }

  void socketNewMessage() {}

  void _scrollDown() async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.linear);
    }
  }

  Future getChat(int RelatedMessageId) async {
    await _controllerChat.GetChat(_controllerDB.headers(), widget.Id, 0,
            widget.isGroup, RelatedMessageId)
        .then((value) => {
              _getChatResult = value,
            });
    setState(() {
      isLoading = true;
    });
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _scrollController.position.extentAfter == 0) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1
      try {
        await _controllerChat.GetChat(_controllerDB.headers(), widget.Id, 0,
                widget.isGroup, firstMessage)
            .then((value) => {
                  if (value.result!.messages!.length > 0)
                    {
                      setState(() {
                        _getChatResult.result!.messages!
                            .insertAll(0, value.result!.messages!);
                      })
                    }
                  else
                    {
                      setState(() {
                        _hasNextPage = false;
                        _isLoadMoreRunning = false;
                      })
                    }
                });
      } catch (err) {}

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  PostChatMessageSave(int ReceiverId, String Message, String MessageBase64,
      int RelatedMessageId, int type) async {
    await _controllerChat.ChatMessageSave(_controllerDB.headers(),
            Id: 0,
            SenderId: _controllerDB.user.value!.result!.id!,
            ReceiverId: widget.isGroup == 1 ? 0 : ReceiverId,
            Type: type,
            Message: Message,
            MessageBase64: MessageBase64,
            PublicId: 0,
            GroupId: widget.isGroup == 1 ? ReceiverId : 0,
            RelatedMessageId: RelatedMessageId)
        .then((value) {
      _chatMessageSaveResult = value;
      _controllerDB.socket!.value.emit("newChatMessage", {
        "SenderId": _controllerDB.user.value!.result!.id!,
        "ReceiverId": widget.isGroup == 1 ? 0 : ReceiverId,
        "Type": 1,
        "Unread": 1,
        "GroupId": widget.isGroup == 1 ? ReceiverId : null,
        "PublicId": 0,
        "Message": value.result!.message!,
        "CreateDate": '/Date(1645620370121)/',
        "CreateDateString": '23/02/2022 1:46 PM',
        "Id": value.result!.id!,
        "UserId": _controllerDB.user.value!.result!.id!,
      });
    });
  }

  PostChatMessageSaveForList(int ReceiverId, ChatFileInsert Files,
      int RelatedMessageId, int type) async {
    await _controllerChat.ChatMessageSave(_controllerDB.headers(),
            Id: 0,
            SenderId: _controllerDB.user.value!.result!.id!,
            ReceiverId: widget.isGroup == 1 ? 0 : ReceiverId,
            Type: type,
            Files: Files,
            PublicId: 0,
            GroupId: widget.isGroup == 1 ? ReceiverId : 0,
            RelatedMessageId: RelatedMessageId)
        .then((value) {
      _chatMessageSaveResult = value;
      _controllerDB.socket!.value.emit("newChatMessage", {
        "SenderId": _controllerDB.user.value!.result!.id!,
        "ReceiverId": widget.isGroup == 1 ? 0 : ReceiverId,
        "Type": 1,
        "Unread": 1,
        "GroupId": widget.isGroup == 1 ? ReceiverId : 0,
        "PublicId": 0,
        "Message": value.result!.message!,
        "CreateDate": '/Date(1645620370121)/',
        "CreateDateString": '23/02/2022 1:46 PM',
        "Id": value.result!.id!,
        "UserId": _controllerDB.user.value!.result!.id!
      });
    });
  }

  deleteMessage(int messageId) {
    _chatMessageSaveDB.DeleteMessage(messageId);
    _controllerDB.socket!.value.emit("deleteChatMessage", {
      "SenderId": _controllerDB.user.value!.result!.id!,
      "ReceiverId": widget.Id,
      "messageId": messageId,
      "UserId": widget.Id,
      "data": messageId
    });
  }

  selectedMessageFalser() {
    setState(() {
      selectedMessage = 0;
      selectedIndex.clear();
      selectedMessageIDNumber.clear();
    });
  }

/* 
  Future<void> CareateOrJoinMetting(List<int> TargetUserIdList) async {
    await _commonDB.CareateOrJoinMetting(_controllerDB.headers(),
            OwnerId: _controllerDB.user.value!.result!.id!,
            UserId: _controllerDB.user.value!.result!.id!,
            TargetUserIdList: TargetUserIdList,
            ModuleType: 20)
        .then((value) {
      setState(() {
        _careateOrJoinMettingResult = value;
        mesajUrl = _careateOrJoinMettingResult.result!.meetingUrl!;
        print("MESAJ URL 2" + mesajUrl.toString());
        debugPrint("Debugprin MESAJ URL 2" + mesajUrl);
        print("MESAJ URL 2" + value.result!.meetingUrl!);
        loading = false;
      });
    });
  }
 */
  final ServiceUrl _serviceUrl = ServiceUrl();
  Future<CareateOrJoinMettingResult> CareateOrJoinMetting2(
      Map<String, String> header,
      {int? OwnerId,
      int? UserId,
      List<int>? TargetUserIdList,
      int? ModuleType}) async {
    var body = jsonEncode({
      "OwnerId": OwnerId,
      "UserId": UserId,
      "TargetUserIdList": TargetUserIdList,
      "ModuleType": ModuleType
    });
    var response = await http.post(Uri.parse(_serviceUrl.careateOrJoinMetting),
        headers: header, body: body);
    print(response.body);
    if (response.body.isEmpty) {
      return CareateOrJoinMettingResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return CareateOrJoinMettingResult.fromJson(responseData);
    }
  }

  EndMeeting(String MeetingId) async {
    await _commonDB.EndMeeting(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!, MeetingId: MeetingId)
        .then((value) {});
  }

  updareUserList() async {
    await _controllerChat.GetUserList(
        _controllerDB.headers(), _controllerDB.user.value!.result!.id!);
  }

  bool isTargetPageLoaded = false;
  @override
  Widget build(BuildContext context) {
    Uri uri = Uri.parse(widget.meetingUrl);
    String meetingID =
        uri.queryParameters['meetingID'] ?? 'No Meeting ID Found';
    // Print the meeting ID
    print('Meeting ID: $meetingID');
    return GetBuilder<ControllerChatNew>(builder: (c) {
      if (c.refreshDetail) {
        getChat(0);
        c.refreshDetail = false;
        c.update();
      }
      return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          body: !isLoading
              ? Text("ChatDetailPage")
              //CustomLoadingCircle()
              : SlidingUpPanel(
                  defaultPanelState: PanelState.CLOSED,
                  controller: _pc,
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
                  panel: loading
                      ? Container()
                      : Container(
                          child: Stack(
                            children: [
                              InAppWebView(
                                  onLoadStop: (controller, url) {
                                    if (url
                                        .toString()
                                        .contains("target-page")) {
                                      setState(() {
                                        isTargetPageLoaded = true;
                                        print("Target page loaded" +
                                            isTargetPageLoaded.toString());
                                      });
                                    }
                                  },
                                  onReceivedError: (controller, url, message) {
                                    print("mesaj: $message");
                                  },
                                  onConsoleMessage:
                                      (controller, consoleMessage) {
                                    print(
                                        "Console message: ${consoleMessage.message}");
                                  },
                                  onPermissionRequest:
                                      (controller, permissionRequest) async {
                                    return PermissionResponse(
                                        resources: permissionRequest.resources,
                                        action: PermissionResponseAction.GRANT);
                                  },
                                  initialSettings: InAppWebViewSettings(
                                    domStorageEnabled: true,
                                    cacheEnabled: true,
                                    isInspectable: true,
                                    allowBackgroundAudioPlaying: true,
                                    javaScriptEnabled: true,
                                    useShouldOverrideUrlLoading: false,
                                    mediaPlaybackRequiresUserGesture: false,
                                    //  userAgent:
                                    //    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36 OPR/84.0.4316.21",
                                    userAgent:
                                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36",
                                    useHybridComposition: true,
                                    supportZoom: true,
                                    allowsInlineMediaPlayback: true,
                                  ),
                                  initialUrlRequest: URLRequest(
                                    //!Uri.parse yyerine WebUri kullanildi

                                    url: WebUri(widget.directLink
                                        ? widget.meetingUrl
                                        // : "https://bbb.baulinx.com/bigbluebutton/api/join?meetingID=9316bf49e4cd46f6886737d47fb1b7c0&fullName=Ozgor+Mayir&password=NpkunQNR6Uamk4dD&joinViaHtml5=true&checksum=65441f81b22d7228621be3bc7a3e94ad01645a64",
                                        // ),

                                        : mesajUrl),
                                  )),

                              /* 
                                              
                            InAppWebView(
                                androidOnPermissionRequest:
                                    (InAppWebViewController controller,
                                        String origin,
                                        List<String> resources) async {
                                  return PermissionRequestResponse(
                                      resources: resources,
                                      action: PermissionRequestResponseAction
                                          .GRANT);
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
                                  //!Uri.parse yyerine WebUri kullanildi
                                              
                                  url: WebUri(widget.directLink
                                      ? widget.meetingUrl
                                      : _careateOrJoinMettingResult
                                          .result!.meetingUrl!),
                                )),
                                              
                                              
                                               */

                              Positioned(
                                right: Get.width / 8, //411
                                top: Get.height / 85, //890
                                child: GestureDetector(
                                  onTap: () async {
                                    EndMeeting(widget.directLink
                                        ? meetingID
                                        : _careateOrJoinMettingResult
                                            .result!.meetingId!);
                                    setState(() {
                                      _panelMinSize = 0.0;
                                    });
                                    _pc.close();
                                    loading = true;
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 55,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        shape: BoxShape.rectangle,
                                        color: Colors.red),
                                    child: Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                  maxHeight: Get.height - 200,
                  minHeight: _panelMinSize,
                  margin: EdgeInsets.only(bottom: 100),
                  body: ModalProgressHUD(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_controller.text.isBlank!) {
                              setState(() {
                                sendButton = false;
                              });
                            }

                            selectedMessageFalser();
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          child: Container(
                            width: Get.width,
                            height: Get.height,
                            child: Column(children: [
                              if (selectedMessageIDNumber.length == 0)
                                InkWell(
                                  child: Header(
                                      MediaQuery.of(context).padding.top,
                                      _getChatResult,
                                      widget.image),
                                )
                              else if (selectedMessageIDNumber.length == 1 &&
                                  _getChatResult.result!.messages!
                                          .firstWhere((element) =>
                                              element.id ==
                                              selectedMessageIDNumber.first)
                                          .senderId ==
                                      _controllerDB.user.value!.result!.id!)
                                Header2(MediaQuery.of(context).padding.top,
                                    selectedMessageIDNumber)
                              else
                                Header3(MediaQuery.of(context).padding.top),
                              Expanded(
                                child: Container(
                                  width: Get.width,
                                  child: Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: Get.theme.scaffoldBackgroundColor,
                                    ),
                                    child: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          if (_isLoadMoreRunning == true)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 40),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              controller: _scrollController,
                                              reverse: true,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  addAutomaticKeepAlives: true,
                                                  physics: ScrollPhysics(),
                                                  padding: EdgeInsets.only(
                                                      bottom: 5),
                                                  itemCount: _getChatResult
                                                      .result!.messages!.length,
                                                  itemBuilder: (ctx, i) {
                                                    if (i % 30 == 0) {
                                                      firstMessage =
                                                          _getChatResult.result!
                                                              .messages![0].id!;
                                                    }

                                                    if (_getChatResult
                                                            .result!
                                                            .messages![i]
                                                            .senderId ==
                                                        _controllerDB
                                                            .user
                                                            .value!
                                                            .result!
                                                            .id!) {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          i != 0
                                                              ? (DateTime.parse(_getChatResult
                                                                              .result!
                                                                              .messages![
                                                                                  i]
                                                                              .createDate!)
                                                                          .day !=
                                                                      DateTime.parse(_getChatResult
                                                                              .result!
                                                                              .messages![i - 1]
                                                                              .createDate!)
                                                                          .day)
                                                                  ? TimeMessage(
                                                                      message: DateFormat.yMMMd().format(DateTime.parse(_getChatResult.result!.messages![i].createDate!)) ==
                                                                              DateFormat.yMMMd().format(DateTime
                                                                                  .now())
                                                                          ? AppLocalizations.of(context)!
                                                                              .today
                                                                          : DateFormat.yMMMd().format(DateTime.parse(_getChatResult
                                                                              .result!
                                                                              .messages![i]
                                                                              .createDate!)),
                                                                    )
                                                                  : Container()
                                                              : Container(),
                                                          GestureDetector(
                                                            child: messageBox(
                                                                _getChatResult
                                                                    .result!
                                                                    .messages![i],
                                                                i),
                                                          ),
                                                        ],
                                                      );
                                                    } else {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          i != 0
                                                              ? (DateTime.parse(_getChatResult
                                                                              .result!
                                                                              .messages![
                                                                                  i]
                                                                              .createDate!)
                                                                          .day !=
                                                                      DateTime.parse(_getChatResult
                                                                              .result!
                                                                              .messages![i - 1]
                                                                              .createDate!)
                                                                          .day)
                                                                  ? TimeMessage(
                                                                      message: DateFormat.yMMMd().format(DateTime.parse(_getChatResult.result!.messages![i].createDate!)) ==
                                                                              DateFormat.yMMMd().format(DateTime
                                                                                  .now())
                                                                          ? AppLocalizations.of(context)!
                                                                              .today
                                                                          : DateFormat.yMMMd().format(DateTime.parse(_getChatResult
                                                                              .result!
                                                                              .messages![i]
                                                                              .createDate!)),
                                                                    )
                                                                  : Container()
                                                              : Container(),
                                                          GestureDetector(
                                                            onLongPress: () {},
                                                            child: messageBox(
                                                                _getChatResult
                                                                    .result!
                                                                    .messages![i],
                                                                i),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  }),
                                            ),
                                          ),
                                          Container(
                                            color: Colors.grey[200],
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: replyButton
                                                          ? 100
                                                          : null,
                                                      decoration: BoxDecoration(
                                                          color: replyButton
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.9)
                                                              : null,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30))),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          replyButton
                                                              ? Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      80,
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              5)),
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.7)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              selectedMessagePerson!,
                                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                                            ),
                                                                            Spacer(),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  replyButton = false;
                                                                                });
                                                                              },
                                                                              child: Icon(
                                                                                Icons.close,
                                                                                size: 15,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                              selectedMessageContant.first,
                                                                              overflow: TextOverflow.clip),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                100,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Container(
                                                                height:
                                                                    Get.height /
                                                                        22,
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        10,
                                                                        10,
                                                                        10),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(30))),
                                                                child:
                                                                    TextFormField(
                                                                  onTap: () {
                                                                    if (_controller
                                                                        .text
                                                                        .isBlank!) {
                                                                      setState(
                                                                          () {
                                                                        sendButton =
                                                                            false;
                                                                      });
                                                                    }
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  controller:
                                                                      _controller,
                                                                  focusNode:
                                                                      focusNode,
                                                                  textAlignVertical:
                                                                      TextAlignVertical
                                                                          .center,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .multiline,
                                                                  maxLines: 5,
                                                                  minLines: 1,
                                                                  onChanged:
                                                                      (value) {
                                                                    if (value
                                                                            .length >
                                                                        0) {
                                                                      setState(
                                                                          () {
                                                                        sendButton =
                                                                            true;
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        sendButton =
                                                                            false;
                                                                      });
                                                                    }
                                                                  },
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintMaxLines:
                                                                        1,
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        hintmessage,
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                    // prefixIcon:
                                                                    //     IconButton(
                                                                    //   icon: Icon(
                                                                    //     Icons
                                                                    //         .keyboard,
                                                                    //   ),
                                                                    // ),
                                                                    suffixIcon:
                                                                        Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        IconButton(
                                                                          icon:
                                                                              Image.asset(
                                                                            'assets/images/icon/attach.png',
                                                                            width:
                                                                                25,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            focusNode.unfocus();
                                                                            focusNode.canRequestFocus =
                                                                                false;
                                                                            _showPicker(context);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    contentPadding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Image.asset(
                                                        'assets/images/icon/camera.png',
                                                        width: 22,
                                                      ),
                                                      onPressed: () {
                                                        focusNode.unfocus();
                                                        focusNode
                                                                .canRequestFocus =
                                                            false;
                                                        _imgFromCamera();
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: GestureDetector(
                                                        onLongPressStart:
                                                            (_) async {
                                                          if (sendButton) {
                                                          } else {
                                                            getRecorderFn();
                                                            HapticFeedback
                                                                .lightImpact();
                                                            setState(() {
                                                              iconsize = 25;
                                                              iconColor =
                                                                  Colors.red;
                                                              hintmessage =
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .recording;
                                                              recordingBackGround = Get
                                                                  .theme
                                                                  .primaryColor;
                                                            });
                                                          }
                                                        },
                                                        onLongPressEnd:
                                                            (_) async {
                                                          if (sendButton) {
                                                          } else {
                                                            iconsize = 24;
                                                            iconColor =
                                                                Colors.white;
                                                            hintmessage =
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .typeaMessage;
                                                            recordingBackGround = Get
                                                                .theme
                                                                .secondaryHeaderColor;

                                                            await getRecorderFn();

                                                            await PostChatMessageSave(
                                                                widget.Id,
                                                                "deneme.mp3",
                                                                getRecordedSound(),
                                                                0,
                                                                4);
                                                            await getChat(0);

                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    new FocusNode());
                                                          }
                                                        },
                                                        child: sendButton
                                                            ? Icon(
                                                                Icons.send,
                                                                color: Colors
                                                                    .black,
                                                                size: 22,
                                                              )
                                                            : Image.asset(
                                                                'assets/images/icon/mic.png',
                                                                width: 22,
                                                              ),
                                                      ),
                                                      onPressed: () async {
                                                        if (sendButton &&
                                                            !_controller.text
                                                                .isBlank!) {
                                                          if (replyButton) {
                                                            await PostChatMessageSave(
                                                                widget.Id,
                                                                _controller.text
                                                                    .trim(),
                                                                "",
                                                                selectedMessageIDNumber
                                                                    .first,
                                                                1);
                                                          } else {
                                                            await PostChatMessageSave(
                                                                widget.Id,
                                                                _controller.text
                                                                    .trim(),
                                                                "",
                                                                0,
                                                                1);
                                                          }

                                                          await getChat(0);
                                                          selectedMessageFalser();
                                                          replyButton = false;
                                                          _controller.clear();
                                                          sendButton = false;

                                                          setState(() {});
                                                        } else {
                                                          print("mice basıldı");
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Container(),
                                              ],
                                            ),
                                          ),
                                          isKeyboardVisible
                                              ? SizedBox(height: 0)
                                              : SizedBox(
                                                  height: 80,
                                                )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: WidgetsBinding
                                            .instance.window.viewInsets.bottom >
                                        0
                                    ? EdgeInsets.fromWindowPadding(
                                            WidgetsBinding
                                                .instance.window.viewInsets,
                                            WidgetsBinding.instance.window
                                                .devicePixelRatio)
                                        .bottom
                                    : 0,
                              ),
                              SizedBox(
                                height: widget.diffentPage == 1 ? 160 : 0,
                              )
                            ]),
                          ),
                        ),
                        panelType && !loading
                            ? Positioned(
                                bottom: 150,
                                left: 0,
                                child: GestureDetector(
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
                                ),
                              )
                            : Container()
                      ],
                    ),
                    inAsyncCall: _isOpenPross,
                  ),
                ),
        );
      });
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.insert_drive_file,
                        color: Colors.indigo,
                      ),
                      title: new Text('Document'),
                      onTap: () {
                        openFile();

                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                        color: Colors.purple,
                      ),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _onImageButtonPressed(ImageSource.gallery,
                            context: context);

                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                      color: Colors.pink,
                    ),
                    title: new Text('Camera'),
                    onTap: () {
                      _onImageButtonPressed(ImageSource.camera,
                          context: context);
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                      leading: new Icon(
                        Icons.headset,
                        color: Colors.orange,
                      ),
                      title: new Text('Audio'),
                      onTap: () {
                        openAudio();

                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }

  Widget bottomSheet() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Card(
              margin: const EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            openFile();
                          },
                          child: iconCreation(Icons.insert_drive_file,
                              Colors.indigo, "Document"),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                            onTap: () {
                              print("camera");
                              _imgFromCamera();
                              Navigator.pop(context);
                            },
                            child: iconCreation(
                                Icons.camera_alt, Colors.pink, "Camera")),
                        SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            _onImageButtonPressed(ImageSource.gallery,
                                context: context);
                            Navigator.pop(context);
                          },
                          child: iconCreation(
                              Icons.insert_photo, Colors.purple, "Gallery"),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                            onTap: () {
                              openAudio();
                              Navigator.pop(context);
                            },
                            child: iconCreation(
                                Icons.headset, Colors.orange, "Audio")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(text)
        .forEach((RegExpMatch match) => print(match.group(0)));
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(
            icons,
            // semanticLabel: "Help",
            size: 29,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            // fontWeight: FontWeight.w100,
          ),
        )
      ],
    );
  }

  Widget Header(double padding, GetChatResult getChatResult, String image) {
    return Container(
      width: Get.width,
      height: widget.diffentPage == 0
          ? Get.height > 800
              ? 130
              : 110
          : 75,
      padding: EdgeInsets.only(
        top: widget.diffentPage == 0 ? padding : 0,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 15, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/images/icon/arrowleftlineless.png',
                    width: 25,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          image ??
                              "http://test.vir2ell-office.com/Content/UploadPhoto/User/13ad079a-0b1f-4ea9-8724-71be82020d68.jpg",
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                      ),
                      widget.online!
                          ? Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 1.0,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      child: Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 9,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade300,
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    getChatResult.result!.otherUserName! +
                        " " +
                        getChatResult.result!.otherUserSurname!,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await Permission.camera.request();
                        await Permission.microphone.request();
                        print(loading);
                        setState(() {
                          _pc.open();
                          _panelMinSize = 170.0;
                          targetUserIdList.add(widget.Id);
                        });
                        // await CareateOrJoinMetting(targetUserIdList);
                        await CareateOrJoinMetting2(_controllerDB.headers(),
                                OwnerId: _controllerDB.user.value!.result!.id!,
                                UserId: _controllerDB.user.value!.result!.id!,
                                TargetUserIdList: targetUserIdList,
                                ModuleType: 20)
                            .then((value) {
                          setState(() {
                            _careateOrJoinMettingResult = value;
                            loading = false;
                            mesajUrl =
                                _careateOrJoinMettingResult.result!.meetingUrl!;
                            print("MESAJ URL 3" + mesajUrl.toString());
                            printLongString(mesajUrl);
                          });
                        });
/*
                        showModalBottomSheet(
                            transitionAnimationController: controller,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25.0))),
                            isScrollControlled: true,
                            context: context,
                            useRootNavigator: true,
                            backgroundColor: Get.theme.scaffoldBackgroundColor,
                            builder: (context) {
                              return loading
                                  ? CustomLoadingCircle()
                                  : Container(
                                      height: Get.height - 100,
                                      child: InAppWebView(
                                          androidOnPermissionRequest:
                                              (InAppWebViewController
                                                      controller,
                                                  String origin,
                                                  List<String>
                                                      resources) async {
                                            return PermissionRequestResponse(
                                                resources: resources,
                                                action:
                                                    PermissionRequestResponseAction
                                                        .GRANT);
                                          },
                                          initialOptions:
                                              InAppWebViewGroupOptions(
                                                  crossPlatform:
                                                      InAppWebViewOptions(
                                            userAgent:
                                                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 OPR/81.0.4196.60",
                                          )),
                                          initialUrl:
                                              _careateOrJoinMettingResult
                                                  .result.meetingUrl),
                                    );
                            }).whenComplete(() {
                          initController();
                          targetUserIdList.clear();
                          loading = true;
                        });*/
                      },
                      child: Image.asset(
                        'assets/images/icon/phone.png',
                        width: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    PopupMenuButton(
                        onSelected: (a) async {
                          if (a == 1) {
                            _blockReportDB.BlockUser(_controllerDB.headers(),
                                userId: _controllerDB.user.value!.result!.id!,
                                blockedUserId:
                                    getChatResult.result!.otherUserId!,
                                blockType: 1);
                            Navigator.pop(context);
                          }
                          if (a == 2) {
                            String text = await showModalTextInput(
                                    context,
                                    "Kullanıcıyı reporlama sebebinizi yazınız",
                                    "Report") ??
                                "";

                            _blockReportDB.ReportUser(_controllerDB.headers(),
                                userId: _controllerDB.user.value!.result!.id!,
                                reportedUserId:
                                    getChatResult.result!.otherUserId!,
                                reportMessage: text,
                                blockType: 1);
                            Navigator.pop(context);
                          }
                          if (a == 3) {
                            _blockReportDB.UnBlockUser(_controllerDB.headers(),
                                userId: _controllerDB.user.value!.result!.id!,
                                blockedUserId:
                                    getChatResult.result!.otherUserId!,
                                blockType: 1);
                            Navigator.pop(context);
                          }
                        },
                        child: Center(
                          child: Image.asset(
                            'assets/images/icon/three-circles.png',
                            width: 25,
                          ),
                        ),
                        itemBuilder: (context) => [
                              widget.blocked
                                  ? PopupMenuItem(
                                      child: Text(AppLocalizations.of(context)!
                                          .unBlock),
                                      value: 3,
                                    )
                                  : PopupMenuItem(
                                      child: Text(
                                          AppLocalizations.of(context)!.block),
                                      value: 1,
                                    ),
                              PopupMenuItem(
                                child:
                                    Text(AppLocalizations.of(context)!.report),
                                value: 2,
                              )
                            ]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget Header2(double padding, List<int> MessageId) {
    return Container(
      width: Get.width,
      height: 110,
      padding: EdgeInsets.only(top: padding),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                  size: 35,
                ),
                Spacer(),
                selectedMessageContant.any((element) => [
                              "jpg",
                              "png",
                              "pdf",
                              "jpeg"
                            ].contains(element.split(".").last)) &&
                        selectedMessageContant.length > 1
                    ? Container()
                    : Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (selectedMessageContant.any((element) => [
                                    "jpg",
                                    "png",
                                    "pdf",
                                    "jpeg"
                                  ].contains(element.split(".").last))) {
                                await FileShareFn([
                                  selectedMessageContant.join("\n")
                                ], context, url: false);
                                return;
                              }
                              await FileShareFn(
                                  [selectedMessageContant.join("\n")], context,
                                  url: true);
                            },
                            child: Icon(
                              Icons.share,
                              color: Colors.black,
                              size: 27,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              replyButton = true;
                              selectedMessagePerson = _controllerChat
                                  .UserListRx?.value!.result!
                                  .where((element) => element.id == widget.Id)
                                  .first
                                  .fullName!;
                              setState(() {});
                            },
                            child: Icon(
                              Icons.reply,
                              color: Colors.black,
                              size: 27,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Icon(
                            Icons.content_copy,
                            color: Colors.black,
                            size: 27,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () async {
                              for (int i = 0; i < MessageId.length; i++) {
                                await deleteMessage(MessageId[i]);
                              }
                              await getChat(0);
                              Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)!.deleted,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor:
                                      Get.theme.secondaryHeaderColor,
                                  textColor: Get.theme.primaryColor,
                                  fontSize: 16.0);
                              setState(() {});
                              selectedMessageFalser();
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 27,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ForwardChatPage(
                                    message: selectedMessageIDNumber,
                                    id: widget.Id,
                                  ));
                            },
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                              size: 27,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget Header3(double padding) {
    return Container(
      width: Get.width,
      height: 110,
      padding: EdgeInsets.only(top: padding),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                  size: 35,
                ),
                Spacer(),
                Row(
                  children: [
                    selectedMessageContant.any((element) => [
                                  "jpg",
                                  "png",
                                  "pdf",
                                  "jpeg"
                                ].contains(element.split(".").last)) &&
                            selectedMessageContant.length > 1
                        ? Container()
                        : GestureDetector(
                            onTap: () async {
                              if (selectedMessageContant.any((element) => [
                                    "jpg",
                                    "png",
                                    "pdf",
                                    "jpeg"
                                  ].contains(element.split(".").last))) {
                                await FileShareFn([
                                  selectedMessageContant.join("\n")
                                ], context, url: false);
                                return;
                              }
                              await FileShareFn(
                                  [selectedMessageContant.join("\n")], context,
                                  url: true);
                            },
                            child: Icon(
                              Icons.share,
                              color: Colors.black,
                              size: 27,
                            ),
                          ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        replyButton = true;
                        setState(() {});
                      },
                      child: Icon(
                        Icons.reply,
                        color: Colors.black,
                        size: 27,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(
                      Icons.content_copy,
                      color: Colors.black,
                      size: 27,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ForwardChatPage(
                              message: selectedMessageIDNumber,
                              id: widget.Id,
                            ));
                      },
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                        size: 27,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget micIcon(double size, Color Color) {
    return Icon(Icons.mic, size: size, color: Color);
  }

  void _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      ChatFileInsert files = new ChatFileInsert();
      files.fileList = <FileList>[];
      files.fileList!.clear();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpeg', 'jpg', 'png'],
          allowMultiple: true);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        files.fileList!.add(FileList(
            base64FileContent: fileContent,
            fileNameWithExtension:
                "sample.${result.files.first.path!.split(".").last}"));
      });
      await PostChatMessageSaveForList(widget.Id, files, 0, 5);
      // await PostChatMessageSave(widget.Id, "deneme.jpg", base64Image, 0, 5);
      await getChat(0);
      FocusScope.of(context).requestFocus(new FocusNode());
      print('aaa');
    } catch (e) {
      _pickImage = e;
      print("Image Error: " + _pickImage.toString());
    }
  }

  void _imgFromCamera() async {
    Get.to(() => CameraPage())!.then((value) async {
      ChatFileInsert files = new ChatFileInsert();
      files.fileList = <FileList>[];
      files.fileList!.clear();

      if (value != null) {
        List<int> fileBytes = <int>[];
        value.forEach((file) {
          fileBytes = new File(file.path).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          files.fileList!.add(FileList(
              base64FileContent: fileContent,
              fileNameWithExtension: "sample.jpg"));
        });
        await PostChatMessageSaveForList(widget.Id, files, 0, 5);
        await getChat(0);
      }
    });
  }

  Future<void> openFile() async {
    try {
      ChatFileInsert files = new ChatFileInsert();
      files.fileList = <FileList>[];
      files.fileList!.clear();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'mp4'],
          allowMultiple: true);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        files.fileList!.add(FileList(
            base64FileContent: fileContent,
            fileNameWithExtension:
                "sample.${result.files.first.path!.split(".").last}"));
      });
      _controllerBottomNavigationBar.lockUI = true;
      _controllerBottomNavigationBar.update();
      await PostChatMessageSaveForList(widget.Id, files, 0, 5);
      // await PostChatMessageSave(widget.Id, "deneme.jpg", base64Image, 0, 5);
      await getChat(0);
      _controllerBottomNavigationBar.lockUI = false;
      _controllerBottomNavigationBar.update();
      FocusScope.of(context).requestFocus(new FocusNode());
      print('aaa');
    } catch (e) {
      _pickImage = e;
      print("Image Error: " + _pickImage.toString());
    }
  }

  Future<void> openAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) async {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        String fileContent = base64.encode(fileBytes);
        await PostChatMessageSave(
            widget.Id,
            "deneme.${result.files.first.path!.split(".").last}",
            fileContent,
            0,
            4);
        await getChat(0);
      });
      FocusScope.of(context).requestFocus(new FocusNode());
    } catch (e) {
      _pickImage = e;
      print("Image Error: " + _pickImage.toString());
    }
  }

  Future<void> openVideo() async {
    try {
      ChatFileInsert files = new ChatFileInsert();
      files.fileList = <FileList>[];
      files.fileList!.clear();

      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.video, allowMultiple: true);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        files.fileList!.add(FileList(
            base64FileContent: fileContent,
            fileNameWithExtension:
                "sample.${result.files.first.path!.split(".").last}"));
      });
      await PostChatMessageSaveForList(widget.Id, files, 0, 5);
      // await PostChatMessageSave(widget.Id, "deneme.jpg", base64Image, 0, 5);
      await getChat(0);
      FocusScope.of(context).requestFocus(new FocusNode());
      print('aaa');
    } catch (e) {
      _pickImage = e;
      print("Image Error: " + _pickImage.toString());
    }
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();

    advancedPlayer!.onDurationChanged.listen((Duration d) {
      print(d);
      setState(() => _duration = d);
    });
//! onAudioPositionChanged yerine onPositionChanged kullanılıyor
    advancedPlayer!.onPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });

    advancedPlayer!.onPlayerStateChanged.listen((event) {
      if (event.index != 1) {
        setState(() {
          int? a;
          isPlaying = false;
          messageID = a;
          _position = Duration();
        });
      }
    });
  }

  Widget voicePlayer2(Messages message, int index) {
    return GestureDetector(
      onLongPress: () {
        SelectOrUnselect(message.message!, message.id!, index);
      },
      onTap: () {
        if (selectedMessageIDNumber.length > 0) {
          SelectOrUnselect(message.message!, message.id!, index);
        }
      },
      child: Container(
        color: selectedIndex.contains(index) &&
                selectedMessageContant.contains(message.message)
            ? Colors.green.withOpacity(0.5)
            : null,
        child: Row(
          textDirection: ui.TextDirection.ltr,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 3,
                        ),
                        Column(
                          children: [
                            Text(
                              message.senderName!,
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  Image.network(message.senderPhoto!).image,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              // message.mediaLength ?? "",
                              "",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            if (!isPlaying) {
                              setState(() {
                                messageID = message.id;
                                isPlaying = true;
                              });
                              await advancedPlayer!
                                  .play(UrlSource(message.message!));
                              //! messsage.message yerine UrlSource(message.message!) kullanildi
                            } else {
                              setState(() {
                                isPlaying = false;
                              });
                              await advancedPlayer!.stop();
                            }
                          },
                          child: Icon(
                            isPlaying && message.id == messageID
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),
                        Slider(
                            value: message.id == messageID
                                ? _position.inMicroseconds.toDouble()
                                : 0.0,
                            min: 0.0,
                            max: _duration.inMicroseconds.toDouble(),
                            onChanged: (double value) {
                              setState(() {
                                seekToSecond(value.toInt());
                                value = value;
                              });
                            }),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 7,
                    child: Text(
                      DateFormat("HH:mm").format(
                        DateTime.parse(message.createDate!),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void SelectOrUnselect(String message, int Id, int index) {
    setState(() {
      if (selectedMessageContant.contains(message)) {
        selectedIndex.remove(index);
        selectedMessageIDNumber.remove(Id);
        selectedMessageContant.remove(message);
      } else {
        selectedIndex.add(index);
        selectedMessageIDNumber.add(Id);
        selectedMessageContant.add(message);
      }
    });
  }

  Widget voicePlayer(Messages message, int index) {
    return GestureDetector(
      onTap: () {
        if (selectedMessageIDNumber.length > 0) {
          SelectOrUnselect(message.message!, message.id!, index);
        }
      },
      onLongPress: () {
        SelectOrUnselect(message.message!, message.id!, index);
      },
      child: Container(
        color: selectedIndex.contains(index) &&
                selectedMessageContant.contains(message.message)
            ? Colors.green.withOpacity(0.5)
            : null,
        child: Row(
          textDirection: ui.TextDirection.rtl,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: Color(0xffdcf8c6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 3,
                        ),
                        Column(
                          children: [
                            Text(
                              message.senderName!,
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage: Image.network(
                                      _controllerDB.user.value!.result!.photo!)
                                  .image,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              // message.mediaLength ?? "",
                              "",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            if (!isPlaying) {
                              setState(() {
                                messageID = message.id;
                                isPlaying = true;
                              });
                              await advancedPlayer!
                                  .play(UrlSource(message.message!));
                              //! messsage.message yerine UrlSource(message.message!) kullanildi
                            } else {
                              setState(() {
                                isPlaying = false;
                              });
                              await advancedPlayer!.stop();
                            }
                          },
                          child: Icon(
                            isPlaying && message.id == messageID
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),
                        Slider(
                            value: message.id == messageID
                                ? _position.inMicroseconds.toDouble()
                                : 0.0,
                            min: 0.0,
                            max: _duration.inMicroseconds.toDouble(),
                            onChanged: (double value) {
                              setState(() {
                                seekToSecond(value.toInt());
                                value = value;
                              });
                            }),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 7,
                    child: Text(
                      DateFormat("HH:mm").format(
                        DateTime.parse(message.createDate!),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer!.seek(newDuration);
  }

  Widget imageMessage(Messages message, int index) {
    return message.fileList == null
        ? Container(
            color: selectedIndex.contains(index) &&
                    selectedMessageContant.contains(message.message)
                ? Colors.green.withOpacity(0.5)
                : null,
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  if (selectedMessageIDNumber.length > 0) {
                    SelectOrUnselect(message.message!, message.id!, index);
                  } else {
                    openImageview(message.message!);
                  }
                });
                ;
              },
              onLongPress: () {
                SelectOrUnselect(message.message!, message.id!, index);
              },
              child: Align(
                alignment: Alignment.bottomRight,
                child: Stack(
                  children: [
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      color: Color(0xffdcf8c6),
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          width: 200,
                          height: 250,
                          child: CachedNetworkImage(
                              width: 100,
                              imageUrl: (message.message!),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              placeholder: (context, url) =>
                                  new Text("ChatDetailPage")
                              //    CustomLoadingCircle(),
                              )),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 7,
                      child: Text(
                        DateFormat("HH:mm").format(
                          DateTime.parse(message.createDate!),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Container(
            height: 290.0 * message.fileList!.length,
            alignment: Alignment.bottomRight,
            child: ListView.builder(
                itemCount: message.fileList!.length,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  print(message.fileList!.length);
                  return Container(
                    color: selectedIndex.contains(index) &&
                            selectedMessageContant
                                .contains(message.fileList![i].thumbnailPath)
                        ? Colors.green.withOpacity(0.5)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedMessageIDNumber.length > 0) {
                          SelectOrUnselect(message.fileList![i].thumbnailPath!,
                              message.id!, index);
                        } else {
                          openImageview(message.fileList![i].path!);
                        }
                      },
                      onLongPress: () {
                        SelectOrUnselect(message.fileList![i].thumbnailPath!,
                            message.id!, index);
                      },
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Stack(
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              color: Color(0xffdcf8c6),
                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  width: 200,
                                  height: 250,
                                  child: message.fileList!
                                          .isNotEmpty //! != null yerine isNotEmpty kullanildi
                                      ? Stack(
                                          children: [
                                            CachedNetworkImage(
                                                width: 200,
                                                height: 250,
                                                imageUrl: (message.fileList![i]
                                                    .thumbnailPath!),
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                                placeholder: (context, url) =>
                                                    new Text("ChatDetailPage")
                                                // CustomLoadingCircle(),
                                                ),
                                            Positioned(
                                                bottom: 10,
                                                left: 7,
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              getImagePathByFileExtension(
                                                                  message
                                                                      .message!
                                                                      .split(
                                                                          ".")
                                                                      .last)))),
                                                ))
                                          ],
                                        )

                                      //!NetworlImage yerine Image kullanildi
                                      : Image(
                                          image: NetworkImage(message.message!),
                                          fit: BoxFit.cover,
                                        )),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 7,
                              child: Text(
                                DateFormat("HH:mm").format(
                                  DateTime.parse(message.createDate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
  }

  Widget imageMessage2(Messages message, int index) {
    return message.fileList == null
        ? Container(
            color: selectedIndex.contains(index) &&
                    selectedMessageContant.contains(message.message)
                ? Colors.green.withOpacity(0.5)
                : null,
            child: GestureDetector(
              onTap: () {
                if (selectedMessageIDNumber.length > 0) {
                  SelectOrUnselect(message.message!, message.id!, index);
                } else {
                  openImageview(message.message!);
                }
              },
              onLongPress: () {
                SelectOrUnselect(message.message!, message.id!, index);
              },
              child: Align(
                alignment: Alignment.bottomRight,
                child: Stack(
                  children: [
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      color: Color(0xffdcf8c6),
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          width: 200,
                          height: 250,
                          child: CachedNetworkImage(
                              width: 100,
                              imageUrl: (message.message!),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              placeholder: (context, url) =>
                                  new Text("ChatDetailPage")
                              // CustomLoadingCircle(),
                              )),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 7,
                      child: Text(
                        DateFormat("HH:mm").format(
                          DateTime.parse(message.createDate!),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Container(
            height: 290.0 * message.fileList!.length,
            alignment: Alignment.bottomLeft,
            child: ListView.builder(
                itemCount: message.fileList!.length,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return Container(
                    color: selectedIndex.contains(index) &&
                            selectedMessageContant
                                .contains(message.fileList![i].thumbnailPath!)
                        ? Colors.green.withOpacity(0.5)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedMessageIDNumber.length > 0) {
                          SelectOrUnselect(message.fileList![i].thumbnailPath!,
                              message.id!, index);
                        } else {
                          openImageview(message.fileList![i].path!);
                        }
                      },
                      onLongPress: () {
                        SelectOrUnselect(message.fileList![i].thumbnailPath!,
                            message.id!, index);
                      },
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Stack(
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              color: Colors.white,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                height: 250,
                                width: 200,
                                child: message.fileList != null
                                    ? Stack(
                                        children: [
                                          CachedNetworkImage(
                                              height: 250,
                                              width: 200,
                                              imageUrl: (message
                                                  .fileList![i].thumbnailPath!),
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                              placeholder: (context, url) =>
                                                  new Text("ChatDetailPage")
                                              //  CustomLoadingCircle(),
                                              ),
                                          Positioned(
                                              bottom: 10,
                                              left: 7,
                                              child: Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            getImagePathByFileExtension(
                                                                message.message!
                                                                    .split(".")
                                                                    .last)))),
                                              ))
                                        ],
                                      )
                                    : Image(
                                        image: NetworkImage(message.message!),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 7,
                              child: Text(
                                DateFormat("HH:mm").format(
                                  DateTime.parse(message.createDate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
  }

/*
Gruplama işlemi bununla yapılıcak
  Widget MultiImage(List<String> images) {
    return Container(
      width: 200,
      height: images.length == 1 ? 125 : 250,
      child: images.length > 2
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 1.3 / 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5),
              itemCount: images.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext ctx, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => imagePage(
                                  image: images[index],
                                )));
                  },
                  child: CachedNetworkImage(
                    width: 100,
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              })
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 2.5 / 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5),
              itemCount: images.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext ctx, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => imagePage(
                                  image: images[index],
                                )));
                  },
                  child: CachedNetworkImage(
                    width: 100,
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              }),
    );
  }

 */
  Widget pdfFile(Messages message, int index) {
    return message.fileList == null
        ? Container(
            color: selectedIndex.contains(index) &&
                    selectedMessageContant.contains(message.message)
                ? Colors.green.withOpacity(0.5)
                : null,
            alignment: message.senderId == _controllerDB.user.value!.result!.id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if (selectedMessageIDNumber.length > 0) {
                  SelectOrUnselect(message.message!, message.id!, index);
                } else {
                  openPdfView(message.message!, message.message!);
                }
              },
              onLongPress: () {
                SelectOrUnselect(message.message!, message.id!, index);
              },
              child: Align(
                alignment:
                    message.senderId == _controllerDB.user.value!.result!.id
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color:
                      message.senderId == _controllerDB.user.value!.result!.id
                          ? Color(0xffdcf8c6)
                          : Colors.white,
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        Image.network(
                          "https://cdn0.iconfinder.com/data/icons/office-files-icons/110/Pdf-File-512.png",
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 5,
                          right: message.senderId ==
                                  _controllerDB.user.value!.result!.id
                              ? null
                              : 7,
                          left: message.senderId ==
                                  _controllerDB.user.value!.result!.id
                              ? 7
                              : null,
                          child: Text(
                            DateFormat("HH:mm").format(
                              DateTime.parse(message.createDate!),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            height: 290.0 * message.fileList!.length,
            alignment: message.senderId == _controllerDB.user.value!.result!.id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ListView.builder(
                itemCount: message.fileList!.length,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return Container(
                    color: selectedIndex.contains(index) &&
                            selectedMessageContant
                                .contains(message.fileList![i].thumbnailPath!)
                        ? Colors.green.withOpacity(0.5)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedMessageIDNumber.length > 0) {
                          SelectOrUnselect(
                              message.message!, message.id!, index);
                        } else {
                          openPdfView(message.fileList![i].path!,
                              message.fileList![i].thumbnailPath!);
                        }
                      },
                      onLongPress: () {
                        SelectOrUnselect(message.message!, message.id!, index);
                      },
                      child: Align(
                        alignment: message.senderId ==
                                _controllerDB.user.value!.result!.id
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Stack(
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              color: message.senderId ==
                                      _controllerDB.user.value!.result!.id
                                  ? Color(0xffdcf8c6)
                                  : Colors.white,
                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  height: 250,
                                  width: 200,
                                  child: message.fileList!.isNotEmpty
                                      ? Stack(
                                          children: [
                                            CachedNetworkImage(
                                                height: 250,
                                                width: 200,
                                                imageUrl: (message.fileList![i]
                                                    .thumbnailPath!),
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                                placeholder: (context, url) =>
                                                    new Text("ChatDetailPage")
                                                //CustomLoadingCircle(),
                                                ),
                                            Positioned(
                                                bottom: 5,
                                                right: message.senderId ==
                                                        _controllerDB.user
                                                            .value!.result!.id
                                                    ? 7
                                                    : null,
                                                left: message.senderId ==
                                                        _controllerDB.user
                                                            .value!.result!.id
                                                    ? null
                                                    : 7,
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              getImagePathByFileExtension(
                                                                  message
                                                                      .message!
                                                                      .split(
                                                                          ".")
                                                                      .last)))),
                                                ))
                                          ],
                                        )
                                      : Image(
                                          image: NetworkImage(message.message!),
                                          fit: BoxFit.cover,
                                        )),
                            ),
                            Positioned(
                              bottom: 5,
                              right: message.senderId ==
                                      _controllerDB.user.value!.result!.id
                                  ? null
                                  : 7,
                              left: message.senderId ==
                                      _controllerDB.user.value!.result!.id
                                  ? 7
                                  : null,
                              child: Text(
                                DateFormat("HH:mm").format(
                                  DateTime.parse(message.createDate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
  }

  Widget mp4File(Messages message, int index) {
    return message.fileList == null
        ? Container(
            color: selectedIndex.contains(index) &&
                    selectedMessageContant.contains(message.message)
                ? Colors.green.withOpacity(0.5)
                : null,
            alignment: message.senderId == _controllerDB.user.value!.result!.id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if (selectedMessageIDNumber.length > 0) {
                  SelectOrUnselect(message.message!, message.id!, index);
                } else {
                  openMp4View(message.message!);
                }
              },
              onLongPress: () {
                SelectOrUnselect(message.message!, message.id!, index);
              },
              child: Align(
                alignment:
                    message.senderId == _controllerDB.user.value!.result!.id
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color:
                      message.senderId == _controllerDB.user.value!.result!.id
                          ? Color(0xffdcf8c6)
                          : Colors.white,
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        Image.network(
                          "https://cdn0.iconfinder.com/data/icons/office-files-icons/110/Pdf-File-512.png",
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 5,
                          right: message.senderId ==
                                  _controllerDB.user.value!.result!.id
                              ? null
                              : 7,
                          left: message.senderId ==
                                  _controllerDB.user.value!.result!.id
                              ? 7
                              : null,
                          child: Text(
                            DateFormat("HH:mm").format(
                              DateTime.parse(message.createDate!),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            height: 290.0 * message.fileList!.length,
            alignment: message.senderId == _controllerDB.user.value!.result!.id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ListView.builder(
                itemCount: message.fileList!.length,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return Container(
                    color: selectedIndex.contains(index) &&
                            selectedMessageContant
                                .contains(message.fileList![i].thumbnailPath!)
                        ? Colors.green.withOpacity(0.5)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedMessageIDNumber.length > 0) {
                          SelectOrUnselect(
                              message.fileList![i].path!, message.id!, index);
                        } else {
                          openMp4View(message.fileList![i].path!);
                        }
                      },
                      onLongPress: () {
                        SelectOrUnselect(
                            message.fileList![i].path!, message.id!, index);
                      },
                      child: Align(
                        alignment: message.senderId ==
                                _controllerDB.user.value!.result!.id
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Stack(
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              color: message.senderId ==
                                      _controllerDB.user.value!.result!.id
                                  ? Color(0xffdcf8c6)
                                  : Colors.white,
                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  height: 250,
                                  width: 200,
                                  child: message.fileList != null
                                      ? Stack(
                                          children: [
                                            CachedNetworkImage(
                                                height: 250,
                                                width: 200,
                                                imageUrl: (message.fileList![i]
                                                    .thumbnailPath!),
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.asset(
                                                        getImagePathByFileExtension(
                                                            message.message!
                                                                .split(".")
                                                                .last)),
                                                placeholder: (context, url) =>
                                                    new Text("ChatDetailPage")
                                                //CustomLoadingCircle(),
                                                ),
                                            Positioned(
                                                bottom: 5,
                                                right: message.senderId ==
                                                        _controllerDB.user
                                                            .value!.result!.id
                                                    ? 7
                                                    : null,
                                                left: message.senderId ==
                                                        _controllerDB.user
                                                            .value!.result!.id
                                                    ? null
                                                    : 7,
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              getImagePathByFileExtension(
                                                                  message
                                                                      .message!
                                                                      .split(
                                                                          ".")
                                                                      .last)))),
                                                ))
                                          ],
                                        )
                                      : Image(
                                          image: NetworkImage(message.message!),
                                          fit: BoxFit.cover,
                                        )),
                            ),
                            Positioned(
                              bottom: 5,
                              right: message.senderId ==
                                      _controllerDB.user.value!.result!.id
                                  ? null
                                  : 7,
                              left: message.senderId ==
                                      _controllerDB.user.value!.result!.id
                                  ? 7
                                  : null,
                              child: Text(
                                DateFormat("HH:mm").format(
                                  DateTime.parse(message.createDate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
  }

  Widget messageBox(Messages message, int i) {
    String extension = p.extension(message.message!.replaceAll("\"]", ""));
    extension = extension.isBlank! ? message.message! : extension;
    switch (extension) {
      case '.mp3':
        return message.senderId == _controllerDB.user.value!.result!.id
            ? voicePlayer(message, i)
            : voicePlayer2(message, i);
        break;

      case '.jpg':
        return message.senderId == _controllerDB.user.value!.result!.id
            ? imageMessage(message, i)
            : imageMessage2(message, i);
        break;

      case '.jpeg':
        return message.senderId == _controllerDB.user.value!.result!.id
            ? imageMessage(message, i)
            : imageMessage2(message, i);
        break;

      case '.png':
        return message.senderId == _controllerDB.user.value!.result!.id
            ? imageMessage(message, i)
            : imageMessage2(message, i);
        break;

      case '.pdf':
        return pdfFile(message, i);
        break;

      case '.mp4':
        return mp4File(message, i);
        break;
      case '.txt':
        return mp4File(message, i);
        break;
      default:
        return message.senderId == _controllerDB.user.value!.result!.id
            ? GestureDetector(
                onTap: () {
                  if (selectedMessageIDNumber.length > 0) {
                    SelectOrUnselect(message.message!, message.id!, i);
                  }
                },
                onLongPress: () {
                  SelectOrUnselect(message.message!, message.id!, i);
                },
                child: OwnMessageCard(
                  message: message.message!,
                  time: DateFormat("HH:mm")
                      .format(DateTime.parse(message.createDate!)),
                  Selected: selectedIndex.contains(i) &&
                          selectedMessageContant.contains(message.message)
                      ? 1
                      : 0,
                ),
              )
            : GestureDetector(
                onTap: () {
                  if (selectedMessageIDNumber.length > 0) {
                    SelectOrUnselect(message.message!, message.id!, i);
                  }
                },
                onLongPress: () {
                  SelectOrUnselect(message.message!, message.id!, i);
                },
                child: ReplyCard(
                  message: message.message!,
                  time: DateFormat("HH:mm")
                      .format(DateTime.parse(message.createDate!)),
                  Selected: selectedIndex.contains(i) &&
                          selectedMessageContant.contains(message.message)
                      ? 2
                      : 0,
                ),
              );
        break;
    }
  }

  Future<void> openMp4View(String Url) async {
    setState(() {
      _isOpenPross = true;
    });

    await Get.to(() => GenericFileWebView(
          messageUrl: Url,
        ));
    setState(() {
      _isOpenPross = false;
    });
  }

  Future<void> openImageview(String Url) async {
    setState(() {
      _isOpenPross = true;
    });

    await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => imagePage(
                  image: Url,
                )));
    setState(() {
      _isOpenPross = false;
    });
  }

  Future<void> openPdfView(String pdf, String thumNail) async {
    setState(() {
      _isOpenPross = true;
    });
    var file;
    print(pdf);

    setState(() {
      _isOpenPross = false;
    });
    Get.to(() => PDFviewChat(
          file: file,
          thumNail: thumNail,
          pdf: pdf,
        ));
    setState(() {
      _isOpenPross = false;
    });
  }

//#region Recorder Things
  Future<void> openTheRecorder() async {
    await _mRecorder
        .openRecorder(); //! openAudioSession yerine openRecorder kullanildi
    _mRecorderIsInited = true;
  }

  void record() async {
    print("RECORD BASLADI");
    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/flutter_sound_example.aac';
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    outputFile.openWrite();
    _mRecorder
        .startRecorder(
      toFile: _mPath,
      //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder.stopRecorder().then((value) {
      setState(() {});
    });
  }

  getRecorderFn() async {
    if (!_mRecorderIsInited) {
      return null;
    } else {
      if (_mRecorder.isStopped) {
        record();
      } else {
        await stopRecorder; //! stopRecorder() yerine stopRecorder kullanildi
      }
    }
  }

  String getRecordedSound() {
    List<int> filePath;
    File file = File(_mPath);
    filePath = file.readAsBytesSync();
    base64Record = base64Encode(filePath);
    print(base64Record);
    return base64Record;
  }
//#endregion
}
