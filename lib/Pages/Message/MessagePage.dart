import 'dart:math';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerMessage.dart';
import 'package:undede/Custom/CustomLoadingCircle.dart';
import 'package:undede/Custom/removeAllHtmlTags.dart';
import 'package:undede/WidgetsV2/CustomAppBarWithSearch.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/model/Message/GetMessageByUserIdResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tree/flutter_tree.dart';

import '../../WidgetsV2/CustomAppBar.dart';
import '../../WidgetsV2/Helper.dart';
import '../../widgets/CustomSearchDropdownMenu.dart';
import 'MessageDetail.dart';
import 'NewMessage.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with TickerProviderStateMixin {
  TextEditingController txtSearchAll = new TextEditingController();

  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerMessage _controllerMessage = Get.put(ControllerMessage());
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  bool isLoadingMore = false;
  bool isLoading = true;
  bool isLoading1 = true;
  bool isLoading2 = true;
  bool isLoading3 = true;
  bool isFilterOpen = false;
  String appBarTitle = '';
  String folders = '';
  String parentNode1 = 'INBOX';
  String parentNode2 = '';
  String parentNode3 = '';
  SlidableController? slidableController;
  List<TreeNodeData> nodes = <TreeNodeData>[];
  EmailResponse? emailResponse;

  List<Widget> tabs = <Widget>[];
  TabController? _tabController;
  List<String> _emailList = []; //! List<String> olarak duzenlendir
  String selectedEmail = '';
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<String> _titleNotifier = ValueNotifier<String>('Tab 1');
  int _pageNumber = 1; // To track the current page
  int _pageSize = 20; // Items per page
  bool hasMoreData = true;
  List<String> titles = ['trash', 'sent', 'inbox', 'all'];

  List<String> titlesDrop = [
    'WEREWS',
    'WESREWS',
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      getMessageByUserIdDeleted();
      getMessageByUserIdSent();
      getMessageByUserIdReceived();
      getMessageByUserIdAll();
      await getUserEmail();
      await getMailFolders(_emailList.first);

      _scrollController.addListener(() async {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          // Load next page when at the bottom
          setState(() {
            isLoadingMore = true;
          });
          await getUserMails(loadMore: true);
          setState(() {
            isLoadingMore = false;
          });
        }
      });
      setState(() {
        isLoading = false;
      });

      // _tabController.index = 2;
      // _tabController.addListener(() {
      //   setState(() {
      //     appBarTitle = titles[_tabController.index];
      //   });
      // });
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    tabs = <Widget>[
      RotatedBox(
          quarterTurns: 1,
          child: Container(
            height: 15,
            child: Tab(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/icon/delete.png',
                      width: 20, height: 20),
                  SizedBox(width: 5),
                  Text(AppLocalizations.of(context)!.trash),
                ],
              ),
            ),
          )),
      RotatedBox(
          quarterTurns: 1,
          child: Container(
            height: 15,
            child: Tab(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/icon/send.png',
                      width: 20, height: 20),
                  SizedBox(width: 5),
                  Text(AppLocalizations.of(context)!.sent),
                ],
              ),
            ),
          )),
      RotatedBox(
          quarterTurns: 1,
          child: Container(
            height: 15,
            child: Tab(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/icon/inbox.png',
                      width: 20, height: 20),
                  SizedBox(width: 5),
                  Text(AppLocalizations.of(context)!.inbox),
                ],
              ),
            ),
          )),
      RotatedBox(
        quarterTurns: 1,
        child: Container(
          height: 15,
          child: Tab(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/icon/letter.png',
                    width: 20, height: 20),
                SizedBox(width: 5),
                Text(AppLocalizations.of(context)!.all),
              ],
            ),
          ),
        ),
      ),
    ];
    _tabController = new TabController(vsync: this, length: tabs.length);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  getUserMails({bool loadMore = false}) async {
    print('**///**0');
    if (hasMoreData) {
      print('**///**1');
      // Build folder path based on parent nodes
      setState(() {
        folders = parentNode1;
      });
      if (parentNode2.isNotEmpty) {
        setState(() {
          folders += '/$parentNode2';
        });
      }
      if (parentNode3.isNotEmpty) {
        setState(() {
          folders += '/$parentNode3';
        });
      }

      try {
        // Fetch emails from the server
        EmailResponse emailResponsee = await _controllerMessage.GetMails(
          _controllerDB.headers(),
          UserEmail: selectedEmail != '' ? selectedEmail : _emailList.first,
          folderName: folders,
          pageNumber: _pageNumber,
          pageSize: _pageSize,
        );

        print('**///**2' + emailResponsee.result!.length.toString());

        // Check if there are no more emails to load
        if (emailResponsee.result!.isEmpty) {
          hasMoreData = false; // No more data to load
        } else {
          setState(() {
            if (loadMore) {
              // Append new results to the existing email list
              emailResponse!.result!.addAll(emailResponsee.result!);
              _pageNumber++; // Increment page number for the next fetch
            } else {
              // Replace the list with new data on the first load
              print('girdiiiiiiiiiiiii');
              emailResponse = emailResponsee;
            }
          });
        }
      } catch (e) {
        // Handle any errors if needed
        print('Error fetching emails: $e');
      } finally {}
    }
  }

  getMessageByUserIdAll() async {
    await _controllerMessage.GetMessageByUserIdAll(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        Page: 0,
        Size: 999,
        Type: 0);
    setState(() {
      isLoading = false;
    });
  }

  getMessageByUserIdReceived() async {
    await _controllerMessage.GetMessageByUserIdReceived(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        Page: 0,
        Size: 999,
        Type: 1);
    setState(() {
      isLoading1 = false;
    });
  }

  getMessageByUserIdSent() async {
    await _controllerMessage.GetMessageByUserIdSent(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        Page: 0,
        Size: 999,
        Type: 2);

    setState(() {
      isLoading2 = false;
    });
  }

  getMessageByUserIdDeleted() async {
    await _controllerMessage.GetMessageByUserIdDeleted(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        Page: 0,
        Size: 999,
        Type: 3);
    setState(() {
      isLoading3 = false;
    });
  }

  getUserEmail() async {
    var emailList = await _controllerMessage.GetUserEmails(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!);

    // Access the 'Result' field from the response
    EmailList resultEmails = emailList;
    setState(() {
      _emailList = resultEmails.result!;
    });
    print('step11111111');
    await getUserMails();
  }

  getMailFolders(String selectedMail) async {
    setState(() {
      isLoading = true;
    });
    var emailList = await _controllerMessage.GetMailFolders(
        _controllerDB.headers(),
        UserEmail: selectedMail,
        UserId: _controllerDB.user.value!.result!.id!,
        folderName: '');
    FolderListModel resultEmails = emailList;
    List<Folder> folders = resultEmails.result!;
    setState(() {
      nodes = _buildTreeNodes(folders, 'nochild');
    });
    setState(() {
      isLoading = false;
    });
  }

  List<TreeNodeData> _buildTreeNodes(List<Folder> folders, String parent) {
    return folders.map((folder) {
      print('parenttt:: ' + parent);
      return TreeNodeData(
          title: folder.name!,
          children: folder.subFolders!.isNotEmpty
              ? _buildTreeNodes(folder.subFolders!,
                  folder.name ?? 'noparent') // Recursively build child nodes
              : [],
          expaned: false,
          extra: parent,
          checked: false);
    }).toList();
  }

  deleteMessage(int MessageId) {
    _controllerMessage.DeleteMessage(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!, MessageId: MessageId)
        .then((value) {
      if (value) {
        _controllerMessage.GetMessageByUserIdAll(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            Page: 0,
            Size: 999,
            Type: 0);
        _controllerMessage.GetMessageByUserIdSent(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            Page: 0,
            Size: 999,
            Type: 2);
        _controllerMessage.GetMessageByUserIdReceived(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            Page: 0,
            Size: 999,
            Type: 0);
        _controllerMessage.GetMessageByUserIdDeleted(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            Page: 0,
            Size: 999,
            Type: 2);
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final titlesMap = {
      'all': AppLocalizations.of(context)!.all,
      'sent': AppLocalizations.of(context)!.sent,
      'trash': AppLocalizations.of(context)!.trash,
      'inbox': AppLocalizations.of(context)!.inbox,
    };

    final title = appBarTitle.isNotEmpty
        ? (titlesMap[appBarTitle] ?? AppLocalizations.of(context)!.digiPost)
        : AppLocalizations.of(context)!.digiPost;
    return GetBuilder<ControllerMessage>(
      builder: (_) => Scaffold(
          key: _scaffoldKey,
          endDrawer: Container(
            width: MediaQuery.of(context).size.width / 1.5,
            child: Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.digiPost,
                showNotification: false,
              ),
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomSearchDropDownMenu(
                        fillColor: Colors.white,
                        //!labelHeader:

                        /* selectedEmail == ''
                            ? _emailList.first
                            : selectedEmail, */

                        list: _emailList,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedEmail = newValue;
                            parentNode1 = 'INBOX';
                            parentNode2 = '';
                            parentNode3 = '';
                          });
                          await getMailFolders(selectedEmail);
                          await getUserMails();
                        },
                        error: 'Error',
                        labelIcon: Icons.info,
                        labelIconExist: true,
                      ),
                    ),
                    isLoading
                        ? CustomLoadingCircle()
                        : TreeView(
                            data: nodes,
                            lazy: false,
                            showActions: false,
                            showCheckBox: false,
                            showFilter: true,
                            append: (parent) {
                              return TreeNodeData(
                                title: 'Appended',
                                expaned: true,
                                checked: true,
                                children: [],
                              );
                            },
                            onExpand: (node) async {
                              print('onExpand');
                              emailResponse!.result!.clear();
                              if (node.extra == 'nochild') {
                                setState(() {
                                  parentNode2 = '';
                                  parentNode3 = '';
                                  parentNode1 = node.title;
                                });
                              } else if (node.extra == parentNode1) {
                                setState(() {
                                  parentNode2 = node.title;
                                  parentNode3 = '';
                                });
                              } else if (node.extra == parentNode2) {
                                setState(() {
                                  parentNode3 = node.title;
                                });
                              }
                              await getUserMails();
                            },
                            onTap: (node) async {
                              //  emailResponse.result.clear();
                              //   if (node.extra == 'nochild') {
                              //     setState(() {
                              //       parentNode2 = '';
                              //       parentNode3 = '';
                              //       parentNode1 = node.title;
                              //     });
                              //   } else if (node.extra == parentNode1) {
                              //     setState(() {
                              //       parentNode2 = node.title;
                              //       parentNode3 = '';
                              //     });
                              //   } else if (node.extra == parentNode2) {
                              //     setState(() {
                              //       parentNode3 = node.title;
                              //     });
                              //   }
                              //   await getUserMails();
                              //await getMails(node.title);
                            },
                            onCollapse: (node) {
                              print('onCollapse');
                            },
                            onAppend: (node, parent) {
                              print('onAppend');
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: CustomAppBarWithSearch(
              title: title,
              isHomePage: true,
              isMessagePage: true,
              onChanged: (searchtext) {
                print(searchtext);
                setState(() {
                  txtSearchAll.text = searchtext;
                  txtSearchDeleted.text = searchtext;
                  txtSearchReceived.text = searchtext;
                  txtSearchSent.text = searchtext;
                });
              },
              openFilterFunction: () {
                setState(() {
                  _openEndDrawer();
                });
              },
              openBoardFunction: () {
                _openEndDrawer();
              }),
          body: isLoading || isLoading1 || isLoading2 || isLoading3
              ? CustomLoadingCircle()
              : Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.10),
                      width: MediaQuery.of(context).size.width,
                      height: Get.height,
                      child: Column(children: [
                        // isFilterOpen
                        //     ? Row(
                        //         children: [
                        //           SizedBox(
                        //             width: 15,
                        //           ),
                        //           Container(
                        //             height: 35,
                        //             decoration: BoxDecoration(
                        //                 color: Colors.black.withOpacity(0.2),
                        //                 borderRadius: BorderRadius.all(
                        //                     Radius.circular(20))),
                        //             child: TabBar(
                        //               isScrollable: true,
                        //               unselectedLabelColor: Colors.grey,
                        //               indicatorSize: TabBarIndicatorSize.tab,
                        //               labelColor:
                        //                   Get.theme.secondaryHeaderColor,
                        //               indicator: new BubbleTabIndicator(
                        //                 indicatorHeight: 35.0,
                        //                 indicatorColor: Colors.white,
                        //                 tabBarIndicatorSize:
                        //                     TabBarIndicatorSize.label,
                        //                 // Other flags
                        //                 //  indicatorRadius: 1,
                        //                 //insets: EdgeInsets.all(1),
                        //                 padding: EdgeInsets.all(1),
                        //               ),
                        //               tabs: tabs,
                        //               controller: _tabController,
                        //             ),
                        //           ),
                        //           Spacer()
                        //         ],
                        //       )
                        //     : Container(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: HexColor('#f4f5f7'),
                              ),
                              child: MessageWidget(context),
                              // TabBarView(
                              //     controller: _tabController,
                              //     dragStartBehavior: DragStartBehavior.down,
                              //     children: [
                              //       TabBarAllMessageWidget(context),
                              //       TabBarReceivedMessageWidget(context),
                              //       TabBarSentMessageWidget(context),
                              //       TabBarDeletedMessageWidget(context),
                              //     ]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? Get.height * 0.15
                          : Get.height * 0.2,
                      right: MediaQuery.of(context).size.width * 0.05,
                      child: FloatingActionButton.extended(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        heroTag: "MessagePage",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NewMessage(
                                type: 0,
                                selectedMail: selectedEmail != ''
                                    ? selectedEmail
                                    : _emailList.first,
                              ),
                            ),
                          );
                        },
                        backgroundColor: Get.theme.primaryColor,
                        icon: Icon(
                          Icons.mail_outlined,
                          color: primaryYellowColor,
                        ),
                        /*    Image.asset(
                          'assets/images/icon/newMail.png',
                          height: Get.height / 35,
                          width: Get.height / 35,
                        ), */
                        label: Text(
                          AppLocalizations.of(context)!
                              .newMail, // Your label text here
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryYellowColor, // Adjust as necessary
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }

  Widget MessageWidget(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: Get.height * 0.75,
                child: emailResponse == null
                    ? CircularProgressIndicator()
                    : ListView.builder(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: emailResponse!.result!.length ?? 0,
                        itemBuilder: (ctx, i) {
                          EmailResult msg = emailResponse!.result![i];
                          return MessageListItemNew(context, msg);
                        },
                      ),
              ),
              if (isLoadingMore)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget TabBarAllMessageWidget(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filterAllMessage.length ?? 0,
                    itemBuilder: (ctx, i) {
                      MessageList msg = filterAllMessage[i];
                      return MessageListItem(context, msg);
                    }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MessageList> get filterAllMessage {
    List<MessageList> tempList =
        _controllerMessage.getAll.value!.result!.messageList!;
    String srch = txtSearchAll.text.toLowerCase();
    if (srch != "") {
      tempList = tempList
          .where((e) =>
                  e.messageSubject!.toLowerCase().contains(srch) ||
                  e.fromUserNameAndSurname!.toLowerCase().contains(srch)
              //e.messageText == null ? true : e.messageText.toLowerCase().contains(srch)
              //todo: messageText arama bakılacak
              )
          .toList();
    }
    return tempList ?? [];
  }

  Future<void> deleteMessageFunc(EmailResult messageList) async {
    await deleteMessage(messageList.id!);
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)!.deleted,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
  }

  void handleDelete(BuildContext context, EmailResult msg) {
    deleteMessageFunc(msg);
  }

  void replyMessage(BuildContext context, EmailDetailResponse msg) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => NewMessage(
                  type: 2,
                  messageList: msg,
                  selectedMail:
                      selectedEmail != '' ? selectedEmail : _emailList.first,
                )));
  }

  void replyAllMessage(BuildContext context, EmailDetailResponse msg) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => NewMessage(
                  type: 2,
                  messageList: msg,
                  selectedMail:
                      selectedEmail != '' ? selectedEmail : _emailList.first,
                )));
  }

  void forwardMessage(BuildContext context, EmailDetailResponse msg) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => NewMessage(
                  type: 1,
                  messageList: msg,
                  selectedMail:
                      selectedEmail != '' ? selectedEmail : _emailList.first,
                )));
  }

  Slidable MessageListItemNew(BuildContext context, EmailResult msg) {
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          SlidableAction(
            onPressed: (context) => handleDelete(context, msg),
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // SlidableAction(
          //   // An action can be bigger than the others.
          //   onPressed: (context) => replyMessage(context, msg),
          //   backgroundColor: const Color(0xFF7BC043),
          //   foregroundColor: Colors.white,
          //   icon: Icons.reply,
          //   label: '',
          // ),
          // SlidableAction(
          //   onPressed: (context) => replyAllMessage(context, msg),
          //   backgroundColor: const Color(0xFF0392CF),
          //   foregroundColor: Colors.white,
          //   icon: Icons.reply_all,
          //   label: '',
          // ),
          // SlidableAction(
          //   onPressed: (context) => forwardMessage(context, msg),
          //   backgroundColor: Color(0xFF21B7CA),
          //   foregroundColor: Colors.white,
          //   icon: Icons.forward,
          //   label: '',
          // ),
        ],
      ),

      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MessageDetail(
                    messageList: msg,
                    mail:
                        selectedEmail != '' ? selectedEmail : _emailList.first,
                    id: msg.id,
                    folder: folders,
                    selectedMail:
                        selectedEmail != '' ? selectedEmail : _emailList.first,
                  )));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //       boxShadow: standartCardShadow(),
                  //       borderRadius: BorderRadius.circular(30)),
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(30),
                  //     child: Image.network(
                  //       msg.subMessageList.isBlank
                  //           ? msg.fromUserPhotoPath ?? ""
                  //           : msg.subMessageList.first.fromUserPhotoPath ?? "",
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              msg.from!.name ?? "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            Spacer(),
                            Text(DateFormat.yMMMd()
                                .format(DateTime.parse(msg.date.toString()))),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 0.0),
                                child: Text(
                                  msg.subject ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                removeAllHtmlTags((msg.body).toString()),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            )
          ],
        ),
      ),
    );
  }

  Slidable MessageListItem(BuildContext context, MessageList msg) {
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          // SlidableAction(
          //   onPressed: (context) => handleDelete(context, msg),
          //   backgroundColor: Color(0xFFFE4A49),
          //   foregroundColor: Colors.white,
          //   icon: Icons.delete,
          //   label: '',
          // ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // SlidableAction(
          //   // An action can be bigger than the others.
          //   onPressed: (context) => replyMessage(context, msg),
          //   backgroundColor: const Color(0xFF7BC043),
          //   foregroundColor: Colors.white,
          //   icon: Icons.reply,
          //   label: '',
          // ),
          // SlidableAction(
          //   onPressed: (context) => replyAllMessage(context, msg),
          //   backgroundColor: const Color(0xFF0392CF),
          //   foregroundColor: Colors.white,
          //   icon: Icons.reply_all,
          //   label: '',
          // ),
          // SlidableAction(
          //   onPressed: (context) => forwardMessage(context, msg),
          //   backgroundColor: Color(0xFF21B7CA),
          //   foregroundColor: Colors.white,
          //   icon: Icons.forward,
          //   label: '',
          // ),
        ],
      ),

      child: InkWell(
        onTap: () {
          // Navigator.of(context).push(MaterialPageRoute(
          //     builder: (context) => MessageDetail(
          //           messageList: msg,
          //         )));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        boxShadow: standartCardShadow(),
                        borderRadius: BorderRadius.circular(30)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        msg.subMessageList.isBlank!
                            ? msg.fromUserPhotoPath ?? ""
                            : msg.subMessageList!.first.fromUserPhotoPath ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                msg.subMessageList.isBlank!
                                    ? msg.fromUserNameAndSurname!
                                    : msg.subMessageList!.first
                                        .fromUserNameAndSurname!,
                                style: TextStyle(
                                    fontWeight: msg.subMessageList.isBlank!
                                        ? msg.isSeen!
                                            ? FontWeight.w300
                                            : FontWeight.w600
                                        : msg.subMessageList!.first.isSeen!
                                            ? FontWeight.w300
                                            : FontWeight.w600,
                                    fontSize: 16),
                              ),
                              Spacer(),
                              Text(DateFormat.yMMMd().format(DateTime.now()) ==
                                      DateFormat.yMMMd().format(DateTime.parse(
                                          msg.subMessageList!.isBlank!
                                              ? msg.createDate!
                                              : msg.subMessageList!.first
                                                  .createDate!))
                                  ? DateFormat.Hm(AppLocalizations.of(context)!.date).format(DateTime.parse(msg
                                          .subMessageList!.isBlank!
                                      ? msg.createDate!
                                      : msg.subMessageList!.first.createDate!))
                                  : DateFormat.MMMMd(AppLocalizations.of(context)!.date)
                                      .format(DateTime.parse(msg.subMessageList!.isBlank! ? msg.createDate! : msg.subMessageList!.first.createDate!))),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Text(
                                    msg.subMessageList!.isBlank!
                                        ? msg.messageSubject ?? ""
                                        : msg.subMessageList!.first
                                                .messageSubject ??
                                            "",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: msg.subMessageList!.isBlank!
                                          ? msg.isSeen!
                                              ? FontWeight.w300
                                              : FontWeight.w600
                                          : msg.subMessageList!.first.isSeen!
                                              ? FontWeight.w300
                                              : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  removeAllHtmlTags(
                                      (msg.subMessageList!.isBlank!
                                              ? msg.messageText
                                              : msg.subMessageList!.first
                                                  .messageText)
                                          .toString()),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider()
          ],
        ),
      ),
    );
  }

  TextEditingController txtSearchReceived = new TextEditingController();
  Widget TabBarReceivedMessageWidget(BuildContext context) {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Expanded(
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(horizontal: 20),
        //         child: Container(
        //           height: 45,
        //           margin: EdgeInsets.only(top: 15),
        //           decoration: BoxDecoration(
        //               boxShadow: standartCardShadow(),
        //               borderRadius: BorderRadius.circular(45)),
        //           child: CustomTextField(
        //             prefixIcon: Icon(Icons.search),
        //             hint: AppLocalizations.of(context).search,
        //             controller: txtSearchReceived,
        //             onChanged: (val) {
        //               setState(() {});
        //             },
        //           ),
        //         ),
        //       ),
        //     ),
        //     Container(
        //       margin: EdgeInsets.only(top: 15, right: 20),
        //       child: PopupMenuButton(
        //           child: Center(
        //               child: Icon(
        //             Icons.more_vert,
        //             color: Colors.black,
        //             size: 27,
        //           )),
        //           itemBuilder: (context) => [
        //                 PopupMenuItem(
        //                   child: Text(AppLocalizations.of(context).newGroup),
        //                   value: 1,
        //                 ),
        //                 PopupMenuItem(
        //                   child:
        //                       Text(AppLocalizations.of(context).newPublicGroup),
        //                   value: 2,
        //                 ),
        //                 PopupMenuItem(
        //                   child: Text(AppLocalizations.of(context).settings),
        //                   value: 3,
        //                 )
        //               ]),
        //     )
        //   ],
        // ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filterReceived.length ?? 0,
                    itemBuilder: (ctx, i) {
                      MessageList msg = filterReceived[i];

                      return MessageListItem(context, msg);
                    }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MessageList> get filterReceived {
    List<MessageList> tempList =
        _controllerMessage.getReceived.value!.result!.messageList!;
    String srch = txtSearchReceived.text.toLowerCase();
    if (srch != "") {
      tempList = tempList
          .where((e) =>
                  e.messageSubject!.toLowerCase().contains(srch) ||
                  e.fromUserNameAndSurname!.toLowerCase().contains(srch)
              //e.messageText == null ? true : e.messageText.toLowerCase().contains(srch)
              //todo: messageText arama bakılacak
              )
          .toList();
    }
    return tempList ?? [];
  }

  TextEditingController txtSearchSent = new TextEditingController();
  Widget TabBarSentMessageWidget(BuildContext context) {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Expanded(
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(horizontal: 20),
        //         child: Container(
        //           height: 45,
        //           margin: EdgeInsets.only(top: 15),
        //           decoration: BoxDecoration(
        //               boxShadow: standartCardShadow(),
        //               borderRadius: BorderRadius.circular(45)),
        //           child: CustomTextField(
        //             prefixIcon: Icon(Icons.search),
        //             hint: AppLocalizations.of(context).search,
        //             controller: txtSearchSent,
        //             onChanged: (val) {
        //               setState(() {});
        //             },
        //           ),
        //         ),
        //       ),
        //     ),
        //     Container(
        //       margin: EdgeInsets.only(top: 15, right: 20),
        //       child: PopupMenuButton(
        //           child: Center(
        //               child: Icon(
        //             Icons.more_vert,
        //             color: Colors.black,
        //             size: 27,
        //           )),
        //           itemBuilder: (context) => [
        //                 PopupMenuItem(
        //                   child: Text(AppLocalizations.of(context).newGroup),
        //                   value: 1,
        //                 ),
        //                 PopupMenuItem(
        //                   child:
        //                       Text(AppLocalizations.of(context).newPublicGroup),
        //                   value: 2,
        //                 ),
        //                 PopupMenuItem(
        //                   child: Text(AppLocalizations.of(context).settings),
        //                   value: 3,
        //                 )
        //               ]),
        //     )
        //   ],
        // ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filterSentMessage.length ?? 0,
                    itemBuilder: (ctx, i) {
                      MessageList msg = filterSentMessage[i];

                      return MessageListItem(context, msg);
                    }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MessageList> get filterSentMessage {
    List<MessageList> tempList =
        _controllerMessage.getSent.value!.result!.messageList!;
    String srch = txtSearchSent.text.toLowerCase();
    if (srch != "") {
      tempList = tempList
          .where((e) =>
                  e.messageSubject!.toLowerCase().contains(srch) ||
                  e.fromUserNameAndSurname!.toLowerCase().contains(srch)
              //e.messageText == null ? true : e.messageText.toLowerCase().contains(srch)
              //todo: messageText arama bakılacak
              )
          .toList();
    }
    return tempList ?? [];
  }

  TextEditingController txtSearchDeleted = new TextEditingController();
  Widget TabBarDeletedMessageWidget(BuildContext context) {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Expanded(
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(horizontal: 20),
        //         child: Container(
        //           height: 45,
        //           margin: EdgeInsets.only(top: 15),
        //           decoration: BoxDecoration(
        //               boxShadow: standartCardShadow(),
        //               borderRadius: BorderRadius.circular(45)),
        //           child: CustomTextField(
        //             prefixIcon: Icon(Icons.search),
        //             hint: AppLocalizations.of(context).search,
        //             controller: txtSearchDeleted,
        //             onChanged: (val) {
        //               setState(() {});
        //             },
        //           ),
        //         ),
        //       ),
        //     ),
        //     Container(
        //       margin: EdgeInsets.only(top: 15, right: 20),
        //       child: PopupMenuButton(
        //           child: Center(
        //               child: Icon(
        //             Icons.more_vert,
        //             color: Colors.black,
        //             size: 27,
        //           )),
        //           itemBuilder: (context) => [
        //                 PopupMenuItem(
        //                   child: Text(AppLocalizations.of(context).newGroup),
        //                   value: 1,
        //                 ),
        //                 PopupMenuItem(
        //                   child:
        //                       Text(AppLocalizations.of(context).newPublicGroup),
        //                   value: 2,
        //                 ),
        //                 PopupMenuItem(
        //                   child: Text(AppLocalizations.of(context).settings),
        //                   value: 3,
        //                 )
        //               ]),
        //     )
        //   ],
        // ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filterDeletedMessage.length ?? 0,
                    itemBuilder: (ctx, i) {
                      MessageList msg = filterDeletedMessage[i];

                      return MessageListItem(context, msg);
                    }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MessageList> get filterDeletedMessage {
    List<MessageList> tempList =
        _controllerMessage.getDelete.value!.result!.messageList!;
    String srch = txtSearchDeleted.text.toLowerCase();
    if (srch != "") {
      tempList = tempList
          .where((e) =>
                  e.messageSubject!.toLowerCase().contains(srch) ||
                  e.fromUserNameAndSurname!.toLowerCase().contains(srch)
              //e.messageText == null ? true : e.messageText.toLowerCase().contains(srch)
              //todo: messageText arama bakılacak
              )
          .toList();
    }
    return tempList ?? [];
  }
}

void doNothing(BuildContext context) {}
