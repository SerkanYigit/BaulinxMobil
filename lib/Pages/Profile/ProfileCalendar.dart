import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

class ProfileCalendar extends StatefulWidget {
  const ProfileCalendar({Key? key}) : super(key: key);

  @override
  _ProfileCalendarState createState() => _ProfileCalendarState();
}

class _ProfileCalendarState extends State<ProfileCalendar>
    with TickerProviderStateMixin {
  bool loading = true;
  List<bool> listExpand = <bool>[];
  List<AnimationController> _controller = <AnimationController>[];

  @override
  void initState() {
    super.initState();
    getCalenderByUserId();
  }

  ControllerDB _controllerDB = Get.put(ControllerDB());
  TextEditingController _addNewCalendar = TextEditingController();
  TextEditingController _updateCalendar = TextEditingController();

  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  GetCalendarByUserIdResult _getCalendarByUserIdResult =
      GetCalendarByUserIdResult(hasError: false);

  postAddCalendar(int Id, String CalendarName) async {
    await _controllerCalendar.AddOrUpdateCalendar(_controllerDB.headers(),
            Id: Id,
            UserId: _controllerDB.user.value!.result!.id!,
            CalanderName: CalendarName)
        .then((value) => {});
    getCalenderByUserId();
    _controllerCalendar.refreshCalendar = true;
    _controllerCalendar.update();
  }

  getCalenderByUserId() async {
    await _controllerCalendar.GetCalendarByUserId(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id!)
        .then((value) => {_getCalendarByUserIdResult = value});
    setState(() {
      loading = false;
    });
  }

  deleteCalendar(int Id) async {
    await _controllerCalendar.DeleteCalendar(_controllerDB.headers(), Id)
        .then((value) => {
              if (value = true)
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.deleted,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    //backgroundColor: Colors.red,
                    //textColor: Colors.white,
                    fontSize: 16.0)
            });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.calendarList,
          showNotification: false,
        ),
        body: !loading
            ? Stack(
                children: [
                  Container(
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
                              color: Get.theme.scaffoldBackgroundColor,
                            ),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      height: 45,
                                      margin: EdgeInsets.only(top: 15),
                                      decoration: BoxDecoration(
                                          boxShadow: standartCardShadow(),
                                          borderRadius:
                                              BorderRadius.circular(45)),
                                      child: CustomTextField(
                                        prefixIcon: Icon(Icons.search),
                                        hint:
                                            AppLocalizations.of(context)!.search,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  ListView.builder(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _getCalendarByUserIdResult
                                          .result!.length,
                                      itemBuilder: (ctx, index) {
                                        listExpand.add(false);

                                        _controller.add(new AnimationController(
                                          vsync: this,
                                          duration: Duration(milliseconds: 300),
                                          upperBound: 0.5,
                                        ));
                                        return buildContactCard(
                                            index,
                                            _getCalendarByUserIdResult
                                                .result![index],
                                            context);
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
                  Positioned(
                    bottom: 100,
                    right: 5,
                    child: FloatingActionButton(
                      heroTag: "ProfileCalendar",
                      onPressed: () {
                        _onAlertWithCustomContentPressed(context);
                      },
                      backgroundColor: Get.theme.primaryColor,
                      child: Icon(Icons.add_chart_outlined),
                    ),
                  ),
                ],
              )
            : CustomLoadingCircle());
  }

  Widget buildContactCard(
      int index, Result _getCalendarByUserId, BuildContext context) {
    return Material(
      color: Color(0xFFF0F7F7),
      child: InkWell(
        onTap: () {
          setState(() {
            if (listExpand[index]) {
              _controller[index]..reverse(from: 0.5);
            } else {
              _controller[index]..forward(from: 0.0);
            }
            listExpand[index] = !listExpand[index];
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                //boxShadow: standartCardShadow(),
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Get.theme.scaffoldBackgroundColor,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getCalendarByUserId.title!),
                            RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_controller[index]),
                              child: Icon(Icons.expand_more),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: listExpand[index] ? 40 : 0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: listExpand[index] ? 3 : 0),
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
              ),
              child: Container(
                child: Row(
                  children: [
                    Spacer(),
                    contactMoreIcon(() {
                      _onAlertWithCustomContentPressed2(_getCalendarByUserId.id!,
                          _getCalendarByUserId.title!, context);
                    }, Icons.edit, index),
                    SizedBox(
                      width: 5,
                    ),
                    contactMoreIcon(() async {
                      await deleteCalendar(_getCalendarByUserId.id!);
                      await getCalenderByUserId();
                    }, Icons.delete, index),
                  ],
                ),
              ),
            ),
            Container(
              width: Get.width,
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector contactMoreIcon(
      Function runOnTap, IconData iconData, int index) {
    return GestureDetector(
      onTap: () {
        runOnTap();
      },
      child: AnimatedOpacity(
        opacity: listExpand[index] ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Get.theme.colorScheme.primary,
            boxShadow: standartCardShadow(),
          ),
          padding: EdgeInsets.all(7),
          child: AnimatedOpacity(
            opacity: listExpand[index] ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child:
                Icon(iconData, size: 19, color: Get.theme.secondaryHeaderColor),
          ),
        ),
      ),
    );
  }

  _onAlertWithCustomContentPressed(context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(AppLocalizations.of(context)!.newCalendar),
                content: Container(
                  height: Get.height * 0.1,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _addNewCalendar,
                        decoration: InputDecoration(
                          icon: Icon(Icons.today),
                          labelText: AppLocalizations.of(context)!.calendarName,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      int i = 0;

                      if (_addNewCalendar.text.isBlank!) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.cannotbeblank,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Get.theme.colorScheme.primary,
                            textColor: Get.theme.primaryColor,
                            fontSize: 16.0);
                        return;
                      }

                      await postAddCalendar(0, _addNewCalendar.text);
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }

  _onAlertWithCustomContentPressed2(int Id, String calendarName, context) {
    showDialog(
      context: context,
      builder: (context) {
        _updateCalendar = TextEditingController(text: calendarName);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(AppLocalizations.of(context)!.updateCalendar),
                content: Container(
                  height: Get.height * 0.1,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _updateCalendar,
                        decoration: InputDecoration(
                          icon: Icon(Icons.today),
                          labelText: AppLocalizations.of(context)!.calendarName,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      int i = 0;

                      if (_updateCalendar.text.isBlank!) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.cannotbeblank,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Get.theme.colorScheme.primary,
                            textColor: Get.theme.secondaryHeaderColor,
                            fontSize: 16.0);
                        return;
                      }

                      await postAddCalendar(Id, _updateCalendar.text);
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.change,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }
}
