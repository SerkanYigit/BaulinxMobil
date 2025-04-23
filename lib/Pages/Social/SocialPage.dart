import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerSocial.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/removeAllHtmlTags.dart';
import 'package:undede/Custom/showModalDeleteYesOrNo.dart';
import 'package:undede/Custom/showModalTextInput.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Collaboration/CollaborationPage.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/Services/BlockReport/BlockReportDB.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Common/GetPublicMeetingsResult.dart';
import 'package:undede/model/Social/SocialResult.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialPage extends StatefulWidget {
  Social? social;
  SocialPage({this.social});

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerSocial _controllerSocial = Get.put(ControllerSocial());
  BlockReportDB _blockReportDB = BlockReportDB();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controllerSocial.GetSocialList(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.social,
          isHomePage: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  width: Get.width,
                  height: Get.height - 85,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: Container(
                          width: Get.width,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          child: Column(
                            children: [
                              Container(
                                width: 125,
                                height: 125,
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(150),
                                    border: Border.all(
                                        width: 3, color: Color(0xFFdedede))),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(150),
                                    child: Image.network(
                                      widget.social!.ownerPicture!,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            removeAllHtmlTags(
                                                widget.social!.categoryName!),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black
                                                    .withOpacity(0.9))),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 40,
                                          height: 40,
                                          child: FloatingActionButton(
                                              heroTag: "socialPageComment1",
                                              onPressed: () async {
                                                String? value =
                                                    await showModalTextInput(
                                                        context,
                                                        AppLocalizations.of(
                                                                context)!
                                                            .createNewComment,
                                                        AppLocalizations.of(
                                                                context)!
                                                            .sent);
                                                if (value!.isNotEmpty) {
                                                  await _controllerSocial
                                                          .AddOrUpdateSocialReply(
                                                              _controllerDB
                                                                  .headers(),
                                                              Id: 0,
                                                              UserId:
                                                                  _controllerDB
                                                                      .user
                                                                      .value!
                                                                      .result!
                                                                      .id,
                                                              SocialId: widget
                                                                  .social!.id,
                                                              Feed: value)
                                                      .then((value) {
                                                    setState(() {
                                                      widget.social!.socialReplies!.insert(
                                                          0,
                                                          SocialReplies(
                                                              id: value
                                                                  .result!.id,
                                                              userId: value
                                                                  .result!
                                                                  .userId,
                                                              feed: value
                                                                  .result!.feed,
                                                              createDate:
                                                                  DateTime.now()
                                                                      .toString(),
                                                              ownerName: _controllerDB
                                                                      .user
                                                                      .value!
                                                                      .result!
                                                                      .name! +
                                                                  " " +
                                                                  _controllerDB
                                                                      .user
                                                                      .value!
                                                                      .result!
                                                                      .surname!,
                                                              ownerPicture:
                                                                  _controllerDB
                                                                      .user
                                                                      .value!
                                                                      .result!
                                                                      .photo!,
                                                              socialId: widget
                                                                  .social!.id));
                                                    });
                                                  });
                                                }
                                              },
                                              backgroundColor:
                                                  Color(0xFFdedede),
                                              child: Icon(
                                                Icons.comment,
                                                color: Colors.redAccent,
                                                size: 19,
                                              ))),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Container(
                                          width: 40,
                                          height: 40,
                                          child: FloatingActionButton(
                                              heroTag: "socialPageFavorite1",
                                              onPressed: () {},
                                              backgroundColor:
                                                  Color(0xFFdedede),
                                              child: Icon(
                                                Icons.favorite_border,
                                                color: Colors.redAccent,
                                                size: 19,
                                              ))),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      PopupMenuButton(
                                          onSelected: (a) async {
                                            if (a == 2) {
                                              if (widget.social!.userId ==
                                                  _controllerDB
                                                      .user.value!.result!.id) {
                                                showErrorToast(
                                                    "Kendinizi Reportlayamazsınız");
                                              }
                                              String? text =
                                                  await showModalTextInput(
                                                      context,
                                                      "Kullanıcıyı reporlama sebebinizi yazınız",
                                                      "Report");

                                              await _blockReportDB.ReportUser(
                                                  _controllerDB.headers(),
                                                  userId: _controllerDB
                                                      .user.value!.result!.id,
                                                  reportedUserId:
                                                      widget.social!.userId!,
                                                  reportMessage: text!,
                                                  blockType: 3);
                                              _controllerSocial.GetSocialPost(
                                                _controllerDB.headers(),
                                                UserId: _controllerDB
                                                    .user.value!.result!.id,
                                              );
                                              _controllerSocial
                                                  .GetSocialQuestion(
                                                _controllerDB.headers(),
                                                UserId: _controllerDB
                                                    .user.value!.result!.id,
                                              );
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            child: FloatingActionButton(
                                                heroTag: "socialPageReport1",
                                                onPressed: () {},
                                                backgroundColor:
                                                    Color(0xFFdedede),
                                                child: Icon(
                                                  Icons.report,
                                                  color: Colors.redAccent,
                                                  size: 19,
                                                )),
                                          ),
                                          itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .report),
                                                  value: 2,
                                                )
                                              ]),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          width: 1.0, color: Colors.grey),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 15),
                                  child: textSplitter(
                                      removeAllHtmlTags(widget.social!.feed!))),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    itemCount:
                                        widget.social!.socialReplies!.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (ctx, index) {
                                      return PopupMenuButton(
                                        onSelected: (a) async {
                                          if (a == 2) {
                                            String? text = await showModalTextInput(
                                                context,
                                                "Kullanıcıyı reporlama sebebinizi yazınız",
                                                "Report");

                                            await _blockReportDB.ReportUser(
                                                _controllerDB.headers(),
                                                userId: _controllerDB
                                                    .user.value!.result!.id,
                                                reportedUserId:
                                                    widget.social!.userId!,
                                                reportMessage: text!,
                                                blockType: 3);
                                            _controllerSocial.GetSocialPost(
                                              _controllerDB.headers(),
                                              UserId: _controllerDB
                                                  .user.value!.result!.id,
                                            );
                                            _controllerSocial.GetSocialQuestion(
                                              _controllerDB.headers(),
                                              UserId: _controllerDB
                                                  .user.value!.result!.id,
                                            );
                                            Navigator.pop(context);
                                          }
                                          if (a == 1) {
                                            bool? confirm =
                                                await showModalDeleteYesOrNo(
                                                    context,
                                                    AppLocalizations.of(
                                                            context)!
                                                        .wantToDelete);
                                            if (confirm!) {
                                              _controllerSocial
                                                      .DeleteSocialReply(
                                                          _controllerDB
                                                              .headers(),
                                                          Id: widget
                                                              .social!
                                                              .socialReplies![
                                                                  index]
                                                              .id)
                                                  .then((value) {
                                                if (value) {
                                                  setState(() {
                                                    widget
                                                        .social!.socialReplies!
                                                        .removeWhere((element) =>
                                                            element.id ==
                                                            widget
                                                                .social!
                                                                .socialReplies![
                                                                    index]
                                                                .id);
                                                  });
                                                }
                                              });
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => widget
                                                    .social!
                                                    .socialReplies![index]
                                                    .userId ==
                                                _controllerDB
                                                    .user.value!.result!.id
                                            ? [
                                                PopupMenuItem(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .delete),
                                                  value: 1,
                                                )
                                              ]
                                            : [
                                                PopupMenuItem(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .report),
                                                  value: 2,
                                                )
                                              ],
                                        child: Container(
                                          width: Get.width,
                                          margin: EdgeInsets.only(
                                              bottom: (index ==
                                                          widget
                                                                  .social!
                                                                  .socialReplies!
                                                                  .length -
                                                              1
                                                      ? 0
                                                      : 15.0)
                                                  .toDouble()),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 55,
                                                width: 55,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(widget
                                                            .social!
                                                            .socialReplies![
                                                                index]
                                                            .ownerPicture!))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                widget
                                                                    .social!
                                                                    .socialReplies![
                                                                        index]
                                                                    .ownerName!,
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'TTNorms',
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        textSplitter(
                                                            removeAllHtmlTags(widget
                                                                .social!
                                                                .socialReplies![
                                                                    index]
                                                                .feed!))
                                                      ]),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                    DateFormat.yMMMd(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .date)
                                                        .format(DateTime.parse(
                                                      widget
                                                          .social!
                                                          .socialReplies![index]
                                                          .createDate!,
                                                    )),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'TTNorms',
                                                      color: Colors.grey,
                                                    )),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                    DateFormat.jm(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .date)
                                                        .format(DateTime.parse(
                                                      widget
                                                          .social!
                                                          .socialReplies![index]
                                                          .createDate!,
                                                    )),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'TTNorms',
                                                      color: Colors.grey,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget textSplitter(String input) {
    List<TextSpan> textSpans = [];
    if (input.contains("http")) {
      for (var i = 0; i <= 'http'.allMatches(input).length; i++) {
        String part = input.substring(0,
            input.indexOf('http') == -1 ? input.length : input.indexOf('http'));
        textSpans
            .add(TextSpan(text: part, style: TextStyle(color: Colors.black)));

        input = input.substring(input.indexOf('http'));
        String clickable = input.substring(
            0, input.indexOf(' ') == -1 ? input.length : input.indexOf(' '));
        textSpans.add(
          TextSpan(
            text: clickable,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch(clickable);
              },
          ),
        );
        input = input.substring(
            input.indexOf(' ') == -1 ? input.length : input.indexOf(' '));
      }
    }

    if (textSpans.length == 0) {
      textSpans
          .add(TextSpan(text: input, style: TextStyle(color: Colors.black)));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}
