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
import 'package:undede/Pages/FileViewers/openFileFn.dart';
import 'package:undede/Pages/Private/CopyAndMovePage.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
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
import '../../Custom/DirectoryDetailSearch/DirectoryDetailSearch.dart';
import '../../Custom/dropdownSearchFn.dart';

class DirectoryDetailSelectFilePage extends StatefulWidget {
  String? folderName;
  int? userId; // report ve salary' de gelicek
  bool? hideHeader;
  FileManagerType? fileManagerType;
  int? todoId;
  int? customerId;
  bool
      canViewFolders; //kopyalama veya taşıma için açılan fullscreen modalda klasörleri gezebilmesi için
  String headerTitle;
  DirectoryDetailSelectFilePage(
      {this.folderName,
      this.userId,
      this.hideHeader = false,
      this.fileManagerType,
      this.todoId,
      this.customerId,
      this.canViewFolders = false,
      this.headerTitle = ""});

  @override
  _DirectoryDetailSelectFilePageState createState() =>
      _DirectoryDetailSelectFilePageState();
}

class _DirectoryDetailSelectFilePageState
    extends State<DirectoryDetailSelectFilePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool isLoading = true;
  String isListOrPreview = 'P'; // default preview geliyor.
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  FilesForDirectoryData _files = new FilesForDirectoryData();
  int page = 0;
  ScrollController _scrollController = new ScrollController();
  bool morePageExist = false;
  bool isUploadingNewPage = false;
  bool isMultipleChoiceExpanded = false;
  // multi Select
  selectionModeActive() => selectedFileId != null;
  int? selectedFileId;
  int? ModulType;
  int? CustomerId;
  // Mail

  TextEditingController txtSearchController = new TextEditingController();
  int? folderViewLeng;
  bool _loadingFile = false;

  bool firstOpen = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refresh();
      moduleName = AppLocalizations.of(context)!.private;
      setState(() {
        firstOpen = false;
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

    selectedFileId = null;

    await _controllerFiles.GetFilesByUserIdForDirectory(_controllerDB.headers(),
            userId: widget.userId ?? _controllerDB.user.value!.result!.id,
            customerId: widget.todoId ?? widget.customerId,
            moduleType: widget.fileManagerType!.typeId,
            directory: widget.folderName,
            page: 0)
        .then((value) async {
      if (value.hasError!) {
        return;
      }
      value.result!.result!
          .where((x) => x.folderName != null)
          .forEach((element) {});
      value.result!.result!
          .where((x) => x.fileName != null)
          .forEach((element) {});
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
              .forEach((element) {});
          value.result!.result!
              .where((x) => x.fileName != null)
              .forEach((element) {});

          _files.result!.addAll(value.result!.result!);
        } else
          morePageExist = false;
      }
    });

    setState(() {
      isUploadingNewPage = false;
    });
  }

  String moduleName = "";
  void selectFileManagerType(int value, int commonId, int commonTaskID) {
    if (value == 0) {
      widget.fileManagerType = FileManagerType.PrivateDocument;
      moduleName = AppLocalizations.of(context)!.private;
    } else if (value == 1) {
      widget.fileManagerType = FileManagerType.CommonTask;
      widget.todoId = commonTaskID;
      moduleName = AppLocalizations.of(context)!.collaborationTask;
    } else if (value == 2) {
      widget.fileManagerType = FileManagerType.CommonDocument;
      widget.todoId = commonId;
      moduleName = AppLocalizations.of(context)!.collaboration;
    }
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
      if (c.searchRefresh) {
        selectFileManagerType(
            c.searchModuleType, c.searchCommonId, c.searchCommonTaskId);
        refresh(withoutSetstate: true);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        }
        c.searchRefresh = false;
      }
      return ModalProgressHUD(
        inAsyncCall: isLoading,
        child: firstOpen
            ? CustomLoadingCircle()
            : Scaffold(
                key: scaffoldKey,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniStartFloat,
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.select,
                  actionWidget: Container(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: Row(
                        children: [
                          Text(
                            moduleName,
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.search,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                endDrawer: Drawer(child: DirectoryDetailSearch()),
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
                                        color:
                                            Get.theme.scaffoldBackgroundColor,
                                        margin: EdgeInsets.only(bottom: 3))),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          widget.folderName == "" ||
                                                  widget.folderName == "Picture"
                                              ? Container()
                                              : GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Icon(
                                                    Icons.chevron_left,
                                                    size: 31,
                                                  )),
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
                                                Text(
                                                  "${_files != null ? _files.totalCount : 0} "
                                                  "${AppLocalizations.of(context)!.directoryDetailItems.toLowerCase()}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15,
                                                      color: Colors.grey),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    widget.folderName!,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 11,
                                          ),
                                        ],
                                      ),
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
                                                    ? Get.theme.colorScheme
                                                        .surface
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
                                                    ? Get.theme.colorScheme
                                                        .surface
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
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        hint: AppLocalizations.of(context)!
                                            .search,
                                        prefixIcon: Icon(Icons.search),
                                        controller: txtSearchController,
                                        onChanged: (e) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 11,
                                    ),
                                    Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: standartCardShadow(),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Icon(
                                          Icons.arrow_circle_up_outlined,
                                          color: Get.theme.primaryColor,
                                        )),
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
                                                                (context,
                                                                    index) {
                                                              DirectoryItem
                                                                  item =
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Get.theme
                                                          .secondaryHeaderColor),
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
                          bottom: 10,
                          right: 15,
                          child: FloatingActionButton(
                            heroTag: "directoryDetailSelectFile",
                            onPressed: () async {
                              print(selectedFileId);
                              print(fileFilter()
                                  .where(
                                      (element) => element.id == selectedFileId)
                                  .first
                                  .thumbnailUrl);
                              Navigator.pop(context, {
                                "selectedFileId": selectedFileId,
                                "imageUrl": fileFilter()
                                    .where((element) =>
                                        element.id == selectedFileId)
                                    .first
                                    .thumbnailUrl,
                                "pathPdf": fileFilter()
                                    .where((element) =>
                                        element.id == selectedFileId)
                                    .first
                                    .path
                              });
                            },
                            backgroundColor: Get.theme.primaryColor,
                            child: Icon(
                              Icons.arrow_forward,
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
              ),
      );
    });
  }

  List<DirectoryItem> fileFilter() {
    return _files.result!
        .where((x) => (txtSearchController.text != ""
            ? x.fileName!
                .toLowerCase()
                .contains(txtSearchController.text.toLowerCase())
            : true))
        .toList();
  }

  List<DirectoryItem> folderFilter() {
    return _files.result!
        .where((x) => (txtSearchController.text != ""
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
          CustomerId = item.customerId;
          ModulType = item.moduleType;

          return GestureDetector(
            onTap: () async {
              setState(() {
                if (selectedFileId != item.id)
                  selectedFileId = item.id;
                else
                  selectedFileId = null;
              });
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
                          selectedFileId == item.id
                              ? Get.theme.primaryColor.withOpacity(0.5)
                              : Colors.transparent,
                          selectedFileId == item.id
                              ? Get.theme.primaryColor.withOpacity(0.5)
                              : Colors.transparent,
                          selectedFileId == item.id
                              ? Get.theme.primaryColor.withOpacity(0.5)
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

  Widget FolderView(DirectoryItem item, index, bool moveActionActive) {
    var dateFormatter =
        new DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName);
    return InkWell(
      child: AnimatedContainer(
        width: Get.width,
        height: 55, //openMenuAnimateValuesFolder[index] ? 125 : 80,
        duration: Duration(milliseconds: 350),
        color: Colors.transparent,
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
                              () async {},
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

  Widget FileViewInListView(DirectoryItem item, int index) {
    var dateFormatter =
        new DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName);

    return InkWell(
      onTap: () async {
        setState(() {
          if (selectedFileId != (item.id))
            selectedFileId = (item.id);
          else
            selectedFileId = null;
        });
      },
      child: AnimatedContainer(
        width: Get.width,
        height: 65, //openMenuAnimateValuesFile[index] ? 125 : 80,
        duration: Duration(milliseconds: 350),
        color:
            selectedFileId == item.id ? Color(0xFFdedede) : Colors.transparent,
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

  @override
  void dispose() {
    super.dispose();
  }
}
