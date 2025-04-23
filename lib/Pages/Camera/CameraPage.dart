import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';

class CameraPage extends StatefulWidget {
  bool isOneClick;
  bool isScan;

  CameraPage({this.isOneClick = false, this.isScan = false});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller; //! late kullanildi
  List<File> images = [];
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    controller = CameraController(
      cameras[0], // Assuming 'cameras' is a list of available cameras
      ResolutionPreset.high, // Set a default resolution preset
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool isTablet(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600;
  }

  void initializeCamera(BuildContext context) {
    if (controller.value.isInitialized) {
      return; // Don't reinitialize the camera if it's already initialized.
    }

    // Set resolution preset based on device type
    ResolutionPreset resolutionPreset =
        isTablet(context) ? ResolutionPreset.medium : ResolutionPreset.high;

    controller = CameraController(
      cameras[0],
      resolutionPreset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    initializeCamera(context); // Initialize the camera in the build method

    if (!controller.value.isInitialized) {
      return Container(); // Show an empty container until the camera is initialized
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, images);
        return false;
      },
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            Container(
              width: Get.width,
              height: 100,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, null);
                          },
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                            size: 31,
                          ),
                        ),
                        Row(
                          children: [
                            images.isEmpty
                                ? Container()
                                : InkWell(
                                    onTap: () async {
                                      if (widget.isOneClick || widget.isScan) {
                                        await uploadImages();
                                      } else {
                                        Navigator.pop(context, images);
                                      }
                                    },
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          borderRadius:
                                              BorderRadius.circular(45),
                                          boxShadow: standartCardShadow()),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Center(
                                            child: Text(
                                          AppLocalizations.of(context)!.save,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 215,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AspectRatio(
                      aspectRatio: 1 / controller.value.aspectRatio,
                      child: CameraPreview(controller),
                    ),
                    Align(
                      alignment: Alignment(0, 0.9),
                      child: FloatingActionButton(
                        heroTag: "camerapagec2",
                        onPressed: () async {
                          XFile imageFile = await controller.takePicture();
                          //! File? croppedFile =  yerine CroppedFile? croppedFile =  kullanildi
                          CroppedFile? croppedFile =

                              //! ImageCropper yerine ImageCropper().cropImage kullanildi
                              await ImageCropper().cropImage(
                                  sourcePath: imageFile.path,
                                  aspectRatio:
                                      CropAspectRatio(ratioX: 3, ratioY: 4),
                                  //! depraceted olanlar degistirildi
                                  uiSettings: [
                                AndroidUiSettings(
                                    toolbarTitle: 'Cropper',
                                    toolbarColor:
                                        Get.theme.scaffoldBackgroundColor,
                                    toolbarWidgetColor: Colors.black,
                                    initAspectRatio:
                                        CropAspectRatioPreset.original,
                                    lockAspectRatio: false),
                                IOSUiSettings(
                                  minimumAspectRatio: 1.0,
                                )
                              ]);

                          setState(() {
//! images.add(croppedFile)  yerine images.add(File(croppedFile!.path)); kullanildi
                            images.add(File(croppedFile!.path));
                          });
                        },
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.photo_camera,
                          size: 45,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shrinkWrap: true,
                    controller: ScrollController(keepScrollOffset: false),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Container(
                            width: 65,
                            child: Image.file(
                              images[index],
                              fit: BoxFit.cover,
                            )),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  uploadImages() async {
    Files files = new Files();
    files.fileInput = <FileInput>[];

    if (images.length > 0) {
      List<int> fileBytes = <int>[];

      images.forEach((file) {
        fileBytes = new File(file.path).readAsBytesSync().toList();
        String fileContent = base64.encode(fileBytes);
        files.fileInput!.add(new FileInput(
            fileName: widget.isOneClick ? 'sample.jpeg' : 'sample.jpg',
            directory: widget.isOneClick ? "Picture" : "",
            fileContent: fileContent));
      });
    }

    bool isCombine = false;
    if (widget.isScan) {
      if (files.fileInput!.length > 1) {
        bool? result = await showModalYesOrNo(
            context,
            AppLocalizations.of(context)!.fileUpload,
            AppLocalizations.of(context)!.doyouwanttocombinefiles);
        print("Combine işlemi boş bırakıldı metod geri döndü : " +
            result.toString());
        isCombine = result ?? false;
      }
    }

    await uploadFilesToPrivate(files, isCombine);
    Navigator.of(context).pop();
  }

  Future<void> uploadFilesToPrivate(Files files, bool isCombine) async {
    print("files.fileInput.length : " + files.fileInput!.length.toString());

    if (widget.isOneClick) {
      await _controllerFiles.UploadFilesToPrivate(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: null,
        ModuleTypeId: FileManagerType.PrivateDocument.typeId,
        files: files,
        IsCombine: isCombine,
        CombineFileName: 'vir2ell_office.jpg',
      );
    } else if (widget.isScan) {
      await _controllerFiles.UploadFiles(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: null,
        ModuleTypeId: FileManagerType.PrivateDocument.typeId,
        files: files,
        IsCombine: isCombine,
        CombineFileName: 'vir2ell_office.pdf',
      );
    }
  }
  // uploadImages() and uploadFilesToPrivate() methods remain unchanged
}
