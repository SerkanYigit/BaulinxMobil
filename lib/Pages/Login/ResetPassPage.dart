import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/landingPage.dart';
import 'package:undede/widgets/CustomDialogWidgets.dart';
import 'package:undede/widgets/GradientWidget.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Custom/CustomLoadingCircle.dart';

// ignore: must_be_immutable
class ResetPassPage extends StatefulWidget {
  String mail;

  ResetPassPage(this.mail);

  @override
  _ResetPassPageState createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  final ControllerDB c = Get.put(ControllerDB());

  String? pass;

  String? pass2;

  String? confirmCode;
  bool isLoading = false;

  Color themeColor = Get.theme.colorScheme.secondary;

  final _formKey = GlobalKey<FormState>();

  TextStyle buttonStyle = TextStyle(color: Colors.white, fontSize: 16);

  Widget _entryField(

   //! Function(String)? yerine FormFieldSetter<String>? kullanildi
   FormFieldSetter<String>?
     onSaved, 
    {
    String? title,
    TextInputType inputType = TextInputType.name,
    bool secure = true,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        keyboardType: inputType,
        obscureText: secure,
        onTap: () {},
        style: TextStyle(color: Colors.black, fontSize: 17),
        validator: (value) {
          if (value!.isEmpty) {
            return AppLocalizations.of(context)!.pleasefillin;
          } else {
            return null;
          }
        },
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: title,
          focusedBorder: UnderlineInputBorder(),
          border: UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          if (pass2 == pass) {
            setState(() {
              isLoading = true;
            });
            bool result =
                await c.forgotPasswordDone(widget.mail, confirmCode!, pass!);
            if (!result) {
              Get.showSnackbar(GetBar(
                message:
                    AppLocalizations.of(context)!.yourPasswordHasBeenChanged,
                duration: Duration(seconds: 3),
              ));
              Timer(Duration(seconds: 2), () {
                setState(() {
                  isLoading = false;
                });

                c.updateLoginState(Login.SignIn);

                Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => LandingPage(),
                        fullscreenDialog: true));
              });
            } else {
              setState(() {
                isLoading = false;
              });
              _showMyDialog(
                  AppLocalizations.of(context)!.theoperationfailed,
                  AppLocalizations.of(context)!
                      .makesureyouenteredtheconfirmationcodecorrectly);
            }
          } else {
            Get.showSnackbar(GetBar(
              message: AppLocalizations.of(context)!.passwordsdonotmatch,
              duration: Duration(seconds: 2),
            ));
          }
        }
      },
      child: Container(
        width: Get.width - 20,
        height: 40,
        decoration: BoxDecoration(
            color: themeColor, borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.changePassword,
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

  Widget _passAndConfirmWidget() {
    return Form(
      key: _formKey,
      child: Container(
        child: Column(
          children: [
            Container(
                child: _entryField((value) {
              confirmCode = value;
            },
                    title: AppLocalizations.of(context)!.confirmationcode,
                    inputType: TextInputType.number,
                    secure: false)),
            Container(
                child: _entryField((value) {
              pass = value;
            }, title: AppLocalizations.of(context)!.signInPasswordLabel)),
            Container(
                child: _entryField((value) {
              pass2 = value;
            }, title: AppLocalizations.of(context)!.newPasswordConfirmation)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: isLoading
            ? CustomLoadingCircle()
            : SingleChildScrollView(
                child: Container(
                  height: height,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(Icons.clear))),
                            SizedBox(
                              height: 0,
                            ),
                            Image.asset(
                              "assets/images/app_logo/logobeyaz.png",
                              color: themeColor,
                              width: 250,
                              height: 200,
                            ),
                            _infoText(),
                            SizedBox(
                              height: 30,
                            ),
                            _passAndConfirmWidget(),
                            SizedBox(
                              height: 25,
                            ),
                            _submitButton(),
                            /*   SizedBox(
                        height: 20,
                      ),
                      _registerButton(),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  Widget _infoText() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.changePassword,
          style: TextStyle(color: Colors.black, fontSize: 32),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
            AppLocalizations.of(context)!
                .changeyourpasswordbyenteringtheconfirmationcodesenttoyouremailhere,
            style: TextStyle(color: Colors.black, fontSize: 17))
      ],
    );
  }

  Future<void>? _showMyDialog(String title, String content) {
    CustomDialogs().errorDialog(
        context: context,
        title: title,
        desc: content,
        cancelOnTap: () {},
        btnCancelText: AppLocalizations.of(context)!.okey);

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
