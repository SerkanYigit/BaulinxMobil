import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Collaboration/TodoComments/TodoCommentsDetail.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Todo/GetTodoCommentsResult.dart'
    as a;

class TodoComments extends StatefulWidget {
  final int? todoId;
  final int? openCommentId;
  final String? header;

  const TodoComments({Key? key, this.todoId, this.openCommentId, this.header})
      : super(key: key);
  @override
  _TodoCommentsState createState() => _TodoCommentsState();
}

class _TodoCommentsState extends State<TodoComments>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
  List<bool> listExpand = <bool>[];
  UserDB userDB = new UserDB();
  AdminCustomerResult adminCustomer = new AdminCustomerResult(hasError: false);
  bool isLoading = false;
  TextEditingController _search = TextEditingController();
  TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  String? hintmessage;
  bool show = false;
  Files files = new Files();
  Color recordingBackGround = Get.theme.secondaryHeaderColor;
  double iconsize = 24;
  Color iconColor = Colors.white;
  List<a.Comments> sarchTodoComments = [];

  @override
  void initState() {
    files.fileInput = <FileInput>[];
    SchedulerBinding.instance.addPostFrameCallback((_) {
      hintmessage = AppLocalizations.of(context)!.createNewComment;

      int index = _controllerTodo.commnets.value!.result!.indexOf(
          _controllerTodo.commnets.value!.result!.firstWhere(
              (e) => e.id == widget.openCommentId,
            //!  orElse: () {}
              ));

      index == -1
          ? index = _controllerTodo.commnets.value!.result!.indexOf(
              _controllerTodo.commnets.value!.result!.firstWhere((e) => e
                  .relatedCommentList!
                  .any((element) => element.id == widget.openCommentId)))
          : index = -1;
      if (index == -1) {
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoCommentsDetail(
              index: index,
              title: widget.header! +
                  " - " +
                  _controllerTodo.commnets.value!.result![index].comment!,
            ),
          ));
        });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  sendComments(
    String Comment,
    String AudioFile,
    Files files,
  ) async {
    await _controllerTodo.InsertTodoComment(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        TodoId: widget.todoId,
        Comment: Comment,
        AudioFile: AudioFile,
        files: files,
        isCombine: true,
        CombineFileName: "sample.pdf");
  }

  Widget micIcon(double size, Color Color) {
    return Icon(Icons.mic, size: size, color: Color);
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return GetBuilder<ControllerTodo>(
        builder: (_) => Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                Container(
                  width: Get.width,
                  height: Get.height,
                  child: Column(children: [
                    Expanded(
                      child: Container(
                        width: Get.width,
                        color: Get.theme.secondaryHeaderColor,
                        child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F7F7),
                          ),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Container(
                                          height: 45,
                                          margin: EdgeInsets.only(top: 15),
                                          decoration: BoxDecoration(
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(45)),
                                          child: CustomTextField(
                                            controller: _search,
                                            prefixIcon: Icon(Icons.search),
                                            hint: AppLocalizations.of(context)!
                                                .search,
                                            onChanged: (changed) {
                                              setState(() {
                                                sarchTodoComments.clear();
                                              });

                                              for (int i = 0;
                                                  i <
                                                      _controllerTodo.commnets
                                                          .value!.result!.length;
                                                  i++) {
                                                if (_controllerTodo.commnets
                                                    .value!.result![i].comment!
                                                    .toLowerCase()
                                                    .contains(changed
                                                        .toString()
                                                        .camelCase!)) {
                                                  sarchTodoComments.add(
                                                      _controllerTodo.commnets
                                                          .value!.result![i]);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Visibility(
                                  visible: !_search.text.isBlank!,
                                  child: ListView.builder(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: sarchTodoComments.length,
                                      itemBuilder: (ctx, i) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TodoCommentsDetail(
                                                    index: _controllerTodo
                                                        .commnets.value!.result!
                                                        .indexWhere((element) =>
                                                            element.comment ==
                                                            sarchTodoComments[i]
                                                                .comment),
                                                    title: widget.header! +
                                                        " - " +
                                                        _controllerTodo.commnets
                                                            .value!.result!
                                                            .firstWhere((element) =>
                                                                element
                                                                    .comment ==
                                                                sarchTodoComments[
                                                                        i]
                                                                    .comment)
                                                            .comment!,
                                                  ),
                                                ));
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                              boxShadow:
                                                                  standartCardShadow(),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            child:
                                                                Image.network(
                                                              sarchTodoComments[
                                                                      i]
                                                                  .userPhoto!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          8.0),
                                                                  child: Text(
                                                                    sarchTodoComments[
                                                                            i]
                                                                        .userName!,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Avenir-Book',
                                                                        fontSize:
                                                                            17.0,
                                                                        letterSpacing:
                                                                            -0.41000000190734864,
                                                                        height:
                                                                            1.29,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              8.0),
                                                                  child: Text(DateFormat.yMMMd(
                                                                          AppLocalizations.of(context)!
                                                                              .date)
                                                                      .format(DateTime.parse(
                                                                          sarchTodoComments[i]
                                                                              .createDate!))),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            15.0),
                                                                    child: Text(
                                                                      sarchTodoComments[i]
                                                                              .comment ??
                                                                          ".....",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Avenir-Book',
                                                                          fontSize:
                                                                              17.0,
                                                                          letterSpacing:
                                                                              -0.41000000190734864,
                                                                          height:
                                                                              1.29,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight:
                                                                              FontWeight.w300),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                                Visibility(
                                  visible: _search.text.isBlank!,
                                  child: ListView.builder(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _controllerTodo
                                          .commnets.value!.result!.length,
                                      itemBuilder: (ctx, i) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TodoCommentsDetail(
                                                    index: i,
                                                    title: widget.header! +
                                                        " - " +
                                                        _controllerTodo
                                                            .commnets
                                                            .value!
                                                            .result![i]
                                                            .comment!,
                                                  ),
                                                ));
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                              boxShadow:
                                                                  standartCardShadow(),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            child:
                                                                Image.network(
                                                              _controllerTodo
                                                                  .commnets
                                                                  .value!
                                                                  .result![i]
                                                                  .userPhoto!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          8.0),
                                                                  child: Text(
                                                                    _controllerTodo
                                                                        .commnets
                                                                        .value!
                                                                        .result![
                                                                            i]
                                                                        .userName!,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Avenir-Book',
                                                                        fontSize:
                                                                            17.0,
                                                                        letterSpacing:
                                                                            -0.41000000190734864,
                                                                        height:
                                                                            1.29,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              8.0),
                                                                  child: Text(DateFormat.yMMMd(
                                                                          AppLocalizations.of(context)!
                                                                              .date)
                                                                      .format(DateTime.parse(_controllerTodo
                                                                          .commnets
                                                                          .value!
                                                                          .result![
                                                                              i]
                                                                          .createDate!))),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            15.0),
                                                                    child: Text(
                                                                      _controllerTodo
                                                                              .commnets
                                                                              .value!
                                                                                .result![i]
                                                                              .comment ??
                                                                          ".....",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Avenir-Book',
                                                                          fontSize:
                                                                              17.0,
                                                                          letterSpacing:
                                                                              -0.41000000190734864,
                                                                          height:
                                                                              1.29,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight:
                                                                              FontWeight.w300),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                                SizedBox(
                                  height: 100,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Positioned(
                  bottom: 100,
                  right: 5,
                  child: FloatingActionButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    heroTag: "TodoComments",
                    onPressed: () {
                      confirmDeleteWidget(context);
                    },
                    backgroundColor: Get.theme.primaryColor,
                    child: ImageIcon(
                      AssetImage('assets/images/icon/comment.png'),
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            )));
  }

  confirmDeleteWidget(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.createNewComment,
                ),
                content: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: 50,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      margin: EdgeInsets.only(
                        left: 2,
                        right: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextFormField(
                        onTap: () {
                          if (_controller.text.isBlank!) {
                            setState(() {
                              sendButton = false;
                            });
                          }
                          setState(() {});
                        },
                        controller: _controller,
                        focusNode: focusNode,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.multiline,
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintmessage,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(
                              show
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                            ),
                            onPressed: () {
                              if (!show) {
                                focusNode.unfocus();
                                focusNode.canRequestFocus = false;
                              }
                              setState(() {
                                show = !show;
                              });
                            },
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());

                                  showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (builder) => bottomSheet());
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () {
                                  print("camera");
                                  _onImageButtonPressed(ImageSource.camera,
                                      context: context);
                                },
                              ),
                            ],
                          ),
                          contentPadding: EdgeInsets.all(5),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (sendButton && !_controller.text.isBlank!) {
                            await sendComments(_controller.text, "", files);
                            _controllerTodo.GetTodoComments(
                              _controllerDB.headers(),
                              TodoId: widget.todoId,
                              UserId: _controllerDB.user.value!.result!.id,
                            );
                            print(files.fileInput!.length);
                            if (files.fileInput!.length != 0) {
                              files.fileInput!.clear();
                            }
                          }
                          _controller.clear();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 120,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(45)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.create,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.white),
                          )),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                        child: Container(
                          width: 120,
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(45)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.close,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.white),
                          )),
                        ),
                      ),
                    ],
                  ),
                ]);
          },
        );
      },
    );
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

  //                                   //
  Future<void> openFile() async {
    try {
      files.fileInput = <FileInput>[];

      files.fileInput!.clear();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: true);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        files.fileInput!.add(new FileInput(
            fileName: "sample.${result.files.first.path!.split(".").last}",
            directory: "",
            fileContent: fileContent));
      });
          FocusScope.of(context).requestFocus(new FocusNode());
    } catch (e) {}
  }

  void _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      files.fileInput = <FileInput>[];
      files.fileInput!.clear();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpeg', 'jpg', 'png'],
          allowMultiple: true);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        files.fileInput!.add(new FileInput(
            fileName: "sample.${result.files.first.path!.split(".").last}",
            directory: "",
            fileContent: fileContent));
      });
          // await PostChatMessageSave(widget.Id, "deneme.jpg", base64Image, 0, 5);
      FocusScope.of(context).requestFocus(new FocusNode());
      print('aaa');
    } catch (e) {}
  }

  void _imgFromCamera() async {
    Get.to(() => CameraPage())?.then((value) async {
      files.fileInput = <FileInput>[];

      files.fileInput!.clear();

      if (value != null) {
        List<int> fileBytes = <int>[];
        value.forEach((file) {
          fileBytes = new File(file.path!).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          files.fileInput!.add(new FileInput(
              fileName: "sample.${file.path.split(".").last}",
              directory: "",
              fileContent: fileContent));
        });
      }
    });
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
      });
          FocusScope.of(context).requestFocus(new FocusNode());
    } catch (e) {}
  }

  // Icon

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
}
