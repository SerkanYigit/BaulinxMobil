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
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Controller/ControllerChatNew.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/showModalTextInput.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Chat/OwnMessage.dart';
import 'package:undede/Pages/Chat/PDFviewChat.dart';
import 'package:undede/Pages/Chat/ReplyMessage.dart';
import 'package:undede/Pages/Message/NewMessage.dart';
import 'package:undede/Pages/Message/imagePage.dart';
import 'package:undede/Services/BlockReport/BlockReportDB.dart';
import 'package:undede/Services/Chat/ChatDB.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/model/Chat/ChatMessageSaveResult.dart';
import 'package:undede/model/Chat/GetChatResult.dart';
import 'package:undede/model/Common/CareateOrJoinMettingResult.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:socket_io_client/src/darty.dart';
import '../../../Custom/CustomLoadingCircle.dart';
import '../../PDFView.dart';
import '../../PdfApi.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'ChatGroupDetailHeader.dart';

class ChatGroupDetailPage extends StatefulWidget {
  final int Id;
  final String image;
  final int? diffentPage;
  final int isGroup;
  final bool blocked;
  const ChatGroupDetailPage(
      {required this.Id,
      required this.image,
      this.diffentPage,
      required this.isGroup,
      required this.blocked});

  @override
  _ChatGroupDetailPageState createState() => _ChatGroupDetailPageState();
}

bool message = true;
int selectedMessage = 0;
ChatDB _chatMessageSaveDB = ChatDB();
PanelController _pc = new PanelController();

