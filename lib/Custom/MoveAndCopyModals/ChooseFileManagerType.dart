import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//!  Future<FileManagerType> yerine  dynamic kullanildi.
Future<dynamic> chooseFileManagerType(
    BuildContext context, String title, String btnText) async {
  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      context: context,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 435,
                width: Get.width,
                child: Column(
                  children: [
                    Container(
                        height: 45,
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                        ),
                        child: Center(
                            child: Text(
                          title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Get.theme.secondaryHeaderColor),
                        ))),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: Get.width,
                      height: 275,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // ListItem(
                          //     context,
                          //     FileManagerType.Salary,
                          //     AppLocalizations.of(context).commonCloud,
                          //     Icons.groups),
                          // ListItem(
                          //     context,
                          //     FileManagerType.Report,
                          //     AppLocalizations.of(context).contact,
                          //     Icons.badge),
                          // ListItem(
                          //     context,
                          //     FileManagerType.CommonDocument,
                          //     AppLocalizations.of(context).collaboration +
                          //         " " +
                          //         AppLocalizations.of(context).board,
                          //     Icons.assessment),
                          ListItem(
                              context,
                              FileManagerType.CommonTask,
                              AppLocalizations.of(context)!.chooseProject,
                              Icons.task_alt),
                          // ListItem(
                          //     context,
                          //     FileManagerType.PrivateDocument,
                          //     AppLocalizations.of(context).privateCloud,
                          //     Icons.cloud,
                          //     noBorder: true),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      });
}

InkWell ListItem(
    BuildContext context, FileManagerType fmt, String txt, IconData iconData,
    {bool noBorder = false}) {
  return InkWell(
    onTap: () {
      Navigator.pop(context, fmt);
    },
    child: Container(
      width: Get.width,
      height: 55,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: noBorder
            ? null
            : Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: Get.theme.colorScheme.surface,
          ),
          SizedBox(
            width: 7,
          ),
          Text(
            txt,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    ),
  );
}
