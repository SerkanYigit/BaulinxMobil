import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/WidgetsV2/CustomAppBarWithSearch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Controller/ControllerChatNew.dart';
import '../../Controller/ControllerCommon.dart';
import '../../Controller/ControllerDB.dart';
import '../../Controller/ControllerUser.dart';
import '../../Custom/CustomLoadingCircle.dart';
import '../../Custom/DebouncerForSearch.dart';
import '../../Services/User/UserDB.dart';
import '../../WidgetsV2/Helper.dart';
import '../../WidgetsV2/customCardShadow.dart';
import '../../WidgetsV2/customTextField.dart';
import '../../model/Chat/GetUserListUser.dart';
import '../../model/Contact/AdminCustomer.dart';
import '../../widgets/MyCircularProgress.dart';

class CustomerPage extends StatefulWidget {
  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  String name = 'Customer';

  TextEditingController _searchController = TextEditingController();
  TextEditingController _searchAllActive = TextEditingController();
  TextEditingController _commonInviteMail = TextEditingController();
  TextEditingController _commonInvite = TextEditingController();
  TextEditingController textEditingController = new TextEditingController();

  ControllerUser _controllerUser = ControllerUser();
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  ControllerChatNew _controllerChatNew = Get.put(ControllerChatNew());
  List<int> SelectedUsersId = [];
  String searchText = '';

  final _debouncer = DebouncerForSearch();

  UserDB userDB = new UserDB();

  ControllerDB _controllerDB = Get.put(ControllerDB());

  AdminCustomerResult adminCustomer = new AdminCustomerResult(hasError: false);

  bool searchTile = false;

  AnimationController? controller;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _loading = true;
      });
      getUserList();
      await userDB.GetAdminCustomer(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id,
        administrationId: _controllerDB.user.value!.result!.administrationId,
      ).then((value) {
        adminCustomer = value;
      });
      setState(() {
        _loading = false;
      });
    });
  }

  getUserList({withoutSetState = false}) async {
    await _controllerChatNew.GetUserList(
        _controllerDB.headers(), _controllerDB.user.value!.result!.id!);
    if (!withoutSetState) {
      setState(() {});
    }
  }

  CommonInvite(List<int> TargetUserIdList, String CommentText, String Email,
      String Language) async {
    await _controllerCommon.CommonInvite(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            TargetUserIdList: TargetUserIdList,
            CommentText: CommentText,
            Email: Email,
            Language: Language)
        .then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.invitationSent,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithSearch(
          title: AppLocalizations.of(context)!.partner,
          isPartnerPage: true,
          onChanged: (name) {
            setState(() {
              searchText = name;
            });
          },
          openFilterFunction: () {},
          openBoardFunction: () {}),
      body: _loading
          ? CustomLoadingCircle()
          : Container(
              color: Get.theme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    Container(
                      width: Get.width * 0.88,
                      height: 45,
                      decoration: BoxDecoration(
                          boxShadow: standartCardShadow(),
                          borderRadius: BorderRadius.circular(15)),
                      child: CustomTextField(
                          controller: _searchController,
                          hint: AppLocalizations.of(context)!.search,
                          prefixIcon: Icon(Icons.search),
                          onChanged: (String value) {
                            setState(() {
                              searchText = value;
                            });
                          }),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: FilterCustomer().length,
                        itemBuilder: ((context, index) {
                          Result cstmr = FilterCustomer()[index];
                          return CustomCard(
                              name: cstmr.fullName!,
                              title: cstmr.status.toString(),
                              profession: '2024.10.10',
                              adress: cstmr.fullName!,
                              city: cstmr.status!,
                              language: cstmr.fullName!,
                              profilePictureUrl: cstmr.photo!,
                              phoneNumber: cstmr.mail!,
                              customerName: cstmr.fullName!,
                              isCustomer: cstmr.customerId ==
                                  _controllerDB.user.value!.result!.id!,
                              isMyPerson: cstmr.isMyPerson!,
                              onPressed: () async {
                                await CommonInvite(
                                    SelectedUsersId,
                                    _commonInvite.text,
                                    "",
                                    AppLocalizations.of(context)!.date);
                                await _controllerChatNew.GetUserList(
                                    _controllerDB.headers(),
                                    _controllerDB.user.value!.result!.id!);
                                setState(() {
                                  SelectedUsersId.clear();
                                  _commonInvite.clear();
                                });
                                Get.back();
                              });
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Stack _buildInvite(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
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
                        controller: _searchAllActive,
                        prefixIcon: Icon(Icons.search),
                        hint: AppLocalizations.of(context)!.search,
                        onChanged: (asd) async {
                          await _debouncer.run(() {
                            setState(() {});
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15, right: 20),
                  child: PopupMenuButton(
                      onSelected: (i) {
                        _onAlertExternalIntive(context);
                      },
                      child: Center(
                          child: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                        size: 27,
                      )),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text(
                                  AppLocalizations.of(context)!.externalInvite),
                              value: 1,
                            ),
                          ]),
                )
              ],
            ),
          ],
        ),
        Positioned(
            bottom: 100,
            right: 5,
            child: FloatingActionButton(
              heroTag: "customerPageAdd",
              onPressed: () {},
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ))
      ],
    );
  }

  List<Result> FilterCustomer() {
    List<Result>? listFilterCustomer = searchText == ''
        ? _controllerChatNew.UserListRx?.value!.result!
            .where((element) => (element.isMyPerson == false &&
                element.customerId == _controllerDB.user.value!.result!.id))
            .toList()
        : _controllerChatNew.UserListRx?.value!.result;
    return listFilterCustomer!;
  }

  _onAlertExternalIntive(context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.inviteUsers,
                ),
                content: Container(
                  height: Get.height * 0.15,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _commonInviteMail,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.signInEmailLabel,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _commonInvite,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.inviteMessage,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      await CommonInvite([],
                          _commonInvite.text,
                          _commonInviteMail.text,
                          AppLocalizations.of(context)!.date);
                      await _controllerChatNew.GetUserList(
                          _controllerDB.headers(),
                          _controllerDB.user.value!.result!.id!);
                      _commonInvite.clear();
                      _commonInviteMail.clear();
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.invite,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }
}

