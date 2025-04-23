import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/HomePage/DashBoardNew.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';

import '../Controller/ControllerInvoice.dart';
import '../Pages/Business/InvoiceWithDocumentPage.dart';
import '../Pages/Chat/ChatPage.dart';
import '../Pages/Chat/GroupChat/CreateNewGrup.dart';

class CustomAppBarWithSearch extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isHomePage;
  final bool showNotification;
  final Widget? actionWidget;
  final Function(String) onChanged; // Add this prop for onChanged callback
  final Function() openFilterFunction;
  final Function() openBoardFunction;
  final Function(ChatActivity)? openFirstRadioButton;
  final Function(int)? onChangedForInvoiceRadio;
  final Function(int, TargetAccount)? onChangedForInvoiceRadio2;
  final int? initialBoardNumber;
  final String? totalCount;
  final bool? commonResult;
  final bool isChatPage;
  final bool isNotificationsOpen;
  final bool isSearchOpen;
  final bool isInvoicePage;
  final bool isMessagePage;
  final bool isPartnerPage;
  final bool isSelectParticipantsPage;
  final bool isNotificationPage;
  final ControllerInvoice? controllerInvoice;
  final int? selectedCustomerId;
  final TargetAccount? targetAccount;

  CustomAppBarWithSearch({
    Key? key,
    required this.title,
    this.isSearchOpen = true,
    this.isHomePage = false,
    this.showNotification = true,
    this.actionWidget,
    this.initialBoardNumber,
    this.totalCount,
    this.commonResult,
    this.isChatPage = false,
    this.isNotificationsOpen = false,
    this.isInvoicePage = false,
    this.onChangedForInvoiceRadio,
    this.controllerInvoice,
    this.isMessagePage = false,
    this.isPartnerPage = false,
    this.isSelectParticipantsPage = false,
    this.isNotificationPage = false,
    required this.onChanged, // Add this prop to constructor
    required this.openFilterFunction,
    required this.openBoardFunction,
    this.openFirstRadioButton,
    this.selectedCustomerId,
    this.onChangedForInvoiceRadio2,
    this.targetAccount,
  }) : super(key: key);

  @override
  _CustomAppBarWithSearchState createState() => _CustomAppBarWithSearchState();
  ChatActivity _chatActivity = ChatActivity.All;

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomAppBarWithSearchState extends State<CustomAppBarWithSearch> {
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  ControllerDB _controllerDB = Get.put(ControllerDB());

  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // height of the divider
          child: Container(
            color: Colors.grey[200], // color of the divider
            height: 0.5, // thickness of the divider
          ),
        ),
        title: _isSearching
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  widget.onChanged(value); // Trigger the onChanged callback
                },
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // widget.isMessagePage
                    //     ? GestureDetector(
                    //         onTap: () {
                    //           widget.openBoardFunction();
                    //         },
                    //         child: Container(
                    //           height: 35,
                    //           width: 35,
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(30)),
                    //           child: Icon(
                    //             Icons.line_weight_outlined,
                    //             size: 20,
                    //           ),
                    //         ),
                    //       )
                    //     : Container(),
                    Text(
                      widget.title,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                )),
        titleTextStyle: TextStyle(color: Colors.black),
        leading: widget.isSelectParticipantsPage
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(
                              _controllerDB.user.value!.result?.photo ??
                                  "https://img2.pngindir.com/20180720/ivv/kisspng-computer-icons-user-profile-avatar-job-icon-5b521c567f49d7.5742234415321078625214.jpg",
                              height: 35,
                              width: 35,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 10,
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
                  ),
                ],
              )
            : Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (widget.isHomePage == true) {
                      _controllerBottomNavigationBar.goHomePage = true;
                      _controllerBottomNavigationBar.update();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),

