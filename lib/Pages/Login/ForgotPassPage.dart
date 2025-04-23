import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Pages/Login/ResetPassPage.dart';
import 'package:undede/widgets/CustomDialogWidgets.dart';
import 'package:undede/widgets/GradientWidget.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Custom/CustomLoadingCircle.dart';

class ForgotPassPage extends StatefulWidget {
  @override
  _ForgotPassPageState createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final ControllerDB c = Get.put(ControllerDB());
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Color themeColor = Get.theme.colorScheme.secondary;
  final _formKey = GlobalKey<FormState>();
  TextStyle buttonStyle = TextStyle(color: Colors.white, fontSize: 16);

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          setState(() {
            isLoading = true;
          });
          bool result = await c.forgotPassword(
              emailController.text, AppLocalizations.of(context)!.localeName);

          setState(() {
            isLoading = false;
          });
          if (!result) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ResetPassPage(emailController.text)));
          } else {
            _showMyDialog(AppLocalizations.of(context)!.theoperationfailed,
                AppLocalizations.of(context)!.makesureyourMail);
          }
        }
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
                AppLocalizations.of(context)!.sendMail.toUpperCase(),
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
              ? CustomLoadingCircle()
              : SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      c.updateLoginState(Login.SignIn);
                                    },
                                    child: Icon(
                                      Icons.chevron_left,
                                      size: 31,
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Form(
                              key: _formKey,
                              child: Container(
                                height: 390,
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
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .hello,
                                              style: TextStyle(
                                                  fontSize: 33,
                                                  fontFamily: 'TTNorms',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .recoveryMail,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.grey[700],
                                                  fontFamily: 'TTNorms',
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 60,
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Email',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.grey[600],
                                                  fontFamily: 'TTNorms',
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            controller: emailController,
                                            decoration: const InputDecoration(
                                              errorStyle: TextStyle(height: 0),
                                              border: UnderlineInputBorder(),
                                              hintText: 'Email',
                                              hintStyle: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            style: TextStyle(
                                                fontSize: 21,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                            validator: (value) =>
                                                validateEmail(value!),
                                          ),
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

  Widget _infoText() {
    return Column(
      children: [
        Text(
          "Şifremi Unutttum",
          style: TextStyle(color: Colors.black, fontSize: 32),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
            "Lütfen mailinizi giriniz.Size parolanızı oluşturmanız için bir link göndereceğiz.",
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

  String validateEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value.isEmpty || !regex.hasMatch(value))
      return 'Enter a valid email address';
    else
      return ''; //! null yerine "" konuldu
   }
}
