import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Chat/OwnMessage.dart';
import 'package:undede/Pages/Chat/ReplyMessage.dart';
import 'package:undede/Pages/Collaboration/TodoComments/OwnComment.dart';
import 'package:undede/Pages/Collaboration/TodoComments/ReplyComment.dart';
import 'package:undede/Pages/Message/imagePage.dart';
import 'package:undede/Pages/PDFView.dart';
import 'package:undede/Pages/PdfApi.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Chat/GetChatResult.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Todo/GetTodoCommentsResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TodoCommentsDetail extends StatefulWidget {
  final int? index;
  final String? title;
  const TodoCommentsDetail({Key? key, this.index, this.title}) : super(key: key);

  @override
  _TodoCommentsDetailState createState() => _TodoCommentsDetailState();
}

bool message = true;
int selectedMessage = 0;

class _TodoCommentsDetailState extends State<TodoCommentsDetail>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  GetChatResult _getChatResult = GetChatResult(hasError: false);
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
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
  List<FileInput> allFiles = [];
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

  int firstMessage = 0;
  Files files = new Files();
  @override
  void initState() {
    super.initState();
    GetComments();
    advancedPlayer = new AudioPlayer();
    initPlayer();
    files.fileInput = <FileInput>[];
    SchedulerBinding.instance.addPostFrameCallback((_) {
      hintmessage = AppLocalizations.of(context)!.typeaMessage;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  GetComments() async {
    await _controllerTodo.GetTodoComments(
      _controllerDB.headers(),
      TodoId: _controllerTodo.commnets.value!.result![0].todoId!,
      UserId: _controllerDB.user.value!.result!.id!,
    );
  }

  sendComments(
    String Comment,
    String AudioFile,
    Files files,
  ) async {
    await _controllerTodo.InsertTodoComment(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        TodoId: _controllerTodo.commnets.value!.result![widget.index!].todoId!,
        RelatedCommentId:
            _controllerTodo.commnets.value!.result![widget.index!].id!,
        Comment: Comment,
        AudioFile: AudioFile,
        files: files,
        isCombine: true,
        CombineFileName: "sample.pdf");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerTodo>(
        builder: (_) => Scaffold(
              backgroundColor: Color(0xFFF0F7F7),
              appBar: CustomAppBar(title:AppLocalizations.of(context)!.collaboration,),
              body: GestureDetector(
                onTap: () {
                  if (_controller.text.isBlank!) {
                    setState(() {
                      sendButton = false;
                    });
                  }
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  child: Column(children: [

                    widget.title != null
                        ? Container(
                            width: Get.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${widget.title!.split('-')[0].toString().trim()}",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500),
                                ),
                                widget.title!
                                        .split('-')[0]
                                        .toString()
                                        .trim()
                                        .isBlank!
                                    ? Container()
                                    : Container(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 3),
                                        child: Icon(
                                          Icons.double_arrow,
                                          color: Get.theme.colorScheme.surface,
                                        )),
                                Text(
                                  "${widget.title!.split('-')[1].toString().trim()}",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    child: Icon(
                                      Icons.double_arrow,
                                      color: Get.theme.colorScheme.surface,
                                    )),
                                Text(
                                  "${widget.title!.split('-')[2].toString().trim()}",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: Get.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.notification,
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    child: Icon(
                                      Icons.double_arrow,
                                      color: Get.theme.colorScheme.surface,
                                    )),
                              ],
                            ),
                          ),
                    Expanded(
                      child: Container(
                        width: Get.width,
                        color: Get.theme.secondaryHeaderColor,
                        child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: 10, left: 10, right: 10, top: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundImage: NetworkImage(
                                                _controllerTodo
                                                    .commnets
                                                    .value!
                                                    .result![widget.index!]
                                                    .userPhoto!),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            _controllerTodo.commnets.value!
                                                .result![widget.index!].userName!,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Spacer(),
                                          Text(
                                            DateFormat.yMMMd(
                                                    AppLocalizations.of(context)
                                                        !.date)
                                                .add_jm()
                                                .format(DateTime.parse(
                                                    _controllerTodo
                                                        .commnets
                                                        .value!
                                                        .result![widget.index!]
                                                        .createDate!)),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 40),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _controllerTodo.commnets.value!
                                                  .result![widget.index!]
                                                  .comment!,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: Get.width,
                                              height: 75,
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: _controllerTodo
                                                      .commnets
                                                      .value!
                                                      .result![widget.index!]
                                                      .fileList!
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      textDirection:
                                                          ui.TextDirection.rtl,
                                                      children: [
                                                        pdfFile(_controllerTodo
                                                            .commnets
                                                            .value!
                                                            .result![
                                                                widget.index!]
                                                            .fileList![index]),
                                                      ],
                                                    );
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        thickness: 0.7,
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    reverse: true,
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                            reverse: true,
                                            shrinkWrap: true,
                                            addAutomaticKeepAlives: true,
                                            physics: ScrollPhysics(),
                                            itemCount: _controllerTodo
                                                .commnets
                                                .value!
                                                .result![widget.index!]
                                                .relatedCommentList!
                                                .length,
                                            padding: EdgeInsets.only(left: 20),
                                            itemBuilder: (ctx, i) {
                                              return _controllerTodo
                                                          .commnets
                                                          .value!
                                                          .result![widget.index!]
                                                          .relatedCommentList![i]
                                                          .userId ==
                                                      _controllerDB
                                                          .user.value!.result!.id!
                                                  ? OwnMessage(i)
                                                  : Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 50),
                                                      child: GestureDetector(
                                                          onLongPress: () {
                                                            setState(() {});
                                                          },
                                                          child:
                                                              ReplyMessage(i)),
                                                    );
                                            }),
                                      ],
                                    ),
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              80,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
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
                                                                          FontWeight
                                                                              .w500),
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
                                                                    Icons.close,
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
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    child: TextFormField(
                                                      onTap: () {
                                                        if (_controller
                                                            .text.isBlank!) {
                                                          setState(() {
                                                            sendButton = false;
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
                                                        if (value.length > 0) {
                                                          setState(() {
                                                            sendButton = true;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            sendButton = false;
                                                          });
                                                        }
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: hintmessage,
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey),
                                                        prefixIcon: IconButton(
                                                          icon: Icon(
                                                            show
                                                                ? Icons.keyboard
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
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(Icons
                                                                  .attach_file),
                                                              onPressed: () {
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus(
                                                                        new FocusNode());

                                                                _showPicker(
                                                                    context);
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: Icon(Icons
                                                                  .camera_alt),
                                                              onPressed: () {
                                                                print("camera");
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
                                                  } else {}
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

                                                    await _stop();

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
                                                    !_controller.text.isBlank!) {
                                                  await sendComments(
                                                      _controller.text,
                                                      "",
                                                      files);
                                                  print(files.fileInput!.length);
                                                  if (files.fileInput!.length !=
                                                      0) {
                                                    files.fileInput!.clear();
                                                  }
                                                  await _controllerTodo
                                                      .GetTodoComments(
                                                    _controllerDB.headers(),
                                                    TodoId: _controllerTodo
                                                        .commnets
                                                        .value!
                                                        .result![0]
                                                        .todoId!,
                                                    UserId: _controllerDB
                                                        .user.value!.result!.id!,
                                                  );
                                                  if (replyButton) {
                                                    replyButton = false;
                                                    _controller.clear();
                                                    sendButton = false;

                                                    setState(() {});
                                                  } else {
                                                    print("mice basıldı");
                                                  }
                                                }
                                                _controller.clear();
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
                  ]),
                ),
              ),
            ));
  }

  Column ReplyMessage(int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(_controllerTodo.commnets.value!
                  .result![widget.index!].relatedCommentList![i].userPhoto!),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              _controllerTodo.commnets.value!.result![widget.index!]
                  .relatedCommentList![i].userName!,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Text(
              DateFormat.yMMMd(AppLocalizations.of(context)!.date)
                  .add_jm()
                  .format(DateTime.parse(_controllerTodo.commnets.value!
                      .result![widget.index!]
                      .relatedCommentList![i]
                      .createDate!)),
              textAlign: TextAlign.right,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _controllerTodo.commnets.value!.result![widget.index!]
                    .relatedCommentList![i].comment!,
              ),
              SizedBox(
                height: 5,
              ),
              _controllerTodo.commnets.value!.result![widget.index!]
                          .relatedCommentList![i].fileList!.length ==
                      0
                  ? Container()
                  : Container(
                      width: Get.width,
                      height: 75,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _controllerTodo
                              .commnets
                              .value!
                              .result![widget.index!]
                              .relatedCommentList![i]
                              .fileList!
                              .length,
                          itemBuilder: (context, index) {
                            return Row(
                              textDirection: ui.TextDirection.rtl,
                              children: [
                                pdfFile(_controllerTodo
                                    .commnets
                                    .value!
                                    .result![widget.index!]
                                    .relatedCommentList![i]
                                    .fileList![index]),
                              ],
                            );
                          }),
                    ),
            ],
          ),
        ),
        Divider(
          thickness: 0.7,
        )
      ],
    );
  }

  Column OwnMessage(int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(_controllerTodo.commnets.value!
                  .result![widget.index!]
                  .relatedCommentList![i]
                  .userPhoto!),
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Text(
                  _controllerTodo.commnets.value!.result![widget.index!]
                      .relatedCommentList![i]
                      .userName!,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  _controllerTodo.commnets.value!.result![widget.index!]
                      .relatedCommentList![i]
                      .comment!,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                DateFormat.yMd(AppLocalizations.of(context)!.date)
                    .add_jm()
                    .format(DateTime.parse(_controllerTodo
                        .commnets
                        .value!
                        .result![widget.index!]
                        .relatedCommentList![i]
                        .createDate!)),
              ),
              _controllerTodo.commnets.value!.result![widget.index!]
                          .relatedCommentList![i]
                          .fileList!.length ==
                      0
                  ? Container()
                  : Container(
                      width: Get.width,
                      height: 75,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _controllerTodo
                              .commnets
                              .value!
                              .result![widget.index!]
                              .relatedCommentList![i]
                              .fileList!
                              .length,
                          itemBuilder: (context, index) {
                            return Row(
                              textDirection: ui.TextDirection.rtl,
                              children: [
                                pdfFile(_controllerTodo
                                    .commnets
                                    .value!
                                    .result![widget.index!]
                                    .relatedCommentList![i]
                                    .fileList![index]),
                              ],
                            );
                          }),
                    ),
            ],
          ),
        ),
        Divider(
          thickness: 0.7,
        )
      ],
    );
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
                  /*  new ListTile(
                      leading: new Icon(
                        Icons.insert_drive_file,
                        color: Colors.indigo,
                      ),
                      title: new Text('Document'),
                      onTap: () {
                        openFile();

                        Navigator.of(context).pop();
                      }),

                 */
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
                ],
              ),
            ),
          );
        });
  }

  Widget bottomSheet() {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        margin: const EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        print("camera");
                        _onImageButtonPressed(ImageSource.camera,
                            context: context);
                      },
                      child: iconCreation(
                          Icons.camera_alt, Colors.pink, "Camera")),
                  SizedBox(
                    width: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      _onImageButtonPressed(ImageSource.gallery,
                          context: context);
                    },
                    child: iconCreation(
                        Icons.insert_photo, Colors.purple, "Gallery"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
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
      decoration: BoxDecoration(
        color: Get.theme.secondaryHeaderColor,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                Spacer(),
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
        files.fileInput = <FileInput>[];

        List<int> imageBytes = File(profileImage!.path).readAsBytesSync();
        base64Image = base64Encode(imageBytes);
        files.fileInput!.add(new FileInput(
            fileName: 'sample.pdf', directory: "", fileContent: base64Image));
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
    files.fileInput = <FileInput>[];
    base64file = base64Encode(filePath);
    files.fileInput!.add(new FileInput(
        fileName: 'sample.pdf', directory: "", fileContent: base64file));

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

  _stop() async {}

  void initPlayer() {
    advancedPlayer = new AudioPlayer();

    advancedPlayer!.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

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

  Widget voicePlayer2(Messages message) {
    return Row(
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
                          style: TextStyle(color: Colors.green, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        CircleAvatar(
                          radius: 15,
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
                          style: TextStyle(color: Colors.green, fontSize: 12),
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
                          await advancedPlayer!.play(UrlSource(message.message!));
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
    );
  }

  Widget voicePlayer(Messages message) {
    return Row(
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
                          style: TextStyle(color: Colors.green, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        CircleAvatar(
                          radius: 15,
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
                          style: TextStyle(color: Colors.green, fontSize: 12),
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
                          await advancedPlayer!.play(UrlSource(message.message!));
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
    );
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer!.seek(newDuration);
  }

  Widget imageMessage(Messages message) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => imagePage(
                      image: message.message!,
                    )));
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
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                height: 300,
                child: Image.network(
                  message.message!,
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
            )
          ],
        ),
      ),
    );
  }

  Widget imageMessage2(Messages message) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => imagePage(
                      image: message.message!,
                    )));
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
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                height: 300,
                child: Image.network(
                  message.message!,
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
            )
          ],
        ),
      ),
    );
  }

  Widget pdfFile(FileList pdf) {
    return GestureDetector(
      onTap: () {
        openPdfView(pdf.path!);
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: pdf.userId == _controllerDB.user.value!.result!.id!
            ? Color(0xffdcf8c6)
            : Colors.white,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              height: 35,
              child: Image.network(
                "https://cdn0.iconfinder.com/data/icons/office-files-icons/110/Pdf-File-512.png",
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageBox(Messages message) {
    String extension = p.extension(message.message!);

    switch (extension) {
      case '.mp3':
        return message.senderId == _controllerDB.user.value!.result!.id!
            ? voicePlayer(message)
            : voicePlayer2(message);
        break;

      case '.jpg':
        return message.senderId == _controllerDB.user.value!.result!.id!
            ? imageMessage(message)
            : imageMessage2(message);
        break;

      case '.jpeg':
        return message.senderId == _controllerDB.user.value!.result!.id!
            ? imageMessage(message)
            : imageMessage2(message);
        break;

      case '.png':
        return message.senderId == _controllerDB.user.value!.result!.id!
            ? imageMessage(message)
            : imageMessage2(message);
        break;

      case '.pdf':
        return Container();
        break;

      //{case '.mp4':
      //         return videoMessage(message);
      //         break;}

      default:
        return Container();
        break;
    }
  }

  Future<void> openPdfView(String pdf) async {
    var file;
    try {
      pdf = pdf.replaceAll('\\', '/');

      file = await PDFApi.loadNetwork(pdf);
    } catch (e, stacktrace) {
      showToast('"Dosya pathi hatalı"');
      print(stacktrace);
    }
    if (file != null) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => PDFViewerPage(
                    fileUrl: pdf,
                  )));
    }
  }
}
