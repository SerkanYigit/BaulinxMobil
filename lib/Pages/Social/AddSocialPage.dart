import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerCommon.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerSocial.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

bool selected1 = false;
bool selected2 = true;
bool status1 = false;

class AddSocialPage extends StatefulWidget {
  @override
  _AddSocialPageState createState() => _AddSocialPageState();
}

class _AddSocialPageState extends State<AddSocialPage> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerSocial _controllerSocial = Get.put(ControllerSocial());
  ControllerCommon _controllerCommon = Get.put(ControllerCommon());

  int? _companyType;
  int? _companyCategoryId;
  TextEditingController _feedController = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  bool isLoading = true;
  final List<DropdownMenuItem> cboCommonGroups = [];
  int? selectedCategoryId;
  List<DropdownMenuItem> cboType = [];
  int? selectedType;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      cboType = [
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.posts),
          value: 1,
          key: Key(AppLocalizations.of(context)!.posts),
        ),
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)!.questions),
          value: 2,
          key: Key(AppLocalizations.of(context)!.questions),
        ),
      ];
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> InsertOrUpdateData(String feed, int categoryId, int type) async {
    await _controllerSocial.AddOrUpdateSocial(_controllerDB.headers(),
            Id: 0,
            UserId: _controllerDB.user.value!.result!.id,
            Type: type,
            CategoryId: categoryId,
            Feed: feed)
        .then((value) async {
      setState(() {});
    });
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.addSocial),
      floatingActionButton: isLoading
          ? Container()
          : Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: FloatingActionButton(
                heroTag: "addSocial",
                onPressed: () async {
                  if (_feedController.text.isNotEmpty) {
                    if (formKey.currentState!.validate()) {
                      await InsertOrUpdateData(_feedController.text,
                          selectedCategoryId!, selectedType!);
                      await _controllerSocial.GetSocialPost(
                        _controllerDB.headers(),
                        UserId: _controllerDB.user.value!.result!.id,
                      );
                      await _controllerSocial.GetSocialQuestion(
                        _controllerDB.headers(),
                        UserId: _controllerDB.user.value!.result!.id,
                      );
                      formKey.currentState!.save();
                      Navigator.pop(context);
                    }
                  }
                },
                child: Icon(Icons.done),
              ),
            ),
      //resizeToAvoidBottomInset: false,

      body: isLoading
          ? CustomLoadingCircle()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/create.png"),
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 45,
                              decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(15)),
                              child: SearchableDropdown.single(
                                color: Colors.white,
                                height: 45,
                                displayClearIcon: false,
                                menuBackgroundColor:
                                    Get.theme.scaffoldBackgroundColor,
                                items: cboType,
                                value: selectedType,
                                icon: Icon(Icons.expand_more),
                                hint: AppLocalizations.of(context)!.selectType,
                                searchHint:
                                    AppLocalizations.of(context)!.selectType,
                                onChanged: (value) async {
                                  setState(() {
                                    selectedType = value;
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
                            Container(
                              height: 45,
                              decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(15)),
                              child: SearchableDropdown.single(
                                color: Colors.white,
                                height: 45,
                                displayClearIcon: false,
                                menuBackgroundColor:
                                    Get.theme.scaffoldBackgroundColor,
                                items: cboCommonGroups,
                                value: selectedCategoryId,
                                icon: Icon(Icons.expand_more),
                                hint: AppLocalizations.of(context)!
                                    .selectCategory,
                                searchHint: AppLocalizations.of(context)!
                                    .selectCategory,
                                onChanged: (value) async {
                                  setState(() {
                                    selectedCategoryId = value;
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
                            Container(
                              decoration: BoxDecoration(
                                  boxShadow: standartCardShadow(),
                                  borderRadius: BorderRadius.circular(15)),
                              child: CustomTextField(
                                controller: _feedController,
                                validator: (value) {
                                  value = value.trim();
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }

                                  return null;
                                },
                                label: "Add Feed",
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
