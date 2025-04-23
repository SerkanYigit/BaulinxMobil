import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerMessage.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/model/Common/GetInviteUserListResult.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Message/FileInputMessage.dart';
import 'package:undede/model/Message/GetMessageByUserIdResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import '../../Controller/ControllerUser.dart';
import '../../Custom/CustomLoadingCircle.dart';
import '../../WidgetsV2/Helper.dart';
import '../../model/Common/CommonGroup.dart';
import '../../model/Common/MessageCategoryResult.dart';
import '../../widgets/CustomSearchDropdownMenu.dart';

class NewMessage extends StatefulWidget {
  final EmailDetailResponse? messageList;
  final int? type;
  final bool isReply;
  final String? selectedMail;

  const NewMessage(
      {Key? key,
      this.messageList,
      this.type,
      this.isReply = false,
      this.selectedMail})
      : super(key: key);

  NewMessageState createState() => NewMessageState();
}

class NewMessageState extends State<NewMessage> {
  bool isLoading = true;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCommon _controllerCommon = ControllerCommon();
  ControllerUser _controllerUser = Get.put(ControllerUser());
  ControllerMessage _controllerMessage = Get.put(ControllerMessage());
  GetInviteUserListResult _getInviteUserListResult =
      GetInviteUserListResult(hasError: false);
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List<String> suggestions = [];
  List<String> suggestionsImages = [];
  FocusNode _subjectFocusNode = FocusNode();
  List<String> _ccList = [];
  List<String> _bccList = [];
  List<String> _toList = [];

  String currentText = "";
  TextEditingController _fromController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _textcontroller = TextEditingController();
  HtmlEditorController _replyTextcontroller = HtmlEditorController();
  TextEditingController _comingMail = TextEditingController();

  TextEditingController _toController = TextEditingController();
  TextEditingController _ccController = TextEditingController();
  TextEditingController _bccController = TextEditingController();