class _ChatGroupDetailPageState extends State<ChatGroupDetailPage>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerChatNew _controllerChat = Get.put(ControllerChatNew());
  GetChatResult _getChatResult = GetChatResult(hasError: false);
  CommonDB _commonDB = new CommonDB();

  ChatMessageSaveResult _chatMessageSaveResult =
      ChatMessageSaveResult(hasError: false);
  bool isLoading = false;
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  // Selected Message
  int? selectedMessageID;
  int? selectedMessageIDNumber;
  String? selectedMessageContant;
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
  late AnimationController controller;
  List<int> targetUserIdList = [];
  bool loading = true;
  CareateOrJoinMettingResult _careateOrJoinMettingResult =
      CareateOrJoinMettingResult(hasError: false);
  double _panelMinSize = 0.0;

  /*      FLUTTER SOUND     */
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  String _mPath = 'flutter_sound_example.aac';

  void initController() {
    controller = BottomSheet.createAnimationController(this);
    controller.duration = const Duration(milliseconds: 100);
    controller.reverseDuration = const Duration(milliseconds: 100);
  }

  int firstMessage = 0;
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
    _scrollController = new ScrollController()..addListener(_loadMore);
    _firstAutoscrollExecuted = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
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
    updareUserList();
  }

  updareUserList() async {
    await _controllerChat.GetUserList(
        _controllerDB.headers(), _controllerDB.user.value!.result!.id!);
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
      setState(() {});
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
    List<int> GroupUserIdList = [];
    _getChatResult.result!.userList!.forEach((element) {
      GroupUserIdList.add(element.id!);
    });
    await _controllerChat.ChatMessageSave(_controllerDB.headers(),
            Id: 0,
            SenderId: _controllerDB.user.value!.result!.id!,
            ReceiverId: widget.isGroup == 1 ? 0 : ReceiverId,
            Type: type,
            Message: Message,
            MessageBase64: MessageBase64,
            PublicId: 0,
            GroupId: widget.isGroup == 1 ? ReceiverId : 0,
            RelatedMessageId: 0)
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
        "UserId": _controllerDB.user.value!.result!.id!,
        "GroupUserIdList": GroupUserIdList
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
    });
  }

  Future<void> CareateOrJoinMetting(List<int> TargetUserIdList) async {
    await _commonDB.CareateOrJoinMetting(_controllerDB.headers(),
            OwnerId: _controllerDB.user.value!.result!.id!,
            UserId: _controllerDB.user.value!.result!.id!,
            TargetUserIdList: TargetUserIdList,
            ModuleType: 20)
        .then((value) {
      setState(() {
        _careateOrJoinMettingResult = value;
        loading = false;
      });
    });
  }

  BlockReportDB _blockReportDB = BlockReportDB();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerChatNew>(builder: (c) {
      if (c.refreshDetail) {
        getChat(0);
        c.refreshDetail = false;
        c.update();
      }
      return Scaffold(
        backgroundColor: Color(0xFFF0F7F7),
        body: !isLoading
            ? Text("ChatDetailPage") //CustomLoadingCircle()
            : SlidingUpPanel(
                defaultPanelState: PanelState.CLOSED,
                controller: _pc,
                panel: Container(
                  child: loading
                      ? Text("ChatDetailPage") //CustomLoadingCircle()
                      : Stack(
                          children: [
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
                                          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 OPR/81.0.4196.60",
                                    ),
                                    android: AndroidInAppWebViewOptions(
                                      useHybridComposition: true,
                                    ),
                                    ios: IOSInAppWebViewOptions(
                                      allowsInlineMediaPlayback: true,
                                    )),
                                initialUrlRequest: URLRequest(
                                  url:
                                      //! Uri.parse yerine WebUri kullanildi
                                      WebUri(_careateOrJoinMettingResult
                                          .result!.meetingUrl!),
                                )),
                            Positioned(
                              right: 13,
                              bottom: 9,
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _panelMinSize = 0.0;
                                  });
                                  _pc.close();
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                  child: Icon(
                                    Icons.call_end,
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
                body: GestureDetector(
                  onTap: () {
                    if (_controller.text.isBlank!) {
                      setState(() {
                        sendButton = false;
                      });
                    }

                    selectedMessageFalser();
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    width: Get.width,
                    height: Get.height,
                    child: Column(children: [
                      if (selectedMessage == 0)
                        Header(MediaQuery.of(context).padding.top,
                            _getChatResult, widget.image)
                      else if (selectedMessage == 1)
                        Header2(MediaQuery.of(context).padding.top,
                            selectedMessageIDNumber!)
                      else
                        Header3(MediaQuery.of(context).padding.top,
                            selectedMessageIDNumber!),
                      Expanded(
                        child: Container(
                          width: Get.width,
                          color: Get.theme.secondaryHeaderColor,
                          child: Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F7F7),
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
                                        child: CircularProgressIndicator(),
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
                                          itemCount: _getChatResult
                                              .result!.messages!.length,
                                          itemBuilder: (ctx, i) {
                                            print(i);
                                            if (i % 30 == 0) {
                                              firstMessage = _getChatResult
                                                  .result!.messages![0].id!;
                                              print(
                                                  "relatedıd içine girdi$firstMessage");
                                            }

                                            return _getChatResult
                                                        .result!
                                                        .messages![i]
                                                        .senderId ==
                                                    _controllerDB
                                                        .user.value!.result!.id!
                                                ? GestureDetector(
                                                    child: messageBox(
                                                        _getChatResult.result!
                                                            .messages![i],
                                                        i),
                                                  )
                                                : GestureDetector(
                                                    child: messageBox(
                                                        _getChatResult.result!
                                                            .messages![i],
                                                        i),
                                                  );
                                          }),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            height: replyButton ? 100 : null,
                                            decoration: BoxDecoration(
                                                color: replyButton
                                                    ? Colors.white
                                                        .withOpacity(0.9)
                                                    : null,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
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
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.7)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    selectedMessagePerson!,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Spacer(),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        replyButton =
                                                                            false;
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      size: 15,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              Flexible(
                                                                child: Text(
                                                                    selectedMessageContant!,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      60,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Card(
                                                      margin: EdgeInsets.only(
                                                        left: 2,
                                                        right: 2,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                      ),
                                                      child: TextFormField(
                                                        onTap: () {
                                                          if (_controller
                                                              .text.isBlank!) {
                                                            setState(() {
                                                              sendButton =
                                                                  false;
                                                            });
                                                          }
                                                          setState(() {});
                                                        },
                                                        controller: _controller,
                                                        focusNode: focusNode,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        maxLines: 5,
                                                        minLines: 1,
                                                        onChanged: (value) {
                                                          if (value.length >
                                                              0) {
                                                            setState(() {
                                                              sendButton = true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              sendButton =
                                                                  false;
                                                            });
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: hintmessage,
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                          prefixIcon:
                                                              IconButton(
                                                            icon: Icon(
                                                              show
                                                                  ? Icons
                                                                      .keyboard
                                                                  : Icons
                                                                      .emoji_emotions_outlined,
                                                            ),
                                                            onPressed: () {
                                                              if (!show) {
                                                                focusNode
                                                                    .unfocus();
                                                                focusNode
                                                                        .canRequestFocus =
                                                                    false;
                                                              }
                                                              setState(() {
                                                                show = !show;
                                                              });
                                                            },
                                                          ),
                                                          suffixIcon: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons
                                                                    .attach_file),
                                                                onPressed: () {
                                                                  showModalBottomSheet(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (builder) =>
                                                                              bottomSheet());
                                                                },
                                                              ),
                                                              IconButton(
                                                                icon: Icon(Icons
                                                                    .camera_alt),
                                                                onPressed: () {
                                                                  print(
                                                                      "camera");
                                                                  _onImageButtonPressed(
                                                                      ImageSource
                                                                          .camera,
                                                                      context:
                                                                          context);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets.all(5),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 2,
                                              left: 2,
                                            ),
                                            child: CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  recordingBackGround,
                                              child: IconButton(
                                                icon: GestureDetector(
                                                  onLongPressStart: (_) async {
                                                    if (sendButton) {
                                                    } else {
                                                      getRecorderFn();
                                                    }
                                                  },
                                                  onLongPressEnd: (_) async {
                                                    if (sendButton) {
                                                    } else {
                                                      iconsize = 24;
                                                      iconColor = Colors.white;
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

                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              new FocusNode());
                                                    }
                                                  },
                                                  child: sendButton
                                                      ? Icon(
                                                          Icons.send,
                                                          color: Colors.white,
                                                        )
                                                      : micIcon(
                                                          iconsize, iconColor),
                                                ),
                                                onPressed: () async {
                                                  if (sendButton &&
                                                      !_controller
                                                          .text.isBlank!) {
                                                    if (replyButton) {
                                                      await PostChatMessageSave(
                                                          widget.Id,
                                                          _controller.text
                                                              .trim(),
                                                          "",
                                                          selectedMessageIDNumber!,
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
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: WidgetsBinding.instance.window
                                                .viewInsets.bottom >
                                            0
                                        ? 10
                                        : 100,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            WidgetsBinding.instance.window.viewInsets.bottom > 0
                                ? EdgeInsets.fromWindowPadding(
                                        WidgetsBinding
                                            .instance.window.viewInsets,
                                        WidgetsBinding
                                            .instance.window.devicePixelRatio)
                                    .bottom
                                : 0,
                      )
                    ]),
                  ),
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
                            openFile();
                            Navigator.pop(context);
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
                              _onImageButtonPressed(ImageSource.camera,
                                  context: context);
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
    print(widget.diffentPage.isBlank);
    return Container(
      width: Get.width,
      height: widget.diffentPage == 0 ? 100 : 75,
      padding: EdgeInsets.only(
        top: widget.diffentPage == 0 ? padding : 0,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChatGroupDetailHeader(
                              userList: _getChatResult.result!.userList!,
                              Name: _getChatResult.result!.otherUserName!,
                              Photo: _getChatResult.result!.otherUserPhoto!,
                              groupId: widget.Id,
                            )));
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Stack(
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.0,
                              color: Colors.black,
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
                                    size: 7,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          await Permission.camera.request();
                          await Permission.microphone.request();
                          setState(() {
                            _pc.open();
                            _panelMinSize = 170.0;
                            targetUserIdList.add(widget.Id);
                          });
                          await CareateOrJoinMetting(targetUserIdList);

                          print(
                              _careateOrJoinMettingResult.result!.meetingUrl!);
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
                        child: Icon(
                          Icons.call,
                          color: Colors.black,
                          size: 27,
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
                                  blockType: 2);
                              Navigator.pop(context);
                            }
                            if (a == 2) {
                              String? text = await showModalTextInput(
                                  context,
                                  "Kullanıcıyı reporlama sebebinizi yazınız",
                                  "Report");
                              _blockReportDB.ReportUser(_controllerDB.headers(),
                                  userId: _controllerDB.user.value!.result!.id!,
                                  reportedUserId:
                                      getChatResult.result!.otherUserId!,
                                  reportMessage: text!,
                                  blockType: 2);
                              Navigator.pop(context);
                            }
                            if (a == 3) {
                              _blockReportDB.UnBlockUser(
                                  _controllerDB.headers(),
                                  userId: _controllerDB.user.value!.result!.id!,
                                  blockedUserId:
                                      getChatResult.result!.otherUserId!,
                                  blockType: 2);
                              Navigator.pop(context);
                            }
                          },
                          child: Center(
                              child: Icon(
                            Icons.more_vert,
                            color: Colors.black,
                            size: 27,
                          )),
                          itemBuilder: (context) => [
                                widget.blocked
                                    ? PopupMenuItem(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .unBlock),
                                        value: 3,
                                      )
                                    : PopupMenuItem(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .block),
                                        value: 1,
                                      ),
                                PopupMenuItem(
                                  child: Text(
                                      AppLocalizations.of(context)!.report),
                                  value: 2,
                                )
                              ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget Header2(double padding, int MessageId) {
    return Container(
      width: Get.width,
      height: 100,
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
                      onTap: () async {
                        await deleteMessage(MessageId);
                        await getChat(0);
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.deleted,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Get.theme.secondaryHeaderColor,
                            textColor: Get.theme.primaryColor,
                            fontSize: 16.0);
                        setState(() {});
                        selectedMessageFalser();
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 27,
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

  Widget Header3(double padding, int MessageId) {
    return Container(
      width: Get.width,
      height: 100,
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
                    Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 27,
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
      final pickedFile = await _imagePicker.pickImage(source: source);
      setState(() async {
        profileImage = pickedFile;

        List<int> imageBytes = File(profileImage!.path).readAsBytesSync();
        base64Image = base64Encode(imageBytes);
        await PostChatMessageSave(widget.Id, "deneme.jpg", base64Image, 0, 5);
        await getChat(0);

        FocusScope.of(context).requestFocus(new FocusNode());
        print("dosyaya geldim: $profileImage");
      });
      print('aaa');
    } catch (e) {
      setState(() {
        _pickImage = e;
        print("Image Error: " + _pickImage);
      });
    }
  }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    List<int> filePath;
    filePath = File(result!.files.single.path!).readAsBytesSync();
    base64file = base64Encode(filePath);
    await PostChatMessageSave(widget.Id, "deneme.pdf", base64file, 0, 5);
    await getChat(0);

    FocusScope.of(context).requestFocus(new FocusNode());
    //   final _result = await OpenFile.open(filePath);

    print("********************");

    print(filePath);
    print("********************");
    print("********************");

    setState(() {
      // _openResult = "type=${_result.type}  message=${_result.message}";
    });
  }

  Future<void> openAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    List<int> filePath;
    filePath = File(result!.files.single.path!).readAsBytesSync();
    base64file = base64Encode(filePath);
    await PostChatMessageSave(widget.Id, "deneme.mp3", base64file, 0, 5);
    await getChat(0);

    FocusScope.of(context).requestFocus(new FocusNode());
    //   final _result = await OpenFile.open(filePath);

    print("********************");

    print(filePath);
    print("********************");
    print("********************");

    setState(() {
      // _openResult = "type=${_result.type}  message=${_result.message}";
    });
  }

  Future<void> openVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    List<int> filePath;
    filePath = File(result!.files.single.path!).readAsBytesSync();
    base64file = base64Encode(filePath);
    await PostChatMessageSave(widget.Id, "deneme.mp4", base64file, 0, 5);
    await getChat(0);

    FocusScope.of(context).requestFocus(new FocusNode());
    //   final _result = await OpenFile.open(filePath);

    print("********************");

    print(filePath);
    print("********************");
    print("********************");

    setState(() {
      // _openResult = "type=${_result.type}  message=${_result.message}";
    });
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();

    advancedPlayer!.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });
//! onAudioPositionChanged yerine onPositionChanged.listen kullanildi
    advancedPlayer!.onPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });

    advancedPlayer!.onPlayerStateChanged.listen((event) {
      if (event.index != 1) {
        setState(() {
          int a = 0;
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
        setState(() {
          if (selectedMessage != 0) {
            selectedMessage = 0;
            selectedMessageID = 0;
            selectedMessageIDNumber = 0;
            selectedMessageContant = "";
            return;
          }
          selectedMessage = 2;
          selectedMessageID = index;
          selectedMessageIDNumber = message.id;
          selectedMessageContant = message.message;
          selectedMessagePerson = _getChatResult.result!.otherUserName! +
              " " +
              _getChatResult.result!.otherUserSurname!;
          print("içerde");
        });
        setState(() {});
      },
      onTap: () {
        setState(() {
          if (selectedMessage != 0) {
            selectedMessage = 0;
            selectedMessageID = 0;
            selectedMessageIDNumber = 0;
            selectedMessageContant = "";
            return;
          }
        });
      },
      child: Container(
        color: selectedMessage != 0 &&
                selectedMessageID == index &&
                selectedMessageIDNumber == message.id
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

  Widget voicePlayer(Messages message, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedMessage != 0) {
            selectedMessage = 0;
            selectedMessageID = 0;
            selectedMessageIDNumber = 0;
            selectedMessageContant = "";
            return;
          }
        });
      },
      onLongPress: () {
        setState(() {
          if (selectedMessage != 0) {
            selectedMessage = 0;
            selectedMessageID = 0;
            selectedMessageIDNumber = 0;
            selectedMessageContant = "";
            return;
          }
          selectedMessage = 1;
          selectedMessageID = index;
          selectedMessageIDNumber = message.id;
          selectedMessageContant = message.message;
          selectedMessagePerson = "You";
          print("içerde");
        });
      },
      child: Container(
        color: selectedMessage != 0 &&
                selectedMessageID == index &&
                selectedMessageIDNumber == message.id
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
                              //! messsage.message yerine UrlSource(message.message!) kullanildi
                              await advancedPlayer!
                                  .play(UrlSource(message.message!));
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
            color: selectedMessage != 0 &&
                    selectedMessageID == index &&
                    selectedMessageIDNumber == message.id
                ? Colors.green.withOpacity(0.5)
                : null,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedMessage != 0) {
                    selectedMessage = 0;
                    selectedMessageID = 0;
                    selectedMessageIDNumber = 0;
                    selectedMessageContant = "";
                    return;
                  }
                });
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => imagePage(
                              image: message.message!,
                            )));
              },
              onLongPress: () {
                setState(() {
                  if (selectedMessage != 0) {
                    selectedMessage = 0;
                    selectedMessageID = 0;
                    selectedMessageIDNumber = 0;
                    selectedMessageContant = "";
                    return;
                  }
                  selectedMessage = 1;
                  selectedMessageID = index;
                  selectedMessageIDNumber = message.id;
                  selectedMessageContant = message.message;
                  selectedMessagePerson = "You";
                  print("içerde");
                });
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
                    color: selectedMessage != 0 &&
                            selectedMessageID == index &&
                            selectedMessageIDNumber == message.id
                        ? Colors.green.withOpacity(0.5)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedMessage != 0) {
                            selectedMessage = 0;
                            selectedMessageID = 0;
                            selectedMessageIDNumber = 0;
                            selectedMessageContant = "";
                            return;
                          }
                        });
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) => imagePage(
                                      image: message.fileList![i].path!,
                                    )));
                      },
                      onLongPress: () {
                        setState(() {
                          if (selectedMessage != 0) {
                            selectedMessage = 0;
                            selectedMessageID = 0;
                            selectedMessageIDNumber = 0;
                            selectedMessageContant = "";
                            return;
                          }
                          selectedMessage = 1;
                          selectedMessageID = index;
                          selectedMessageIDNumber = message.id;
                          selectedMessageContant = message.fileList![i].path;
                          selectedMessagePerson = "You";
                          print("içerde");
                        });
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
                                  child: message.fileList != null
                                      ? CachedNetworkImage(
                                          width: 100,
                                          imageUrl: (message
                                              .fileList![i].thumbnailPath!),
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Image.network(
                                          message.message!,
                                          fit: BoxFit.cover,
                                        )
                                  //! NetworkImage yerine Image.network kullanildi
                                  /*    
                                  message.fileList != null
                                      ? CachedNetworkImage(
                                          width: 100,
                                          imageUrl: (message
                                              .fileList![i].thumbnailPath!),
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : NetworkImage(message.message!)),
                         
                          */
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
                    ),
                  );
                }),
          );
  }

  Widget imageMessage2(Messages message, int index) {
    return message.fileList == null
        ? Container(
            color: selectedMessage != 0 &&
                    selectedMessageID == index &&
                    selectedMessageIDNumber == message.id
                ? Colors.green.withOpacity(0.5)
                : null,
            child: GestureDetector(
              onTap: () {
                if (selectedMessage != 0) {
                  selectedMessage = 0;
                  selectedMessageID = 0;
                  selectedMessageIDNumber = 0;
                  selectedMessageContant = "";
                  return;
                }
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => imagePage(
                              image: message.message!,
                            )));
              },
              onLongPress: () {
                setState(() {
                  if (selectedMessage != 0) {
                    selectedMessage = 0;
                    selectedMessageID = 0;
                    selectedMessageIDNumber = 0;
                    selectedMessageContant = "";
                    return;
                  }
                  selectedMessage = 2;
                  selectedMessageID = index;
                  selectedMessageIDNumber = message.id;
                  selectedMessageContant = message.message;
                  selectedMessagePerson =
                      _getChatResult.result!.otherUserName! +
                          " " +
                          _getChatResult.result!.otherUserSurname!;
                  print("içerde");
                });
                setState(() {});
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
                    color: selectedMessage != 0 &&
                            selectedMessageID == index &&
                            selectedMessageIDNumber == message.id
                        ? Colors.green.withOpacity(0.5)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedMessage != 0) {
                          selectedMessage = 0;
                          selectedMessageID = 0;
                          selectedMessageIDNumber = 0;
                          selectedMessageContant = "";
                          return;
                        }
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) => imagePage(
                                      image: message.fileList![i].path!,
                                    )));
                      },
                      onLongPress: () {
                        setState(() {
                          if (selectedMessage != 0) {
                            selectedMessage = 0;
                            selectedMessageID = 0;
                            selectedMessageIDNumber = 0;
                            selectedMessageContant = "";
                            return;
                          }
                          selectedMessage = 2;
                          selectedMessageID = index;
                          selectedMessageIDNumber = message.id;
                          selectedMessageContant = message.fileList![i].path!;
                          selectedMessagePerson =
                              _getChatResult.result!.otherUserName! +
                                  " " +
                                  _getChatResult.result!.otherUserSurname!;
                          print("içerde");
                        });
                        setState(() {});
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
                                      ? CachedNetworkImage(
                                          width: 100,
                                          imageUrl: (message
                                              .fileList![i].thumbnailPath!),
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Image.network(
                                          message.message!,
                                          fit: BoxFit.cover,
                                        )

                                  //  NetworkImage(message.message),
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
                    ),
                  );
                }),
          );
  }

  Widget pdfFile(Messages message, int index) {
    return message.fileList == null
        ? Container(
            color: selectedMessage != 0 &&
                    selectedMessageID == index &&
                    selectedMessageIDNumber == message.id
                ? Colors.green.withOpacity(0.5)
                : null,
            alignment: message.senderId == _controllerDB.user.value!.result!.id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if (selectedMessage != 0) {
                  selectedMessage = 0;
                  selectedMessageID = 0;
                  selectedMessageIDNumber = 0;
                  selectedMessageContant = "";
                  return;
                }
                openPdfView(message.message!);
              },
              onLongPress: () {
                setState(() {
                  if (selectedMessage != 0) {
                    selectedMessage = 0;
                    selectedMessageID = 0;
                    selectedMessageIDNumber = 0;
                    selectedMessageContant = "";
                    return;
                  }
                  if (message.senderId ==
                      _controllerDB.user.value!.result!.id) {
                    selectedMessage = 1;
                    selectedMessageID = index;
                    selectedMessageIDNumber = message.id;
                    selectedMessageContant = message.message;
                    selectedMessagePerson = "You";
                  } else {
                    selectedMessage = 2;
                    selectedMessageID = index;
                    selectedMessageIDNumber = message.id;
                    selectedMessageContant = message.message;
                    selectedMessagePerson =
                        _getChatResult.result!.otherUserName! +
                            " " +
                            _getChatResult.result!.otherUserSurname!;
                  }

                  print("içerde");
                });
                setState(() {});
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
            height: 109.0 * message.fileList!.length,
            alignment: message.senderId == _controllerDB.user.value!.result!.id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ListView.builder(
                itemCount: message.fileList!.length,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return Container(
                    color: selectedMessage != 0 &&
                            selectedMessageID == index &&
                            selectedMessageIDNumber == message.id
                        ? Colors.green.withOpacity(0.5)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedMessage != 0) {
                          selectedMessage = 0;
                          selectedMessageID = 0;
                          selectedMessageIDNumber = 0;
                          selectedMessageContant = "";
                          return;
                        }
                        openPdfView(message.fileList![i].path!);
                      },
                      onLongPress: () {
                        setState(() {
                          if (selectedMessage != 0) {
                            selectedMessage = 0;
                            selectedMessageID = 0;
                            selectedMessageIDNumber = 0;
                            selectedMessageContant = "";
                            return;
                          }
                          if (message.senderId ==
                              _controllerDB.user.value!.result!.id) {
                            selectedMessage = 1;
                            selectedMessageID = index;
                            selectedMessageIDNumber = message.id;
                            selectedMessageContant = message.fileList![i].path!;
                            selectedMessagePerson = "You";
                          } else {
                            selectedMessage = 2;
                            selectedMessageID = index;
                            selectedMessageIDNumber = message.id;
                            selectedMessageContant = message.fileList![i].path!;
                            selectedMessagePerson =
                                _getChatResult.result!.otherUserName! +
                                    " " +
                                    _getChatResult.result!.otherUserSurname!;
                          }

                          print("içerde");
                        });
                        setState(() {});
                      },
                      child: Align(
                        alignment: message.senderId ==
                                _controllerDB.user.value!.result!.id
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          color: message.senderId ==
                                  _controllerDB.user.value!.result!.id
                              ? Color(0xffdcf8c6)
                              : Colors.white,
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: message.fileList![i].thumbnailPath!,
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
                  );
                }),
          );
  }

  Widget messageBox(Messages message, int i) {
    String extension = p.extension(message.message!);
    extension =
        extension.isBlank! ? message.message! : extension; //! buraya bak
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

      //{case '.mp4':
      //         return videoMessage(message);
      //         break;}

      default:
        return message.senderId == _controllerDB.user.value!.result!.id
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedMessage != 0) {
                      selectedMessage = 0;
                      selectedMessageID = 0;
                      selectedMessageIDNumber = 0;
                      selectedMessageContant = "";
                      return;
                    }
                  });
                },
                onLongPress: () {
                  setState(() {
                    if (selectedMessage != 0) {
                      selectedMessage = 0;
                      selectedMessageID = 0;
                      selectedMessageIDNumber = 0;
                      selectedMessageContant = "";
                      return;
                    }
                    selectedMessage = 1;
                    selectedMessageID = i;
                    selectedMessageIDNumber = message.id;
                    selectedMessageContant = message.message;
                    selectedMessagePerson = "You";
                    print("içerde");
                  });
                },
                child: OwnMessageCard(
                  message: message.message!,
                  time: DateFormat("HH:mm")
                      .format(DateTime.parse(message.createDate!)),
                  Selected: selectedMessage != 0 &&
                          selectedMessageID == i &&
                          selectedMessageIDNumber == message.id
                      ? selectedMessage
                      : 0,
                ),
              )
            : GestureDetector(
                onLongPress: () {
                  setState(() {
                    if (selectedMessage != 0) {
                      selectedMessage = 0;
                      selectedMessageID = 0;
                      selectedMessageIDNumber = 0;
                      selectedMessageContant = "";
                      return;
                    }
                    selectedMessage = 2;
                    selectedMessageID = i;
                    selectedMessageIDNumber = message.id;
                    selectedMessageContant = message.message!;
                    selectedMessagePerson =
                        _getChatResult.result!.otherUserName! +
                            " " +
                            _getChatResult.result!.otherUserSurname!;
                    print("içerde");
                  });
                  setState(() {});
                },
                onTap: () {
                  setState(() {
                    if (selectedMessage != 0) {
                      selectedMessage = 0;
                      selectedMessageID = 0;
                      selectedMessageIDNumber = 0;
                      selectedMessageContant = "";
                      return;
                    }
                  });
                },
                child: ReplyCard(
                  message: message.message!,
                  time: DateFormat("HH:mm")
                      .format(DateTime.parse(message.createDate!)),
                  Selected: selectedMessage != 0 &&
                          selectedMessageID == i &&
                          selectedMessageIDNumber == message.id
                      ? selectedMessage
                      : 0,
                ),
              );
        break;
    }
  }

  Future<void> openPdfView(String pdf) async {
    var file;
    try {
      // file = await PDFApi.loadNetwork(pdf);
    } catch (e, stacktrace) {
      print(stacktrace);
    }
  }

  //#region Recorder Things
  Future<void> openTheRecorder() async {
    await _mRecorder
        .openRecorder(); //! openSSesionRrecorder openrecorder deigistirildi
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

  stopRecorder() async {
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
        await stopRecorder();
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
