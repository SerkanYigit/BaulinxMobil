import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Login/rememberMeControl.dart';
import 'package:undede/widgets/CustomDialogWidgets.dart';

import '../../Custom/CustomLoadingCircle.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final ControllerDB c = Get.put(ControllerDB());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String mail = "";
  String password = "";
  bool isLoading = false;

  Color themeColor = Get.theme.colorScheme.secondary;
  final _formKey = GlobalKey<FormState>();

  bool rememberMe = false;
  TextStyle buttonStyle = TextStyle(color: Colors.white, fontSize: 16);

  Widget _entryField({String? title, bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        style: TextStyle(color: Colors.black, fontSize: 17),
        validator: (value) {
          if (value!.isEmpty) {
            return "Doldurunuz";
          } else {
            if (!isPassword && !value.isEmail) {
              return "Email formatına uygun değil";
            } else {
              return null;
            }
          }
        },
        onSaved: (value) {
          if (isPassword) {
            password = value!;
          } else {
            mail = value!;
          }
        },
        decoration: InputDecoration(
          labelText: title,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide(color: themeColor)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
        ),
        obscureText: isPassword,
        controller: isPassword ? emailController : passwordController,
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        await signIn();
      },
      child: Container(
        padding: EdgeInsets.only(top: 0, bottom: 0, left: 70, right: 70),
        decoration: BoxDecoration(
            color: themeColor, borderRadius: BorderRadius.circular(35)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Center(
            child: Text(
              "Hesabıma Giriş Yap",
              style: TextStyle(fontSize: 20),
            ),
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
                "Hesabın yok mu ?  ",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                "Kayıt ol",
                style: TextStyle(fontSize: 16, color: themeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      await c
          .signIn(mail: mail, password: password, rememberMe: true)
          .then((value) {
        if (value != null) {
          _showMyDialog("Hatalı Kayıt", value.toString());
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
        .signIn(mail: signInfo[0], password: signInfo[1], rememberMe: false)
        .then((value) {
      if (value != null) {
        _showMyDialog("Hatalı Kayıt", value.toString());
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Widget _createAccountLabel() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () {
              c.updateLoginState(Login.Forgot);
            },
            child: Container(
              child: Text(
                'Şifremi unuttum? ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _formKey,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(child: _entryField(title: "E-mail")),
            SizedBox(
              height: 10,
            ),
            Container(child: _entryField(title: "Şifre", isPassword: true)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<String> temp = await RememberMeControl.instance.getRemember("login");
      signInRememberMe(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: isLoading
            ? Text("signinpage") //CustomLoadingCircle()
            : SingleChildScrollView(
                child: Container(
                  height: height,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment(1.5, 1.2),
                              child: Image.asset(
                                "assets/images/Login/fill2.png",
                                height: 200,
                                width: Get.width,
                                fit: BoxFit.cover,
                                color: Get.theme.colorScheme.secondary,
                              ),
                            ),
                            Align(
                              alignment: Alignment(1.3, 1.3),
                              child: Image.asset(
                                "assets/images/Login/fill1.png",
                                height: 200,
                                width: Get.width,
                                fit: BoxFit.cover,
                                color: Get.theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              height: 130,
                            ),
                            Image.asset(
                              "assets/images/logo/logo_orj.png",
                              height: 80,
                              width: Get.width / 1.7,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _emailPasswordWidget(),
                            SizedBox(
                              height: 20,
                            ),
                            _submitButton(),
                            SizedBox(
                              height: 20,
                            ),
                            _createAccountLabel(),
                            SizedBox(
                              height: 20,
                            ),
                            _registerButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  Future<void>? _showMyDialog(String title, String content) {
    CustomDialogs().errorDialog(
        context: context,
        title: title,
        desc: content,
        cancelOnTap: () {},
        btnCancelText: "Tamam");
    return null;
/*
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.red,
                  ),
                )
              ],
            ),
            content: Text(content),
          );
        }).then((value) => {
      */
/*   setState(() {
        isLoading = false;
      })*/ /*

    });
*/
  }
}
