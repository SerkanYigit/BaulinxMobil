import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerSocial.dart';
import 'package:undede/Custom/DebouncerForSearch.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/removeAllHtmlTags.dart';
import 'package:undede/Custom/showModalDeleteYesOrNo.dart';
import 'package:undede/Custom/showModalFilter.dart';
import 'package:undede/Custom/showModalTextInput.dart';
import 'package:undede/Pages/Social/AddSocialPage.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Social/SocialResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Custom/CustomLoadingCircle.dart';
import 'SocialPage.dart';

class SocialList extends StatefulWidget {
  Social? social;
  SocialList({this.social});

  @override
  _SocialListState createState() => _SocialListState();
}

class _SocialListState extends State<SocialList> with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerSocial _controllerSocial = Get.put(ControllerSocial());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  bool isLoading = true;
  List<Widget> tabs = [];
  TabController? _tabController;
  final List<DropdownMenuItem> cboCommonGroups = [];
  int? selectedCategoryId;
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controllerSocial.GetSocialPost(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
      );
      await _controllerSocial.GetSocialQuestion(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
      );
      cboCommonGroups.add(DropdownMenuItem(
        child: Row(
          children: [
            Text(AppLocalizations.of(context)!.all),
          ],
        ),
        value: null,
        key: Key(AppLocalizations.of(context)!.all),
      ));

      await _controllerCommon.GetPublicCategory(_controllerDB.headers(),
              Language: AppLocalizations.of(context)!.date)
          .then((value) {
        value.result?.asMap().forEach((index, category) {
          cboCommonGroups.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.date == "tr"
                    ? category.tR!
                    : AppLocalizations.of(context)!.date == "en"
                        ? category.eN!
                        : category.dE!),
              ],
            ),
            value: category.id,
            key: Key(AppLocalizations.of(context)!.date == "tr"
                ? category.tR!
                : AppLocalizations.of(context)!.date == "en"
                    ? category.eN!
                    : category.dE!),
          ));
        });
      });
      tabs = [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(AppLocalizations.of(context)!.posts),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(AppLocalizations.of(context)!.questions),
        ),
      ];
      _tabController = new TabController(vsync: this, length: tabs.length);
      _tabController?.addListener(() {
        setState(() {});
      });
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DebouncerForSearch _bouncer = DebouncerForSearch();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerSocial>(builder: (sc) {
      return isLoading
          ? CustomLoadingCircle()
          : Scaffold(
              backgroundColor: Get.theme.scaffoldBackgroundColor,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 85.0),
                child: FloatingActionButton(
                  heroTag: "socialList",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddSocialPage()));
                  },
                  child: Icon(Icons.add),
                ),
              ),
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.social,
                isHomePage: false,
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  isLoading
                      ? Container()
                      : Center(
                          child: Container(
                            margin: EdgeInsets.all(3),
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25)),
                            child: TabBar(
                              isScrollable: true,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: new BubbleTabIndicator(
                                indicatorHeight: 35.0,
                                indicatorColor: _tabController!.index == 0
                                    ? Get.theme.secondaryHeaderColor
                                    : Get.theme.primaryColor,
                                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                                // Other flags
                                //  indicatorRadius: 1,
                                //insets: EdgeInsets.all(1),
                                padding: EdgeInsets.all(1),
                              ),
                              tabs: tabs,
                              controller: _tabController,
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 45,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        boxShadow: standartCardShadow(),
                        borderRadius: BorderRadius.circular(15)),
                    child: CustomTextField(
                      controller: _textEditingController,
                      hint: AppLocalizations.of(context)!.search,
                      prefixIcon: Icon(Icons.search),
                      onChanged: (a) {
                        _bouncer.run(() async {
                          _controllerSocial.GetSocialPost(
                              _controllerDB.headers(),
                              UserId: _controllerDB.user.value!.result!.id,
                              Search: _textEditingController.text,
                              CategoryId: selectedCategoryId);
                          _controllerSocial.GetSocialQuestion(
                              _controllerDB.headers(),
                              UserId: _controllerDB.user.value!.result!.id,
                              Search: _textEditingController.text,
                              CategoryId: selectedCategoryId);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 45,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        boxShadow: standartCardShadow(),
                        borderRadius: BorderRadius.circular(15)),
                    child: SearchableDropdown.single(
                      color: Colors.white,
                      height: 45,
                      displayClearIcon: false,
                      menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
                      items: cboCommonGroups,
                      value: selectedCategoryId,
                      icon: Icon(Icons.expand_more),
                      hint: AppLocalizations.of(context)!.selectCategory,
                      searchHint: AppLocalizations.of(context)!.selectCategory,
                      onChanged: (value) async {
                        setState(() {
                          selectedCategoryId = value;
                          _controllerSocial.GetSocialPost(
                              _controllerDB.headers(),
                              UserId: _controllerDB.user.value!.result!.id,
                              Search: _textEditingController.text,
                              CategoryId: selectedCategoryId);
                          _controllerSocial.GetSocialQuestion(
                              _controllerDB.headers(),
                              UserId: _controllerDB.user.value!.result!.id,
                              Search: _textEditingController.text,
                              CategoryId: selectedCategoryId);
                        });
                      },
                      doneButton: AppLocalizations.of(context)!.done,
                      displayItem: (item, selected) {
                        return (Row(children: [
                          selected
                              ? Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.grey,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                ),
                          SizedBox(width: 7),
                          Expanded(
                            child: item,
                          ),
                        ]));
                      },
                      isExpanded: true,
                      searchFn: dropdownSearchFn,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  isLoading
                      ? Container()
                      : Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [buildPosts(), buildQuestions()],
                          ),
                        ),
                  SizedBox(
                    height: 85,
                  )
                ],
              ));
    });
  }

  Widget buildPosts() {
    return ListView.builder(
        itemCount: _controllerSocial.socialPost.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return buildSocial(_controllerSocial.socialPost[index]);
        });
  }

  Widget buildQuestions() {
    return ListView.builder(
        itemCount: _controllerSocial.socialQuestion.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return buildSocial(_controllerSocial.socialQuestion[index]);
        });
  }

  Widget buildSocial(Social social) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SocialPage(
                      social: social,
                    )));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25)),
                      child: Text(
                        social.categoryName == null
                            ? "Category"
                            : social.categoryName!,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(social.ownerPicture!))),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            social.ownerName!,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          DateFormat(
                                  "MMMMd", AppLocalizations.of(context)!.date)
                              .format(DateTime.parse(social.createDate!)),
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          DateFormat.jm(AppLocalizations.of(context)!.date)
                              .format(DateTime.parse(social.createDate!)),
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    textSplitter(removeAllHtmlTags(social.feed!)),
                  ],
                )),
                SizedBox(
                  width: 40,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          social.socialReplies!.length.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Comment",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      ],
                    ),
                    VerticalDivider(),
                    Column(
                      children: [
                        Text(
                          social.likeCount.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Like",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      ],
                    ),
                    VerticalDivider(),
                    Column(
                      children: [
                        Text(
                          social.type == 1
                              ? AppLocalizations.of(context)!.posts
                              : AppLocalizations.of(context)!.questions,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Type",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
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
