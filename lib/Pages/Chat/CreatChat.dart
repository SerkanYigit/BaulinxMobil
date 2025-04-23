import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Pages/Chat/ChatDetailPage.dart';
import 'package:undede/Pages/GeneralSearch/GeneralSearchPage.dart';
import 'package:undede/Pages/Notification/NotificationPage.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/model/Chat/GetUserListUser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatChat extends StatefulWidget {
  final GetUserListResult? getUserListResult;
  const CreatChat({Key? key, this.getUserListResult}) : super(key: key);

  @override
  _CreatChatState createState() => _CreatChatState();
}

class _CreatChatState extends State<CreatChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Container(
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
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                height: 45,
                                margin: EdgeInsets.only(top: 15),
                                decoration: BoxDecoration(
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(45)),
                                child: CustomTextField(
                                  prefixIcon: Icon(Icons.search),
                                  hint: AppLocalizations.of(context)!.search,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15, right: 20),
                            child: PopupMenuButton(
                                child: Center(
                                    child: Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                  size: 27,
                                )),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Text(AppLocalizations.of(context)!
                                            .newGroup),
                                        value: 1,
                                      ),
                                      PopupMenuItem(
                                        child: Text(AppLocalizations.of(context)!
                                            .newPublicGroup),
                                        value: 2,
                                      ),
                                      PopupMenuItem(
                                        child: Text(AppLocalizations.of(context)!
                                            .settings),
                                        value: 3,
                                      )
                                    ]),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              widget.getUserListResult!.result!.length != null
                                  ? widget.getUserListResult!.result!.length
                                  : 0,
                          itemBuilder: (ctx, i) {
                            return InkWell(
                              onTap: () {
                                print(i);
                              },
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Image.network(
                                              widget.getUserListResult!.result![i]
                                                          .photo ==
                                                      "/Content//UserDefault.png"
                                                  ? "http://test.vir2ell-office.com/${widget.getUserListResult!.result![i].photo}"
                                                  : "http://test.vir2ell-office.com/Content/UploadPhoto/User/${widget.getUserListResult!.result![i].photo}" ??
                                                      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  widget.getUserListResult!
                                                      .result![i].fullName!,
                                                  style: TextStyle(
                                                      fontFamily: 'Avenir-Book',
                                                      fontSize: 17.0,
                                                      letterSpacing:
                                                          -0.41000000190734864,
                                                      height: 1.29,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
    );
  }
}