  int mainMessageId = 0;
  List<String> recipientUserList = [];
  FileInputMessage _fileInputMessage = FileInputMessage();
  Files files = new Files();
  List<int> fileBytesforpdf = <int>[];
  String defaultPhoto =
      'https://onlinefiles.dsplc.net//Content/UploadPhoto/User/UserDefault.png';
  String initialText = '';
  //list project
  List<CommonGroup> _commonGroup = <CommonGroup>[];
  int? selectedCommonGroupId;
  int? selectedCommonGroupIdForMove;
  int? selectedMessageCategoryId;
  List<ResultItemMessage> _resultItemMessage = <ResultItemMessage>[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getSuggestion();
      await textEditingFill();
      await getSavedSignature();
      files.fileInput = <FileInput>[];
      await getListCommonGrups(); //for project
      _toController.addListener(_onTextFieldChangedTo);
      _ccController.addListener(_onTextFieldChanged);
      _bccController.addListener(_onTextFieldChangedBcc);

      //getMessageCategory();
      setState(() {
        isLoading = false;
      });

      //getMessageCategory();
    });

    super.initState();
  }

  void _onTextFieldChanged() {
    String currentText = _ccController.text;

    // Detect if the user has typed a comma
    if (currentText.contains(',')) {
      // Extract text before the comma
      String cc = currentText.replaceAll(',', '').trim();

      // Add the text to the list if it's not empty
      if (cc.isNotEmpty) {
        setState(() {
          _ccList.add(cc);
        });
      }

      // Clear the input field
      _ccController.clear();
    }
  }

  void _onTextFieldChangedBcc() {
    String currentText = _bccController.text;

    // Detect if the user has typed a comma
    if (currentText.contains(',')) {
      // Extract text before the comma
      String bcc = currentText.replaceAll(',', '').trim();

      // Add the text to the list if it's not empty
      if (bcc.isNotEmpty) {
        setState(() {
          _bccList.add(bcc);
        });
      }

      // Clear the input field
      _bccController.clear();
    }
  }

  void _onTextFieldChangedTo() {
    String currentText = _toController.text;

    // Detect if the user has typed a comma
    if (currentText.contains(',')) {
      // Extract text before the comma
      String to = currentText.replaceAll(',', '').trim();

      // Add the text to the list if it's not empty
      if (to.isNotEmpty) {
        setState(() {
          recipientUserList.add(to);
        });
      }

      // Clear the input field
      _toController.clear();
    }
  }

  //! void kaaldirildi
  getSavedSignature() async {
    if (widget.type == 0) {
      print('Saving signature');

      // Fetch the signature
      var value = await _controllerUser.GetSavedSignature(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
      );

      print('Signature: ${value.result!.signatureContent}');
      initialText = '\n\n\n\n${value.result!.signatureContent}';
    }
  }

  //! void kaaldirildi
  getListCommonGrups() async {
    await _controllerCommon.GetListCommonGroup(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id!,
    ).then((value) async {
      print("res GetGroupByIdddd = " + jsonEncode(value.listOfCommonGroup));
      // common gruplar çekildikten sonra önyüze yansıtır
      _commonGroup = value.listOfCommonGroup!;
      selectedCommonGroupId = _commonGroup.first.id;
      selectedCommonGroupIdForMove = _commonGroup.first.id;
    }).catchError((e) {
      print("res GetGroupById error " + e.toString());
    });
  }

  void getMessageCategory() async {
    await _controllerMessage.GetMessageCategory(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            LanguageId: AppLocalizations.of(context)!.date)
        .then((value) {
      _resultItemMessage = value.result!;
      print('res GetMessageCategory' + _resultItemMessage.toString());
      selectedMessageCategoryId = _resultItemMessage.first.id;
    }).catchError((e) {
      print("res GetMessageCategory error " + e.toString());
    });
  }

  textEditingFill() async {
    if (widget.type == 2) {
      _fromController =
          TextEditingController(text: widget.messageList!.result!.from!.name!);
      _subjectController =
          TextEditingController(text: widget.messageList!.result!.subject!);
      _textcontroller =
          TextEditingController(text: widget.messageList!.result!.body!);
      _replyTextcontroller.setText('asdasadsadsadsadsadsads' ?? '');
      setState(() {
        initialText = widget.messageList!.result!.body!;
      });

      print('******-*-*-*-*-*-');
      recipientUserList.add(widget.messageList!.result!.from!.email!);
      if (widget.messageList!.result!.to!.isNotEmpty)
        recipientUserList
            .addAll(widget.messageList!.result!.to!.map((e) => e.email!));
      mainMessageId = widget.messageList!.result!.id!;
    }
    if (widget.type == 1) {
      _subjectController =
          TextEditingController(text: widget.messageList!.result!.subject!);
      _textcontroller =
          TextEditingController(text: widget.messageList!.result!.body!);
    }
  }

  getSuggestion() async {
    await _controllerCommon.GetInviteUserList(_controllerDB.headers())
        .then((value) {
      _getInviteUserListResult = value;
      suggestions = List.generate(_getInviteUserListResult.result!.length - 1,
          (index) => _getInviteUserListResult.result![index + 1].name!);
      suggestionsImages = List.generate(
          _getInviteUserListResult.result!.length - 1,
          (index) => _getInviteUserListResult.result![index + 1].photo!);
    });

    //_getInviteUserListResult.result.firstWhere((element) => element.name==_fromController.text).id;
  }

  //! void kaaldirildi
  sentMessage(String MessageSubject, String MessageText, int MainMessageId,
      List<int> RecipientUserList, Files FileInputList) async {
    bool isCombine;
    if (files.fileInput!.length > 1) {
      bool? result = await showModalYesOrNo(
          context,
          AppLocalizations.of(context)!.fileUpload,
          AppLocalizations.of(context)!.doyouwanttocombinefiles);
      isCombine = result!;
    }

    String message = await _replyTextcontroller.getText();

    await _controllerMessage.SendMessageNew(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id,
      from: widget.isReply
          ? widget.selectedMail
          : _controllerDB.user.value!.result!
              .mailAddress, // Assuming this is the sender's email
      selectedCustomerId: -1, // Defaulting to -1
      selectedCustomerAdminId: -1, // Defaulting to -1
      recipientUserList:
          recipientUserList, // Assuming you map the user IDs to emails
      cc: _ccList, // Assuming this is the CC field
      bcc: _bccList, // Assuming this is the BCC field
      subject: MessageSubject,
      message: message,
      options: {}, // Empty options as in the provided body
    ).then((value) async {
      if (value == true) {
        // Fetch all messages by user
        await _controllerMessage.GetMessageByUserIdAll(
          _controllerDB.headers(),
          UserId: _controllerDB.user.value!.result!.id!,
          Page: 0,
          Size: 999,
          Type: 0,
        );

        // Fetch sent messages by user
        await _controllerMessage.GetMessageByUserIdSent(
          _controllerDB.headers(),
          UserId: _controllerDB.user.value!.result!.id!,
          Page: 0,
          Size: 999,
          Type: 2,
        );

        // Update the controller to reflect changes
        _controllerMessage.update();
      }
    });

    // await _controllerMessage.SendMessage(_controllerDB.headers(),
    //         UserId: _controllerDB.user.value.result.id,
    //         MessageSubject: MessageSubject,
    //         MessageText: MessageText,
    //         MainMessageId: MainMessageId,
    //         RecipientUserList: RecipientUserList,
    //         IsCombine: isCombine,
    //         FileInputList: FileInputList,
    //         CommonGroupId: selectedCommonGroupId,
    //         MessageCategoryId: selectedMessageCategoryId)
    //     .then((value) async {
    //   if (value) {
    //     _controllerMessage.GetMessageByUserIdAll(_controllerDB.headers(),
    //         UserId: _controllerDB.user.value.result.id,
    //         Page: 0,
    //         Size: 999,
    //         Type: 0);
    //     _controllerMessage.GetMessageByUserIdSent(_controllerDB.headers(),
    //         UserId: _controllerDB.user.value.result.id,
    //         Page: 0,
    //         Size: 999,
    //         Type: 2);
    //     _controllerMessage.update();
    //   }
    // });
  }

  bool isPhotoActive(String link) {
    if (link.endsWith(".jpg") ||
        link.endsWith(".jpeg") ||
        link.endsWith(".png")) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        body: !isLoading
            ? SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                      width: Get.width,
                      height: Get.height,
                      child: Column(
                        children: [
                          Container(
                            width: Get.width,
                            height: 100,
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                            ),
                            decoration: BoxDecoration(
                                color: Get.theme.scaffoldBackgroundColor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: ImageIcon(
                                    AssetImage(
                                        'assets/images/icon/arrowleft.png'),
                                    size: 20,
                                  ),
                                  color: Colors.black,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  iconSize: 20,
                                ),
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      _controllerDB.user.value!.result!.photo!),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.type == 0
                                            ? AppLocalizations.of(context)!
                                                .newPost
                                            : widget.type == 1
                                                ? AppLocalizations.of(context)!
                                                    .forward
                                                : AppLocalizations.of(context)!
                                                    .reply,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                      Text(
                                        _controllerDB
                                            .user.value!.result!.mailAddress!,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
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
                                    color: HexColor('#f4f5f7'),
                                  ),
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                      child: InkWell(
                                        onTap: () {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        },
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10),
                                            // widget.type == 0
                                            //     ? SizedBox()
                                            //     : CustomSearchDropDownMenu(
                                            //         labelHeader: _resultItemMessage
                                            //             .firstWhere((element) =>
                                            //                 element.id ==
                                            //                 selectedMessageCategoryId)
                                            //             .text,
                                            //         list: _resultItemMessage
                                            //             .map((element) =>
                                            //                 element.text)
                                            //             .toList(),
                                            //         onChanged: (newValue) {
                                            //           ResultItemMessage
                                            //               resultItemMessage =
                                            //               _resultItemMessage
                                            //                   .firstWhere(
                                            //                       (element) =>
                                            //                           element
                                            //                               .text ==
                                            //                           newValue);
                                            //           setState(() {
                                            //             selectedMessageCategoryId =
                                            //                 resultItemMessage
                                            //                     .id;
                                            //             // Add your custom logic here
                                            //           });
                                            //         },
                                            //         error: 'Error',
                                            //         labelIcon: Icons.info,
                                            //         labelIconExist: true,
                                            //         fillColor: Get.theme
                                            //             .scaffoldBackgroundColor,
                                            //       ),
                                            SizedBox(height: 10),
                                            TextField(
                                              enabled: false,
                                              controller: _comingMail,
                                              decoration: new InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(left: 7),
                                                  hintText: widget.selectedMail,
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            // TypeAheadField(
                                            //   hideSuggestionsOnKeyboardHide:
                                            //       true,
                                            //   hideOnEmpty: true,
                                            //   getImmediateSuggestions: false,
                                            //   onSuggestionSelected:
                                            //       (suggestion) {
                                            //     _fromController
                                            //         .clear(); // Clear the input field after selection
                                            //     if (!recipientUserList
                                            //         .contains(suggestion)) {
                                            //       recipientUserList.add(
                                            //         _getInviteUserListResult
                                            //             .result
                                            //             .firstWhere((element) =>
                                            //                 element.name ==
                                            //                 suggestion)
                                            //             .name,
                                            //       );
                                            //     }
                                            //     setState(() {});
                                            //     print(_getInviteUserListResult
                                            //         .result
                                            //         .firstWhere((element) =>
                                            //             element.name ==
                                            //             suggestion)
                                            //         .userId);
                                            //   },
                                            //   suggestionsCallback:
                                            //       (pattern) async {
                                            //     return suggestions
                                            //         .where((item) => item
                                            //             .toLowerCase()
                                            //             .startsWith(pattern
                                            //                 .toLowerCase()))
                                            //         .toList();
                                            //   },
                                            //   itemBuilder:
                                            //       (context, suggestion) =>
                                            //           Padding(
                                            //     padding: EdgeInsets.all(8.0),
                                            //     child: ListTile(
                                            //       leading: CircleAvatar(
                                            //         backgroundColor:
                                            //             Colors.transparent,
                                            //         backgroundImage:
                                            //             NetworkImage(
                                            //           isPhotoActive(
                                            //                   suggestionsImages[
                                            //                       suggestions
                                            //                           .indexOf(
                                            //                               suggestion)])
                                            //               ? suggestionsImages[
                                            //                   suggestions.indexOf(
                                            //                       suggestion)]
                                            //               : defaultPhoto,
                                            //         ),
                                            //       ),
                                            //       title: Text(suggestion),
                                            //     ),
                                            //   ),
                                            //   key: key,
                                            //   textFieldConfiguration:
                                            //       TextFieldConfiguration(
                                            //     decoration: InputDecoration(
                                            //       prefixIcon: Padding(
                                            //         padding:
                                            //             const EdgeInsets.only(
                                            //                 top: 12, left: 7),
                                            //         child:
                                            //             SingleChildScrollView(
                                            //           scrollDirection:
                                            //               Axis.horizontal,
                                            //           child: Row(
                                            //             children: [
                                            //               Text(
                                            //                 AppLocalizations.of(
                                            //                         context)
                                            //                     .to, // Replace with AppLocalizations if necessary
                                            //                 style: TextStyle(
                                            //                     fontSize: 16,
                                            //                     fontWeight:
                                            //                         FontWeight
                                            //                             .bold),
                                            //               ),
                                            //               recipientUserList
                                            //                           .length >
                                            //                       0
                                            //                   ? Wrap(
                                            //                       spacing: 8.0,
                                            //                       children:
                                            //                           recipientUserList
                                            //                               .map(
                                            //                                   (userId) {
                                            //                         print(
                                            //                             'userId: $userId');
                                            //                         return Chip(
                                            //                           label: Text(
                                            //                               userId),
                                            //                           onDeleted:
                                            //                               () {
                                            //                             setState(
                                            //                                 () {
                                            //                               recipientUserList
                                            //                                   .remove(userId);
                                            //                             });
                                            //                           },
                                            //                         );
                                            //                       }).toList(),
                                            //                     )
                                            //                   : SizedBox(),
                                            //             ],
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       suffixIcon: IconButton(
                                            //         icon:
                                            //             Icon(Icons.expand_more),
                                            //         color: Colors.black54,
                                            //         onPressed: () {},
                                            //       ),
                                            //     ),
                                            //     controller: _fromController,
                                            //   ),
                                            // ),
                                            _ccAndBccWidget(_toController, 'To',
                                                recipientUserList),
                                            SizedBox(height: 10),
                                            _ccAndBccWidget(
                                                _ccController, 'CC', _ccList),
                                            _ccAndBccWidget(_bccController,
                                                'BCC', _bccList),
                                            TextField(
                                              focusNode: _subjectFocusNode,
                                              controller: _subjectController,
                                              decoration: new InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(left: 7),
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .subject,
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            files.fileInput!.isBlank!
                                                ? Container()
                                                : Container(
                                                    height: 150,
                                                    width: Get.width,
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    child: ListView.builder(
                                                        itemCount: files
                                                            .fileInput!.length,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, i) {
                                                          print(p.extension(
                                                              files
                                                                  .fileInput![i]
                                                                  .fileName!));

                                                          return Stack(
                                                            children: [
                                                              MessageBox(i),
                                                              Positioned(
                                                                top: 10,
                                                                right: 10,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    files
                                                                        .fileInput
                                                                        ?.removeAt(
                                                                            i);
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Get
                                                                          .theme
                                                                          .primaryColor,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .clear,
                                                                        color: Colors
                                                                            .black,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          );
                                                        }),
                                                  ),
                                            SizedBox(height: 10),
                                            Expanded(
                                              child: Listener(
                                                onPointerDown: (_) {
                                                  print(
                                                      'HtmlEditor tapped via Listener!');
                                                  // Perform your action on tap (e.g., removing focus)
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                                child: HtmlEditor(
                                                  controller:
                                                      _replyTextcontroller,
                                                  htmlToolbarOptions:
                                                      HtmlToolbarOptions(
                                                    toolbarPosition:
                                                        ToolbarPosition
                                                            .aboveEditor,
                                                    defaultToolbarButtons: [
                                                      FontButtons(),
                                                      ColorButtons(),
                                                      ListButtons(),
                                                      ParagraphButtons(),
                                                    ],
                                                  ),
                                                  htmlEditorOptions:
                                                      HtmlEditorOptions(
                                                    hint:
                                                        'Enter your message here...',
                                                    autoAdjustHeight: true,
                                                    initialText: initialText,
                                                  ),
                                                  otherOptions: OtherOptions(
                                                    height: Get.height *
                                                        0.6, // Adjust height for better visibility
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: Get.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    _customIconButtonWithBackground(
                                        'assets/images/icon/attach.png',
                                        Colors.black54, () {
                                      openFile();
                                    }),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    _customIconButtonWithBackground(
                                        'assets/images/icon/camera.png',
                                        Colors.black54, () {
                                      //!   _imgFromCamera();
                                    }),
                                  ],
                                ),
                                IconButton(
                                  icon: ImageIcon(
                                    AssetImage('assets/images/icon/send.png'),
                                  ),
                                  color: Colors.black,
                                  onPressed: () async {
                                    printMessageSubject();
                                    await sentMessage(
                                        _subjectController.text,
                                        _textcontroller.text,
                                        mainMessageId,
                                        [0, 1],
                                        files);
                                    if (widget.type == 0)
                                      Navigator.pop(context);
                                    else
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                  },
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Get.height * 0.1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : CustomLoadingCircle());
  }

  Row _ccAndBccWidget(
      TextEditingController controller, String hintText, List<String> list) {
    return Row(
      children: [
        Expanded(
          flex: 1, // Flexibility ratio for TextField section
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 7),
              hintText: hintText,
              hintStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          flex: list.isNotEmpty ? 2 : 0, // Flexibility ratio for chips section
          child: Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: list.map((cc) {
              return Chip(
                label: Text(cc),
                onDeleted: () {
                  setState(() {
                    list.remove(cc); // Remove chip when user deletes it
                  });
                },
              );
            }).toList(),
          ),
        ),
        // Space between chips and TextField
        // TextField for input
      ],
    );
  }

  Future<void> printMessageSubject() async {
    String messageSubject = await _replyTextcontroller.getText();
    print('MessageSubject: $messageSubject');
  }

  Padding _customIconButtonWithBackground(
      String iconPath, Color color, Function onPressed) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: 40,
        height: 38,
        child: IconButton(
          icon: ImageIcon(
            AssetImage(iconPath),
          ),
          color: color,
          onPressed: onPressed(),
        ),
      ),
    );
  }

  Container MessageBox(int i) {
    String extension = p.extension(files.fileInput![i].fileName!);
    switch (extension) {
      case '.pdf':
        return Container(
          width: 100,
          height: 150,
          margin: EdgeInsets.only(right: 5),
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/file_types/pdf.png"))),
          ),
        );
        break;
      case '.jpg':
        return Container(
          width: 100,
          height: 150,
          margin: EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: MemoryImage(
                      base64Decode(files.fileInput![i].fileContent!)))),
        );
        break;
      case '.jpeg':
        return Container(
          width: 100,
          height: 150,
          margin: EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: MemoryImage(
                      base64Decode(files.fileInput![i].fileContent!)))),
        );
        break;
      case '.png':
        return Container(
          width: 100,
          height: 150,
          margin: EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: MemoryImage(
                      base64Decode(files.fileInput![i].fileContent!)))),
        );
        break;
      default:
        return Container(
          width: 100,
          height: 150,
          margin: EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(getImagePathByFileExtensionWithDot(
                      p.extension(files.fileInput![i].fileName!))))),
        );
    }
  }

  void _imgFromCamera() async {
    Get.to(() => CameraPage())?.then((value) async {
      if (value != null) {
        List<int> fileBytes = <int>[];
        value.forEach((file) {
          fileBytes = new File(file.path).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          files.fileInput!.add(new FileInput(
              fileName: 'sample.${file.path.split(".").last}',
              directory: "",
              fileContent: fileContent));
        });
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> openFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        files.fileInput!.add(new FileInput(
            fileName: 'sample.${file.path!.split(".").last}',
            directory: "Message",
            fileContent: fileContent));
      });
      setState(() {});

      print('aaa');
    } catch (e) {}
  }
}
