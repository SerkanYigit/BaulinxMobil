import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';

class UploadOption {
  Color? color;
  ImageIcon? iconData;
  String? title;
  Function? onTapFunction;
  UploadOption({this.color, this.iconData, this.title, this.onTapFunction});
}

List<UploadOption> uploadOptions =  <UploadOption>[];

Future<dynamic> selectUploadType(BuildContext context,
    {bool folderEnable = false,
    bool invoiceEnable = true,
    bool picture = true,
    bool invoice = false,
    bool word = false,
    bool excel = false,
    bool cloud = false,
    int invoiceType = 0}) {
  uploadOptions.clear();
  uploadOptions.add(
    new UploadOption(
      color: Color(0xFFE8FDF5),
      iconData: ImageIcon(
        AssetImage('assets/images/icon/camera.png'),
      ),
      title: AppLocalizations.of(context)!.camera,
    ),
  );
  uploadOptions.add(
    new UploadOption(
      color: Color(0xFFFAECFF),
      iconData: !picture
          ? ImageIcon(AssetImage('assets/images/icon/image.png'))
          : ImageIcon(AssetImage('assets/images/icon/foldermove.png')),
      title: !picture
          ? AppLocalizations.of(context)!.gallery
          : AppLocalizations.of(context)!.file,
    ),
  );
  invoiceEnable
      ? uploadOptions.add(
          new UploadOption(
            color: Color(0xFFFAECFF),
            iconData: ImageIcon(AssetImage('assets/images/icon/bill.png')),
            title: invoiceType == 3
                ? AppLocalizations.of(context)!.inquiry
                : invoiceType == 2
                    ? AppLocalizations.of(context)!.offer
                    : AppLocalizations.of(context)!.invoice,
          ),
        )
      : SizedBox();
  if (picture) {
    if (folderEnable) {
      uploadOptions.add(
        new UploadOption(
          color: Color(0xFFFFF1ED),
          iconData: ImageIcon(AssetImage('assets/images/icon/image.png')),
          title: AppLocalizations.of(context)!.folder,
        ),
      );
    }
  }
  if (word) {
    uploadOptions.add(
      new UploadOption(
        color: Color(0xFFFFF1ED),
        iconData: ImageIcon(AssetImage('assets/images/icon/word.png')),
        title: "Word",
      ),
    );
  }
  if (excel) {
    uploadOptions.add(
      new UploadOption(
        color: Color(0xFFFFF1ED),
        iconData: ImageIcon(AssetImage('assets/images/icon/excel.png')),
        title: "Excel",
      ),
    );
  }
  if (cloud) {
    uploadOptions.add(
      new UploadOption(
        color: Color(0xFFFFF1ED),
        iconData: ImageIcon(AssetImage('assets/images/icon/cloud4.png')),
        title: "Cloud",
      ),
    );
  }
  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool b = false;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              height: 550,
              width: Get.width,
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: Get.width,
                    padding: EdgeInsets.all(25),
                    /*child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.red,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Uploading 2 files',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '7 seconds left',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w100,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              Container(),
                              Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ),*/
                  ),
                  Container(
                    height: 400,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.only(
                        topRight: const Radius.circular(20.0),
                        topLeft: const Radius.circular(20.0),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(AppLocalizations.of(context)!.uploadNew,
                                style: TextStyle(
                                    fontSize: 21,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))),
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 30),
                          height: 5,
                          width: 70,
                          decoration: BoxDecoration(
                              color: Get.theme.secondaryHeaderColor,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 100,
                                    childAspectRatio: 3 / 3,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14),
                            itemCount: uploadOptions.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return Stack(children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context, index);
                                  },
                                  child: Container(
                                    height: 350.0,
                                    width: 350,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Get.theme.colorScheme.secondary,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        uploadOptions[index].iconData!    ,
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          uploadOptions[index].title!,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]);
                            }),
                      ],
                    ),
                  ),
                ],
              ));
        });
      });
}

GestureDetector expandMoreIcons(
    Function runOnTap, IconData iconData, bool isOpened) {
  return GestureDetector(
    onTap: () {
      runOnTap();
    },
    child: AnimatedOpacity(
      opacity: isOpened ? 1 : 0,
      duration: Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFe3d5a4),
          boxShadow: standartCardShadow(),
        ),
        padding: EdgeInsets.all(7),
        child: AnimatedOpacity(
          opacity: isOpened ? 1 : 0,
          duration: Duration(milliseconds: 200),
          child:
              Icon(iconData, size: 19, color: Get.theme.secondaryHeaderColor),
        ),
      ),
    ),
  );
}