/* 
        actions: 
        widget.isInvoicePage 
           ? 
            [
                widget.isInvoicePage ? _invoicePopup2() : Container(),
                SizedBox(width: 10),
                widget.isChatPage ? _chatPagePopup() : _filter(),
                SizedBox(width: 10),
                widget.isInvoicePage ? _invoicePopup1() : Container(),
              ]
            :   
            //! buraya tekraar bakilacak, ==true ekledim amaa olmadi
             widget.isMessagePage == true 
               ? 
               [
                    _isSearchOpen(),
                    _filter(),
                    SizedBox(
                      width: 10,
                    )
                  ]
                : widget.isPartnerPage== true
                    ? []
                    : widget.isChatPage== true
                        ? 
                        [
                            _isSearchOpen(),
                            SizedBox(width: 10),
                            _chatPagePopup(),
                            SizedBox(width: 10),
                            _chatPageNewGroup(context),
                            SizedBox(width: 10),
                          ]
                        : widget.isSelectParticipantsPage== true
                            ? [
                                _isSearchOpen(),
                                SizedBox(width: 10),
                                _checkNotifications(),
                              ]
                            : widget.isNotificationPage== true
                                ? [
                                    _isSearchOpen(),
                                    SizedBox(width: 10),
                                    _checkNotifications(),
                                    SizedBox(width: 10),
                                  ]
                                : 
                                [
                                      widget.actionWidget? == null
                                        ? Container()
                                        : widget.actionWidget,
                                    widget.isSearchOpen
                                        ? _isSearchOpen()
                                        : Container(),
                                    widget.isNotificationsOpen
                                        ? _notifications()
                                        : _collaborationTotalCount(),
                                  ], */

        actions: widget.isInvoicePage
            ? [
                widget.isInvoicePage ? _invoicePopup2() : Container(),
                SizedBox(width: 10),
                widget.isChatPage ? _chatPagePopup() : _filter(),
                SizedBox(width: 10),
                widget.isInvoicePage ? _invoicePopup1() : Container(),
              ]
            : widget.isMessagePage
                ? [
                    _isSearchOpen(),
                    _filter(),
                    SizedBox(
                      width: 10,
                    )
                  ]
                : widget.isPartnerPage
                    ? []
                    : widget.isChatPage
                        ? [
                            _isSearchOpen(),
                            SizedBox(width: 10),
                            _chatPagePopup(),
                            SizedBox(width: 10),
                            _chatPageNewGroup(context),
                            SizedBox(width: 10),
                          ]
                        : widget.isSelectParticipantsPage
                            ? [
                                _isSearchOpen(),
                                SizedBox(width: 10),
                                _checkNotifications(),
                              ]
                            : widget.isNotificationPage
                                ? [
                                    _isSearchOpen(),
                                    SizedBox(width: 10),
                                    _checkNotifications(),
                                    SizedBox(width: 10),
                                  ]
                                : [
                                    widget.actionWidget == null
                                        ? Container()
                                        : widget.actionWidget!,
                                    widget.isSearchOpen
                                        ? _isSearchOpen()
                                        : Container(),
                                    widget.isNotificationsOpen
                                        ? _notifications()
                                        : _collaborationTotalCount(),
                                  ],
      ),
    );
  }

  Align _checkNotifications() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          widget.openBoardFunction();
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Image.asset(
            'assets/images/icon/check.png',
            width: 28,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Padding _chatPageNewGroup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: PopupMenuButton(
          onSelected: (a) {
            if (a == 1) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateNewGrup()));
            }
          },
          child: Image.asset('assets/images/icon/three-circles.png', width: 25),
          itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('New Group'),
                  value: 1,
                ),
                //PopupMenuItem(
                //child: Text(AppLocalizations.of(context).settings),
                //value: 2,
                //)
              ]),
    );
  }

  Padding _collaborationTotalCount() {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Text(
          widget.commonResult == true
              ? '${widget.initialBoardNumber! + 1} / ${widget.totalCount}'
              : '',
          style: TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
        ));
  }

  Padding _notifications() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        children: [
          Container(
            height: 45,
            width: 45,
            padding: EdgeInsets.all(5), // Add padding here
            child: IconButton(
              onPressed: () {
                widget.openBoardFunction();
              },
              icon: ImageIcon(
                AssetImage(
                  'assets/images/icon/notification.png',
                ),
                color: Colors.black54,
              ),
              color: Colors.black,
            ),
          ),
          Positioned(
              top: 0,
              right: 2,
              child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      _controllerDB.notificationUnreadCount.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  )))
        ],
      ),
    );
  }

  GestureDetector _filter() {
    return GestureDetector(
      onTap: () {
        widget.openFilterFunction();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: (widget.isInvoicePage || widget.isMessagePage)
            ? Icon(
                Icons.line_weight_outlined,
                color: Colors.black54,
              )
            : ImageIcon(AssetImage('assets/images/icon/filter.png')),
      ),
    );
  }

  Padding _chatPagePopup() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: PopupMenuButton(
          onSelected: (a) {
            if (a == 1) {
              widget.openFirstRadioButton!(ChatActivity.All);
            }
            if (a == 2) {
              widget.openFirstRadioButton!(ChatActivity.Online);
            }
            if (a == 3) {
              widget.openFirstRadioButton!(ChatActivity.Offline);
            }
          },
          child: ImageIcon(AssetImage('assets/images/icon/filter.png')),
          itemBuilder: (context) => [
                PopupMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Radio<ChatActivity>(
                          focusColor: Get.theme.primaryColor,
                          hoverColor: Get.theme.primaryColor,
                          activeColor: Get.theme.primaryColor,
                          fillColor: WidgetStateColor.resolveWith(
                              (states) => Get.theme.primaryColor),
                          value: ChatActivity.All,
                          groupValue: widget._chatActivity,
                          onChanged: (value) {},
                        ),
                        Text(
                          'All',
                          style: TextStyle(
                              color: Get.theme.primaryColor, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Radio<ChatActivity>(
                          focusColor: Colors.green,
                          hoverColor: Colors.green,
                          activeColor: Colors.green,
                          fillColor: WidgetStateColor.resolveWith(
                              (states) => Colors.green),
                          value: ChatActivity.Online,
                          groupValue: widget._chatActivity,
                          onChanged: (value) {},
                        ),
                        Text(
                          'Online',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Radio<ChatActivity>(
                          focusColor: Colors.red,
                          hoverColor: Colors.red,
                          activeColor: Colors.red,
                          fillColor: WidgetStateColor.resolveWith(
                              (states) => Colors.red),
                          value: ChatActivity.Offline,
                          groupValue: widget._chatActivity,
                          onChanged: (value) {},
                        ),
                        Text(
                          'Offline',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                          overflow: TextOverflow.clip,
                        )
                      ],
                    ),
                  ),
                  value: 3,
                )
              ]),
    );
  }

  Padding _invoicePopup2() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: PopupMenuButton(
        onSelected: (int a) {
          setState(() {
            if (a == 1) {
              widget.onChangedForInvoiceRadio2!(1, TargetAccount.All);
            } else if (a == 2) {
              widget.onChangedForInvoiceRadio2!(2, TargetAccount.Private);
            } else if (a == 3) {
              widget.onChangedForInvoiceRadio2!(3, TargetAccount.Cashbox);
            } else if (a == 4) {
              widget.onChangedForInvoiceRadio2!(4, TargetAccount.Bank);
            }
          });
        },
        child: ImageIcon(
          AssetImage('assets/images/icon/filter.png'),
          color: Colors.black54,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Container(
              child: Row(
                children: [
                  Radio<TargetAccount>(
                    focusColor: Colors.black,
                    hoverColor: Colors.black,
                    activeColor: Colors.black,
                    fillColor:
                        WidgetStateColor.resolveWith((states) => Colors.black),
                    value: TargetAccount.All,
                    groupValue: widget.targetAccount,
                    onChanged: (value) {},
                  ),
                  Text(
                    AppLocalizations.of(context)!.all,
                    style: TextStyle(color: Colors.black),
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
            value: 1,
          ),
          PopupMenuItem(
            child: Container(
              child: Row(
                children: [
                  Radio<TargetAccount>(
                    focusColor: Colors.red,
                    hoverColor: Colors.red,
                    activeColor: Colors.red,
                    fillColor:
                        WidgetStateColor.resolveWith((states) => Colors.red),
                    value: TargetAccount.Private,
                    groupValue: widget.targetAccount,
                    onChanged: (value) {},
                  ),
                  Text(
                    AppLocalizations.of(context)!.private,
                    style: TextStyle(color: Colors.red),
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
            value: 2,
          ),
          PopupMenuItem(
            child: Container(
              child: Row(
                children: [
                  Radio<TargetAccount>(
                    focusColor: Get.theme.primaryColor,
                    hoverColor: Get.theme.primaryColor,
                    activeColor: Get.theme.primaryColor,
                    fillColor: WidgetStateColor.resolveWith(
                        (states) => Get.theme.primaryColor),
                    value: TargetAccount.Cashbox,
                    groupValue: widget.targetAccount,
                    onChanged: (value) {},
                  ),
                  Text(
                    AppLocalizations.of(context)!.cashBox,
                    style: TextStyle(color: Get.theme.primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            value: 3,
          ),
          PopupMenuItem(
            child: Container(
              child: Row(
                children: [
                  Radio<TargetAccount>(
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    activeColor: Colors.green,
                    fillColor:
                        WidgetStateColor.resolveWith((states) => Colors.green),
                    value: TargetAccount.Bank,
                    groupValue: widget.targetAccount,
                    onChanged: (value) {},
                  ),
                  Text(
                    AppLocalizations.of(context)!.bank,
                    style: TextStyle(color: Colors.green),
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
            value: 4,
          ),
        ],
      ),
    );
  }

  Padding _invoicePopup1() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: PopupMenuButton(
            onSelected: (a) async {
              //! a degiskeni int parse olarak degistirdim
              widget.onChangedForInvoiceRadio!(int.parse(a.toString()));
            },
            child: Center(
                child: Icon(
              Icons.more_vert,
              color: Colors.black54,
              size: 27,
            )),

/* //! Bu kisim kodlar , asagidaki kodlar ile degistirildi.
            
            [
                  widget.controllerInvoice.getInvoicePeriod.value.result
                                  .firstWhere((element) =>
                                      element.month ==
                                      widget.controllerInvoice.selectedMonth)
                                  .status ==
                              0 ||
                          widget.controllerInvoice.getInvoicePeriod.value
                                  .result
                                  .firstWhere((element) =>
                                      element.month ==
                                      widget.controllerInvoice.selectedMonth)
                                  .status ==
                              1
                      ? PopupMenuItem(
                          child: Text(AppLocalizations.of(context).closePeriod),
                          value: 1,
                        )
                      : null,
                  widget.controllerInvoice.getInvoicePeriod.value.result
                                  .firstWhere((element) =>
                                      element.month ==
                                      widget.controllerInvoice.selectedMonth)
                                  .status ==
                              1 ||
                          widget.controllerInvoice.getInvoicePeriod.value
                                  .result
                                  .firstWhere((element) =>
                                      element.month ==
                                      widget.controllerInvoice.selectedMonth)
                                  .status ==
                              2
                      ? PopupMenuItem(
                          child: Text(AppLocalizations.of(context).openPeriod),
                          value: 2,
                        )
                      : null,
                  widget.controllerInvoice.getInvoicePeriod.value.result
                                  .firstWhere((element) =>
                                      element.month ==
                                      widget.controllerInvoice.selectedMonth)
                                  .status ==
                              0 ||
                          widget.controllerInvoice.getInvoicePeriod.value
                                  .result
                                  .firstWhere((element) =>
                                      element.month ==
                                      widget.controllerInvoice.selectedMonth)
                                  .status ==
                              2
                      ? PopupMenuItem(
                          child:
                              Text(AppLocalizations.of(context).continuePeriod),
                          value: 3,
                        )
                      : null,
                  // PopupMenuItem(
                  //   child: Row(
                  //     children: [
                  //       Icon(
                  //           widget.controllerInvoice.invoiceSettings
                  //                   .firstWhere((e) =>
                  //                       e.CustomerId ==
                  //                       widget.selectedCustomerId)
                  //                   .ShowUnpaid
                  //               ? Icons.radio_button_checked
                  //               : Icons.radio_button_unchecked,
                  //           color: Get.theme.secondaryHeaderColor),
                  //       SizedBox(
                  //         width: 5,
                  //       ),
                  //       Text(AppLocalizations.of(context).showUnpaid)
                  //     ],
                  //   ),
                  //   value: 5,
                  // ),
                ]));
  

 */

            itemBuilder: (context) => <PopupMenuEntry<int>>[
                  if (widget.controllerInvoice!.getInvoicePeriod.value!.result!
                              .firstWhere((element) =>
                                  element.month ==
                                  widget.controllerInvoice!.selectedMonth)
                              .status ==
                          0 ||
                      widget.controllerInvoice!.getInvoicePeriod.value!.result!
                              .firstWhere((element) =>
                                  element.month ==
                                  widget.controllerInvoice!.selectedMonth)
                              .status ==
                          1)
                    PopupMenuItem<int>(
                      child: Text(AppLocalizations.of(context)!.closePeriod),
                      value: 1,
                    ),
                  if (widget.controllerInvoice!.getInvoicePeriod.value!.result!
                              .firstWhere((element) =>
                                  element.month ==
                                  widget.controllerInvoice!.selectedMonth)
                              .status ==
                          1 ||
                      widget.controllerInvoice!.getInvoicePeriod.value!.result!
                              .firstWhere((element) =>
                                  element.month ==
                                  widget.controllerInvoice!.selectedMonth)
                              .status ==
                          2)
                    PopupMenuItem<int>(
                      child: Text(AppLocalizations.of(context)!.openPeriod),
                      value: 2,
                    ),
                  if (widget.controllerInvoice!.getInvoicePeriod.value!.result!
                              .firstWhere((element) =>
                                  element.month ==
                                  widget.controllerInvoice!.selectedMonth)
                              .status ==
                          0 ||
                      widget.controllerInvoice!.getInvoicePeriod.value!.result!
                              .firstWhere((element) =>
                                  element.month ==
                                  widget.controllerInvoice!.selectedMonth)
                              .status ==
                          2)
                    PopupMenuItem<int>(
                      child: Text(AppLocalizations.of(context)!.continuePeriod),
                      value: 3,
                    ),
                  // PopupMenuItem(
                  //   child: Row(
                  //     children: [
                  //       Icon(
                  //           widget.controllerInvoice.invoiceSettings
                  //                   .firstWhere((e) =>
                  //                       e.CustomerId ==
                  //                       widget.selectedCustomerId)
                  //                   .ShowUnpaid
                  //               ? Icons.radio_button_checked
                  //               : Icons.radio_button_unchecked,
                  //           color: Get.theme.secondaryHeaderColor),
                  //       SizedBox(
                  //         width: 5,
                  //       ),
                  //       Text(AppLocalizations.of(context).showUnpaid)
                  //     ],
                  //   ),
                  //   value: 5,
                  // ),
                ]));
  }

  Padding _isSearchOpen() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: IconButton(
        icon: _isSearching
            ? Icon(
                Icons.close,
                color: Colors.black54,
              )
            : ImageIcon(
                AssetImage('assets/images/icon/magnifying-glass.png'),
                color: Colors.black54,
              ),
        onPressed: () {
          setState(() {
            _isSearching = !_isSearching;
            _isSearching == false
                ? widget.onChanged('')
                : widget.onChanged(''); // Trigger the onChanged callback
          });
        },
        color: Colors.black54,
      ),
    );
  }
}
