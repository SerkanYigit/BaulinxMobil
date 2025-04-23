import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../../Custom/CustomLoadingCircle.dart';
import 'ProfileLabelAdd.dart';
import 'ProfileLabelUpdate.dart';

class ProfileLabel extends StatefulWidget {
  const ProfileLabel({Key? key}) : super(key: key);

  @override
  _ProfileLabelState createState() => _ProfileLabelState();
}

class _ProfileLabelState extends State<ProfileLabel>
    with TickerProviderStateMixin {
  bool loading = true;
  List<bool> listExpand = <bool>[];
  List<AnimationController> _controller = <AnimationController>[];

  @override
  void initState() {
    super.initState();
    getLabelByUserId();
  }

  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerLabel controllerLabel = Get.put(ControllerLabel());
  void getLabelByUserId() async {
    await controllerLabel.GetLabelByUserId(_controllerDB.headers(),
            Id: 0, UserId: _controllerDB.user.value!.result!.id, CustomerId: 0)
        .then((value) {});
    setState(() {
      loading = false;
    });
  }

  void deleteLabel(int LabelId) {
    controllerLabel.DeleteLabel(_controllerDB.headers(),
            LabelId: LabelId, UserId: _controllerDB.user.value!.result!.id)
        .then((value) {
      if (value)
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.deleted,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      getLabelByUserId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerLabel>(
        builder: (_) => Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.labels,
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
                                          itemCount: controllerLabel
                                              .getLabel.value!.result!.length,
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
                                                controllerLabel.getLabel.value!,
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
                          heroTag: "ProfileLabel",
                          onPressed: () {
                            Get.to(() => ProfileLabelAdd());
                          },
                          backgroundColor: Get.theme.colorScheme.primary,
                          child: Icon(Icons.new_label_outlined),
                        ),
                      ),
                    ],
                  )
                : CustomLoadingCircle()));
  }

  Widget buildContactCard(int index,
      GetLabelByUserIdResult getLabelByUserIdResult, BuildContext context) {
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
                          Icons.lens,
                          color: Color(int.parse(
                              controllerLabel.getLabel.value!.result![index].color!
                                  .replaceFirst('#', "FF"),
                              radix: 16)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                            controllerLabel.getLabel.value!.result![index].title!),
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
                color: Get.theme.scaffoldBackgroundColor,
              ),
              child: Container(
                child: Row(
                  children: [
                    Spacer(),
                    contactMoreIcon(() {
                      Get.to(() => ProfileLabelUpdate(
                            labelId:
                                controllerLabel.getLabel.value!.result![index].id!,
                            labelTitle: controllerLabel
                                .getLabel.value!.result![index].title!,
                            labelColor: controllerLabel
                                .getLabel.value!.result![index].color!
                                .replaceFirst('#', "FF"),
                          ));
                    }, Icons.edit, index),
                    SizedBox(
                      width: 5,
                    ),
                    contactMoreIcon(() {
                      setState(() {
                        deleteLabel(
                            controllerLabel.getLabel.value!.result![index].id!);
                      });
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
