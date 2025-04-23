import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController adressController = TextEditingController();

  PhoneNumber number = PhoneNumber(isoCode: 'DE');
  TextEditingController phoneController = TextEditingController();
  String? phoneNumber;
  //resim alma
  final ImagePicker _imagePicker = ImagePicker();
  XFile? profileImage;
  dynamic _pickImage;
  String base64Image = "";

  @override
  void initState() {
    nameController =
        TextEditingController(text: _controllerDB.user.value!.result!.name);
    surnameController =
        TextEditingController(text: _controllerDB.user.value!.result!.surname);
    mailController = TextEditingController(
        text: _controllerDB.user.value!.result!.mailAddress);
    print('_controllerDB' + _controllerDB.user.value!.result!.phone.toString());
    phoneController =
        TextEditingController(text: _controllerDB.user.value!.result!.phone);
    adressController =
        TextEditingController(text: _controllerDB.user.value!.result!.address);

    super.initState();
  }

  updateUserProfile(String Name, String Surname, String MailAddress,
      String PhoneNumber, String Address) {
    print('phoneNumber: $PhoneNumber');
    _controllerDB.updateUserProfile(_controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
        Name: Name,
        Surname: Surname,
        MailAddress: MailAddress,
        PhoneNumber: PhoneNumber,
        Address: Address,
        Photo: base64Image == "" ? null : base64Image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.profileUpdate,
        showNotification: false,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: Get.width,
                color: Get.theme.scaffoldBackgroundColor,
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
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage: NetworkImage(
                                    _controllerDB.user.value!.result!.photo!),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          CustomTextField(
                            hint: AppLocalizations.of(context)!.signUpName,
                            controller: nameController,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            hint: AppLocalizations.of(context)!.signUpSurname,
                            controller: surnameController,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextField(
                            hint: AppLocalizations.of(context)!.signInEmailLabel,
                            controller: mailController,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            height: 45,
                            decoration: BoxDecoration(
                              boxShadow: standartCardShadow(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
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
                                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                hintText: AppLocalizations.of(context)!.phoneNumber,
                                hintStyle: Get.theme.inputDecorationTheme.hintStyle,
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              onChanged: (value) {
                                setState(() {

                                  phoneNumber = value; // Update phone number with the text field value
                                });
                              },
                            ),
                          ),

                          SizedBox(height: 15),
                          Container(
                            height: 135,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
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
                                    left: 15, bottom: 11, top: 11, right: 15),
                                hintText: AppLocalizations.of(context)!.adress,
                                hintStyle:
                                    Get.theme.inputDecorationTheme.hintStyle,
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
                await updateUserProfile(
                  nameController.text,
                  surnameController.text,
                  mailController.text,
                  phoneNumber!,
                  adressController.text,
                );
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
                      fontWeight: FontWeight.w500),
                )),
              ),
            ),
            SizedBox(
              height: WidgetsBinding.instance.window.viewInsets.bottom == 0
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
