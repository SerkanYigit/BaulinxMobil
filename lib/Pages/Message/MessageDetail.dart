import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerMessage.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/openFileFormessage.dart';
import 'package:undede/Custom/removeAllHtmlTags.dart';
import 'package:undede/Pages/Message/Components/ShowBase64Modal.dart';
import 'package:undede/Pages/Message/NewMessage.dart';
import 'package:undede/model/Message/GetMessageByUserIdResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Controller/ControllerCommon.dart';
import '../../Custom/CustomLoadingCircle.dart';

class MessageDetail extends StatefulWidget {
  final EmailResult? messageList;
  final int? differentPage;
  final String? mail;
  final String? folder;
  final int? id;
  final String selectedMail;
  const MessageDetail({
    Key? key,
    this.messageList,
    this.differentPage,
    this.mail,
    this.folder,
    this.id,
    this.selectedMail = '',
  }) : super(key: key);
  @override
  MessageDetailState createState() => MessageDetailState();
}

class MessageDetailState extends State<MessageDetail> {
  bool isLoading = false;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerMessage _controllerMessage = Get.put(ControllerMessage());
  bool isShow = false;
  int? messageId;
  bool openNewPage = false;
  ControllerCommon _controllerCommon = ControllerCommon();
  String? selectedCategoryName;
  String? selectedCommonGroupName;
  EmailDetailResponse? emailResponse;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      findListCommonGrups();
      findMessageCategory();
      await getMailDetail();
    });
    super.initState();
  }

  //! void kaldirildi
  getMailDetail() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch emails from the server
      EmailDetailResponse emailResponsee =
          await _controllerMessage.GetMailDetail(
        _controllerDB.headers(),
        UserEmail: widget.mail,
        folderName: widget.folder,
        id: widget.id,
      );
      setState(() {
        emailResponse = emailResponsee;
      });
      print(
          'emailResponse: ${emailResponse!.result!.attachments!.first.fileName.toString()}');
      // Check if there are no more emails to load
    } catch (e) {
      // Handle any errors if needed
      print('Error fetching emails: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void findListCommonGrups() async {
    await _controllerCommon.GetListCommonGroup(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id,
    ).then((value) async {
      print("res GetGroupByIdddd = " + jsonEncode(value.listOfCommonGroup));
      // common gruplar çekildikten sonra önyüze yansıtır
      setState(() {
        selectedCommonGroupName = value.listOfCommonGroup!
            .firstWhere((element) => element.id == widget.messageList!.id)
            .groupName;

        print("selectedCommonGroupName = " + selectedCommonGroupName!);
      });
    }).catchError((e) {});
  }

  void findMessageCategory() async {
    await _controllerMessage.GetMessageCategory(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, LanguageId: "EN")
        .then((value) {
      setState(() {
        selectedCategoryName = value.result!
            .firstWhere((element) => element.id == widget.messageList!
                //! buraya .id gerekebilir
                )
            .text;
        print("selectedCommon = " + selectedCategoryName!);
      });
    }).catchError((e) {
      print("res GetMessageCategory error " + e.toString());
    });
  }

  deleteMessage(int MessageId) {
    _controllerMessage.DeleteMessage(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, MessageId: MessageId)
        .then((value) {
      if (value) {
        _controllerMessage.GetMessageByUserIdAll(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            Page: 0,
            Size: 999,
            Type: 0);
        _controllerMessage.GetMessageByUserIdSent(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            Page: 0,
            Size: 999,
            Type: 2);
        _controllerMessage.GetMessageByUserIdReceived(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            Page: 0,
            Size: 999,
            Type: 0);
        _controllerMessage.GetMessageByUserIdDeleted(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            Page: 0,
            Size: 999,
            Type: 2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GetBuilder<ControllerMessage>(
        builder: (_) => Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            body: !isLoading
                ? ModalProgressHUD(
                    child: Container(
                      width: Get.width,
                      height: Get.height * 0.85,
                      child: Column(
                        children: [
                          Container(
                            width: Get.width,
                            height: 80,
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                            ),
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Image.asset(
                                      'assets/images/icon/close.png',
                                      width: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: InkWell(
                                      onTap: () async {
                                        await deleteMessage(
                                            widget.messageList!.id!);
                                        Fluttertoast.showToast(
                                            msg: AppLocalizations.of(context)!
                                                .deleted,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            //backgroundColor: Colors.red,
                                            //textColor: Colors.white,
                                            fontSize: 16.0);
                                        Navigator.pop(context);
                                      },
                                      child: Image.asset(
                                          'assets/images/icon/delete.png',
                                          width: 25,
                                          color: Colors.black)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: Image.asset(
                                      'assets/images/icon/archive.png',
                                      width: 22,
                                      color: Colors.black),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: widget.differentPage != null
                                      ? _popUpForReply()
                                      : _popUpForReplyConditionTwo(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: width,
                                        height: 50,
                                        color: Color(0xFFe0eded),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: width * 0.8,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: Text(
                                                widget.messageList!.subject!,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          setState(() {
                                            isShow = !isShow;
                                            messageId = widget.messageList!.id;
                                          });
                                        },
                                        // leading: CircleAvatar(
                                        //   backgroundImage: NetworkImage(widget
                                        //           .messageList
                                        //           . ??
                                        //       ""),
                                        //   child: Container(),
                                        // ),
                                        title: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 15),
                                            width: width,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.messageList!.from!
                                                              .name ??
                                                          '',
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                        context)!
                                                                    .to +
                                                                ' ' +
                                                                widget
                                                                    .messageList!
                                                                    .from!
                                                                    .email!,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF7f7f7f),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  DateFormat.yMMMd().format(DateTime.now()) ==
                                                          DateFormat.yMMMd().format(
                                                              DateTime.parse(widget
                                                                  .messageList!
                                                                  .date
                                                                  .toString()))
                                                      ? DateFormat.Hm(AppLocalizations.of(context)!.date)
                                                          .format(DateTime.parse(
                                                              widget.messageList!
                                                                      .date
                                                                      .toString() ??
                                                                  ''))
                                                      : DateFormat.MMMMd(AppLocalizations.of(context)!.date)
                                                          .format(DateTime.parse(widget.messageList!.date.toString() ?? '')),
                                                ),
                                              ],
                                            )),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            isShow = !isShow;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Visibility(
                                              visible: isShow &&
                                                  widget.messageList!.id ==
                                                      messageId,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 40,
                                                    vertical: 5),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .to),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        // Text(widget
                                                        //     .messageList
                                                        //     .toUserList[0]
                                                        //     .mailAddress),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(DateFormat.yMMMd(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .date)
                                                            .format(DateTime
                                                                .parse(widget
                                                                    .messageList!
                                                                    .date
                                                                    .toString()))),
                                                      ],
                                                    ),
                                                    Text(selectedCategoryName ??
                                                        ''),
                                                    Text(
                                                        selectedCommonGroupName ??
                                                            ''),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ListView.builder(
                                      //     physics:
                                      //         NeverScrollableScrollPhysics(),
                                      //     shrinkWrap: true,
                                      //     itemCount: widget.messageList
                                      //         .subMessageList.length,
                                      //     itemBuilder: (context, index) {
                                      //       return Container(
                                      //         width: Get.width,
                                      //         margin: EdgeInsets.symmetric(
                                      //             horizontal: 5),
                                      //         child: ListView.builder(
                                      //             itemCount: widget.messageList
                                      //                 .fileList.length,
                                      //             shrinkWrap: true,
                                      //             scrollDirection:
                                      //                 Axis.horizontal,
                                      //             itemBuilder:
                                      //                 (context, index) {
                                      //               Uri link = Uri.parse(widget
                                      //                   .messageList
                                      //                   .fileList[index]
                                      //                   .thumbnailPath);
                                      //               return Stack(
                                      //                 children: [
                                      //                   GestureDetector(
                                      //                     onTap: () async {
                                      //                       setState(() {
                                      //                         openNewPage =
                                      //                             true;
                                      //                       });
                                      //                       await openFileMessage(
                                      //                           widget
                                      //                               .messageList
                                      //                               .fileList[
                                      //                                   index]
                                      //                               .path);
                                      //                       setState(() {
                                      //                         openNewPage =
                                      //                             false;
                                      //                       });
                                      //                       print("basıldı");
                                      //                     },
                                      //                     child: Container(

                                      //                         width: 150,
                                      //                         height: 65,
                                      //                         margin: EdgeInsets
                                      //                             .only(
                                      //                                 left: 10),
                                      //                         child:
                                      //                             CachedNetworkImage(
                                      //                           imageUrl: widget
                                      //                                   .messageList
                                      //                                   .fileList[
                                      //                                       index]
                                      //                                   .thumbnailPath
                                      //                                   .isBlank
                                      //                               ? ExtensionImage(widget
                                      //                                   .messageList
                                      //                                   .fileList[
                                      //                                       index]
                                      //                                   .path)
                                      //                               : widget
                                      //                                   .messageList
                                      //                                   .fileList[
                                      //                                       index]
                                      //                                   .thumbnailPath
                                      //                                   .replaceAll(
                                      //                                       ' ',
                                      //                                       '%20'),
                                      //                           fit: BoxFit
                                      //                               .cover,
                                      //                           errorWidget: (context,
                                      //                                   url,
                                      //                                   error) =>
                                      //                               Icon(Icons
                                      //                                   .error),
                                      //                           placeholder: (context,
                                      //                                   url) =>
                                      //                               new MyCircular(),
                                      //                         )),
                                      //                   ),
                                      //                   Positioned(
                                      //                     bottom: 5,
                                      //                     right: 5,
                                      //                     child: Image.asset(
                                      //                       getImagePathByFileExtension(
                                      //                           widget
                                      //                               .messageList
                                      //                               .fileList[
                                      //                                   index]
                                      //                               .path
                                      //                               .split('.')
                                      //                               .last),
                                      //                       width: 15,
                                      //                     ),
                                      //                   ),
                                      //                 ],
                                      //               );
                                      //             }),
                                      //       );
                                      //     }),
                                      Divider(
                                        thickness: 1,
                                      ),
                                      emailResponse != null
                                          ? emailResponse!.result!.attachments!
                                                  .isNotEmpty
                                              ? _pdfAndImageViewer()
                                              : SizedBox()
                                          : SizedBox(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 15),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                removeAllHtmlTags(
                                                    widget.messageList!.body!),
                                                style: TextStyle(fontSize: 17),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.1,
                                      ),
                                    ],
                                  ),
                                  // ListView.builder(
                                  //     physics: NeverScrollableScrollPhysics(),
                                  //     shrinkWrap: true,
                                  //     itemCount: widget
                                  //         .messageList.subMessageList.length,
                                  //     itemBuilder: (context, index) {
                                  //       return Container(
                                  //         child: Column(
                                  //           children: [
                                  //             Container(
                                  //               color: Color(0xFFe0eded),
                                  //               height: 10,
                                  //             ),
                                  //             ListTile(
                                  //               onTap: () {
                                  //                 setState(() {
                                  //                   isShow = !isShow;
                                  //                   messageId = widget
                                  //                       .messageList
                                  //                       .subMessageList[index]
                                  //                       .id;
                                  //                 });
                                  //               },
                                  //               leading: CircleAvatar(
                                  //                   backgroundImage:
                                  //                       NetworkImage(widget
                                  //                           .messageList
                                  //                           .subMessageList[
                                  //                               index]
                                  //                           .fromUserPhotoPath),
                                  //                   child: SizedBox()),
                                  //               title: Container(
                                  //                   width: width,
                                  //                   child: Row(
                                  //                     mainAxisAlignment:
                                  //                         MainAxisAlignment
                                  //                             .spaceBetween,
                                  //                     crossAxisAlignment:
                                  //                         CrossAxisAlignment
                                  //                             .start,
                                  //                     children: [
                                  //                       Column(
                                  //                         mainAxisAlignment:
                                  //                             MainAxisAlignment
                                  //                                 .start,
                                  //                         crossAxisAlignment:
                                  //                             CrossAxisAlignment
                                  //                                 .start,
                                  //                         children: [
                                  //                           Text(
                                  //                             widget
                                  //                                 .messageList
                                  //                                 .subMessageList[
                                  //                                     index]
                                  //                                 .fromUserNameAndSurname,
                                  //                             maxLines: 2,
                                  //                             style: TextStyle(
                                  //                               fontSize: 16,
                                  //                             ),
                                  //                           ),
                                  //                           Text(
                                  //                             isShow &&
                                  //                                     messageId ==
                                  //                                         widget
                                  //                                             .messageList
                                  //                                             .subMessageList[
                                  //                                                 index]
                                  //                                             .id
                                  //                                 ? widget
                                  //                                     .messageList
                                  //                                     .subMessageList[
                                  //                                         index]
                                  //                                     .fromUserMail
                                  //                                 : (widget
                                  //                                         .messageList
                                  //                                         .subMessageList[
                                  //                                             index]
                                  //                                         .toUsers ??
                                  //                                     ""),
                                  //                             maxLines: 2,
                                  //                             style: TextStyle(
                                  //                               fontSize: 16,
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                       Text(DateFormat.yMMMd().format(DateTime.now()) ==
                                  //                               DateFormat.yMMMd().format(DateTime.parse(widget
                                  //                                   .messageList
                                  //                                   .subMessageList[
                                  //                                       index]
                                  //                                   .createDate))
                                  //                           ? DateFormat.Hm(AppLocalizations.of(context).date).format(DateTime.parse(widget
                                  //                               .messageList
                                  //                               .subMessageList[
                                  //                                   index]
                                  //                               .createDate))
                                  //                           : DateFormat.MMMMd(AppLocalizations.of(context).date)
                                  //                               .format(DateTime.parse(widget.messageList.subMessageList[index].createDate))),
                                  //                     ],
                                  //                   )),
                                  //               trailing: PopupMenuButton(
                                  //                   child: Icon(
                                  //                     Icons.more_vert,
                                  //                     color: Colors.black,
                                  //                     size: 27,
                                  //                   ),
                                  //                   itemBuilder: (context) => [
                                  //                         PopupMenuItem(
                                  //                           child: InkWell(
                                  //                             onTap: () {
                                  //                               print("burada");
                                  //                               Navigator.push(
                                  //                                   context,
                                  //                                   new MaterialPageRoute(
                                  //                                       builder: (BuildContext
                                  //                                               context) =>
                                  //                                           NewMessage(
                                  //                                             type: 2,
                                  //                                             messageList: widget.messageList,
                                  //                                           )));
                                  //                             },
                                  //                             child: Row(
                                  //                               children: [
                                  //                                 Icon(Icons
                                  //                                     .reply),
                                  //                                 SizedBox(
                                  //                                   width: 10,
                                  //                                 ),
                                  //                                 Text(AppLocalizations.of(
                                  //                                         context)
                                  //                                     .reply),
                                  //                               ],
                                  //                             ),
                                  //                           ),
                                  //                           value: 1,
                                  //                         ),
                                  //                         PopupMenuItem(
                                  //                           child: Row(
                                  //                             children: [
                                  //                               Icon(Icons
                                  //                                   .reply_all),
                                  //                               SizedBox(
                                  //                                 width: 10,
                                  //                               ),
                                  //                               Text(AppLocalizations.of(
                                  //                                       context)
                                  //                                   .replyAll),
                                  //                             ],
                                  //                           ),
                                  //                           value: 2,
                                  //                         ),
                                  //                         PopupMenuItem(
                                  //                           child: InkWell(
                                  //                             onTap: () {
                                  //                               Navigator.push(
                                  //                                   context,
                                  //                                   new MaterialPageRoute(
                                  //                                       builder: (BuildContext
                                  //                                               context) =>
                                  //                                           NewMessage(
                                  //                                             type: 1,
                                  //                                             messageList: widget.messageList,
                                  //                                           )));
                                  //                             },
                                  //                             child: Row(
                                  //                               children: [
                                  //                                 Icon(Icons
                                  //                                     .forward),
                                  //                                 SizedBox(
                                  //                                   width: 10,
                                  //                                 ),
                                  //                                 Text(AppLocalizations.of(
                                  //                                         context)
                                  //                                     .forward),
                                  //                               ],
                                  //                             ),
                                  //                           ),
                                  //                           value: 3,
                                  //                         )
                                  //                       ]),
                                  //             ),
                                  //             InkWell(
                                  //               onTap: () {
                                  //                 setState(() {
                                  //                   isShow = !isShow;
                                  //                 });
                                  //               },
                                  //               child: Row(
                                  //                 children: [
                                  //                   Visibility(
                                  //                     visible: isShow &&
                                  //                         widget
                                  //                                 .messageList
                                  //                                 .subMessageList[
                                  //                                     index]
                                  //                                 .id ==
                                  //                             messageId,
                                  //                     child: Container(
                                  //                       padding: EdgeInsets
                                  //                           .symmetric(
                                  //                               horizontal: 40,
                                  //                               vertical: 5),
                                  //                       child: Column(
                                  //                         children: [
                                  //                           Row(
                                  //                             children: [
                                  //                               Text(AppLocalizations.of(
                                  //                                       context)
                                  //                                   .to),
                                  //                               SizedBox(
                                  //                                 width: 20,
                                  //                               ),
                                  //                               Text(widget
                                  //                                       .messageList
                                  //                                       .subMessageList[
                                  //                                           index]
                                  //                                       .toUsers ??
                                  //                                   ""),
                                  //                             ],
                                  //                           ),
                                  //                           SizedBox(
                                  //                             height: 5,
                                  //                           ),
                                  //                           Padding(
                                  //                             padding:
                                  //                                 const EdgeInsets
                                  //                                         .only(
                                  //                                     left:
                                  //                                         25.0),
                                  //                             child: Text(DateFormat.yMMMd(
                                  //                                     AppLocalizations.of(
                                  //                                             context)
                                  //                                         .date)
                                  //                                 .format(DateTime.parse(widget
                                  //                                     .messageList
                                  //                                     .subMessageList[
                                  //                                         index]
                                  //                                     .createDate))),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //             Divider(),
                                  //             Container(
                                  //               padding: EdgeInsets.symmetric(
                                  //                   vertical: 15,
                                  //                   horizontal: 15),
                                  //               child: Row(
                                  //                 children: [
                                  //                   // Expanded(
                                  //                   //   child: Text(
                                  //                   //     removeAllHtmlTags(widget
                                  //                   //         .messageList
                                  //                   //         .body[
                                  //                   //             index]
                                  //                   //         .messageText),
                                  //                   //     style: TextStyle(
                                  //                   //         fontSize: 17),
                                  //                   //     textAlign:
                                  //                   //         TextAlign.justify,
                                  //                   //   ),
                                  //                   // ),
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //             SizedBox(
                                  //               height: widget
                                  //                           .messageList
                                  //                           .attachments
                                  //                           .length ==
                                  //                       0
                                  //                   ? 0
                                  //                   : 10,
                                  //             ),
                                  //             SizedBox(
                                  //               height: 10,
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       );
                                  //     }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    inAsyncCall: openNewPage,
                  )
                : CustomLoadingCircle()));
  }

  Container _pdfAndImageViewer() {
    return Container(
      height: Get.height * 0.05,
      width: Get.width,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: emailResponse!.result!.attachments!.isNotEmpty
          ? ListView.builder(
              itemCount: emailResponse!.result!.attachments!.length ??
                  0, // Check if attachments is null
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var attachment = emailResponse!.result!.attachments![index];

                print('Attachment data: ${attachment.data}');

                // Get the file extension
                String fileExtension =
                    attachment.fileName!.split('.').last.toLowerCase();

                bool isImage =
                    ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension);
                bool isPdf = fileExtension == 'pdf';

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Check if the file is an image or a PDF and open the appropriate modal
                        if (isPdf || isImage) {
                          String base64Data = attachment.data!;
                          showBase64Modal(
                              context, base64Data, isPdf ? 'pdf' : 'image');
                        } else {
                          print(
                              "Unsupported file type or no action for this file type.");
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: isPdf
                            ? buildPdfAttachmentWidget(attachment.fileName!)
                            : Container(
                                width: 60,
                                height: 65,
                                margin: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  // Show image or PDF icon
                                  image: isImage
                                      ? DecorationImage(
                                          image: MemoryImage(base64Decode(
                                              attachment.data!)), // For images
                                          fit: BoxFit.cover,
                                        )
                                      : null, // No image decoration for PDFs
                                ),
                              ),
                      ),
                    ),
                    // Positioned(
                    //   bottom: 5,
                    //   right: 5,
                    //   child: Image.asset(
                    //     getImagePathByFileExtension(
                    //         fileExtension), // Icon by file extension
                    //     width: 15,
                    //   ),
                    // ),
                  ],
                );
              },
            )
          : SizedBox(),
    );
  }

  Container buildPdfAttachmentWidget(String fileName) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 10, vertical: 5), // Adjust padding as needed
      constraints:
          BoxConstraints(maxWidth: 200), // Set max width to prevent overflow
      decoration: BoxDecoration(
        color: Colors.transparent, // Or any color you'd like for the background
        border: Border.all(
          color:
              Colors.lightBlueAccent, // Border color similar to the screenshot
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20), // Rounded border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Shrinks the Row to fit its content
        children: [
          Icon(
            Icons.attach_file, // Use the paperclip icon
            color: Colors.lightBlueAccent, // Icon color
            size: 18,
          ),
          SizedBox(width: 5), // Add spacing between icon and text
          Flexible(
            // Allows text to shrink if it overflows
            child: Text(
              fileName,
              style: TextStyle(
                color: Colors.lightBlueAccent, // Text color
                fontSize: 14,
                fontWeight: FontWeight.bold, // You can adjust the font weight
              ),
              overflow:
                  TextOverflow.ellipsis, // In case the filename is too long
              softWrap: false, // Prevents the text from wrapping to a new line
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<int> _popUpForReplyConditionTwo() {
    return PopupMenuButton(
        child: Image.asset('assets/images/icon/three-circles.png', width: 25),
        itemBuilder: (context) => [
              PopupMenuItem(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NewMessage(
                              isReply: true,
                              selectedMail: widget.selectedMail,
                              type: 2,
                              messageList: emailResponse!,
                            )));
                  },
                  child: Row(
                    children: [
                      Image.asset('assets/images/icon/reply.png', width: 22),
                      SizedBox(
                        width: 10,
                      ),
                      Text(AppLocalizations.of(context)!.reply),
                    ],
                  ),
                ),
                value: 1,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Image.asset('assets/images/icon/reply-all.png', width: 22),
                    SizedBox(
                      width: 10,
                    ),
                    Text(AppLocalizations.of(context)!.replyAll),
                  ],
                ),
                value: 2,
              ),
              PopupMenuItem(
                child: InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     new MaterialPageRoute(
                    //         builder: (BuildContext context) => NewMessage(
                    //               type: 1,
                    //               messageList: widget.messageList,
                    //             )));
                  },
                  child: Row(
                    children: [
                      Image.asset('assets/images/icon/forward.png', width: 22),
                      SizedBox(
                        width: 10,
                      ),
                      Text(AppLocalizations.of(context)!.forward),
                    ],
                  ),
                ),
                value: 3,
              )
            ]);
  }

  PopupMenuButton<int> _popUpForReply() {
    return PopupMenuButton(
        child: Image.asset('assets/images/icon/three-circles.png', width: 25),
        itemBuilder: (context) => [
              PopupMenuItem(
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Image.asset('assets/images/icon/reply.png', width: 22),
                      SizedBox(
                        width: 10,
                      ),
                      Text(AppLocalizations.of(context)!.reply),
                    ],
                  ),
                ),
                value: 1,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Image.asset('assets/images/icon/reply-all.png', width: 22),
                    SizedBox(
                      width: 10,
                    ),
                    Text(AppLocalizations.of(context)!.replyAll),
                  ],
                ),
                value: 2,
              ),
              PopupMenuItem(
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Image.asset('assets/images/icon/forward.png', width: 22),
                      SizedBox(
                        width: 10,
                      ),
                      Text(AppLocalizations.of(context)!.forward),
                    ],
                  ),
                ),
                value: 3,
              )
            ]);
  }

  String ExtensionImage(String Path) {
    String extension = p.extension(Path);
    switch (extension) {
      case 'xlsx':
        return 'assets/images/file_types/xls.png';
      case 'xls':
        return 'assets/images/file_types/xls.png';
      case 'docx':
        return 'assets/images/file_types/doc.png';
      case 'doc':
        return 'assets/images/file_types/doc.png';
      case 'png':
        return 'assets/images/file_types/png.png';
      case 'jpg':
        return 'assets/images/file_types/jpg.png';
      case 'jpeg':
        return 'assets/images/file_types/jpg.png';
      case 'pdf':
        return 'assets/images/file_types/pdf.png';
      case 'txt':
        return 'assets/images/file_types/txt.png';
      case 'ppt':
        return 'assets/images/file_types/ppt.png';
      case 'zip':
        return 'assets/images/file_types/zip.png';
      case 'mp4':
        return 'assets/images/file_types/mp4.png';
      case 'm4a':
      case 'mp3':
        return 'assets/images/file_types/mp3.png';
      default:
        return 'assets/images/file_types/txt.png';
    }
  }
}
