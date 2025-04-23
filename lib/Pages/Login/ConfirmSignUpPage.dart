import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/widgets/CustomDialogWidgets.dart';
import 'package:undede/widgets/GradientWidget.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Custom/CustomLoadingCircle.dart';

class ConfirmSignUpPage extends StatefulWidget {
  @override
  _ConfirmSignUpPageState createState() => _ConfirmSignUpPageState();
}

class _ConfirmSignUpPageState extends State<ConfirmSignUpPage> {
  final ControllerDB c = Get.put(ControllerDB());

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final companyNameController = TextEditingController();

  final pinController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordControllerCheck = TextEditingController();

  bool _passwordVisible = false;
  bool accept = false;
  String? mail;
  String? password;
  String? title;
  String? firstName;
  String? lastName;

  Color themeColor = Get.theme.colorScheme.secondary;
  Color background = Get.theme.colorScheme.surface;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool isEasy = false;
  TextStyle buttonStyle = TextStyle(color: Colors.white, fontSize: 16);
  void _launchURL() async {
    String? _url;
    if (AppLocalizations.of(context)!.language == "Türkçe") {
      _url = "https://vir2ell-office.com/LandingPage/tr-TR/Home/Agb";
    }
    if (AppLocalizations.of(context)!.language == "English") {
      _url = "https://vir2ell-office.com/LandingPage/en-US/Home/Agb";
    }
    if (AppLocalizations.of(context)!.language == "Sprache") {
      _url = "https://vir2ell-office.com/LandingPage/de-DE/Home/Agb";
    }

    if (!await launch(_url!)) throw 'Could not launch $_url';
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        c.updateLoginState(Login.PinCode);
      },
      child: Container(
        width: Get.width - 20,
        height: 50,
        decoration: BoxDecoration(
            color: themeColor, borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.signInSignUp,
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontFamily: 'TTNorms',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return Container(
      height: 45,
      child: Row(
        children: [
          SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
                value: accept,
                onChanged: (bool? value) {
                  setState(() {
                    accept = value!;
                  });
                }),
          ),
          SizedBox(
            width: 8,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: TextButton(
              onPressed: _launchURL,
              child: Text(AppLocalizations.of(context)!.signUpKVKK,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontFamily: 'TTNorms',
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _rememberMe() {
    return Container(
      child: Row(
        children: <Widget>[
          Checkbox(
            checkColor: themeColor,
            activeColor: Colors.white,
            onChanged: (value) {
              setState(() {
                rememberMe = !rememberMe;
              });
            },
            value: rememberMe,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                  text: 'Kullanım koşulları',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 15,    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AgreementPage()));
                    },
                  children: <TextSpan>[
                    TextSpan(
                      text: " ve ",
                      style: TextStyle(color: Colors.black, fontSize: 15, decoration: TextDecoration.none),
                    ),
                    TextSpan(
                        text: 'Kişisel verilerin korunması',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 15,    decoration: TextDecoration.underline,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    AgreementPage(isKVKK: true)));
                          }),
                    TextSpan(
                        text: " sözleşmelerini kabul ediyorum.",
                        style: TextStyle(color: Colors.black, fontSize: 15, decoration: TextDecoration.none))
                  ]),
            ),
          )
        ],
      ),
    );
  }*/

