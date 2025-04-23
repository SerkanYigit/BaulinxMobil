import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Login/rememberMeControl.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/l10n/l10n.dart';
import 'package:undede/widgets/CustomDialogWidgets.dart';
import 'package:undede/widgets/FloatingNavigationBar.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Custom/CustomLoadingCircle.dart';
import '../../widgets/buildBottomNavigationBar.dart';

class SignInPageV2 extends StatefulWidget {
  @override
  _SignInPageV2State createState() => _SignInPageV2State();
}

class _SignInPageV2State extends State<SignInPageV2> {
  final ControllerDB c = Get.put(ControllerDB());
  final ControllerLocal cL = Get.put(ControllerLocal());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String mail = "";
  String password = "";
  bool isLoading = false;
  bool _passwordVisible = false;
  bool _rememberMe = true;

  Color themeColor =
      Get.theme.primaryColor; //! buttoncolor yerine primarycolor kullanildi
  final _formKey = GlobalKey<FormState>();

  TextStyle buttonStyle = TextStyle(color: Colors.white, fontSize: 16);

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        await signIn();
      },
      child: Container(
        width: Get.width - 20,
        height: Get.height * 0.05, //! 40 yerine Get.height * 0.07 kullanildi
        decoration: BoxDecoration(
            color: themeColor, borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.signInSignInButtonText,
            style: TextStyle(
                fontSize: 17, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () {
          c.updateLoginState(Login.SignUp);
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.signInAskNoAccount + " ",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 107, 12, 202)),
              ),
              Text(
                AppLocalizations.of(context)!.signInSignUp,
                style: TextStyle(
                    fontSize: 8, color: const Color.fromARGB(255, 218, 14, 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    if (emailController.text.isEmpty) {
      setState(() {
        isLoading = true;
      });
      if (kDebugMode) {
        await c
            .signIn(
                mail:
                    'oezgoer@bsabau.de', //! 'musterburo@gmail.com', //'damimüsteri@gmail.com',
                password: 'holding_4344', //! '1234', //'1234',
                rememberMe: true,
                langCode: AppLocalizations.of(context)!.localeName)
            .then((value) {
          if (value != null) {
            _showMyDialog(AppLocalizations.of(context)!.incorrectregistration,
                value.toString());
          } else {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => FloatingNavigationBar(),
                /*  BuildBottomNavigationBar(
                        page: 0,
                      ) */
              ),
            );
          }
        });
      }

      setState(() {
        isLoading = false;
      });
      return;
    }
    print(_formKey.currentState!.validate());
    if (_formKey.currentState!.validate()) {
      print("rememberMe" + _rememberMe.toString());
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      await c
          .signIn(
              mail: emailController.text,
              password: passwordController.text,
              rememberMe: _rememberMe,
              langCode: AppLocalizations.of(context)!.localeName)
          .then((value) {
        if (value != null) {
          _showMyDialog(AppLocalizations.of(context)!.incorrectregistration,
              value.toString());
        } else {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (BuildContext context) => FloatingNavigationBar(),
              /* BuildBottomNavigationBar(
                      page: 0,
                    ), */
            ),
          );
        }
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  Future signInRememberMe(List<String> signInfo) async {
    setState(() {
      isLoading = true;
    });

    await c
        .signIn(
            mail: signInfo[0],
            password: signInfo[1],
            rememberMe: _rememberMe,
            langCode: AppLocalizations.of(context)!.localeName)
        .then((value) {
      if (value != null) {
        _showMyDialog(AppLocalizations.of(context)!.incorrectregistration,
            value.toString());
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Widget _createAccountLabel() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: Container(
              height: 30,
              child: Row(
                children: [
                  SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        }),
                  ),
                  Text(AppLocalizations.of(context)!.signInRememberMe,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: InkWell(
              onTap: () {
                c.updateLoginState(Login.Forgot);
              },
              child: Container(
                child: Text(
                  AppLocalizations.of(context)!.signInForgotPassword,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _passwordVisible = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<String> temp = await RememberMeControl.instance.getRemember("login");
      if (temp.isNotEmpty) {
        signInRememberMe(temp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment
              .bottomCenter, // 10% of the width, so there are ten blinds.
          colors: <Color>[
            Colors.white.withOpacity(0.99),
            Colors.grey[200]!,
          ], // red to yellow
          tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: isLoading
              ? Text("signin2") //CustomLoadingCircle()
              : SingleChildScrollView(
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 50),
                              height: isTablet ? 150 : 75,
                              width: isTablet ? 150 : 75,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/app_logo/logonew.png"))),
                            ),
                            Form(
                              key: _formKey,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0, top: 50.0),
                                child: Container(
                                  height: Get.height * 0.47,
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 20, 15, 20),
                                    child: Column(
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                        .hello +
                                                    ",",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 30,
                                                    fontFamily: 'TTNorms',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .signInToKeepContinue,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[700],
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                              validator: (value) {
                                                validateEmail(value!);
                                                return null;
                                              },
                                            ),
                                            SizedBox(
                                              height: 30,
                                            ),
                                            TextFormField(
                                                decoration: InputDecoration(
                                                  errorStyle:
                                                      TextStyle(height: 0),
                                                  border:
                                                      UnderlineInputBorder(),
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
                                                    fontWeight:
                                                        FontWeight.w500),
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                controller: passwordController,
                                                validator: (value) {
                                                  value = value!.trim();
                                                  if (value.isEmpty) {
                                                    return "";
                                                  }

                                                  return null;
                                                }),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            _createAccountLabel(),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            _submitButton(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _registerButton(),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        /*Positioned(
                      top: 100 - (75 / 2),
                      left: (Get.width - 75) / 2,
                     child: Container(
                        width: 75,
                        height: 75,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(75),
                          color: Colors.grey.shade300,
                        ),
                        child: Image.asset(
                          "assets/images/app_logo/vir2ell-logo.png",
                          width: 55,
                          height: 55,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),*/
                      ],
                    ),
                  ),
                )),
    );
  }

  Future<void>? _showMyDialog(String title, String content) {
    return CustomDialogs().errorDialog(
        context: context,
        title: title,
        desc: content,
        cancelOnTap: () {},
        btnCancelText: AppLocalizations.of(context)!.okey);
  }

  String validateEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value.isEmpty || !regex.hasMatch(value))
      return 'Enter a valid email address';
    else
      return ''; //! null yerine '' kullanildi
  }
}
