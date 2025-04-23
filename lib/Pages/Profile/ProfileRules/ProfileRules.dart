import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Pages/Profile/ProfileRules/AddRules.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Common/GetDefinedRoleListResult.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../../Custom/CustomLoadingCircle.dart';

class ProfileRules extends StatefulWidget {
  const ProfileRules({Key? key}) : super(key: key);

  @override
  _ProfileRulesState createState() => _ProfileRulesState();
}

class _ProfileRulesState extends State<ProfileRules>
    with TickerProviderStateMixin {
  bool loading = true;
  List<bool> listExpand =<bool>[];
  List<AnimationController> _controller = <AnimationController>[];
  TextEditingController _controllerRules = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDefinedRoleList();
  }

  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());
  void getDefinedRoleList() async {
    await _controllerCommon.GetDefinedRoleList(_controllerDB.headers())
        .then((value) {});
    setState(() {
      loading = false;
    });
  }

  Future<void> deleteDefinedRole(int DefinedRoleId) async {
    await _controllerCommon.DeleteDefinedRole(_controllerDB.headers(),
            DefinedRoleId: DefinedRoleId)
        .then((value) {
      if (!value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.deleted,
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
  Widget build(BuildContext context) {
    return GetBuilder<ControllerCommon>(
        builder: (_) => Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.rules,
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Container(
                                          height: 45,
                                          margin: EdgeInsets.only(top: 15),
                                          decoration: BoxDecoration(
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(45)),
                                          child: CustomTextField(
                                            prefixIcon: Icon(Icons.search),
                                            hint: AppLocalizations.of(context)!
                                                .search,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      ListView.builder(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: _controllerCommon
                                              .getDefinedRole
                                              .value!
                                              .result!
                                              .length,
                                          itemBuilder: (ctx, index) {
                                            listExpand.add(false);
                                            _controller
                                                .add(new AnimationController(
                                              vsync: this,
                                              duration:
                                                  Duration(milliseconds: 300),
                                              upperBound: 0.5,
                                            ));
                                            return buildContactCard(
                                                index,
                                                _controllerCommon
                                                    .getDefinedRole.value!,
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
                          SizedBox(
                            height: 75,
                          ),
                        ]),
                      ),
                      Positioned(
                        bottom: 100,
                        right: 5,
                        child: FloatingActionButton(
                          heroTag: "ProfileRules",
                          onPressed: () {
                            Get.to(() => AddRules());
                          },
                          backgroundColor: Get.theme.colorScheme.primary,
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  )
                : CustomLoadingCircle()));
  }

  Widget buildContactCard(int index,
      GetDefinedRoleListResult getDefinedRoleListResult, BuildContext context) {
    return Material(
      color: Get.theme.scaffoldBackgroundColor,
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
                      child: Row(children: [
                        Icon(
                          getDefinedRoleListResult.result![index].moduleType ==
                                  14
                              ? Icons.dashboard_customize
                              : Icons.task,
                          color: Get.theme.primaryColor,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(getDefinedRoleListResult.result![index].name!),
                        Spacer(),
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
                  //color: Color(0xFFe3d5a4),
                  ),
              child: Container(
                child: Row(
                  children: [
                    Spacer(),
                    contactMoreIcon(() {
                      Get.to(() => AddRules(
                            Id: getDefinedRoleListResult.result![index].id!,
                            Name: getDefinedRoleListResult.result![index].name!,
                            ModuleType: getDefinedRoleListResult
                                .result![index].moduleType!,
                          ));
                    }, Icons.edit, index),
                    SizedBox(
                      width: 5,
                    ),
                    contactMoreIcon(() async {
                      await deleteDefinedRole(
                          getDefinedRoleListResult.result![index].id!);
                      getDefinedRoleList();
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
}
