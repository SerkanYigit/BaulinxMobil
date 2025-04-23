import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/PDFCreate/PdfApi.dart';
import 'package:undede/Custom/Translator/TranslatToText.dart';
import 'package:undede/Custom/showModalDeleteYesOrNo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/Services/OpenAI/OpenAIDB.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/OpenAI/GetOpenAIChatMessagesResult.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Controller/ControllerBottomNavigationBar.dart';
import '../../Custom/CustomLoadingCircle.dart';
import '../Private/DirectoryDetailSelectFilePage.dart';
import 'OwnMessageDigi.dart';
import 'ReplyMessageDigi.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DocumentAnalysis extends StatefulWidget {
  final int? fileId;
  const DocumentAnalysis({Key? key, this.fileId}) : super(key: key);

  @override
  State<DocumentAnalysis> createState() => _DocumentAnalysisState();
}

class _DocumentAnalysisState extends State<DocumentAnalysis> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  OpenAIDB _aidb = OpenAIDB();
  GetOpenAIChatMessagesResult _aiChatMessagesResult =
      GetOpenAIChatMessagesResult(hasError: false);
  bool loading = true;
  int? UploadedFileId;
  FToast? fToast;
  List<OpenAIChatDetails> selectedMessage = [];
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await GetOpenAiChatMessage();
      setState(() {
        UploadedFileId = widget.fileId;
      });

      //  showWarningToast(AppLocalizations.of(context)!.itWillTakeTime);
      setState(() {
        fileLoading = true;
      });
      await _aidb.InsertOpenAIChat(_controllerDB.headers(),
          FileId: UploadedFileId,
          SenderId: _controllerDB.user.value!.result!.id!,
          Message: AppLocalizations.of(context)!.whatisTheSubjectofThisArtcile);
      await GetOpenAiChatMessage();

      setState(() {
        fileLoading = false;
      });
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  Future<void> GetOpenAiChatMessage() async {
    _aiChatMessagesResult = await _aidb.GetOpenAIChatMessages(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!);
    setState(() {});
  }

  String getSelectedMessageTextToString() {
    String allDatas = "";
    selectedMessage.forEach((element) {
      allDatas += element.message! + "\n";
    });
    return allDatas;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: fileLoading,
      child: Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.analyzeDocument),
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            actions: [
              selectedMessage.length >= 1 &&
                      !(selectedMessage
                              .where((element) => element.reciverId == 0)
                              .length >
                          0)
                  ? buildPopupMenuButton(
                      context, [getSelectedMessageTextToString()])
                  : Container(),
              SizedBox(
                width: 15,
              ),
              selectedMessage.length >= 1 &&
                      !(selectedMessage
                              .where((element) => element.reciverId == 0)
                              .length >
                          0)
                  ? InkWell(
                      onTap: () async {
                        PdfApi().generateCenteredText(
                            getSelectedMessageTextToString());
                      },
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 20,
                      ),
                    )
                  : Container(),
              SizedBox(
                width: 15,
              ),
              selectedMessage.length >= 1 &&
                      !(selectedMessage
                              .where((element) => element.reciverId == 0)
                              .length >
                          0)
                  ? InkWell(
                      onTap: () async {
                        FileShareFn([getSelectedMessageTextToString()], context,
                            url: true);
                      },
                      child: Icon(
                        Icons.share_outlined,
                        size: 20,
                      ),
                    )
                  : Container(),
              SizedBox(
                width: 15,
              ),
              selectedMessage.length >= 1
                  ? InkWell(
                      onTap: () async {
                        var data = await showModalDeleteYesOrNo(
                            context, AppLocalizations.of(context)!.delete);
                        if (data!) {
                          selectedMessage.forEach((element) async {
                            await _aidb.DeleteOpenAIChatMessage(
                                _controllerDB.headers(),
                                id: element.id);
                          });
                          GetOpenAiChatMessage();
                        }
                      },
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                      ),
                    )
                  : Container(),
              SizedBox(
                width: 15,
              ),
              InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .analyzeDocumentDesc)));
                  },
                  child: Icon(Icons.info_outline)),
              SizedBox(
                width: 15,
              ),
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back), // Back arrow icon
              onPressed: () {
                _controllerBottomNavigationBar.goHomePage = true;
                _controllerBottomNavigationBar.update();
              },
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 120, right: 20),
            child: FloatingActionButton(
              heroTag: "documentAnalysis",
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onPressed: () async {
                int? fileUploadType;
                await selectUploadType(context,
                        folderEnable: false, picture: true, cloud: true)
                    .then((value) => fileUploadType = value);
                if (fileUploadType == 0) {
                  _imgFromCamera();
                } else if (fileUploadType == 1) {
                  _uploadFilesFromDevice();
                } else if (fileUploadType == 2) {
                  var data = await Get.to(() => DirectoryDetailSelectFilePage(
                        folderName: "",
                        hideHeader: true,
                        fileManagerType: FileManagerType.PrivateDocument,
                        //!  todoId: null,
                      ));
                  if (data != 0 && data != null) {
                    print("fileId " + data.toString());
                    setState(() {
                      UploadedFileId = data["selectedFileId"];
                    });

                    //  showWarningToast(
                    //     AppLocalizations.of(context)!.itWillTakeTime);
                    setState(() {
                      fileLoading = true;
                    });
                    await _aidb.InsertOpenAIChat(_controllerDB.headers(),
                        FileId: UploadedFileId,
                        SenderId: _controllerDB.user.value!.result!.id!,
                        Message: AppLocalizations.of(context)!
                            .whatisTheSubjectofThisArtcile);
                    await GetOpenAiChatMessage();

                    setState(() {
                      fileLoading = false;
                    });
                  }
                }
              },
              backgroundColor: Get.theme.primaryColor,
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          ),
          body: loading
              ? Text("document") //CustomLoadingCircle()
              : Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.1),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      _aiChatMessagesResult.result!.length == 0
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10),
                              child: Container(
                                  /*  child: Text(
                                  AppLocalizations.of(context)
                                      .analyzeDocumentDesc,
                                  style: TextStyle(
                                      color: Get.theme.secondaryHeaderColor),
                                ), */
                                  ),
                            )
                          : Container(),
                      Expanded(
                        child: SingleChildScrollView(
                          reverse: true,
                          padding: EdgeInsets.only(top: 10, bottom: 80),
                          child: ListView.builder(
                              shrinkWrap: true,
                              addAutomaticKeepAlives: true,
                              itemCount: _aiChatMessagesResult.result!.length,
                              padding: EdgeInsets.only(
                                  bottom: 10, left: 5, right: 0),
                              physics: ScrollPhysics(),
                              itemBuilder: (ctx, i) {
                                return buildChatDeatials(
                                    _aiChatMessagesResult.result![i]);
                              }),
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }

  Widget buildChatDeatials(OpenAIChatDetails data) {
    if (data.senderId == 0) {
      return GestureDetector(
        onLongPress: () {
          if (selectedMessage.isBlank!) {
            setState(() {
              selectedMessage.add(data);
            });
          }
        },
        onTap: () {
          if (selectedMessage.length != 0) if (selectedMessage
              .any((element) => element == data)) {
            setState(() {
              selectedMessage.remove(data);
            });
          } else
            setState(() {
              selectedMessage.add(data);
            });
        },
        child: ReplyCardDigi(
          message: data.message!,
          time: DateFormat("HH:mm").format(DateTime.parse(data.createdDate!)),
          Selected: selectedMessage.any((element) => element == data),
        ),
      );
    } else {
      return GestureDetector(
        onLongPress: () {
          if (selectedMessage.isBlank!) {
            setState(() {
              selectedMessage.add(data);
            });
          }
        },
        onTap: () {
          if (selectedMessage.length != 0) if (selectedMessage
              .any((element) => element == data)) {
            setState(() {
              selectedMessage.remove(data);
            });
          } else
            setState(() {
              selectedMessage.add(data);
            });
        },
        child: OwnMessageDigiCard(
          message: data.message!,
          time: DateFormat("HH:mm").format(DateTime.parse(data.createdDate!)),
          myImage: _controllerDB.user.value!.result!.photo!,
          FileThumbnail: data.files?.fileThumbnail ?? "",
          File: data.files?.fileContent,
          Selected: selectedMessage.any((element) => element == data),
        ),
      );
    }
  }

  Future<void> _uploadFilesFromDevice() async {
    String fileContent = "";
    bool isCombine = false;
    Files files = new Files();
    files.fileInput = <FileInput>[];
    var data = await Permission.photos.request();
    print(data);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpeg',
          'jpg',
          'png',
          'docx',
          'mp3',
          'mp4',
          'doc',
          'xls',
          'xlsx',
          'txt'
        ],
        allowMultiple: false);

    List<int> fileBytes = <int>[];
    isCombine = result!.files.length > 1 ? true : false;

    result.files.forEach((file) {
      fileBytes = new File(file.path!).readAsBytesSync().toList();
      //todo: crop eklenecek
      String fileContent = base64.encode(fileBytes);
      files.fileInput!.add(new FileInput(
          fileName: 'sample.${result.files.first.path!.split(".").last}',
          directory: "",
          fileContent: fileContent));
    });
    await uploadFiles(
      files,
    );
  }

  bool fileLoading = false;

  Future<void> uploadFiles(Files files) async {
    var data2;
    try {
      bool isCombine = false;
      setState(() {
        fileLoading = true;
      });

      var data = await _controllerFiles.UploadFiles(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id!,
        CustomerId: null,
        ModuleTypeId: FileManagerType.PrivateDocument.index,
        files: files,
        IsCombine: files.fileInput!.length > 1 ? true : false,
        CombineFileName: "sample.pdf",
      ).then((value) async {
        _controllerFiles.refreshPrivate = true;
        _controllerFiles.update();
        await Future.delayed(Duration(seconds: 30));
        if (value.isBlank!)
          "";
        else {
          showToast(AppLocalizations.of(context)!.fileisuploaded);
          setState(() {
            UploadedFileId = value.id;
          });
          data2 = await _aidb.InsertOpenAIChat(_controllerDB.headers(),
              FileId: value.id,
              SenderId: _controllerDB.user.value!.result!.id!,
              Message:
                  AppLocalizations.of(context)!.whatisTheSubjectofThisArtcile);

          await GetOpenAiChatMessage();
          setState(() {
            UploadedFileId = value.id;

            fileLoading = false;
          });
          return value.id;
        }
        setState(() {
          UploadedFileId = value.id;

          fileLoading = false;
        });
      });
      return data2; //! data yerine data2 yazildi
    } catch (e, stack) {
      print(stack);
      setState(() {
        fileLoading = false;
      });
    }
  }

  Future<void> _imgFromCamera() async {
    bool isCombine = true;
    Files files = new Files();
    files.fileInput = <FileInput>[];
    await Get.to(() => CameraPage())!.then((value) async {
      if (value != null) {
        List<int> fileBytes = <int>[];
        isCombine = value.length > 1 ? true : false;

        value.forEach((file) {
          fileBytes = new File(file.path).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          files.fileInput!.add(new FileInput(
              fileName: 'sample.jpg', directory: "", fileContent: fileContent));
        });
        await uploadFiles(files);
      }
    });
  }
}