//Kullanıcı Sözleşmesi 'ni okudum, ve sözleşme şartlarını kabul ediyorum
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment
              .bottomCenter, // 10% of the width, so there are ten blinds.
          colors: <Color>[
            Colors.white.withValues(alpha: 0.99),
            Colors.grey[200]!,
          ], // red to yellow
          tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: isLoading
              ? Text("confirm") //CustomLoadingCircle()
              : SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 0.0),
                        child: Column(
                          children: [
                            Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/app_logo/logonew.png"))),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Form(
                              key: _formKey,
                              child: Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                  child: Column(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .signInSignUp,
                                              style: TextStyle(
                                                  fontSize: 33,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Container(
                                            height: 60,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: TextFormField(
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                        errorStyle: TextStyle(
                                                            height: 0),
                                                        border:
                                                            UnderlineInputBorder(),
                                                        hintText:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .companyName,
                                                        hintStyle: TextStyle(
                                                            fontSize: 21,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      style: TextStyle(
                                                          fontSize: 21,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      controller:
                                                          companyNameController,
                                                      validator: (value) {
                                                        value = value?.trim();
                                                        if (value!.isEmpty) {
                                                          return "";
                                                        }

                                                        return null;
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Container(
                                            height: 60,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                      bottom: BorderSide(
                                                          width: 1.0,
                                                          color: Colors.grey),
                                                    )),
                                                    child:
                                                        DropdownButton<String>(
                                                      underline: Container(),
                                                      hint: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .selectCompanyType,
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      style: TextStyle(
                                                          fontSize: 21,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      items: ["b", "c"]
                                                          .map((var e) {
                                                        return DropdownMenuItem(
                                                          value: e,
                                                          key: Key(e),
                                                          child: Text(
                                                            e,
                                                          ),
                                                        );
                                                      }).toList(),
                                                      value: null,
                                                      icon: Icon(
                                                          Icons.expand_more),
                                                      onChanged: (value) {},
                                                      isExpanded: true,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Container(
                                            height: 60,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: TextFormField(
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                        errorStyle: TextStyle(
                                                            height: 0),
                                                        border:
                                                            UnderlineInputBorder(),
                                                        hintText:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .signUpName,
                                                        hintStyle: TextStyle(
                                                            fontSize: 21,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      style: TextStyle(
                                                          fontSize: 21,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      controller:
                                                          nameController,
                                                      validator: (value) {
                                                        value = value!.trim();
                                                        if (value.isEmpty) {
                                                          return "";
                                                        }

                                                        return null;
                                                      }),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: TextFormField(
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                        errorStyle: TextStyle(
                                                            height: 0),
                                                        border:
                                                            UnderlineInputBorder(),
                                                        hintText:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .signUpSurname,
                                                        hintStyle: TextStyle(
                                                            fontSize: 21,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      style: TextStyle(
                                                          fontSize: 21,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      controller:
                                                          surnameController,
                                                      validator: (value) {
                                                        value = value!.trim();
                                                        if (value.isEmpty) {
                                                          return "";
                                                        }

                                                        return null;
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          TextFormField(
                                              decoration: InputDecoration(
                                                errorStyle:
                                                    TextStyle(height: 0),
                                                border: UnderlineInputBorder(),
                                                hintText: AppLocalizations.of(
                                                        context)!
                                                    .signInEmailLabel,
                                                hintStyle: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              style: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                              controller: emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) {
                                                value = value?.trim();
                                                if (value!.isEmpty) {
                                                  return "";
                                                }

                                                return null;
                                              }),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          TextFormField(
                                              decoration: InputDecoration(
                                                errorStyle:
                                                    TextStyle(height: 0),
                                                border: UnderlineInputBorder(),
                                                hintText: AppLocalizations.of(
                                                        context)!
                                                    .signInPasswordLabel,
                                                hintStyle: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _passwordVisible
                                                          ? Icons.visibility
                                                          : Icons
                                                              .visibility_off,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      // Update the state i.e. toogle the state of passwordVisible variable
                                                      setState(() {
                                                        _passwordVisible =
                                                            !_passwordVisible;
                                                      });
                                                    }),
                                              ),
                                              obscureText: !_passwordVisible,
                                              style: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                              keyboardType:
                                                  TextInputType.visiblePassword,
                                              controller: passwordController,
                                              validator: (value) {
                                                value = value?.trim();
                                                if (value!.isEmpty) {
                                                  return "";
                                                }

                                                return null;
                                              }),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          TextFormField(
                                              decoration: InputDecoration(
                                                errorStyle:
                                                    TextStyle(height: 0),
                                                border: UnderlineInputBorder(),
                                                hintText: AppLocalizations.of(
                                                        context)!
                                                    .confirm,
                                                hintStyle: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _passwordVisible
                                                          ? Icons.visibility
                                                          : Icons
                                                              .visibility_off,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      // Update the state i.e. toogle the state of passwordVisible variable
                                                      setState(() {
                                                        _passwordVisible =
                                                            !_passwordVisible;
                                                      });
                                                    }),
                                              ),
                                              obscureText: !_passwordVisible,
                                              style: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                              keyboardType:
                                                  TextInputType.visiblePassword,
                                              controller:
                                                  passwordControllerCheck,
                                              validator: (value) {
                                                value = value?.trim();
                                                if (value!.isEmpty) {
                                                  return "";
                                                }

                                                return null;
                                              }),
                                          SizedBox(
                                            height: 14,
                                          ),
                                          _createAccountLabel(),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          _submitButton(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
    );
  }

  Future signUp() async {
    if (_formKey.currentState!.validate()) {
      if (accept) {
        _formKey.currentState!.save();

        setState(() {
          isLoading = true;
        });
        if (passwordControllerCheck.text != passwordController.text) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.passwordsdonotmatch,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              //backgroundColor: Colors.red,
              //textColor: Colors.white,
              fontSize: 16.0);
          return;
        }
        await c
            .signUp(
          mail: emailController.text,
          password: passwordController.text,
          firstName: nameController.text,
          lastName: surnameController.text,
          rememberMe: true,
          regType: 1,
          title: "",
        )
            .then((value) {
          print("valuee= $value");
          _showMyDialog(AppLocalizations.of(context)!.incorrectregistration,
              value.toString(), context);
        });
        setState(() {
          isLoading = false;
        });
      } else {
        Get.showSnackbar(GetBar(
          message: AppLocalizations.of(context)!.pleaseConfirmtheAgreement,
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void>? _showMyDialog(
      String title, String content, BuildContext context) {
    CustomDialogs().errorDialog(
        context: context,
        title: title,
        desc: content,
        cancelOnTap: () {},
        btnCancelText: AppLocalizations.of(context)!.okey);
    return null;
  }
}
