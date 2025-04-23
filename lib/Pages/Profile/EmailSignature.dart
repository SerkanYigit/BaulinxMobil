import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Controller/ControllerDB.dart';
import '../../Controller/ControllerUser.dart';
import '../../model/User/GetSavedSignatureResult.dart';

class EmailSignature extends StatefulWidget {
  @override
  _EmailSignatureState createState() => _EmailSignatureState();
}

class _EmailSignatureState extends State<EmailSignature> {
  // Controller for HtmlEditor
  HtmlEditorController _htmlController = HtmlEditorController();
  ControllerUser _controllerUser = Get.put(ControllerUser());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  EmailSignatureResponse emailSignature = EmailSignatureResponse();
  String? initialText;

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getSavedSignature();
    });
  }


/* //! void  
  getSavedSignature() async {
    emailSignature = await _controllerUser.GetSavedSignature(
            _controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id!)
       
        .then((value) {  _htmlController.setText(value.result!.signatureContent!);

 });
  } */

//! yukaridaki kodun yeni hali.
  Future<EmailSignatureResponse> getSavedSignature() async {
    return await _controllerUser.GetSavedSignature(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id!
    ).then((value) {
      _htmlController.setText(value.result!.signatureContent!);
      return value;
    });
  }

  

  //! void kaldirildi
  saveSignature() async {
    var signature = await _htmlController.getText();
    _controllerUser.SaveSignature(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id!, signature: signature)
        .then((value) {
      if (value) {
        Get.snackbar("Success", "Signature saved successfully");
      }
    }).catchError((error) {
      Get.snackbar("Error", "An error occurred while saving the signature");
    });

    print("Signature: $signature");
    // Here you can save the signature or do any action you need
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        title: Text("Email Signature"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: HtmlEditor(
                controller: _htmlController,
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.aboveEditor,
                  defaultToolbarButtons: [
                    FontButtons(),
                    ColorButtons(),
                    ListButtons(),
                    ParagraphButtons(),
                  ],
                ),
                htmlEditorOptions: HtmlEditorOptions(
                  hint: "Enter your signature...",
                  autoAdjustHeight: true,
                ),
                otherOptions: OtherOptions(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () async {
                    var signature = await _htmlController.getText();
                    await saveSignature();
                    // Here you can save the signature or do any action you need
                  },
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(color: Colors.black),
                  ), // Save button
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20), backgroundColor: Theme.of(context)
                        .primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ), // Adjust the button color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
