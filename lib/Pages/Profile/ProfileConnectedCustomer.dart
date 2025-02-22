import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';

import 'package:undede/Custom/showToast.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';

class ProfileConnectedCustomer extends StatefulWidget {
  @override
  _ProfileConnectedCustomerState createState() =>
      _ProfileConnectedCustomerState();
}

class _ProfileConnectedCustomerState extends State<ProfileConnectedCustomer>
    with TickerProviderStateMixin {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerUser _controllerUser = Get.put(ControllerUser());
  bool loading = true;
  List<bool> listExpand = <bool>[];
  final List<DropdownMenuItem> dmiPersons = [];
  int? selectedPerson;
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controllerUser.GetMyPersons(_controllerDB.headers(),
              userId: _controllerDB.user.value!.result!.id!)
          .then((value) async {
        value.result!.forEach((element) {
          dmiPersons.add(DropdownMenuItem(
            child: Text(element.userName!),
            value: element.userId,
            key: Key(element.userName!),
          ));
        });
        selectedPerson = value.result!.first.userId!;
        GetConnected(value.result!.first.userId!);
      });

      loading = false;
      setState(() {});
    });
  }

  Future<void> GetConnected(int selected) async {
    await _controllerUser.GetConnectedCustomer(_controllerDB.headers(),
        ownerUserId: _controllerDB.user.value!.result!.id!, userId: selected);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      builder: (ControllerUser controller) {
        return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(title: AppLocalizations.of(context)!.personal),
          body: Stack(
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
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                    height: 45,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              boxShadow: standartCardShadow(),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 11),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: Get.width,
                                                  height: 23,
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton(
                                                      menuMaxHeight: 350,
                                                      value: selectedPerson,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                          fontFamily: 'TTNorms',
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      icon: Icon(
                                                        Icons.expand_more,
                                                        color: Colors.black,
                                                      ),
                                                      items: dmiPersons,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedPerson =
                                                              value;
                                                        });
                                                        GetConnected(value);
                                                      },
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                SizedBox(
                                  height: 15,
                                ),
                                Divider(
                                  color: Colors.grey,
                                  thickness: 0.3,
                                ),
                                Container(
                                  height: _controllerUser.getConnectedResult
                                              .result?.length ==
                                          null
                                      ? 0.0
                                      : 45.0 *
                                          _controllerUser.getConnectedResult
                                              .result!.length,
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _controllerUser
                                                  .getConnectedResult
                                                  .result
                                                  ?.length ==
                                              null
                                          ? 0
                                          : _controllerUser.getConnectedResult
                                              .result!.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _controllerUser
                                                          .getConnectedResult
                                                          .result![index]
                                                          .customerName!,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (_controllerUser
                                                              .getConnectedResult
                                                              .result![index]
                                                              .id !=
                                                          0) {
                                                        _controllerUser.DeleteConnectedCustomer(
                                                                _controllerDB
                                                                    .headers(),
                                                                id: _controllerUser
                                                                    .getConnectedResult
                                                                    .result![
                                                                        index]
                                                                    .id)
                                                            .then((value) {
                                                          GetConnected(
                                                              selectedPerson!);
                                                        });
                                                      } else {
                                                        _controllerUser.AddConnectedCustomer(
                                                                _controllerDB
                                                                    .headers(),
                                                                userId:
                                                                    selectedPerson,
                                                                customerId: _controllerUser
                                                                    .getConnectedResult
                                                                    .result![
                                                                        index]
                                                                    .customerId)
                                                            .then((value) {
                                                          GetConnected(
                                                              selectedPerson!);
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black)),
                                                      child: _controllerUser
                                                                  .getConnectedResult
                                                                  .result![
                                                                      index]
                                                                  .id !=
                                                              0
                                                          ? Icon(
                                                              Icons.check,
                                                              color: Get.theme
                                                                  .primaryColor,
                                                            )
                                                          : Container(),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                                SizedBox(
                                  height: 100,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    heroTag: "ProfileConnectedCustomer",
                    onPressed: () async {
                      if (_textEditingController.text.isBlank!) {
                        showErrorToast(
                            AppLocalizations.of(context)!.cannotbeblank);
                        return;
                      }

                      Navigator.pop(context);
                    },
                    child: Icon(Icons.save),
                  ))
            ],
          ),
        );
      },
    );
  }
}
