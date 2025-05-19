import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/DioDownloader.dart';
import 'package:undede/Custom/FileGeneratorExcellorWord.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseCommon.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseCustomer.dart';
import 'package:undede/Custom/MoveAndCopyModals/ChooseFileManagerType.dart';
import 'package:undede/Custom/showModalTextInput.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/DocumentAnalysis/DocumentAnalysis.dart';
import 'package:undede/Pages/FileViewers/openFileFn.dart';
import 'package:undede/Pages/ObjectDetection/detection_camera.dart';
import 'package:undede/Pages/Private/CopyAndMovePage.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/confirmDeleteWidget.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Label/uploadLabels.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Custom/CustomLoadingCircle.dart';

class DirectoryDetailOldest extends StatefulWidget {
  String? folderName;
  int? userId; // report ve salary' de gelicek
  bool? hideHeader;
  FileManagerType? fileManagerType;
  int? todoId;
  int? customerId;
  bool?
      canViewFolders; //kopyalama veya taşıma için açılan fullscreen modalda klasörleri gezebilmesi için
  String? headerTitle;
  DirectoryDetailOldest(
      {this.folderName,
      this.userId,
      this.hideHeader = false,
      this.fileManagerType,
      this.todoId,
      this.customerId,
      this.canViewFolders = false,
      this.headerTitle = ""});

  @override
  _DirectoryDetailState createState() => _DirectoryDetailState();
}

class _DirectoryDetailState extends State<DirectoryDetailOldest> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool isLoading = true;
  String isListOrPreview = 'P'; // default preview geliyor.
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerLabel _controllerLabel = ControllerLabel();
  //List<bool> openMenuAnimateValuesFolder = [];
  //List<bool> openMenuAnimateValuesFile = [];
  List<bool> itemsSelectedFolder = <bool>[];

  FilesForDirectoryData _files = new FilesForDirectoryData();

  int page = 0;
  ScrollController _scrollController = new ScrollController();
  bool morePageExist = false;
  bool isUploadingNewPage = false;

  //List<AnimationController> _animationControllerFolder = new List<AnimationController>();
  //List<AnimationController> _animationControllerFile = new List<AnimationController>();
  bool isMultipleChoiceExpanded = false;
  // multi Select
  selectionModeActive() =>
      selectedFileIdList.length > 0 || itemsSelectedFolder.contains(true);
  List<int> selectedFileIdList = [];
  int? ModulType;
  int? CustomerId;
  // Mail
  ControllerUser _controllerUser = Get.put(ControllerUser());

  String? selectedMail;
  int? selectedMailId;

  TextEditingController _password = TextEditingController();
  TextEditingController _message = TextEditingController();
  TextEditingController _receiver = TextEditingController();
  TextEditingController _subject = TextEditingController();
  List<DropdownMenuItem> cmbEmails = [];

