import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Pages/Contact/CommonDetailEditPage.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommonDetailsTabPage extends StatefulWidget {
  int customerId;
  int? customerAdminId;
  int? type;
  CommonDetailsTabPage(
      {required this.customerId, this.customerAdminId, this.type});

  @override
  _CommonDetailsTabPageState createState() => _CommonDetailsTabPageState();
}

class _CommonDetailsTabPageState extends State<CommonDetailsTabPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(
      length: 5,
      vsync: this,
      initialIndex: 0,
    );
    _tabController!.addListener(() {
      setState(() {
        currentTab = _tabController!.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        body: Container(
            width: Get.width,
            height: Get.height,
            color: Get.theme.secondaryHeaderColor,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F7F7),
                    ),
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: true,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Navigator(
                                          key: Key('xx'),
                                          onGenerateRoute: (routeSettings) {
                                            return MaterialPageRoute(
                                              builder: (context) =>
                                                  DirectoryDetail(
                                                folderName: "",
                                                hideHeader: true,
                                                fileManagerType: widget.type ==
                                                        0
                                                    ? FileManagerType.Salary
                                                    : FileManagerType.Report,
                                                customerId: widget.customerId,
                                                userId: widget
                                                    .customerAdminId!, //widget.todoId,
                                              ),
                                            );
                                          },
                                        )),
                                    Container(),
                                    Container(
                                      width: 50,
                                      height: 50,
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                    ),
                                    CommonDetailEditPage(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    /*SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: Get.width,
                            height: 35,
                            padding: EdgeInsets.symmetric(horizontal: 5,),
                            margin: EdgeInsets.only(top: 7),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  TabMenu(Icons.edit, 'Düzenle', 0),
                                  TabMenu(Icons.cloud_upload, 'Yükle', 1),
                                  TabMenu(Icons.comment_outlined, 'Yorumlar', 2),
                                  TabMenu(Icons.checklist, 'Takip', 3),
                                  TabMenu(Icons.note, 'Notlar', 4),
                                  TabMenu(Icons.color_lens, 'Tasarım', 5),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          /*Container(
                            width: Get.width,
                            height: 500,
                            child: NestedScrollView(
                              headerSliverBuilder: (context, value) {
                                return [
                                  SliverToBoxAdapter(child: _buildCarousel()),
                                  SliverToBoxAdapter(
                                    child: TabBar(
                                      controller: _tabController2,
                                      labelColor: Colors.redAccent,
                                      isScrollable: false,
                                      tabs: myTabs,
                                    ),
                                  ),
                                ];
                              },
                              body: Container(
                                child: TabBarView(
                                  controller: _tabController2,
                                  children: [_buildTabContext(2), _buildTabContext(200), _buildTabContext(2)],
                                ),
                              ),
                            ),
                          ),*/
                          /*Container(
                            width: Get.width,
                            height: 500,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                commonDetailsEditPage(),
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: DirectoryDetail(folderName: "", hideHeader: true)
                                ),
                                Container(),
                                Container(
                                  width: 50,
                                  height: 50,
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                ),
                              ],
                            ),
                          ),*/
                          SizedBox(height: 100,)
                        ],
                      ),
                    ),*/
                  ),
                )
              ],
            )));
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
          color: Color(currentTab == index ? 0xFFe3d5a4 : 0xFFe3d5a4),
          boxShadow: standartCardShadow(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        margin: EdgeInsets.only(right: 3),
        child: Row(
          children: [
            Icon(
              icondata,
              size: 19,
              color: currentTab == index
                  ? Get.theme.secondaryHeaderColor
                  : Colors.black.withOpacity(0.5),
            ),
            currentTab == index
                ? SizedBox(
                    width: 3,
                  )
                : Container(),
            currentTab == index
                ? Text(
                    desc,
                    style: TextStyle(
                        color: currentTab == index
                            ? Get.theme.secondaryHeaderColor
                            : Colors.black.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  List<BoxShadow> standartCardShadow() {
    return <BoxShadow>[
      BoxShadow(
        color: Colors.grey,
        offset: Offset(0, 0),
        blurRadius: 15,
        spreadRadius: -11,
      )
    ];
  }
}
