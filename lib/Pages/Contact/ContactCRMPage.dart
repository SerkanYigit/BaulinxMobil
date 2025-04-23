import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/InvoiceWithDocumentType.dart';
import 'package:undede/Pages/Business/InvoiceWithDocumentPage.dart';
import 'package:undede/Pages/Business/InvoiceWithDocumentTabPage.dart';
import 'package:undede/Pages/Chat/ChatDetailPage.dart';
import 'package:undede/Pages/Collaboration/CommonDetailsPage.dart';
import 'package:undede/Pages/Contact/MessagePageTabPage.dart';
import 'package:undede/Pages/Contact/NotePageTabPage.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';

import 'CommonDetailsTabPage.dart';

class ContactCRMPage extends StatefulWidget {
  final int? index;
  final int? customerId;
  const ContactCRMPage({Key? key, this.index, this.customerId})
      : super(key: key);
  @override
  _ContactCRMPageState createState() => _ContactCRMPageState();
}

class _ContactCRMPageState extends State<ContactCRMPage>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  TabController? _tabController;
  int currentTab = 0;

  int? selectedCustomerForCloudCommon;
  final List<DropdownMenuItem> customers = [];

  @override
  void initState() {
    super.initState();
    if (!widget.index.isBlank!) {
      setState(() {
        currentTab = widget.index!;
      });
    }
    _tabController = new TabController(
      length: (_controllerDB.user.value!.result!.orderId != 18) ? 7 : 6,
      vsync: this,
      initialIndex: currentTab,
    );

    _tabController!.addListener(() {
      setState(() {
        currentTab = _tabController!.index;
      });
    });

    _controllerDB.user.value!.result!.userCustomers!.userCustomerList!
        .forEach((customer) {
      customers.add(DropdownMenuItem(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: Image.network(
                customer.photo ??
                    'http://test.vir2ell-office.com/Content/cardpicture/userDefault.png',
                width: 21,
                height: 21,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(customer.title!),
          ],
        ),
        value: customer.id,
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: _controllerDB.user.value!.result!.userCustomers!.userCustomerList!
                  .firstWhere((element) => element.id == widget.customerId)
                  .customerAdminName! +
              " " +
              _controllerDB.user.value!.result!.userCustomers!.userCustomerList!
                  .firstWhere((element) => element.id == widget.customerId)
                  .customerAdminSurname!,
        ),
        body: Container(
            width: Get.width,
            height: Get.height,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: Get.width,
                    color: Get.theme.secondaryHeaderColor,
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
                              children: [
                                ClipRRect(
                                  child: Container(
                                    width: Get.width,
                                    height: 35,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    margin: EdgeInsets.only(
                                      top: 15,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        children: [
                                          TabMenu(
                                            Icons.cloud_upload,
                                            AppLocalizations.of(context)!.cloud,
                                            0,
                                          ),
                                          TabMenu(
                                              Icons.message,
                                              AppLocalizations.of(context)!.chat,
                                              1),
                                          TabMenu(
                                              Icons.mail,
                                              AppLocalizations.of(context)!
                                                  .message,
                                              2),
                                          TabMenu(
                                              Icons.note,
                                              AppLocalizations.of(context)!
                                                  .notes,
                                              3),
                                          TabMenu(
                                              Icons.cloud_done,
                                              AppLocalizations.of(context)!
                                                  .commonCloud,
                                              4),
                                          if (_controllerDB
                                                  .user.value!.result!.orderId !=
                                              18)
                                            TabMenu(
                                                Icons.receipt_long,
                                                AppLocalizations.of(context)!
                                                    .invoiceWithDocument,
                                                5),
                                          TabMenu(
                                              Icons.history,
                                              AppLocalizations.of(context)!
                                                  .history,
                                              6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                /*
                                Visibility(
                                  visible: currentTab == 5 ||
                                          currentTab == 1 ||
                                          currentTab == 2
                                      ? false
                                      : true,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 7),
                                    child: SearchableDropdown.single(
                                      displayClearIcon: false,
                                      menuBackgroundColor:
                                          Get.theme.scaffoldBackgroundColor,
                                      items: customers,
                                      value: selectedCustomerForCloudCommon ??
                                          _controllerDB
                                              .user
                                              .value
                                              .result
                                              .userCustomers
                                              .userCustomerList
                                              .first
                                              .id,
                                      hint: "Select one",
                                      searchHint: "Select one",
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCustomerForCloudCommon =
                                              value;
                                        });

                                        reloadDirectoryDetail();
                                      },
                                      doneButton: "Done",
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
                                      height: 41,
                                    ),
                                  ),
                                ),
                                */
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      Navigator(
                                        key: _commonCloudKey,
                                        onGenerateRoute: (routeSettings) {
                                          return MaterialPageRoute(
                                              builder: (context) =>
                                                  CommonDetailsTabPage(
                                                    customerId:
                                                        widget.customerId!,
                                                    customerAdminId: _controllerDB
                                                        .user
                                                        .value!
                                                        .result!
                                                        .userCustomers!
                                                        .userCustomerList!
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            widget.customerId)
                                                        .customerAdminId,
                                                    type: 0,
                                                  ));
                                        },
                                      ),
                                      Navigator(
                                        key: Key('customerDirectoryDetail'),
                                        onGenerateRoute: (routeSettings) {
                                          return MaterialPageRoute(
                                            builder: (context) =>
                                                ChatDetailPage(
                                              image: _controllerDB
                                                  .user
                                                  .value!
                                                  .result!
                                                  .userCustomers!
                                                  .userCustomerList!
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      widget.customerId)
                                                  .photo!,
                                              Id: _controllerDB
                                                  .user
                                                  .value!
                                                  .result!
                                                  .userCustomers!
                                                  .userCustomerList!
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      widget.customerId)
                                                  .customerAdminId!,
                                              diffentPage: 1,
                                              isGroup: 0,
                                              online: false,
                                              blocked: false,
                                            ),
                                          );
                                        },
                                      ),
                                      Navigator(
                                        key: Key('MessagePageTabPage'),
                                        onGenerateRoute: (routeSettings) {
                                          return MaterialPageRoute(
                                            builder: (context) =>
                                                MessagePageTabPage(
                                              UserId: _controllerDB
                                                  .user
                                                  .value!
                                                  .result!
                                                  .userCustomers!
                                                  .userCustomerList!
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      widget.customerId)
                                                  .customerAdminId!,
                                            ),
                                          );
                                        },
                                      ),
                                      Navigator(
                                        key: Key('NotePage'),
                                        onGenerateRoute: (routeSettings) {
                                          return MaterialPageRoute(
                                            builder: (context) =>
                                                NotePageTabPage(
                                              CustomerId: _controllerDB
                                                  .user
                                                  .value!
                                                  .result!
                                                  .userCustomers!
                                                  .userCustomerList!
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      widget.customerId!)
                                                  .customerAdminId!,
                                              moduleType: 36,
                                            ),
                                          );
                                        },
                                      ),
                                      Navigator(
                                        key: Key("commonCloud"),
                                        onGenerateRoute: (routeSettings) {
                                          return MaterialPageRoute(
                                              builder: (context) =>
                                                  CommonDetailsTabPage(
                                                    customerId:
                                                        widget.customerId!,
                                                    customerAdminId: _controllerDB
                                                        .user
                                                        .value!
                                                        .result!
                                                        .userCustomers!
                                                        .userCustomerList!
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            widget.customerId)
                                                        .customerAdminId,
                                                    type: 1,
                                                  ));
                                        },
                                      ),
                                      if (_controllerDB
                                              .user.value!.result!.orderId !=
                                          18)
                                        Navigator(
                                          key: Key("invoice"),
                                          onGenerateRoute: (routeSettings) {
                                            return MaterialPageRoute(
                                              builder: (context) =>
                                                  InvoiceWithDocumentPageTabPage(
                                                      invoiceWithDocumentType:
                                                          InvoiceWithDocumentType
                                                              .IncomePaid,
                                                      customerAdminId: _controllerDB
                                                          .user
                                                          .value!
                                                          .result!
                                                          .userCustomers!
                                                          .userCustomerList!
                                                          .firstWhere((element) =>
                                                              element.id ==
                                                              widget.customerId!)
                                                          .customerAdminId!,
                                                      customerId:
                                                          widget.customerId!),
                                            );
                                          },
                                        ),
                                      Container(
                                        width: 50,
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )));
  }

  final _commonCloudKey = GlobalKey<NavigatorState>();
  void reloadDirectoryDetail() {
    setState(() {
      _commonCloudKey.currentState!.pushReplacement(MaterialPageRoute(
        builder: (context) => DirectoryDetail(
          folderName: "",
          //userId: selectedCustomer.customerAdminId ?? selectedCustomer.id,
          hideHeader: true,
          fileManagerType: FileManagerType.Report,
       //!   todoId: null,
       
          //customerId: fType != null ? selectedCustomer.id : null
        ),
      ));
    });
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
          color: Get.theme.primaryColor,
          boxShadow: standartCardShadow(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        margin: EdgeInsets.only(right: 7),
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
