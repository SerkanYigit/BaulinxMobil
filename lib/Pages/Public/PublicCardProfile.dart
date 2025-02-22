import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/removeAllHtmlTags.dart';
import 'package:undede/Pages/Collaboration/CollaborationPage.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/model/Common/GetPublicMeetingsResult.dart';

class PublicCardProfile extends StatefulWidget {
  PublicBoardListItem publicBoardListItem;

  PublicCardProfile({required this.publicBoardListItem});

  @override
  _PublicCardProfileState createState() => _PublicCardProfileState();
}

class _PublicCardProfileState extends State<PublicCardProfile>
    with TickerProviderStateMixin {
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  TabController? _tabController;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    );
    _tabController?.addListener(() {
      setState(() {
        currentTab = _tabController!.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            width: Get.width,
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(
                      15, MediaQuery.of(context).padding.top, 15, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.chevron_left,
                            size: 31,
                            color: Colors.black,
                          )),
                      SizedBox(
                        width: 11,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          _controllerCommon.selectedBoardItem.photo!,
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              _controllerCommon.selectedBoardItem.title!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 21,
                              ),
                              maxLines: 1,
                            )),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: Get.width,
                  height: 550,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Container(
                        width: Get.width,
                        height: 550,
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
                                    widget.publicBoardListItem.photo!,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          removeAllHtmlTags(widget
                                              .publicBoardListItem.title!),
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          removeAllHtmlTags(widget
                                              .publicBoardListItem
                                              .publicCategoryName!),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black
                                                  .withOpacity(0.9))),
                                    ],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 40,
                                        height: 40,
                                        child: FloatingActionButton(
                                            heroTag: "publicPageCall1",
                                            onPressed: () {},
                                            backgroundColor:
                                                Get.theme.colorScheme.surface,
                                            child: Icon(
                                              Icons.call,
                                              color: Colors.white,
                                              size: 19,
                                            ))),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Container(
                                        width: 40,
                                        height: 40,
                                        child: FloatingActionButton(
                                            heroTag: "publicPageFavorite1",
                                            onPressed: () {},
                                            backgroundColor: Color(0xFFdedede),
                                            child: Icon(
                                              Icons.favorite_border,
                                              color: Colors.redAccent,
                                              size: 19,
                                            ))),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            /*Container(
                              width: Get.width,
                              height: 500,
                              child: InAppWebView(
                                  initialOptions: InAppWebViewGroupOptions(
                                    crossPlatform: InAppWebViewOptions(
                                        preferredContentMode: UserPreferredContentMode.MOBILE),
                                  ),
                                  initialUrlRequest: URLRequest(
                                    url: Uri.dataFromString("<html style=""background-color: red;""><body>" + widget.publicBoardListItem.description + "</html></body>", mimeType: 'text/html').toString(),
                                  )),
                            ),*/
                            Container(
                              width: Get.width,
                              height: 35,
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TabMenu(
                                        Icons.info_outlined,
                                        AppLocalizations.of(context)!
                                            .information,
                                        0),
                                    TabMenu(Icons.cloud_upload,
                                        AppLocalizations.of(context)!.cloud, 1),
                                    TabMenu(
                                        Icons.dvr,
                                        AppLocalizations.of(context)!
                                            .recordingPublicBoard,
                                        2),
                                  ],
                                ),
                              ),
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
                                child: Text(
                                  removeAllHtmlTags(
                                      widget.publicBoardListItem.description!),
                                  style: TextStyle(fontSize: 14),
                                ))
                          ],
                        ),
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: DirectoryDetail(
                            folderName: "",
                            customerId: widget.publicBoardListItem.id,
                            hideHeader: true,
                            fileManagerType: FileManagerType.CommonDocument,
                          )),
                      Container(),
                    ],
                  ),
                ),
                /*Container(
                    width: Get.width,
                    height: 600,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Değerlendirmeler",
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'TTNorms',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 45,
                                  width: 100,
                                  child: Text("deneme",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 35,
                                        fontFamily: 'TTNorms',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Text('xxx' + " Değerlendirme",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'TTNorms',
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w100,
                                    )),
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 20,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 65,
                                          child: RatingBarIndicator(
                                              itemSize: 13,
                                              rating: 5,
                                              itemBuilder: (context, _) => Icon(
                                                    Icons.star_rate_rounded,
                                                    size: 11,
                                                    color: Colors.amber,
                                                  )),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  flex: 3,
                                                  /*(comments
                                                    .where((x) => x.star == 5)
                                                    .length ==
                                                    0
                                                    ? 1
                                                    : comments
                                                    .where((x) => x.star == 5)
                                                    .map((item) => 1)
                                                    .reduce((a, b) => a + b))
                                                    .toInt(),*/
                                                  child: Container(
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                        color: Get
                                                            .theme.buttonColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 6,
                                                  /*(comments
                                                    .where((x) => x.star == 5)
                                                    .length ==
                                                    0
                                                    ? 9
                                                    : (comments.length -
                                                    comments
                                                        .where((x) => x.star == 5)
                                                        .map((item) => 1)
                                                        .reduce((a, b) => a + b)))
                                                    .toInt(),*/
                                                  child: Container(),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 22,
                                          child: Text('ccc',
                                              /*comments.where((x) => x.star == 5).length == 0
                                                ? "0"
                                                : comments
                                                .where((x) => x.star == 5)
                                                .map((item) => 1)
                                                .reduce((a, b) => a + b)
                                                .toString(),*/
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'TTNorms',
                                                color: Colors.black,
                                                fontWeight: FontWeight.w100,
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                  /*Container(
                                  height: 20,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 65,
                                        padding: EdgeInsets.only(left: 13),
                                        child: RatingBarIndicator(
                                            itemSize: 13,
                                            rating: 5,
                                            itemCount: 4,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star_rate_rounded,
                                              size: 11,
                                              color: Colors.amber,
                                            )),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 4)
                                                    .length ==
                                                    0
                                                    ? 1
                                                    : comments
                                                    .where((x) => x.star == 4)
                                                    .map((item) => 1)
                                                    .reduce((a, b) => a + b))
                                                    .toInt(),
                                                child: Container(
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                      color: Get.theme.buttonColor,
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 4)
                                                    .length ==
                                                    0
                                                    ? 9
                                                    : (comments.length -
                                                    comments
                                                        .where((x) => x.star == 4)
                                                        .map((item) => 1)
                                                        .reduce((a, b) => a + b)))
                                                    .toInt(),
                                                child: Container(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 22,
                                        child: Text(
                                            comments.where((x) => x.star == 4).length == 0
                                                ? "0"
                                                : comments
                                                .where((x) => x.star == 4)
                                                .map((item) => 1)
                                                .reduce((a, b) => a + b)
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'TTNorms',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w100,
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 65,
                                        padding: EdgeInsets.only(left: 26),
                                        child: RatingBarIndicator(
                                            itemSize: 13,
                                            rating: 5,
                                            itemCount: 3,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star_rate_rounded,
                                              size: 11,
                                              color: Colors.amber,
                                            )),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 3)
                                                    .length ==
                                                    0
                                                    ? 1
                                                    : comments
                                                    .where((x) => x.star == 3)
                                                    .map((item) => 1)
                                                    .reduce((a, b) => a + b))
                                                    .toInt(),
                                                child: Container(
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                      color: Get.theme.buttonColor,
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 3)
                                                    .length ==
                                                    0
                                                    ? 9
                                                    : (comments.length -
                                                    comments
                                                        .where((x) => x.star == 3)
                                                        .map((item) => 1)
                                                        .reduce((a, b) => a + b)))
                                                    .toInt(),
                                                child: Container(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 22,
                                        child: Text(
                                            comments.where((x) => x.star == 3).length == 0
                                                ? "0"
                                                : comments
                                                .where((x) => x.star == 3)
                                                .map((item) => 1)
                                                .reduce((a, b) => a + b)
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'TTNorms',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w100,
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 65,
                                        padding: EdgeInsets.only(left: 39),
                                        child: RatingBarIndicator(
                                            itemSize: 13,
                                            rating: 5,
                                            itemCount: 2,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star_rate_rounded,
                                              size: 11,
                                              color: Colors.amber,
                                            )),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 2)
                                                    .length ==
                                                    0
                                                    ? 1
                                                    : comments
                                                    .where((x) => x.star == 2)
                                                    .map((item) => 1)
                                                    .reduce((a, b) => a + b))
                                                    .toInt(),
                                                child: Container(
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                      color: Get.theme.buttonColor,
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 2)
                                                    .length ==
                                                    0
                                                    ? 9
                                                    : (comments.length -
                                                    comments
                                                        .where((x) => x.star == 2)
                                                        .map((item) => 1)
                                                        .reduce((a, b) => a + b)))
                                                    .toInt(),
                                                child: Container(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 22,
                                        child: Text(
                                            comments.where((x) => x.star == 2).length == 0
                                                ? "0"
                                                : comments
                                                .where((x) => x.star == 2)
                                                .map((item) => 1)
                                                .reduce((a, b) => a + b)
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'TTNorms',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w100,
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 65,
                                        padding: EdgeInsets.only(left: 52),
                                        child: RatingBarIndicator(
                                            itemSize: 13,
                                            rating: 5,
                                            itemCount: 1,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star_rate_rounded,
                                              size: 11,
                                              color: Colors.amber,
                                            )),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 1)
                                                    .length ==
                                                    0
                                                    ? 1
                                                    : comments
                                                    .where((x) => x.star == 1)
                                                    .map((item) => 1)
                                                    .reduce((a, b) => a + b))
                                                    .toInt(),
                                                child: Container(
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                      color: Get.theme.buttonColor,
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: (comments
                                                    .where((x) => x.star == 1)
                                                    .length ==
                                                    0
                                                    ? 9
                                                    : (comments.length -
                                                    comments
                                                        .where((x) => x.star == 1)
                                                        .map((item) => 1)
                                                        .reduce((a, b) => a + b)))
                                                    .toInt(),
                                                child: Container(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 22,
                                        child: Text(
                                            comments.where((x) => x.star == 1).length == 0
                                                ? "0"
                                                : comments
                                                .where((x) => x.star == 1)
                                                .map((item) => 1)
                                                .reduce((a, b) => a + b)
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'TTNorms',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w100,
                                            )),
                                      )
                                    ],
                                  ),
                                ),*/
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ListView.builder(
                            padding: EdgeInsets.all(0),
                            shrinkWrap: true,
                            itemCount: 2,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (ctx, index) {
                              //DateTime cmntDt = comments[index].createDateDateTime;
                              return Container(
                                width: Get.width,
                                //margin: EdgeInsets.only(bottom: (index == comments.length - 1 ? 0 : 10.0).toDouble()),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 70,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              /*child: Image.network(
                                              _controllerChange.urlUsers +comments[index].senderUser.profilePhoto,
                                            ),*/
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                                "bnbn"
                                                /*cmntDt.day.toString() +
                                                  "/" +
                                                  cmntDt.month.toString() +
                                                  "/" +
                                                  cmntDt.year.toString()*/
                                                ,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontFamily: 'TTNorms',
                                                  color: Colors.grey,
                                                )),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 1),
                                            child: Text(
                                                "mnnm"
                                                /*cmntDt.hour.toString() +
                                                  ":" +
                                                  cmntDt.minute.toString()*/
                                                ,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontFamily: 'TTNorms',
                                                  color: Colors.grey,
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      "vvv"
                                                      /*comments[index]
                                                        .senderUser
                                                        .firstName
                                                        .capitalizeFirst +
                                                        " " +
                                                        comments[index]
                                                            .senderUser
                                                            .lastName
                                                            .capitalizeFirst*/
                                                      ,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontFamily: 'TTNorms',
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                  RatingBarIndicator(
                                                      itemSize: 13,
                                                      rating: 3.0 ?? 2.5,
                                                      itemBuilder: (context,
                                                              _) =>
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 15,
                                                          ))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text("comments[index].message",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: 'TTNorms',
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w100,
                                                  )),
                                            ]),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Yorum Yapın",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'TTNorms',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                )),
                            Row(
                              children: [
                                Text("Değerlendirin",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'TTNorms',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    )),
                                RatingBar.builder(
                                  itemSize: 17,
                                  minRating: 1,
                                  initialRating: 1,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    size: 17,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    //commentRating = rating.toInt();
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintStyle: TextStyle(
                              fontSize: 11,
                              fontFamily: 'TTNorms',
                              color: Colors.grey,
                              fontWeight: FontWeight.w100,
                            ),
                            hintText: "Düşüncelerinizi Paylaşın",
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10),
                          ),
                          maxLines: 5,
                          minLines: 2,
                          //controller: txtController,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'TTNorms',
                            color: Colors.black,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                /*if (current == 1) {
                                _controllerDB
                                    .insertComment(
                                  _controllerDB.headers(),
                                  message: txtController.text,
                                  star: commentRating,
                                  officeId: office.id,
                                )
                                    .then((value) {
                                  setState(() {
                                    comments.insert(0, value);
                                  });
                                });
                              } else {
                                _controllerDB
                                    .insertComment(
                                  _controllerDB.headers(),
                                  message: txtController.text,
                                  star: commentRating,
                                  userId: user.id,
                                )
                                    .then((value) {
                                  setState(() {
                                    comments.insert(0, value);
                                  });
                                });
                              }

                              setState(() {
                                txtController.text = "";
                              });*/
                              },
                              child: Container(
                                width: 100,
                                height: 35,
                                decoration: BoxDecoration(
                                    color: Get.theme.backgroundColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text("GÖNDER",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'TTNorms',
                                          color: Get.theme.backgroundColor,
                                        ))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),*/
              ],
            ),
          ),
        ));
  }

  Widget TabMenu(IconData icondata, String desc, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentTab = index;
          _tabController!.animateTo(currentTab);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Get.theme.secondaryHeaderColor,
          boxShadow: standartCardShadow(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        margin: EdgeInsets.only(right: 3),
        child: Row(
          children: [
            Icon(
              icondata,
              size: 19,
              color:
                  currentTab == index ? Get.theme.primaryColor : Colors.white,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              desc,
              style: TextStyle(
                  color: currentTab == index
                      ? Get.theme.primaryColor
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
