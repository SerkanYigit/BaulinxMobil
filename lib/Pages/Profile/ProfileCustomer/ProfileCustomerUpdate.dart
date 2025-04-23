import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/User/UpdatedCustomerResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../../Custom/CustomLoadingCircle.dart';

class ProfileCustomerUpdate extends StatefulWidget {
  const ProfileCustomerUpdate({Key? key}) : super(key: key);

  @override
  _ProfileCustomerUpdateState createState() => _ProfileCustomerUpdateState();
}

class _ProfileCustomerUpdateState extends State<ProfileCustomerUpdate> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerUser _controllerUser = Get.put(ControllerUser());
  TextEditingController titleController = TextEditingController();
  TextEditingController ibanController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  TextEditingController companyDetailsController = TextEditingController();
  TextEditingController companyNumberController = TextEditingController();
  TextEditingController customerNumberController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();

  PhoneNumber? number;
  TextEditingController phoneController = TextEditingController();
  String? phoneNumber;
  //resim alma
  final ImagePicker _imagePicker = ImagePicker();
  XFile? profileImage;
  dynamic _pickImage;
  String base64Image = "";
  bool isLoading = true;
  UpdatedCustomerResult _customerResult = UpdatedCustomerResult(hasError: false);
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      number =
          PhoneNumber(isoCode: AppLocalizations.of(context)!.date.toUpperCase());
      await updateUser();
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  Future<void> updateUser() async {
    await _controllerUser.GetCustomer(_controllerDB.headers(),
            Id: _controllerDB.user.value!.result!.customerId)
        .then((value) {
      _customerResult = value;
      titleController =
          TextEditingController(text: value.companyResult!.title ?? "");
      ibanController =
          TextEditingController(text: value.companyResult!.iban ?? "");
      mailController =
          TextEditingController(text: value.companyResult!.mail ?? "");
      phoneController =
          TextEditingController(text: value.companyResult!.phone ?? "");
      adressController =
          TextEditingController(text: value.companyResult!.address ?? "");
      companyNumberController =
          TextEditingController(text: value.companyResult!.companyNumber ?? "");
      taxNumberController =
          TextEditingController(text: value.companyResult!.taxNumber ?? "");
      customerNumberController =
          TextEditingController(text: value.companyResult!.customerNumber ?? "");
      companyDetailsController =
          TextEditingController(text: value.companyResult!.companyDetail ?? "");
      setState(() {});
    });
  }

  Future<void> updateUserProfile(
      String title,
      String address,
      String mail,
      String iban,
      String phone,
      String companyNumber,
      String customerNumber,
      String taxNumber,
      String companyDetail) async {
    await _controllerUser.UpdateCustomer(_controllerDB.headers(),
        Id: _controllerDB.user.value!.result!.customerId,
        Title: title,
        Address: address,
        Mail: mail,
        Iban: iban,
        Phone: phone,
        CompanyNumber: companyNumber,
        CustomerNumber: customerNumber,
        TaxNumber: taxNumber,
        Photo: base64Image == "" ? null : base64Image,
        CompanyDetail: companyDetail);
    await updateUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.profileUpdate,
        showNotification: false,
      ),
      body: isLoading
          ? CustomLoadingCircle()
          : Container(
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
                          color: Get.theme.scaffoldBackgroundColor,
                        ),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showPicker(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: standartCardShadow()),
                                    child: !base64Image.isNullOrBlank!
                                        ? Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(60),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: MemoryImage(
                                                        base64Decode(
                                                            base64Image)))),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: _customerResult
                                                .companyResult!.photo!,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(60),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: CustomTextField(
                                    hint:
                                        AppLocalizations.of(context)!.signUpName,
                                    controller: titleController,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: CustomTextField(
                                    hint: AppLocalizations.of(context)!
                                        .signInEmailLabel,
                                    controller: mailController,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: CustomTextField(
                                    hint: "Iban",
                                    controller: ibanController,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: CustomTextField(
                                    hint: "Tax Number",
                                    controller: taxNumberController,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: CustomTextField(
                                    hint: "Customer Number  ",
                                    controller: customerNumberController,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: CustomTextField(
                                    hint: "Company Number",
                                    controller: companyNumberController,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: InternationalPhoneNumberInput(
                                    spaceBetweenSelectorAndTextField: 0,
                                    inputDecoration: new InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 11,
                                          top: 11,
                                          right: 15),
                                      hintText: AppLocalizations.of(context)! 
                                          .phoneNumber,
                                      hintStyle: Get
                                          .theme.inputDecorationTheme.hintStyle,
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    onInputChanged: (PhoneNumber number) {
                                      print(number.phoneNumber);
                                      phoneNumber = number.phoneNumber;
                                    },
                                    selectorConfig: SelectorConfig(
                                      setSelectorButtonAsPrefixIcon: true,
                                      trailingSpace: false,
                                      selectorType:
                                          PhoneInputSelectorType.BOTTOM_SHEET,
                                      leadingPadding: 20,
                                    ),
                                    ignoreBlank: true,
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    selectorTextStyle:
                                        TextStyle(color: Colors.black),
                                    initialValue: number,
                                    textFieldController: phoneController,
                                    formatInput: false,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            signed: true, decimal: true),
                                    inputBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.elliptical(10, 10))),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: adressController,
                                    onChanged: (a) {
                                      setState(() {});
                                    },
                                    //  controller: adressController,
                                    decoration: new InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 11,
                                          top: 11,
                                          right: 15),
                                      hintText:
                                          AppLocalizations.of(context)!.adress,
                                      hintStyle: Get
                                          .theme.inputDecorationTheme.hintStyle,
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, minLines: 4,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Container(
                                  height: 135,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: companyDetailsController,
                                    onChanged: (a) {
                                      setState(() {});
                                    },
                                    //  controller: adressController,
                                    decoration: new InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 11,
                                          top: 11,
                                          right: 15),
                                      hintText: AppLocalizations.of(context)!
                                          .companyDetail,
                                      hintStyle: Get
                                          .theme.inputDecorationTheme.hintStyle,
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, minLines: 4,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (phoneController.text[0] == "0") {
                        showErrorToast(
                            AppLocalizations.of(context)!.phoneNumberCannot);
                        return;
                      }
                      await updateUserProfile(
                          titleController.text,
                          adressController.text,
                          mailController.text,
                          ibanController.text,
                          phoneController.text,
                          companyNumberController.text,
                          customerNumberController.text,
                          taxNumberController.text,
                          companyDetailsController.text);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: standartCardShadow(),
                      ),
                      child: Center(
                          child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w400),
                      )),
                    ),
                  ),
                  SizedBox(
                    height:
                        WidgetsBinding.instance.window.viewInsets.bottom == 0
                            ? 100
                            : 5,
                  )
                ],
              ),
            ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                      ),
                      title:
                          new Text(AppLocalizations.of(context)!.photoLibrary),
                      onTap: () {
                        _onImageButtonPressed(ImageSource.gallery,
                            context: context);

                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                    ),
                    title: new Text(AppLocalizations.of(context)!.camera),
                    onTap: () {
                      _onImageButtonPressed(ImageSource.camera,
                          context: context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      setState(() {
        profileImage = pickedFile;
        List<int> imageBytes = File(profileImage!.path).readAsBytesSync();
        base64Image = base64Encode(imageBytes);
      });
      print('aaa');
    } catch (e) {
      setState(() {
        _pickImage = e;
      });
    }
  }
}