class CustomCard extends StatelessWidget {
  final String? name;
  final String? profession;
  final String? adress;
  final String? city;
  final String? language;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? title;
  final String? customerName;
  final bool? isCustomer;
  final bool? isMyPerson;
  final Function? onPressed;

  CustomCard(
      {this.name,
      this.profession,
      this.adress,
      this.city,
      this.language,
      this.profilePictureUrl,
      this.phoneNumber,
      this.title,
      this.customerName,
      this.onPressed,
      this.isMyPerson,
      this.isCustomer = false});

  @override
  Widget build(BuildContext context) {
    String baseUrl = 'https://onlinefiles.dsplc.net//Content/UploadPhoto/User/';
    print('profilepicture : ' + baseUrl + profilePictureUrl!);
    return Stack(
      children: [
        Container(
          height: Get.height * 0.38,
          child: ClipPath(
            clipper: (isCustomer! || isMyPerson!) ? null : CustomCardClipper(),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              //elevation: 4,
              margin: EdgeInsets.all(24.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image(
                                  image: NetworkImage(profilePictureUrl!)),
                            )),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Text(
                              //     DateFormat('dd MMM yyyy').format(createDate)),
                            ],
                          ),
                        ),
                        // Column(
                        //   children: [
                        //     Icon(Icons.favorite_border),
                        //     SizedBox(height: 5),
                        //     Text('0'),
                        //   ],
                        // ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.black26,
                    ),
                    // Text(
                    //   customerName + 'asd',
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // Text(
                    //   title,
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ImageIcon(
                                    AssetImage('assets/images/icon/mail.png'),
                                    size: 25,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10),
                                  Chip(
                                    labelPadding: EdgeInsets.all(5),
                                    label: Text(phoneNumber!),
                                    backgroundColor:
                                        Get.theme.colorScheme.secondary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(children: [
                                ImageIcon(
                                  AssetImage('assets/images/icon/profile.png'),
                                  size: 25,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10),
                                Chip(
                                  labelPadding: EdgeInsets.all(5),
                                  label: Text(
                                    isCustomer!
                                        ? AppLocalizations.of(context)!.customer
                                        : isMyPerson!
                                            ? AppLocalizations.of(context)!
                                                .personal
                                            : AppLocalizations.of(context)!
                                                .private,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: isCustomer!
                                      ? Get.theme.colorScheme
                                          .onSecondaryContainer
                                      : isMyPerson!
                                          ? Get.theme.colorScheme
                                              .onPrimaryContainer
                                          : Get.theme.colorScheme
                                              .onTertiaryContainer,
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Text(
                    //   qualificationStatus,
                    //   style: TextStyle(
                    //     color: Colors.blue,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: Container(
            width: (isCustomer! || isMyPerson!) ? 70 : 52,
            height: (isCustomer! || isMyPerson!) ? 70 : 52,
            decoration: (isCustomer! || isMyPerson!)
                ? BoxDecoration()
                : BoxDecoration(
                    color: HexColor('#27d1df'),
                    shape: BoxShape.circle,
                  ),
            child: (isCustomer! || isMyPerson!)
                ? Container()
                : IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => onPressed,
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }
}

class CustomCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 70);
    path.arcToPoint(
      Offset(size.width - 70, size.height),
      radius: Radius.circular(20),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