// inserLabelList
  ControllerLabel controllerLabel = Get.put(ControllerLabel());
  GetLabelByUserIdResult _getLabelByUserIdResult =
      GetLabelByUserIdResult(hasError: false);
  final List<DropdownMenuItem> cboLabelsList = [];
  List<UserLabel> labelsList = <UserLabel>[];
  List<int> selectedLabels = [];
  List<String> selectedLabelsForLabel = [];
  int? selectedLabelIndex;

  List<int> selectedLabelIndexes = [];
  List<String> selectedLabelsColor = [];
  uploadLabels selectedLabelAndFiles = uploadLabels();
  TextEditingController txtSearchController = new TextEditingController();
  int? folderViewLeng;
  bool _loadingFile = false;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    _prepareSaveDir();
    selectedLabelAndFiles.labelIds = <LabelIds>[];
    selectedLabelAndFiles.filesIds = <FilesIds>[];

    super.initState();

    _scrollController.addListener(() async {
      if (!isUploadingNewPage &&
          _scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        print("morePageExist" + morePageExist.toString());
        if (morePageExist) {
          await loadMore();
        }
      }
    });
    getUserEmailList();
    getLabelByUserId();
    refresh();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getTodoList();
      setState(() {});
    });
  }

  getTodoList() async {
    await controllerLabel.GetTodoLabelList(
      _controllerDB.headers(),
      TodoId: widget.todoId,
      UserId: _controllerDB.user.value!.result!.id,
    ).then((value) {
      selectedLabelIndexes.clear();
      selectedLabelsColor.clear();
      selectedLabels.clear();
      print('Selected Indexes:s:' + value.result!.first.labelId.toString());
      if (value.result != null && value.result!.length > 0) {
        setState(() {
          value.result!.forEach((label) {
            if (!selectedLabelIndexes.contains(label.labelId!)) {
              selectedLabelIndexes.add(label.labelId!);
              selectedLabelsForLabel.add(label.labelTitle!);
              selectedLabelsColor.add(label.labelColor!);

              print(
                  'Selected Indexes: ${label.todoLabelId} + ${label.labelId}');
              print(
                  'Selected Indexes: $selectedLabelIndexes + $selectedLabelsForLabel ');
            }
          });
        });
      }
    });
  }

  void getLabelByUserId() async {
    await controllerLabel.GetLabelByUserId(_controllerDB.headers(),
            Id: 0, UserId: _controllerDB.user.value!.result!.id, CustomerId: 0)
        .then((value) {
      labelsList = value.result!;

      List.generate(controllerLabel.getLabel.value!.result!.length, (index) {
        if (selectedLabelsForLabel
            .contains(controllerLabel.getLabel.value!.result![index].title)) {
          cboLabelsList.add(DropdownMenuItem(
              child: Row(
                children: [
                  Text(controllerLabel.getLabel.value!.result![index].title!),
                  Icon(
                    Icons.lens,
                    color: Color(int.parse(
                        controllerLabel.getLabel.value!.result![index].color!
                            .replaceFirst('#', "FF"),
                        radix: 16)),
                  )
                ],
              ),
              key: Key(controllerLabel.getLabel.value!.result![index].title
                  .toString()),
              value: controllerLabel.getLabel.value!.result![index].title! +
                  "+" +
                  controllerLabel.getLabel.value!.result![index].color!));
        }
      });
    });
  }

  Future<void> refresh({bool withoutSetstate = false}) async {
    if (!withoutSetstate) {
      setState(() {
        page = 0;
        isLoading = true;
      });
    } else {
      page = 0;
      isLoading = true;
    }

    itemsSelectedFolder.clear();
    selectedFileIdList.clear();

    await _controllerFiles.GetFilesByUserIdForDirectory(_controllerDB.headers(),
            userId: widget.userId ?? _controllerDB.user.value!.result!.id,
            customerId: widget.todoId ?? widget.customerId,
            moduleType: widget.fileManagerType!.typeId,
            directory: widget.folderName,
            page: 0)
        .then((value) async {
      value.result!.result!
          .where((x) => x.folderName != null)
          .forEach((element) {
        itemsSelectedFolder.add(false);
        /*openMenuAnimateValuesFolder.add(false);
        _animationControllerFolder.add(new AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
          upperBound: 0.5,
        ));*/
      });
      value.result!.result!.where((x) => x.fileName != null).forEach((element) {
        /*openMenuAnimateValuesFile.add(false);
        _animationControllerFile.add(new AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
          upperBound: 0.5,
        ));*/
      });
      _files = value.result!;
    });

    if (_files.totalPage! > 1)
      morePageExist = true;
    else
      morePageExist = false;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadMore() async {
    setState(() {
      page++;
      isUploadingNewPage = true;
    });

    await _controllerFiles.GetFilesByUserIdForDirectory(_controllerDB.headers(),
            userId: widget.userId ?? _controllerDB.user.value!.result!.id,
            customerId: widget.todoId ?? widget.customerId,
            moduleType: widget.fileManagerType!.typeId,
            directory: widget.folderName,
            page: page)
        .then((value) async {
      if (value.hasError!) {
        print(value.resultCode! + " hata");
      } else {
        if (value.result!.result!.length > 0) {
          value.result!.result!
              .where((x) => x.folderName != null)
              .forEach((element) {
            itemsSelectedFolder.add(false);
            /*openMenuAnimateValuesFolder.add(false);
            _animationControllerFolder.add(new AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 300),
              upperBound: 0.5,
            ));*/
          });
          value.result!.result!
              .where((x) => x.fileName != null)
              .forEach((element) {
            /*openMenuAnimateValuesFile.add(false);
            _animationControllerFile.add(new AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 300),
              upperBound: 0.5,
            ));*/
          });
          print('valueresult' + value.result!.result.toString());
          _files.result!.addAll(value.result!.result!);
        } else
          morePageExist = false;
      }
    });

    setState(() {
      isUploadingNewPage = false;
    });
  }

  DeleteMultiFileAndDirectory(List<int> FileIdList, int CustomerId) async {
    await _controllerFiles.DeleteMultiFileAndDirectory(
      _controllerDB.headers(),
      UserId: widget.userId ?? _controllerDB.user.value!.result!.id,
      CustomerId: CustomerId ?? widget.todoId ?? widget.customerId,
      ModuleTypeId: widget.fileManagerType!.typeId,
      FileIdList: FileIdList,
      SourceDirectoryNameList: _controllerFiles.SourceDirectoryNameList,
      SourceOwnerId: widget.userId ?? _controllerDB.user.value!.result!.id,
    );
  }

  String? _localPath;

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());
    final savedDir = Directory(_localPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        final directory = "/storage/emulated/0/Download/";
        externalStorageDirPath = directory;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  SendEMail(String Receivers, String Subject, String Message,
      List<int> Attachtments, int Type, int UserEmailId, String Password) {
    _controllerFiles.SendEMail(_controllerDB.headers(),
        UserId: widget.userId ?? _controllerDB.user.value!.result!.id,
        Receivers: Receivers,
        Subject: Subject,
        Message: Message,
        Attachtments: Attachtments,
        Type: Type,
        UserEmailId: UserEmailId,
        Password: Password);
  }

  InsertFileListLabelList(List<int> FilesIds, List<int> LabelIds) async {
    await controllerLabel.InsertFileListLabelList(_controllerDB.headers(),
        UserId: widget.userId ?? _controllerDB.user.value!.result!.id,
        FilesIds: FilesIds,
        LabelIds: LabelIds);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerFiles>(builder: (c) {
      if (c.refreshPrivate) {
        refresh(withoutSetstate: true);
        c.refreshPrivate = false;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        }
        c.update();
      }
      return isLoading
          ? CustomLoadingCircle()
          : Scaffold(
              backgroundColor: Color(0xFFF0F7F7),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniStartFloat,
              body: ModalProgressHUD(
                  child: Stack(
                    children: [
                      Container(
                        height: Get.height,
                        width: Get.width,
                        child: Column(
                          children: [
                            if (Platform.isIOS)
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                      height: 25,
                                      color: Get.theme.scaffoldBackgroundColor,
                                      margin: EdgeInsets.only(bottom: 3))),
                            widget.hideHeader!
                                ? Container()
                                : Container(
                                    width: Get.width,
                                    height: 110,
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).padding.top,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Get.theme.secondaryHeaderColor,
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: Get.width,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 15, 20, 10),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Icon(
                                                            Icons.arrow_back,
                                                            color: Get
                                                                .theme
                                                                .colorScheme
                                                                .surface,
                                                          )),
                                                      SizedBox(
                                                        width: 25,
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          widget.headerTitle!,
                                                          style: TextStyle(
                                                              color: Get
                                                                  .theme
                                                                  .colorScheme
                                                                  .surface,
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  showOnlyActionButtons(c)
                                      ? Container()
                                      : Expanded(
                                          child: Row(
                                            children: [
                                              widget.folderName == "" ||
                                                      widget.folderName ==
                                                          "Picture"
                                                  ? Container()
                                                  : GestureDetector(
                                                      onTap: () {
                                                        _controllerTodo
                                                            .update();
                                                        _controllerFiles
                                                            .update();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Icon(
                                                        Icons.chevron_left,
                                                        size: 31,
                                                      )),
                                              SizedBox(
                                                width: 11,
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        isListOrPreview = 'L';
                                                      });
                                                    },
                                                    child: Container(
                                                        width: 35,
                                                        height: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              isListOrPreview ==
                                                                      'L'
                                                                  ? Get
                                                                      .theme
                                                                      .colorScheme
                                                                      .surface
                                                                  : Colors
                                                                      .white,
                                                          boxShadow:
                                                              standartCardShadow(),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .format_list_bulleted,
                                                          size: 19,
                                                          color:
                                                              isListOrPreview ==
                                                                      'L'
                                                                  ? Colors.white
                                                                  : Color(
                                                                      0xFF5c5c5c),
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        isListOrPreview = 'P';
                                                      });
                                                    },
                                                    child: Container(
                                                        width: 35,
                                                        height: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              isListOrPreview ==
                                                                      'P'
                                                                  ? Get
                                                                      .theme
                                                                      .colorScheme
                                                                      .surface
                                                                  : Colors
                                                                      .white,
                                                          boxShadow:
                                                              standartCardShadow(),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .description_outlined,
                                                          size: 19,
                                                          color:
                                                              isListOrPreview ==
                                                                      'P'
                                                                  ? Colors.white
                                                                  : Color(
                                                                      0xFF5c5c5c),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 11,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          45.0, // Set the desired height for your horizontal ListView
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemCount:
                                                            selectedLabelsForLabel
                                                                    .length +
                                                                1, // Add 1 for the extra widget
                                                        scrollDirection: Axis
                                                            .horizontal, // Set scroll direction to horizontal
                                                        itemBuilder:
                                                            (context, index) {
                                                          // Check if index is 0 to show the additional widget
                                                          if (index == 0) {
                                                            return GestureDetector(
                                                              onTap: () async {
                                                                await refresh();
                                                              },
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                      height:
                                                                          40,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[400],
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                        boxShadow:
                                                                            standartCardShadow(),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            AppLocalizations.of(context)!.all,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                  SizedBox(
                                                                      width: 5),
                                                                ],
                                                              ), // Widget you want to display at the start
                                                            );
                                                          }
                                                          // Adjust index to account for the extra widget at the start
                                                          int adjustedIndex =
                                                              index - 1;
                                                          return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    selectedLabelIndex =
                                                                        adjustedIndex;
                                                                    isLoading =
                                                                        true;
                                                                  });

                                                                  await _controllerFiles
                                                                      .GetFilesByUserIdForLabels(
                                                                    _controllerDB
                                                                        .headers(),
                                                                    userId: widget
                                                                            .userId ??
                                                                        _controllerDB
                                                                            .user
                                                                            .value!
                                                                            .result!
                                                                            .id,
                                                                    customerId: widget
                                                                            .todoId ??
                                                                        widget
                                                                            .customerId,
                                                                    moduleType: widget
                                                                        .fileManagerType!
                                                                        .typeId,
                                                                    keyword: "",
                                                                    labelIds: [
                                                                      selectedLabelIndexes[
                                                                          adjustedIndex]
                                                                    ],
                                                                    pageIndex:
                                                                        0,
                                                                    endDate: "",
                                                                    startDate:
                                                                        "",
                                                                    isPaid: 0,
                                                                    targetAccount:
                                                                        0,
                                                                  ).then(
                                                                      (value) async {
                                                                    _files
                                                                        .result!
                                                                        .clear();
                                                                    if (value
                                                                        .hasError!) {
                                                                      print(value
                                                                              .resultCode! +
                                                                          " hata");
                                                                    } else {
                                                                      if (value
                                                                              .result!
                                                                              .fileOCRs!
                                                                              .length >
                                                                          0) {
                                                                        value
                                                                            .result!
                                                                            .fileOCRs!
                                                                            .where((x) =>
                                                                                x.fileName !=
                                                                                null)
                                                                            .forEach((element) {
                                                                          itemsSelectedFolder
                                                                              .add(false);
                                                                        });
                                                                        _files.result!.addAll(value
                                                                            .result!
                                                                            .fileOCRs!);
                                                                      } else {
                                                                        morePageExist =
                                                                            false;
                                                                      }
                                                                    }
                                                                  });

                                                                  setState(() {
                                                                    isLoading =
                                                                        false;
                                                                  });
                                                                },
                                                                child: _chipCard(
                                                                    selectedLabelsForLabel[
                                                                        adjustedIndex],
                                                                    adjustedIndex),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                    // Text(
                                                    //   "${_files != null ? _files.totalCount : 0} "
                                                    //   "${AppLocalizations.of(context).directoryDetailItems.toLowerCase()}",
                                                    //   style: TextStyle(
                                                    //       fontWeight:
                                                    //           FontWeight.w500,
                                                    //       fontSize: 15,
                                                    //       color: Colors.grey),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 11,
                                              ),
                                            ],
                                          ),
                                        ),
                                  c.isCopyActionActive
                                      ? Row(
                                          children: [
                                            TopBarButton(
                                                () => () async {
                                                      if (!await _controllerFiles.CopyDirectoryAndFile(
                                                              _controllerDB
                                                                  .headers(),
                                                              CustomerId: widget
                                                                  .customerId,
                                                              TargetModuleTypeId:
                                                                  widget
                                                                      .fileManagerType!
                                                                      .typeId,
                                                              TargetDirectoryName:
                                                                  widget
                                                                      .folderName,
                                                              SourceModuleTypeId:
                                                                  _controllerFiles
                                                                      .sourceModuleTypeId,
                                                              SourceDirectoryNameList: c
                                                                  .SourceDirectoryNameList,
                                                              FileIdList:
                                                                  c.FileIdList,
                                                              TargetOwnerIdList: [
                                                                widget
                                                                    .customerId!
                                                              ], //todo:taskın id si verilecek board ise boardun id si
                                                              SourceOwnerId: widget
                                                                  .customerId) //
                                                          .then((value) => value
                                                              .hasError!)) {
                                                        _controllerFiles
                                                                .removeCopyAndMovePage =
                                                            true;
                                                        _controllerFiles
                                                            .update();
                                                      }
                                                    },
                                                Icons.check_circle_outlined),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            TopBarButton(
                                                () => () {
                                                      _cancelCopy();
                                                    },
                                                Icons.cancel_outlined),
                                          ],
                                        )
                                      : c.isMoveActionActive
                                          ? SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  TopBarButton(
                                                      () => () async {
                                                            if (!await _controllerFiles.MoveDirectoryAndFile(
                                                                _controllerDB
                                                                    .headers(),
                                                                CustomerId: widget
                                                                    .customerId,
                                                                TargetModuleTypeId:
                                                                    widget
                                                                        .fileManagerType!
                                                                        .typeId,
                                                                TargetDirectoryName:
                                                                    widget
                                                                        .folderName,
                                                                SourceModuleTypeId:
                                                                    _controllerFiles
                                                                        .sourceModuleTypeId,
                                                                SourceDirectoryNameList: c
                                                                    .SourceDirectoryNameList,
                                                                FileIdList: c
                                                                    .FileIdList,
                                                                TargetOwnerId: widget
                                                                    .fileManagerType!
                                                                    .typeId, //todo:taskın id si verilecek board ise boardun id si
                                                                SourceOwnerId:
                                                                    widget
                                                                        .customerId)) {
                                                              _controllerFiles
                                                                      .removeCopyAndMovePage =
                                                                  true;
                                                              _controllerFiles
                                                                  .update();
                                                            }
                                                          },
                                                      Icons
                                                          .check_circle_outlined),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                  TopBarButton(
                                                      () => () {
                                                            _cancelMove();
                                                          },
                                                      Icons.cancel_outlined),
                                                ],
                                              ),
                                            )
                                          : selectionModeActive()
                                              ? _folderLongPressActions(context)
                                              : SizedBox()
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  /*  Expanded(
                                    child: CustomTextField(
                                      enabled: false,
                                      hint:
                                          AppLocalizations.of(context)!.search,
                                      prefixIcon: Icon(Icons.search),
                                      controller: txtSearchController,
                                      onChanged: (e) {
                                        setState(() {});
                                      },
                                    ),
                                  ), */

                                  //? List Grid Buttons
                                  /*    SizedBox(
                                    width: 11,
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isListOrPreview = 'L';
                                          });
                                        },
                                        child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: isListOrPreview == 'L'
                                                  ? Get
                                                      .theme.colorScheme.surface
                                                  : Colors.white,
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.format_list_bulleted,
                                              size: 19,
                                              color: isListOrPreview == 'L'
                                                  ? Colors.white
                                                  : Color(0xFF5c5c5c),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isListOrPreview = 'P';
                                          });
                                        },
                                        child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: isListOrPreview == 'P'
                                                  ? Get
                                                      .theme.colorScheme.surface
                                                  : Colors.white,
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.description_outlined,
                                              size: 19,
                                              color: isListOrPreview == 'P'
                                                  ? Colors.white
                                                  : Color(0xFF5c5c5c),
                                            )),
                                      ),
                                    ],
                                  ),
 */

                                  // Container(
                                  //     width: 50,
                                  //     height: 50,
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.white,
                                  //       boxShadow: standartCardShadow(),
                                  //       borderRadius: BorderRadius.circular(25),
                                  //     ),
                                  //     child: Icon(
                                  //       Icons.arrow_circle_up_outlined,
                                  //       color: Get.theme.primaryColor,
                                  //     )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    _files == null
                                        ? Container(
                                            width: Get.width,
                                            height: Get.height - 500,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Center(
                                                child: Text(
                                                    'Herhangi bir dosya bulunamadı.')))
                                        : Column(
                                            children: [
                                              ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  itemCount:
                                                      folderFilter().length,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    DirectoryItem item =
                                                        folderFilter()[index];

                                                    if (widget.fileManagerType ==
                                                            FileManagerType
                                                                .PrivateDocument &&
                                                        item.folderName ==
                                                            'Picture' &&
                                                        widget.folderName ==
                                                            '') {
                                                      return Container();
                                                    } else {
                                                      return FolderView(
                                                          item,
                                                          index,
                                                          c.isMoveActionActive);
                                                    }
                                                  }),
                                              !c.moveOrCopyActionActive()
                                                  ? isListOrPreview == 'L'
                                                      ? ListView.builder(
                                                          shrinkWrap: true,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemCount:
                                                              fileFilter()
                                                                  .length,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (context, index) {
                                                            DirectoryItem item =
                                                                fileFilter()
                                                                    .elementAt(
                                                                        index);

                                                            /*openMenuAnimateValuesFile
                                                              .add(false);
                                                          _animationControllerFile
                                                              .add( new AnimationController(
                                                            vsync: this,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    300),
                                                            upperBound: 0.5,
                                                          ));*/

                                                            return FileViewInListView(
                                                                item, index);
                                                          })
                                                      : buildGridView()
                                                  : Container(),
                                            ],
                                          ),
                                    isUploadingNewPage
                                        ? CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<
                                                    Color>(
                                                Get.theme.secondaryHeaderColor),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 100,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: Get.height * 0.1,
                        right: 15,
                        child: FloatingActionButton(
                          heroTag: "directoryDetail",
                          onPressed: () async {
                            int? fileUploadType;
                            await selectUploadType(
                              context,
                              invoiceEnable: false,
                              folderEnable: true,
                              word: true,
                              excel: true,
                              picture:
                                  widget.folderName != "Picture" ? true : false,
                            ).then((value) => fileUploadType = value);
                            print(fileUploadType);
                            print(fileUploadType);
                            if (fileUploadType == 0) {
                              _imgFromCamera();
                              return;
                            } else if (fileUploadType == 1) {
                              widget.folderName != "Picture"
                                  ? _uploadFilesFromDevice()
                                  : _uploadFilesFromDevicePicture();
                            } else if (fileUploadType == 2) {
                              String? directoryName = await showModalTextInput(
                                  context,
                                  AppLocalizations.of(context)!.newFolder,
                                  AppLocalizations.of(context)!.add);

                              if (directoryName != '') {
                                if (!await _controllerFiles.CreateDirectory(
                                    _controllerDB.headers(),
                                    UserId:
                                        _controllerDB.user.value!.result!.id,
                                    CustomerId: widget.customerId,
                                    ModuleTypeId:
                                        widget.fileManagerType!.typeId,
                                    OwnerId: widget.todoId,
                                    DirectoryName: widget.folderName! +
                                        "/" +
                                        directoryName!)) {
                                  await Future.delayed(Duration(seconds: 1));
                                  await refresh();
                                }
                              }
                            } else if (fileUploadType == 3) {
                              Get.to(() => FileGeneratorExcellorWord(
                                    isWord: true,
                                  ));
                            } else if (fileUploadType == 4) {
                              Get.to(() => FileGeneratorExcellorWord(
                                    isWord: false,
                                  ));
                            } else {
                              return;
                            }
                          },
                          backgroundColor: primaryYellowColor,
                          //Get.theme.primaryColor,
                          child: Icon(
                            Icons.post_add,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                  inAsyncCall: _controllerFiles.percenteg > 0 || _loadingFile,
                  progressIndicator: new CircularPercentIndicator(
                    circularStrokeCap: CircularStrokeCap.round,
                    radius: 100.0,
                    lineWidth: 10.0,
                    backgroundColor: Get.theme.primaryColor,
                    percent: (_controllerFiles.percenteg / 100) > 1
                        ? 1.0
                        : (_controllerFiles.percenteg / 100),
                    center: Container(
                      child: new Text(
                        "${_controllerFiles.percenteg}%",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    progressColor: Get.theme.secondaryHeaderColor,
                  )),
            );
    });
  }

  Expanded _folderLongPressActions(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            selectedFileIdList.length == 1
                ? Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: TopBarButton(
                        () => () async {
                              Get.to(() => DocumentAnalysis(
                                    fileId: selectedFileIdList.first,
                                  ));
                            },
                        Icons.query_stats),
                  )
                : Container(),

            TopBarButton(
                () => () async {
                      setState(() {
                        selectedFileIdList.clear();
                        itemsSelectedFolder.setAll(
                            0, itemsSelectedFolder.map((e) => false).toList());
                      });
                    },
                Icons.flaky), //UNCHECK SELECTED
            SizedBox(
              width: 7,
            ),
            TopBarButton(
                () => () async {
                      selectedFileIdList.forEach((selectedItemId) {
                        DirectoryItem selectedItem = _files.result!
                            .firstWhere((x) => x.id == selectedItemId);
                        DioDownloader([selectedItem.thumbnailUrl!], context);
                      });
                      //todo: dosya indirme işlemi durum bilgisine göre mesaj verdiricez
                      showToast(
                          AppLocalizations.of(context)!.fileDownloadStarted);
                    },
                Icons.file_download,
                iconasset: 'downloadInvoice'), //DOWNLOAD İŞLEMİ
            SizedBox(
              width: 7,
            ),
            // MOVE ACTION
            TopBarButton(
                () => () async {
                      if (!_controllerFiles.isMoveActionActive) {
                        _controllerFiles.FileIdList.addAll(selectedFileIdList);
                        _controllerFiles.FileIdList =
                            _controllerFiles.FileIdList.toSet().toList();

                        itemsSelectedFolder
                            .asMap()
                            .forEach((selectedFolderIndex, selection) {
                          for (int i = 0;
                              i <
                                  _files.result!
                                      .where((x) => x.folderName != null)
                                      .length;
                              i++) {
                            if (i == selectedFolderIndex && selection) {
                              print(widget.folderName! +
                                  "/" +
                                  _files.result!
                                      .where((x) => x.folderName != null)
                                      .elementAt(i)
                                      .folderName! +
                                  " ${i} : ${selectedFolderIndex}");

                              _controllerFiles.SourceDirectoryNameList.add(
                                  widget.folderName! +
                                      "/" +
                                      _files.result!
                                          .where((x) => x.folderName != null)
                                          .elementAt(i)
                                          .folderName!);
                            }
                          }
                        });
                        _controllerFiles.SourceDirectoryNameList =
                            _controllerFiles.SourceDirectoryNameList.toSet()
                                .toList();

                        _controllerFiles.update();
                        print(_controllerFiles.FileIdList);
                        print(_controllerFiles.SourceDirectoryNameList);
                      } else {
                        _controllerFiles.FileIdList.clear();
                        _controllerFiles.SourceDirectoryNameList.clear();
                        _controllerFiles.update();
                      }

                      await moveAndCopyAction(
                          context,
                          true,
                          AppLocalizations.of(context)!.action +
                              " " +
                              AppLocalizations.of(context)!.move);
                    },
                Icons.abc,
                iconasset: 'move'),
            SizedBox(
              width: 7,
            ),
            // COPY ACTION
            TopBarButton(
                () => () async {
                      if (!_controllerFiles.isCopyActionActive) {
                        _controllerFiles.FileIdList.addAll(selectedFileIdList);

                        _controllerFiles.FileIdList =
                            _controllerFiles.FileIdList.toSet().toList();

                        itemsSelectedFolder
                            .asMap()
                            .forEach((selectedFolderIndex, selection) {
                          for (int i = 0;
                              i <
                                  _files.result!
                                      .where((x) => x.folderName != null)
                                      .length;
                              i++) {
                            if (i == selectedFolderIndex && selection) {
                              print(widget.folderName! +
                                  "/" +
                                  _files.result!
                                      .where((x) => x.folderName != null)
                                      .elementAt(i)
                                      .folderName! +
                                  " ${i} : ${selectedFolderIndex}");

                              _controllerFiles.SourceDirectoryNameList.add(
                                  widget.folderName! +
                                      "/" +
                                      _files.result!
                                          .where((x) => x.folderName != null)
                                          .elementAt(i)
                                          .folderName!);
                            }
                          }
                        });
                        _controllerFiles.SourceDirectoryNameList =
                            _controllerFiles.SourceDirectoryNameList.toSet()
                                .toList();

                        _controllerFiles.update();
                      } else {
                        _controllerFiles.FileIdList.clear();
                        _controllerFiles.SourceDirectoryNameList.clear();
                        _controllerFiles.update();
                      }

                      await moveAndCopyAction(
                          context,
                          false,
                          AppLocalizations.of(context)!.action +
                              " " +
                              AppLocalizations.of(context)!.copy);
                    },
                Icons.copy_all,
                iconasset: 'copy3'),
            SizedBox(
              width: 7,
            ),
            // LABEL ACTION
            TopBarButton(
                () => () async {
                      await _onAlertExternalLabelInsert(context);
                    },
                Icons.label,
                iconasset: 'labels'),
            SizedBox(
              width: 7,
            ),
            // MAIL ACTION
            TopBarButton(
                () => () async {
                      _onAlertExternalIntive(context);
                    },
                Icons.mail,
                iconasset: 'mail'),
            SizedBox(
              width: 7,
            ),
            TopBarButton(
                () => () async {
                      if (!(selectedFileIdList.length > 0)) {
                        showWarningToast(AppLocalizations.of(context)!
                            .onlyFilesCanBeShareable);
                        return;
                      }

                      List<String> downloadTheseFiles = [];

                      selectedFileIdList.forEach((e) {
                        downloadTheseFiles.add(
                            _files.result!.firstWhere((x) => x.id == e).path!);
                      });

                      await FileShareFn(downloadTheseFiles, context);
                    },
                Icons.share,
                iconasset: 'shareinvoice'),
            SizedBox(
              width: 7,
            ),
            TopBarButton(
                () => () async {
                      bool isAccepted = await confirmDeleteWidget(context);
                      if (isAccepted) {
                        itemsSelectedFolder
                            .asMap()
                            .forEach((selectedFolderIndex, selection) {
                          for (int i = 0;
                              i <
                                  _files.result!
                                      .where((x) => x.folderName != null)
                                      .length;
                              i++) {
                            if (i == selectedFolderIndex && selection) {
                              print(widget.folderName! +
                                  "/" +
                                  _files.result!
                                      .where((x) => x.folderName != null)
                                      .elementAt(i)
                                      .folderName! +
                                  " ${i} : ${selectedFolderIndex}");

                              _controllerFiles.SourceDirectoryNameList.add(
                                  widget.folderName! +
                                      "/" +
                                      _files.result!
                                          .where((x) => x.folderName != null)
                                          .elementAt(i)
                                          .folderName!);
                            }
                          }
                        });
                        _controllerFiles.SourceDirectoryNameList =
                            _controllerFiles.SourceDirectoryNameList.toSet()
                                .toList();

                        _controllerFiles.update();

                        await DeleteMultiFileAndDirectory(
                            selectedFileIdList, CustomerId!);
                        setState(() {
                          selectedFileIdList.clear();
                        });
                        refresh();
                      } else {}
                    },
                Icons.delete,
                iconasset: 'delete'),
          ],
        ),
      ),
    );
  }

  Widget _chipCard(String label, int index) {
    return Container(
        height: 40,
        decoration: BoxDecoration(
          color: selectedLabelIndex == index
              ? Colors.grey[400]
              : HexColor('${selectedLabelsColor[index]}'),
          borderRadius: BorderRadius.circular(15),
          boxShadow: standartCardShadow(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              label,
            ),
          ),
        ));
  }

  bool showOnlyActionButtons(ControllerFiles c) =>
      selectionModeActive() || c.isCopyActionActive || c.isMoveActionActive;

  Future<void> moveAndCopyAction(
      BuildContext context, bool isMove, String title) async {
    FileManagerType fmt = await chooseFileManagerType(
        context, title, AppLocalizations.of(context)!.okey);

    print("Seçilen FileManagerType = " + fmt.toString());

    if (!(fmt == FileManagerType.CommonDocument ||
        fmt == FileManagerType.CommonTask)) {
      setState(() {
        if (isMove)
          _controllerFiles.isMoveActionActive =
              !_controllerFiles.isMoveActionActive;
        else
          _controllerFiles.isCopyActionActive =
              !_controllerFiles.isCopyActionActive;

        _controllerFiles.sourceDirectory = widget.folderName;
        _controllerFiles.sourceModuleTypeId = widget.fileManagerType!.typeId;
      });
    }

    if (fmt == FileManagerType.CommonDocument) {
      int commonId = (await chooseCommon(
          context,
          AppLocalizations.of(context)!.chooseBoard,
          AppLocalizations.of(context)!.okey,
          false))['CommonId'];

      if (isMove) {
        _controllerFiles.MoveDirectoryAndFile(_controllerDB.headers(),
            CustomerId: null,
            TargetModuleTypeId: fmt.typeId,
            TargetDirectoryName: "",
            SourceModuleTypeId: widget.fileManagerType!.typeId,
            SourceDirectoryNameList: _controllerFiles.SourceDirectoryNameList,
            FileIdList: _controllerFiles.FileIdList,
            TargetOwnerId: commonId,
            SourceOwnerId: null);
        refresh();
      } else {
        _controllerFiles.CopyDirectoryAndFile(_controllerDB.headers(),
            CustomerId: null,
            TargetModuleTypeId: fmt.typeId,
            TargetDirectoryName: "",
            SourceModuleTypeId: widget.fileManagerType!.typeId,
            SourceDirectoryNameList: _controllerFiles.SourceDirectoryNameList,
            FileIdList: _controllerFiles.FileIdList,
            TargetOwnerIdList: [commonId],
            SourceOwnerId: null);
      }
    } else if (fmt == FileManagerType.CommonTask) {
      int commonTodoId = (await chooseCommon(
          context,
          AppLocalizations.of(context)!.chooseProject,
          AppLocalizations.of(context)!.okey,
          true))['CommonTodoId'];

      if (isMove) {
        _controllerFiles.isMoveActionActive = true;
        _controllerFiles.update();
        await Get.to(
            CopyAndMovePage(
              userId: _controllerDB.user.value!.result!.id,
              folderName: "",
              hideHeader: false,
              fileManagerType: FileManagerType.CommonTask,
              todoId: commonTodoId,
              customerId: commonTodoId,
            ),
            fullscreenDialog: true);
        _controllerFiles.isMoveActionActive = false;
        _controllerFiles.update();
        /*
        _controllerFiles.MoveDirectoryAndFile(_controllerDB.headers(),
            CustomerId: null,
            TargetModuleTypeId: fmt.typeId,
            TargetDirectoryName: "",
            SourceModuleTypeId: widget.fileManagerType.typeId,
            SourceDirectoryNameList: _controllerFiles.SourceDirectoryNameList,
            FileIdList: _controllerFiles.FileIdList,
            TargetOwnerId: commonTodoId,
            SourceOwnerId: null);
        refresh();

         */
      } else if (fmt != FileManagerType.PrivateDocument) {
        _controllerFiles.isCopyActionActive = true;
        _controllerFiles.update();
        await Get.to(
            CopyAndMovePage(
              userId: _controllerDB.user.value!.result!.id,
              folderName: "",
              hideHeader: false,
              fileManagerType: FileManagerType.CommonTask,
              todoId: commonTodoId,
              customerId: commonTodoId,
            ),
            fullscreenDialog: true);
        _controllerFiles.isCopyActionActive = false;
        _controllerFiles.update();
        /*
        _controllerFiles.CopyDirectoryAndFile(_controllerDB.headers(),
            CustomerId: null,
            TargetModuleTypeId: fmt.typeId,
            TargetDirectoryName: "",
            SourceModuleTypeId: widget.fileManagerType.typeId,
            SourceDirectoryNameList: _controllerFiles.SourceDirectoryNameList,
            FileIdList: _controllerFiles.FileIdList,
            TargetOwnerIdList: [commonTodoId],
            SourceOwnerId: null);

         */
      }
    } else if (fmt == FileManagerType.PrivateDocument) {
      Get.to(
          CopyAndMovePage(
            userId: _controllerDB.user.value!.result!.id,
            folderName: "",
            hideHeader: false,
            fileManagerType: fmt,
            todoId: widget.todoId ?? widget.customerId,
          ),
          fullscreenDialog: true);
    } else {
      int selectedCustomerId = await ChooseCustomer(
          context,
          AppLocalizations.of(context)!.chooseCustomer,
          AppLocalizations.of(context)!.okey);

      Get.to(
          CopyAndMovePage(
            userId: _controllerDB
                .user.value!.result!.userCustomers!.userCustomerList!
                .firstWhere((e) => e.id == selectedCustomerId)
                .customerAdminId,
            customerId: selectedCustomerId,
            folderName: "",
            hideHeader: false,
            fileManagerType: fmt,
            todoId: widget.todoId ?? widget.customerId,
          ),
          fullscreenDialog: true);
    }
  }

  GestureDetector TopBarButton(Function onTap, IconData iconData,
      {String iconasset = ''}) {
    return GestureDetector(
      onTap: onTap(),
      child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            boxShadow: standartCardShadow(),
            borderRadius: BorderRadius.circular(10),
          ),
          child: iconasset != ''
              ? IconButton(
                  onPressed: onTap(),
                  icon: ImageIcon(
                    AssetImage(
                      'assets/images/icon/$iconasset.png',
                    ),
                    size: 24,
                    color: Colors.white,
                  ),
                )
              : Icon(iconData, size: 19, color: Colors.white)),
    );
  }

  List<DirectoryItem> fileFilter() {
    return _files.result!
        .where((x) =>
            x.fileName != null &&
            (txtSearchController.text != ""
                ? x.fileName!
                    .toLowerCase()
                    .contains(txtSearchController.text.toLowerCase())
                : true))
        .toList();
  }

  List<DirectoryItem> folderFilter() {
    return _files.result!
        .where((x) =>
            x.folderName != null &&
            (txtSearchController.text != ""
                ? x.folderName!
                    .toLowerCase()
                    .contains(txtSearchController.text.toLowerCase())
                : true))
        .toList();
  }

  buildGridView() {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: 250,
            maxCrossAxisExtent: useTabletLayout
                ? (Get.height > 1000 ? Get.width / 3 : Get.width / 4)
                : (Get.width / 2 - 14),
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 8),
        itemCount: fileFilter().length,
        itemBuilder: (BuildContext ctx, index) {
          DirectoryItem item = fileFilter().elementAt(index);
          bool isSelected = selectedFileIdList.contains(item.id);
          CustomerId = item.customerId;
          ModulType = item.moduleType;

          return GestureDetector(
            onTap: () async {
              if (selectionModeActive()) {
                setState(() {
                  if (isSelected)
                    selectedFileIdList.remove(item.id);
                  else
                    selectedFileIdList.add(item.id!);
                });
              } else
                await OpenFileFn(item);
            },
            onLongPress: () {
              setState(() {
                if (isSelected)
                  selectedFileIdList.remove(item.id);
                else
                  selectedFileIdList.add(item.id!);

                print(selectedFileIdList);
              });
              print(selectionModeActive());
            },
            child: Column(
              children: [
                Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 0.5),
                    gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          isSelected
                              ? Get.theme.primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                          isSelected
                              ? Get.theme.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          isSelected
                              ? Get.theme.primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          0.5,
                          1.0
                        ]),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 250,
                              width: (Get.width / 2 - 14),
                              child: CachedNetworkImage(
                                imageUrl: item.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  getImagePathByFileExtension(
                                      item.fileName!.split('.').last),
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.fitWidth,
                                ),
                                placeholder: (context, url) =>
                                    new CustomLoadingCircle(),
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              right: 5,
                              child: Image.asset(
                                getImagePathByFileExtension(
                                    item.fileName!.split('.').last),
                                width: 27,
                              ),
                            ),
                            Row(
                              children: item.labelList!.map((e) {
                                return Row(
                                  children: [
                                    Positioned(
                                      top: 10,
                                      left: 5,
                                      child: Image.asset(
                                        'assets/images/icon/labels.png',
                                        width: 25,
                                        height: 25,
                                        color: HexColor(e.color!),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(), // Convert the iterable to a list
                            ),
                            Positioned(
                              top: 0,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 25,
                                    width: Get.width / 2 - 27,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                              reverse: true,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemCount: _files
                                                      .result![index +
                                                          folderFilter().length]
                                                      .labelList!
                                                      .length ??
                                                  0,
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, a) {
                                                return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 4, left: 4),
                                                    child: Icon(
                                                      Icons.label,
                                                      color: HexColor(_files
                                                          .result![index +
                                                              folderFilter()
                                                                  .length]
                                                          .labelList![a]
                                                          .color!),
                                                    ));
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 25,
                                    width: Get.width / 2 - 27,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(left: 3),
                                            child: Text(
                                              item.createDateTime!.day
                                                      .toString() +
                                                  "." +
                                                  item.createDateTime!.month
                                                      .toString() +
                                                  "." +
                                                  item.createDateTime!.year
                                                      .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> OpenFileFn(DirectoryItem item) async {
    setState(() {
      _loadingFile = true;
    });
    await openFile(item);
    setState(() {
      _loadingFile = false;
    });
  }

  Widget FolderView(DirectoryItem item, index, bool moveActionActive) {
    print('itemlabelssss' + item.labelList.toString());
    var dateFormatter =
        new DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName);
    return InkWell(
      onLongPress: () {
        setState(() {
          //closeAllExpandedListItems();
          itemsSelectedFolder[index] = !itemsSelectedFolder[index];
        });
      },
      onTap: () {
        if (isAnyItemSelected()) {
          //closeAllExpandedListItems();
        }

        if (isAnyItemSelected()) {
          setState(() {
            itemsSelectedFolder[index] = !itemsSelectedFolder[index];
          });
        } else if (!isAnyItemSelected() || moveActionActive) {
          if (moveActionActive && !widget.canViewFolders!) {
            setState(() {
              print('seçili itemler bırakıldı taşıma için');
              print("itemsSelectedFolder : " + itemsSelectedFolder.toString());
            });
          } else {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new DirectoryDetailOldest(
                          userId: widget.userId ??
                              _controllerDB.user.value!.result!.id,
                          customerId: widget.customerId,
                          folderName:
                              widget.folderName! + "/" + item.folderName!,
                          hideHeader: widget
                              .hideHeader, // ilk hangisi verildiyse o şekilde devam etmeli
                          fileManagerType: widget
                              .fileManagerType, // ilk hangisi verildiyse o şekilde devam etmeli
                          todoId: widget.todoId ??
                              widget
                                  .customerId, // ilk hangisi verildiyse o şekilde devam etmeli
                          canViewFolders: widget.canViewFolders,
                        )));
          }
        }
      },
      child: AnimatedContainer(
        width: Get.width,
        height: 55, //openMenuAnimateValuesFolder[index] ? 125 : 80,
        duration: Duration(milliseconds: 350),
        color:
            itemsSelectedFolder[index] ? Color(0xFFdedede) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Icon(
                    Icons.folder_rounded,
                    color: Get.theme.colorScheme.surface,
                    size: 27,
                  )),
                  SizedBox(
                    height: 3,
                  ),
                  /*Text(
                      "${item.totalFileCount} ${AppLocalizations.of(context).directoryDetailItems}",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500)),*/
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.folderName!,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),

                              /* Text(
                                item.createDateTime == null
                                    ? AppLocalizations.of(context).noDate
                                    : "${dateFormatter.format(item.createDateTime)}",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )*/
                            ],
                          ),
                        ),
                        /*InkWell(
                          onTap: () {
                            /*if (!isAnyItemSelected()) {
                              setState(() {
                                if (openMenuAnimateValuesFolder[index]) {
                                  _animationControllerFolder[index]
                                    ..reverse(from: 0.5);
                                } else {
                                  _animationControllerFolder[index]
                                    ..forward(from: 0.0);
                                }
                                openMenuAnimateValuesFolder[index] =
                                    !openMenuAnimateValuesFolder[index];
                              });
                            }*/
                          },
                          child: Container(
                            width: 60,
                            height: 70,
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0).animate(_animationControllerFolder[index]),
                              child: Icon(Icons.expand_more),
                            ),
                          ),
                        )*/
                      ],
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 350),
                      height: 0, //openMenuAnimateValuesFolder[index] ? 35 : 0,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: AnimatedOpacity(
                        opacity:
                            0, //openMenuAnimateValuesFolder[index] ? 1 : 0,
                        duration: Duration(milliseconds: 350),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            expandMoreIcons(
                              () {},
                              Icons.drive_file_move,
                              false,
                            ),
                            expandMoreIcons(
                              () {},
                              Icons.content_copy,
                              false,
                            ),
                            expandMoreIcons(
                              () async {
                                String? newFolderName = await renameDirectory(
                                    await showModalTextInput(
                                      context,
                                      AppLocalizations.of(context)!
                                          .changeFolderName,
                                      AppLocalizations.of(context)!.save,
                                    ),
                                    item.folderName!,
                                    item.customerId!);

                                setState(() async {
                                  item.folderName = newFolderName;
                                });
                              },
                              Icons.edit_rounded,
                              false,
                            ),
                            expandMoreIcons(
                              () async {
                                bool? isAccepted = await showModalYesOrNo(
                                    context,
                                    AppLocalizations.of(context)!
                                        .deletingaFolder,
                                    '${item.folderName} ${AppLocalizations.of(context)!.folderwillbedeleted}\n${AppLocalizations.of(context)!.doyouconfirm}');

                                if (isAccepted!) await DeleteDirectory(item);
                              },
                              Icons.delete_rounded,
                              false,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isAnyItemSelected() =>
      selectedFileIdList.length > 0 || itemsSelectedFolder.contains(true);

  Widget FileViewInListView(DirectoryItem item, int index) {
    var dateFormatter =
        new DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName);

    bool isSelected = selectedFileIdList.contains(item.id);

    return InkWell(
      onTap: () async {
        if (selectionModeActive()) {
          setState(() {
            if (isSelected)
              selectedFileIdList.remove(item.id);
            else
              selectedFileIdList.add(item.id!);
          });
        } else
          await OpenFileFn(item);
      },
      onLongPress: () {
        setState(() {
          if (isSelected)
            selectedFileIdList.remove(item.id);
          else
            selectedFileIdList.add(item.id!);
        });
      },
      child: AnimatedContainer(
        width: Get.width,
        height: 65, //openMenuAnimateValuesFile[index] ? 125 : 80,
        duration: Duration(milliseconds: 350),
        color: isSelected ? Color(0xFFdedede) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      getImagePathByFileExtension(
                          item.fileName!.split('.').last),
                      width: 27,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.fileName!.length > 15
                                    ? item.fileName!
                                        .substring(item.fileName!.length - 15)
                                    : item.fileName!,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${dateFormatter.format(item.createDateTime!)}",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                        /*InkWell(
                          onTap: () {
                            /*if (!isAnyItemSelected()) {
                              setState(() {
                                if (openMenuAnimateValuesFile[index]) {
                                  _animationControllerFile[index]
                                    ..reverse(from: 0.5);
                                } else {
                                  _animationControllerFile[index]
                                    ..forward(from: 0.0);
                                }
                                openMenuAnimateValuesFile[index] =
                                    !openMenuAnimateValuesFile[index];
                              });
                            }*/
                          },
                          child: Container(
                            width: 60,
                            height: 70,
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_animationControllerFile[index]),
                              child: Icon(Icons.expand_more),
                            ),
                          ),
                        )*/
                      ],
                    ),
                    /*AnimatedContainer(
                      duration: Duration(milliseconds: 350),
                      height: openMenuAnimateValuesFile[index] ? 35 : 0,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: AnimatedOpacity(
                        opacity: openMenuAnimateValuesFile[index] ? 1 : 0,
                        duration: Duration(milliseconds: 350),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            expandMoreIcons(() {}, Icons.drive_file_move,
                                openMenuAnimateValuesFile[index]),
                            expandMoreIcons(() {}, Icons.content_copy,
                                openMenuAnimateValuesFile[index]),
                            expandMoreIcons(() async {
                              await RenameFile(item);
                            }, Icons.edit_rounded,
                                openMenuAnimateValuesFile[index]),
                            expandMoreIcons(() async {
                              if (await showModalYesOrNo(context, 'Dosya Silme',
                                  '${item.fileName} dosyası silenecek.\nOnaylıyor musunuz?')) {
                                if (await DeleteFile(item)) {
                                  setState(() {
                                    _files.result.removeWhere((x) =>
                                        x.id == item.id &&
                                        x.folderName == item.folderName);
                                    openMenuAnimateValuesFile[index] = false;
                                  });
                                }
                              }
                            }, Icons.delete_rounded,
                                openMenuAnimateValuesFile[index]),
                          ],
                        ),
                      ),
                    )*/
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool changed = true;

  _onAlertExternalLabelInsert(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (changed) {
              selectedLabelIndexes.clear();
              if (selectedFileIdList.length == 1)
                _files.result!
                    .firstWhere(
                        (element) => element.id == selectedFileIdList.first)
                    .labelList!
                    .forEach((label) {
                  cboLabelsList.asMap().forEach((index, availableLabel) {
                    if (availableLabel.key
                        .toString()
                        .contains(label.title.toString())) {
                      selectedLabelIndexes.add(index);
                      setState(() {});
                    }
                  });
                });
            }
            List<String> selectedableLabels = [];

            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.selectLabel,
                ),
                content: Container(
                  height: Get.height * 0.15,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
                      SearchableDropdown.multiple(
                        items: cboLabelsList,
                        selectedItems: selectedLabelIndexes,
                        hint: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(AppLocalizations.of(context)!.labels),
                        ),
                        onChanged: (value) {
                          changed = false;
                          setState(() {
                            if (!selectedLabels.isBlank!) {
                              selectedLabels.clear();
                            }
                            if (!selectedLabelAndFiles.labelIds.isBlank!) {
                              selectedLabelAndFiles.labelIds!.clear();
                            }

                            selectedLabelIndexes = value;
                            labelsList.asMap().forEach((index, value) {
                              selectedLabelIndexes
                                  .forEach((selectedLabelIndex) {
                                if (selectedLabelIndex == index) {
                                  selectedLabels.add(value.id!);
                                  selectedLabelAndFiles.labelIds!
                                      .add(LabelIds(labelId: value.id));
                                }
                              });
                            });
                          });
                          print(selectedLabelAndFiles.labelIds!.first.labelId);
                        },
                        displayItem: (item, selected) {
                          return (Row(children: [
                            selected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                  ),
                            SizedBox(width: 7),
                            Expanded(
                              child: item,
                            ),
                          ]));
                        },
                        selectedValueWidgetFn: (item) {
                          return Container(
                            decoration: BoxDecoration(
                                color: Color(0xFFdedede),
                                borderRadius: BorderRadius.circular(30)),
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: (Row(
                              children: [
                                Text(item.toString().split("+").first),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.lens,
                                  color: Color(int.parse(
                                      item
                                          .toString()
                                          .split("+")
                                          .last
                                          .replaceFirst('#', "FF"),
                                      radix: 16)),
                                ),
                              ],
                            )),
                          );
                        },
                        doneButton: (selectedItemsDone, doneContext) {
                          return (ElevatedButton(
                              onPressed: () {
                                Navigator.pop(doneContext);
                                setState(() {});
                              },
                              child: Text(AppLocalizations.of(context)!.save)));
                        },
                        closeButton: null,
                        style: Get.theme.inputDecorationTheme.hintStyle,
                        searchFn: (String keyword, items) {
                          List<int> ret = [];
                          if (items != null && keyword.isNotEmpty) {
                            keyword.split(" ").forEach((k) {
                              int i = 0;
                              items.forEach((item) {
                                if (k.isNotEmpty &&
                                    (item.value
                                        .toString()
                                        .toLowerCase()
                                        .contains(k.toLowerCase()))) {
                                  ret.add(i);
                                }
                                i++;
                              });
                            });
                          }
                          if (keyword.isEmpty) {
                            ret = Iterable<int>.generate(items.length).toList();
                          }
                          return (ret);
                        },
                        //clearIcon: Icons(null), todo:nullable yap
                        icon: Icon(
                          Icons.expand_more,
                          size: 31,
                        ),
                        underline: Container(
                          height: 0.0,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.teal, width: 0.0))),
                        ),
                        iconDisabledColor: Colors.grey,
                        iconEnabledColor: Get.theme.colorScheme.surface,
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      await InsertFileListLabelList(
                          selectedFileIdList, selectedLabels);
                      print(selectedLabels.first);
                      refresh();
                      changed = true;

                      Get.back();
                    },
                    color: Get.theme.primaryColor,
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }

  _onAlertExternalIntive(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.sendMail,
                ),
                content: Container(
                  height: 300,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Flexible(
                        child: Container(
                          width: Get.width,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(45),
                              boxShadow: standartCardShadow()),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              menuMaxHeight: 350,
                              value: selectedMailId,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontFamily: 'TTNorms',
                                  fontWeight: FontWeight.w500),
                              icon: Icon(
                                Icons.expand_more,
                                color: Colors.black,
                              ),
                              items: cmbEmails,
                              onChanged: (value) {
                                setState(() {
                                  print(value);
                                  if (value == 0) {
                                    selectedMailId = value;
                                    return;
                                  }
                                  selectedMail = _controllerUser
                                      .getUserEmailData.value!.result!
                                      .firstWhere(
                                          (element) => element.id == value)
                                      .userName;
                                  selectedMailId = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: selectedMailId != 0,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: TextField(
                            controller: _password,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .signInPasswordLabel,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _receiver,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.receiver,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _subject,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.subject,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.sendMessageMail,
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      SendEMail(
                          _receiver.text,
                          _subject.text,
                          _message.text,
                          selectedFileIdList,
                          0,
                          selectedMailId!,
                          _password.text);
                      setState(() {
                        _receiver.clear();
                        _subject.clear();
                        _message.clear();
                        _password.clear();
                      });

                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.sent,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    );
  }

  getUserEmailList() async {
    await _controllerUser.GetUserEmailList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, UserEmailId: 0)
        .then((value) {
      selectedMailId = 0;
      cmbEmails.add(DropdownMenuItem(
        value: 0,
        child: Text("Baulinx"),
      ));
      if (!(value.result.isBlank!)) {
        selectedMail = value.result?.first.userName;
        for (int i = 0; i < value.result!.length; i++) {
          cmbEmails.add(DropdownMenuItem(
            value: value.result![i].id,
            child: Text(value.result![i].userName ?? "USERNAME EMPTY"),
          ));
        }
      }
    });
    setState(() {});
  }

  _imgFromCamera() async {
    Get.to(() => CameraPage())!.then((value) async {
      bool isCombine = true;
      Files files = new Files();
      files.fileInput = <FileInput>[];

      if (value != null) {
        List<int> fileBytes = [];
        isCombine = value.length > 1 ? true : false;

        value.forEach((file) {
          fileBytes = new File(file.path).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          files.fileInput!.add(new FileInput(
              fileName: 'sample.jpg',
              directory: widget.folderName,
              fileContent: fileContent));
        });

        uploadFiles(files);
      }
    });
  }

  void uploadFiles(Files files) async {
    bool isCombine = false;
    print(widget.folderName);

    if (files.fileInput!.length > 1 && widget.folderName != "Picture") {
      bool? result = await showModalYesOrNo(
          context,
          AppLocalizations.of(context)!.fileUpload,
          AppLocalizations.of(context)!.doyouwanttocombinefiles);
      isCombine = result ?? false;
    }
    print(_controllerFiles.progres);
    return await widget.folderName != "Picture"
        ? _controllerFiles.UploadFiles(
            _controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CustomerId: widget.todoId ?? widget.customerId,
            ModuleTypeId: widget.fileManagerType!.typeId,
            files: files,
            OwnerId: widget.todoId ?? widget.customerId,
            IsCombine: isCombine,
            CombineFileName:
                widget.folderName != "Picture" ? "sample.pdf" : "sample.jpeg",
          ).then((value) async {
            await Future.delayed(Duration(seconds: 1));
            await refresh();
            //todo: apiden dönen resulta göre lokaldeki listeye eklenecek. hız için önemli
          })
        : _controllerFiles.UploadFilesToPrivate(
            _controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CustomerId: widget.todoId ?? widget.customerId,
            ModuleTypeId: widget.fileManagerType!.typeId,
            files: files,
            OwnerId: widget.todoId ?? widget.customerId,
            IsCombine: false,
            CombineFileName:
                widget.folderName != "Picture" ? "sample.jpeg" : "sample.jpeg",
          ).then((value) async {
            if (value)
              showToast(AppLocalizations.of(context)!.fileisnotuploaded);
            else {
              showToast(AppLocalizations.of(context)!.fileisuploaded);
              await Future.delayed(Duration(seconds: 1));
              //todo: apiden dönen resulta göre lokaldeki listeye eklenecek. hız için önemli
              await refresh();
            }
          });
  }

  Future<void> _uploadFilesFromDevice() async {
    String fileContent = "";
    bool isCombine = false;

    Files files = new Files();
    files.fileInput = <FileInput>[];

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
        allowMultiple: true);

    List<int> fileBytes = [];
    isCombine = result!.files.length > 1 ? true : false;

    result.files.forEach((file) {
      fileBytes = new File(file.path!).readAsBytesSync().toList();
      //todo: crop eklenecek
      String fileContent = base64.encode(fileBytes);
      files.fileInput!.add(new FileInput(
          fileName: 'sample.${result.files.first.path!.split(".").last}',
          directory: widget.folderName,
          fileContent: fileContent));
    });

    //await
    uploadFiles(
      files,
    );
  }

  Future<String> renameDirectory(String? newDirectoryName,
      String? currentDirectoryName, int? sourceOwnerId) async {
    return await _controllerFiles.RenameDirectory(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            ModuleTypeId: widget.fileManagerType!.typeId,
            DirectoryName: widget.folderName! + "${currentDirectoryName}",
            NewDirectoryName: newDirectoryName,
            SourceOwnerId: sourceOwnerId)
        .then((value) {
      if (value) {
        showToast(AppLocalizations.of(context)!.errorfailedtochangefoldername);
        return currentDirectoryName!;
      } else {
        showToast(AppLocalizations.of(context)!
            .thefoldernamehasbeensuccessfullychanged);
        return newDirectoryName!;
      }
    });
  }

  void RenameFile(DirectoryItem item) async {
    String? newFileName = await showModalTextInput(
            context,
            AppLocalizations.of(context)!.changefileName,
            AppLocalizations.of(context)!.save) ??
        "";
    if (newFileName.isEmpty || newFileName == "") return;
    await _controllerFiles.RenameFile(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            FileId: item.id,
            NewFileName: newFileName)
        .then((value) {
      if (value) {
        showToast(AppLocalizations.of(context)!.errorFailedtochangefilename);
      } else {
        showToast(AppLocalizations.of(context)!
            .thefilenamehasbeensuccessfullychanged);
        setState(() {
          item.fileName = newFileName;
        });
      }
    });
  }

  DeleteDirectory(DirectoryItem item) async {
    await _controllerFiles.DeleteDirectory(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CustomerId: null,
            ModuleTypeId: widget.fileManagerType!.typeId,
            DirectoryName: widget.folderName! + "${item.folderName}")
        .then((value) {
      if (value) {
        showToast(AppLocalizations.of(context)!.errorFailedtodeletefolder);
      } else {
        _files.result!.removeWhere(
            (x) => x.id == item.id && x.folderName == item.folderName);
        showToast(
            AppLocalizations.of(context)!.thefolderhasbeendeletedsuccessfully);
      }
    });
  }

  Future<bool> DeleteFile(DirectoryItem item) async {
    return await _controllerFiles.DeleteFile(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, FileId: item.id)
        .then((value) {
      if (value) {
        showToast(AppLocalizations.of(context)!.errorFailedtodeletefile);
        return false;
      } else {
        showToast(AppLocalizations.of(context)!.thefilewassuccessfullydeleted);
        return true;
      }
    });
  }

  Future<void> _uploadFilesFromDevicePicture() async {
    String fileContent = "";
    bool isCombine = false;

    Files files = new Files();
    files.fileInput = <FileInput>[];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpeg', 'jpg', 'png'],
        allowMultiple: true);

    List<int> fileBytes = [];
    isCombine = result!.files.length > 1 ? true : false;

    result.files.forEach((file) {
      fileBytes = new File(file.path!).readAsBytesSync().toList();
      //todo: crop eklenecek
      String fileContent = base64.encode(fileBytes);
      files.fileInput!.add(new FileInput(
          fileName: 'sample.${result.files.first.path!.split(".").last}',
          directory: widget.folderName,
          fileContent: fileContent));
    });

    uploadFiles(
      files,
    );
  }

  /*void closeAllExpandedListItems() {
    setState(() {
      print('--------------------');
      print(openMenuAnimateValuesFolder.length.toString());
      for (int i = 0; openMenuAnimateValuesFolder.length > i; i++) {
        print(openMenuAnimateValuesFolder[i]);
        if (openMenuAnimateValuesFolder[i]) {
          openMenuAnimateValuesFolder[i] = false;
          _animationControllerFolder[i].reset();
        }
      }
      for (int i = 0; openMenuAnimateValuesFile.length > i; i++) {
        print(openMenuAnimateValuesFile[i]);
        if (openMenuAnimateValuesFile[i]) {
          openMenuAnimateValuesFile[i] = false;
          _animationControllerFile[i].reset();
        }
      }
    });
  }*/
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());

  @override
  void dispose() {
    /*_animationControllerFile.asMap().forEach((key, value) {
      _animationControllerFile[key].dispose();
    });
    _animationControllerFolder.asMap().forEach((key, value) {
      _animationControllerFolder[key].dispose();
    });*/

    _controllerTodo.refreshNote = true;
    //   _controllerTodo.update();
    //  _controllerFiles.update();
    super.dispose();
  }

  void _cancelMove() {
    _controllerFiles.isMoveActionActive = false;
    _controllerFiles.removeCopyAndMovePage = true;
    _controllerFiles.update();
    showToast(AppLocalizations.of(context)!.migrationcanceled);
  }

  void _cancelCopy() {
    _controllerFiles.isCopyActionActive = false;
    _controllerFiles.removeCopyAndMovePage = true;
    _controllerFiles.update();
    showToast(AppLocalizations.of(context)!.migrationcanceled);
  }
}
