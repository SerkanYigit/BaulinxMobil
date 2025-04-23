import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/openFileInvoice.dart';
import 'package:undede/Custom/showModalMoveInvoiceFiles.dart';
import 'package:undede/Custom/showModalTargetAccountList.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/JpgView.dart';
import 'package:undede/Pages/PDFCreater/ProductClass.dart';
import 'package:undede/Pages/PDFCreater/ProductCreaterPage.dart';
import 'package:undede/Pages/PDFView.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/confirmDeleteWidget.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Invoice/%C4%B0nvoicePosition.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:undede/model/Invoice/InsertOfferResult.dart';
import 'package:undede/model/Invoice/InvoiceFileInsertFiles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

class DirectoryDetailIWD extends StatefulWidget {
  final String? folderName;
  final bool? hideHeader;
  final FileManagerType? fileManagerType;
  final int? todoId;
  final int? customerId;
  final int? customerAdminId;
  final int? invoiceBlock;
  final BuildContext? baseContext;
  final int? SelectedInvoiceTargetAccount;
  final int? TaxAccountId;
  final String? SearchDescription;
  final double? WithTaxValue;
  final double? WithOutTaxValue;
  final int? SelectedAccountType;
  final ControllerInvoice? controllerInvoice;
  final int? invoiceType;

  DirectoryDetailIWD(
      {this.folderName,
      this.hideHeader = false,
      this.fileManagerType,
      this.todoId,
      this.customerId,
      this.customerAdminId,
      this.invoiceBlock,
      this.baseContext,
      this.SelectedInvoiceTargetAccount,
      this.TaxAccountId,
      this.SearchDescription,
      this.WithTaxValue,
      this.WithOutTaxValue,
      this.SelectedAccountType,
      this.controllerInvoice,
      this.invoiceType});

  @override
  _DirectoryDetailIWDState createState() => _DirectoryDetailIWDState();
}

class _DirectoryDetailIWDState extends State<DirectoryDetailIWD> {
  final GlobalKey<RefreshIndicatorState>? _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isLoading = true;
  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  int? selectedMonth;
  int? selectedYear;
  int itemCountOnPage = Get.height > 1000 ? 12 : 6;
  int page = 0;
  ScrollController _scrollController = new ScrollController();
  bool morePageExist = true;
  bool isUploadingNewPage = false;
  bool isListView = false;
  int? selectedType;

  List<bool> openMenuAnimateValue = [];
  //GetInvoiceListResult _invoiceListResult = new GetInvoiceListResult();
  final selectedMonthKey = GlobalKey();
  List<String> months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];

  bool selectionModeActive = false;
  List<int> selectedInvoiceItemsFileId = [];
  List<int> selectedInvoiceItemsId = [];

  // mail
  ControllerUser _controllerUser = Get.put(ControllerUser());
  String? selectedMail;
  int? selectedMailId;
  TextEditingController _password = TextEditingController();
  TextEditingController _message = TextEditingController();
  TextEditingController _receiver = TextEditingController();
  TextEditingController _subject = TextEditingController();
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  List<DropdownMenuItem> cmbEmails = [];

  // inserLabelList
  ControllerLabel controllerLabel = Get.put(ControllerLabel());
  GetLabelByUserIdResult _getLabelByUserIdResult =
      GetLabelByUserIdResult(hasError: false);
  final List<DropdownMenuItem> cboLabelsList = [];
  List<int> selectedLabels = [];
  List<int> selectedLabelIndexes = [];
  List<UserLabel> labelsList = [];
  // Get Invoice Label
  ControllerLabel _controllerLabel = ControllerLabel();
  bool _loadingFile = false;
  // Get GetInvoicePeriodListResult

  int i = 5;
  SendEMail(String Receivers, String Subject, String Message,
      List<int> Attachtments, int Type, int UserEmailId, String Password) {
    _controllerFiles.SendEMail(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        Receivers: Receivers,
        Subject: Subject,
        Message: Message,
        Attachtments: Attachtments,
        Type: Type,
        UserEmailId: UserEmailId,
        Password: Password);
  }

  InsertFileListLabelList(List<int> FilesIds, List<int> LabelIds) {
    controllerLabel.InsertFileListLabelList(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        FilesIds: FilesIds,
        LabelIds: LabelIds);
  }

  var oCcy = new NumberFormat("#,##0.00", "de_DE");

  @override
  void initState() {
    super.initState();
    selectedMonth = _controllerInvoice.selectedMonth;
    selectedYear = _controllerInvoice.selectedYear;
    selectedType = 0;
    _scrollController.addListener(() async {
      if (!isUploadingNewPage &&
          _scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        if (morePageExist) {
          await loadMore();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refresh(invoiceType: widget.invoiceType!);
      await getLabelByUserId();
      if (mounted) {
        await getUserEmailList();
      }

      await GetInvoicePeriodList(DateTime.now().year);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future scrollToSelectedMonth() async {
    print(selectedMonth);
    final contextMonth = selectedMonthKey.currentContext;
    await Scrollable.ensureVisible(contextMonth!,
        alignment: 0.5, duration: Duration(milliseconds: 500));
  }

  getLabelByUserId() async {
    print("GetLabelByUserId");
    await controllerLabel.GetLabelByUserId(_controllerDB.headers(),
            Id: 0, UserId: _controllerDB.user.value!.result!.id, CustomerId: 0)
        .then((value) {
      labelsList = value.result!;
      List.generate(controllerLabel.getLabel.value!.result!.length, (index) {
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
      });
    });
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
      if (!value.result.isBlank!) {
        selectedMail = value.result!.first.userName;
        for (int i = 0; i < value.result!.length; i++) {
          cmbEmails.add(DropdownMenuItem(
            value: value.result![i].id,
            child: Text(value.result![i].userName!),
          ));
        }
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> refresh(
      {bool withoutSetstate = false, int invoiceType = 0}) async {
    if (!withoutSetstate) {
      setState(() {
        isLoading = true;
        page = 0;
      });
    }

    print('blockcount' + widget.invoiceBlock.toString());
    await _controllerInvoice.GetInvoiceList(_controllerDB.headers(),
            invoiceType: invoiceType,
            userId: widget.customerAdminId,
            year: selectedYear,
            month: selectedMonth,
            invoiceBlock: widget.invoiceBlock,
            page: 0,
            size: itemCountOnPage,
            invoiceTargetAccountId: widget.SelectedInvoiceTargetAccount,
            TaxAccountId: widget.TaxAccountId,
            WithTaxValue: widget.WithTaxValue,
            WithOutTaxValue: widget.WithOutTaxValue,
            SearchDescription: widget.SearchDescription)
        .then((value) async {
      //_invoiceListResult = value;
      _controllerInvoice.invoices = value.result!.invoiceListResponse!;
      i = value.result!.invoiceListResponse!.length;
      print("widget.invoiceBlock" + widget.invoiceBlock.toString());
      for (int i = 0; i < value.result!.invoiceListResponse!.length; i++) {
        await _controllerLabel.GetFileLabelList(_controllerDB.headers(),
                UserId: _controllerDB.user.value!.result!.id,
                FilesId: value.result!.invoiceListResponse![i].fileId)
            .then((value) {
          //_invoiceListResult.result.invoiceListResponse[i].todoLabels = value;
          _controllerInvoice.invoices[i].todoLabels = value;
        });
      }

      if (value.result!.totalPage! > 0)
        morePageExist = true;
      else
        morePageExist = false;
    });

    //0- incomeunpaid 1-inpaid 2- outunpaid 3-outpaid
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadMore() async {
    setState(() {
      page++;
      isUploadingNewPage = true;
    });

    print(widget.customerAdminId);

    await _controllerInvoice.GetInvoiceList(_controllerDB.headers(),
            userId: widget.customerAdminId,
            year: selectedYear,
            month: selectedMonth,
            invoiceBlock: widget.invoiceBlock,
            page: page,
            size: itemCountOnPage,
            invoiceTargetAccountId: widget.SelectedAccountType,
            TaxAccountId: widget.TaxAccountId,
            WithTaxValue: widget.WithTaxValue,
            WithOutTaxValue: widget.WithOutTaxValue,
            SearchDescription: widget.SearchDescription)
        .then((invoiceListResponse) async {
      if (invoiceListResponse.hasError!) {
        print(invoiceListResponse.resultCode! + " hata");
      } else {
        if (invoiceListResponse.result!.invoiceListResponse!.length > 0) {
          for (int j = 0;
              j < invoiceListResponse.result!.invoiceListResponse!.length;
              j++) {
            await _controllerLabel.GetFileLabelList(_controllerDB.headers(),
                    UserId: _controllerDB.user.value!.result!.id,
                    FilesId: invoiceListResponse
                        .result!.invoiceListResponse![j].fileId)
                .then((value) {
              invoiceListResponse.result!.invoiceListResponse![j].todoLabels =
                  value;
            });
            i++;
          }

          _controllerInvoice.invoices
              .addAll(invoiceListResponse.result!.invoiceListResponse!);
        } else
          morePageExist = false;
      }
    });

    //0- incomeunpaid 1-inpaid 2- outunpaid 3-outpaid

    setState(() {
      isUploadingNewPage = false;
    });
  }

  DeleteInvoiceList(List<int> InvoiceIdList) async {
    await _controllerInvoice.DeleteInvoiceList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            InvoiceIdList: InvoiceIdList)
        .then((value) {
      if (value)
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.deleted,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
    });
  }

  bool isLoadingForYears = true;
  GetInvoicePeriodList(int Year) async {
    await _controllerInvoice.GetInvoicePeriodList(_controllerDB.headers(),
            CustomerId: widget.customerId,
            Year: Year,
            Language: mounted ? AppLocalizations.of(context)!.date : "de")
        .then((value) {});
    if (mounted) {
      setState(() {
        isLoadingForYears = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    double horizontalPadding;
    if (useTabletLayout && Get.height > 1000) {
      horizontalPadding = 8.0;
    } else if (useTabletLayout && Get.height > 600) {
      horizontalPadding = 20.0;
    } else {
      horizontalPadding = 0.0;
    }
    return GetBuilder<ControllerInvoice>(builder: (c) {
      if (c.refreshIWD) {
        refresh(withoutSetstate: true);
        c.refreshIWD = false;
        c.update();
      }
      return Scaffold(
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
                      widget.hideHeader!
                          ? Container()
                          : Container(
                              width: Get.width,
                              height: 120,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Icon(
                                                    Icons.chevron_left,
                                                    color: Colors.white,
                                                    size: 31,
                                                  ),
                                                ),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child: Image.network(
                                                      _controllerDB.user.value!
                                                          .result!.photo!,
                                                      height: 30,
                                                      width: 30,
                                                      fit: BoxFit.cover),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ]),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      height: 20,
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color:
                                            Get.theme.scaffoldBackgroundColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    SizedBox(
                      height: widget.hideHeader! ? 0 : 10,
                    ),
                    selectionModeActive
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                _customIconsWithBackground(
                                    isListView
                                        ? 'assets/images/icon/description.png'
                                        : 'assets/images/icon/formallist.png',
                                    Colors.black, () {
                                  setState(() {
                                    setState(() {
                                      isListView = !isListView;
                                    });
                                  });
                                }),
                                SizedBox(
                                  width: 2,
                                ),
                                _customIconsWithBackground(
                                    'assets/images/icon/vote.png', Colors.black,
                                    () {
                                  setState(() {
                                    selectedInvoiceItemsFileId.clear();
                                    selectedInvoiceItemsId.clear();
                                    selectionModeActive = false;
                                  });
                                }),
                                SizedBox(
                                  width: 2,
                                ),
                                _customIconsWithBackground(
                                    'assets/images/icon/downloadInvoice.png',
                                    Colors.black, () {
                                  setState(() {
                                    selectedInvoiceItemsFileId.clear();
                                    selectedInvoiceItemsId.clear();
                                    selectionModeActive = false;
                                  });
                                }),
                                SizedBox(
                                  width: 2,
                                ),
                                _customIconsWithBackground(
                                    'assets/images/icon/label.png',
                                    Colors.black, () async {
                                  await _onAlertExternalLabelInsert(context);
                                }),
                                SizedBox(
                                  width: 2,
                                ),
                                _customIconsWithBackground(
                                    'assets/images/icon/letter.png',
                                    Colors.black, () async {
                                  _onAlertExternalIntive(context);
                                }),
                                SizedBox(
                                  width: 2,
                                ),
                                _customIconsWithBackground(
                                    'assets/images/icon/foldermove.png',
                                    Colors.black, () async {
                                  if (_controllerInvoice
                                          .getInvoicePeriod.value!.result!
                                          .firstWhere((element) =>
                                              element.month ==
                                              _controllerInvoice.selectedMonth)
                                          .status ==
                                      0) {
                                    var result = await showModalMoveInvoiceFiles(
                                        context,
                                        widget.invoiceBlock!,
                                        AppLocalizations.of(context)!.moveFiles,
                                        AppLocalizations.of(context)!.move,
                                        selectedInvoiceItemsFileId.length == 1
                                            ? _controllerInvoice.invoices
                                                .where((e) =>
                                                    e.invoiceBlock ==
                                                    widget.invoiceBlock)
                                                .firstWhere((element) =>
                                                    element.fileId ==
                                                    selectedInvoiceItemsFileId
                                                        .first)
                                                .invoiceTargetAccountId!
                                            : 0);
                                    print(result);
                                    if (result['Accept']) {
                                      List<Invoice> movedItems = [];
                                      selectedInvoiceItemsFileId.forEach((e) {
                                        Invoice movedItem = _controllerInvoice
                                            .invoices
                                            .where((e) =>
                                                e.invoiceBlock ==
                                                widget.invoiceBlock)
                                            .firstWhere((x) => x.fileId == e);
                                        movedItem.year = result['Year'];
                                        movedItem.month = result['Month'];
                                        movedItem.invoiceBlock =
                                            result['InvoiceBlock'];
                                        movedItem.invoiceTargetAccountId =
                                            result['TargetAccountId'];
                                        movedItems.add(movedItem);
                                      });

                                      DataLayoutAPI dlApi =
                                          await _controllerInvoice
                                              .InvoiceMultiUpdate(
                                                  _controllerDB.headers(),
                                                  UserId: _controllerDB
                                                      .user.value!.result!.id,
                                                  InvoiceList: movedItems);

                                      if (!dlApi.hasError!) {
                                        await refresh();
                                      }
                                    }
                                  }
                                }),
                                SizedBox(
                                  width: 2,
                                ),
                                _customIconsWithBackground(
                                    'assets/images/icon/shareinvoice.png',
                                    Colors.black, () async {
                                  List<String> downloadTheseFiles = [];

                                  selectedInvoiceItemsId.forEach((e) {
                                    downloadTheseFiles.add(FilterInvoice()
                                        .firstWhere((x) => x.id == e)
                                        .file!
                                        .path!);
                                  });

                                  await FileShareFn(
                                      downloadTheseFiles, context);
                                }),
                                SizedBox(
                                  width: 2,
                                ),
                                _customIconsWithBackground(
                                    'assets/images/icon/delete.png',
                                    Colors.black, () async {
                                  if (_controllerInvoice.invoices
                                      .where((element) => selectedInvoiceItemsId
                                          .contains(element.id))
                                      .any((value) =>
                                          value.handCreatedInvoice != null)) {
                                    return;
                                  }

                                  if (_controllerInvoice
                                          .getInvoicePeriod.value!.result!
                                          .firstWhere((element) =>
                                              element.month ==
                                              _controllerInvoice.selectedMonth)
                                          .status ==
                                      0) {
                                    bool isAccepted =
                                        await confirmDeleteWidget(context);
                                    if (isAccepted) {
                                      await DeleteInvoiceList(
                                          selectedInvoiceItemsId);

                                      setState(() {
                                        selectedInvoiceItemsId.clear();
                                        selectedInvoiceItemsFileId.clear();
                                        selectionModeActive = false;
                                      });
                                      await refresh();
                                    }
                                  }
                                }),
                              ],
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(45),
                                      child: ScrollablePositionedList.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: months.length,
                                        initialScrollIndex: selectedMonth! - 1,
                                        initialAlignment: 0.5,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: horizontalPadding),
                                            child: GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  selectedMonth = index + 1;
                                                  _controllerInvoice
                                                          .selectedMonth =
                                                      selectedMonth!;
                                                });
                                                await refresh();
                                                await scrollToSelectedMonth();
                                              },
                                              child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  key:
                                                      selectedMonth == index + 1
                                                          ? selectedMonthKey
                                                          : null,
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  decoration: BoxDecoration(
                                                      color: _controllerInvoice
                                                                  .getInvoicePeriod.value ==
                                                              null
                                                          ? Colors.white
                                                          : _controllerInvoice
                                                                      .getInvoicePeriod
                                                                      .value!
                                                                      .result![
                                                                          index]
                                                                      .status ==
                                                                  0
                                                              ? Color(
                                                                  0xFF0cab69)
                                                              : _controllerInvoice.getInvoicePeriod.value!.result![index].status ==
                                                                      1
                                                                  ? Color(
                                                                      0xFFffa500)
                                                                  : Colors.red,
                                                      boxShadow:
                                                          standartCardShadow(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: selectedMonth! - 1 == index
                                                              ? Color(0x0ff0079bf)
                                                              : Colors.transparent,
                                                          width: 4)),
                                                  child: Center(child: Text(months[index]))),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .selectYear),
                                          content: Container(
                                            // Need to use container to add size constraint.
                                            width: 300,
                                            height: 300,
                                            child: YearPicker(
                                              firstDate: DateTime(
                                                  DateTime.now().year - 7, 1),
                                              lastDate: DateTime(
                                                  DateTime.now().year + 7, 1),
                                              initialDate: DateTime.now(),
                                              selectedDate:
                                                  DateTime(selectedYear!),
                                              onChanged:
                                                  (DateTime dateTime) async {
                                                Navigator.pop(context);
                                                await GetInvoicePeriodList(
                                                    dateTime.year);
                                                setState(() {
                                                  selectedYear = dateTime.year;
                                                  _controllerInvoice
                                                          .selectedYear =
                                                      dateTime.year;
                                                  refresh();
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                      width: 70,
                                      height: 35,
                                      margin: EdgeInsets.only(right: 5),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                        color: Get.theme.colorScheme.surface,
                                        boxShadow: standartCardShadow(),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(selectedYear.toString()),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isListView = !isListView;
                                    });
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Get.theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isListView
                                          ? Icons.description_outlined
                                          : Icons.format_list_bulleted,
                                      size: 21,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                isLoading
                                    ? CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Get.theme.secondaryHeaderColor),
                                      )
                                    : _controllerInvoice.invoices.length == 0
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                top: useTabletLayout
                                                    ? Get.height / 3
                                                    : Get.height / 5),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                widget.invoiceType == 2
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .documentNotUploadedType2
                                                    : widget.invoiceType == 3
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .documentNotUploadedType3
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .documentNotUploadedYet,
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                          )
                                        : (isListView
                                            ? buildListviewMode()
                                            : buildPreviewMode()),
                              ],
                            ),
                            isUploadingNewPage
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
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
              useTabletLayout
                  ? Positioned(
                      bottom: 140,
                      left: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Get.theme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Get.theme.primaryColor, width: 1)),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 30,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      _controllerInvoice.invoices.length
                                          .toString(),
                                      style: TextStyle(fontSize: 16)),
                                ),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Get.theme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Get.theme.primaryColor, width: 1)),
                              child: Text(
                                  "${AppLocalizations.of(context)!.symbol} ${oCcy.format(_controllerInvoice.totalAmount)}",
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ))
                  : SizedBox(),
              selectionModeActive
                  ? Container()
                  : _controllerInvoice.getInvoicePeriod.value == null
                      ? Container()
                      : ((_controllerInvoice.getInvoicePeriod.value!.result!
                                      .firstWhere((element) =>
                                          element.month ==
                                          _controllerInvoice.selectedMonth)
                                      .status ==
                                  0) ||
                              (_controllerInvoice
                                      .getInvoicePeriod.value!.result!
                                      .firstWhere((element) =>
                                          element.month ==
                                          _controllerInvoice.selectedMonth)
                                      .status ==
                                  1))
                          ? Positioned(
                              bottom: 140,
                              right: 30,
                              child: FloatingActionButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                heroTag: "directoryDetailWD.",
                                onPressed: () async {
                                  int? fileUploadType;
                                  await selectUploadType(context,
                                          invoiceType: widget.invoiceType!,
                                          invoice: _controllerDB
                                                      .user
                                                      .value!
                                                      .result!
                                                      .userCustomers!
                                                      .userCustomerList!
                                                      .firstWhere(
                                                        (element) =>
                                                            element.id ==
                                                            _controllerDB
                                                                .user
                                                                .value!
                                                                .result!
                                                                .customerId!,
                                                        /*     orElse: ()
                                                       {
                                                return;
                                              }*/
                                                      )
                                                      .customerAdminId ==
                                                  widget.customerAdminId &&
                                              (widget.invoiceBlock == 1 ||
                                                  widget.invoiceBlock == 2))
                                      .then((value) => fileUploadType = value);
                                  if (fileUploadType.isBlank!) {
                                    return;
                                  }
                                  String fileContent = "";
                                  InvoiceFileInsertFiles files =
                                      new InvoiceFileInsertFiles();
                                  files.fileInput = [];
                                  bool isCombine = false;

                                  if (fileUploadType == 0) {
                                    _imgFromCamera();
                                    return;
                                  } else if (fileUploadType == 1) {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: [
                                              'pdf',
                                              'jpeg',
                                              'jpg',
                                              'png',
                                              'xls',
                                              'docx',
                                              'xlsx',
                                              'doc',
                                            ],
                                            allowMultiple: true);

                                    bool imageFlag = true;
                                    for (int i = 0;
                                        result!.names.length > i;
                                        i++) {
                                      String fileName =
                                          result.names[i]!.toLowerCase();
                                      if (fileName.contains('.pdf') &&
                                          result.names.length > 1) {
                                        imageFlag = false;
                                        showToast(AppLocalizations.of(context)!
                                            .multiplepdffilescannotbeuploaded);
                                        return;
                                      }
                                      if (!imageFlag) {
                                        showToast(AppLocalizations.of(context)!
                                            .thepdfcannotbeloadedwiththeimage);
                                        return;
                                      }
                                    }

                                    List<int> fileBytes = [];
                                    isCombine =
                                        result.files.length > 1 ? true : false;
                                    if (imageFlag) {
                                      result.files.forEach((file) {
                                        fileBytes = new File(file.path!)
                                            .readAsBytesSync()
                                            .toList();
                                        fileContent = base64.encode(fileBytes);
                                        files.fileInput!.add(new FileInput(
                                            fileName:
                                                'sample.${result.files.first.path!.split(".").last}',
                                            fileContent: fileContent));
                                      });
                                    } else {
                                      fileBytes =
                                          File(result.files.single.path!)
                                              .readAsBytesSync();
                                      fileContent = base64.encode(fileBytes);
                                    }
                                  } else if (fileUploadType == 2) {
                                    List<int> fileBytes = [];
                                    var data =
                                        await Get.to(() => ProductCreaterPage(
                                              invoiceType: widget.invoiceType!,
                                            ));
                                    print(data);
                                    fileBytes = File(data).readAsBytesSync();
                                    fileContent = base64.encode(fileBytes);
                                    files.fileInput!.add(new FileInput(
                                        fileName: 'sample.pdf',
                                        fileContent: fileContent));
                                  }
                                  print("isCombine : " + isCombine.toString());
                                  if (files.fileInput != null) {
                                    await uploadInvoiceFile(files,
                                        products: _controllerInvoice.products,
                                        MyCustomer:
                                            _controllerInvoice.MyCustomer!,
                                        CreatedForUserId: _controllerInvoice
                                            .CreatedForUserId!,
                                        InvoiceName:
                                            _controllerInvoice.InvoiceName!,
                                        InvoiceNumber:
                                            _controllerInvoice.InvoiceNumber!);
                                  }
                                  await refresh();
                                  _controllerInvoice.products.clear();
                                  _controllerInvoice.update();
                                },
                                backgroundColor: Get.theme.primaryColor,
                                child: Icon(
                                  Icons.post_add,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : Container()
            ],
          ),
          inAsyncCall: _controllerInvoice.percenteg > 0 || _loadingFile,
          progressIndicator: new CircularPercentIndicator(
            circularStrokeCap: CircularStrokeCap.round,
            radius: 100.0,
            lineWidth: 10.0,
            backgroundColor: Get.theme.primaryColor,
            percent: (_controllerInvoice.percenteg / 100) > 1
                ? 1.0
                : (_controllerInvoice.percenteg / 100),
            center: Container(
              child: new Text(
                "${_controllerInvoice.percenteg}%",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            progressColor: Get.theme.secondaryHeaderColor,
          ),
          color: Get.theme.secondaryHeaderColor.withOpacity(0.5),
        ),
      );
    });
  }

  Padding _customIconsWithBackground(
      String iconPath, Color color, Function onPressed) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: Get.width * 0.095,
        height: 35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Get.theme.colorScheme.primary),
        child: IconButton(
          icon: ImageIcon(
            AssetImage(iconPath),
          ),
          color: color,
          onPressed: () => onPressed(),
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
              if (selectedInvoiceItemsFileId.length == 1)
                _controllerInvoice.invoices
                    .firstWhere((element) =>
                        element.fileId == selectedInvoiceItemsFileId.first)
                    .todoLabels!
                    .result!
                    .forEach((label) {
                  cboLabelsList.asMap().forEach((index, availableLabel) {
                    if (availableLabel.key
                        .toString()
                        .contains(label.labelTitle.toString())) {
                      selectedLabelIndexes.add(index);
                      setState(() {});
                    }
                  });
                });
            }

            selectedLabelIndexes.map((e) {
              print(e);
            }).toList();
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
                            selectedLabels.clear();
                            selectedLabelIndexes = value;
                            labelsList.asMap().forEach((index, value) {
                              selectedLabelIndexes
                                  .forEach((selectedLabelIndex) {
                                if (selectedLabelIndex == index) {
                                  selectedLabels.add(value.id!);
                                }
                              });
                            });
                          });
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
                          List<int> ret = <int>[];
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
                          selectedInvoiceItemsFileId, selectedLabels);
                      setState(() {
                        selectedInvoiceItemsId.clear();
                        selectedInvoiceItemsFileId.clear();
                        selectionModeActive = false;
                      });
                      refresh();
                      Get.back();
                      changed = true;
                    },
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
                          _controllerInvoice.invoices
                              .where((e) =>
                                  selectedInvoiceItemsFileId.contains(e.fileId))
                              .map((x) => x.fileId!)
                              .toList(),
                          0,
                          selectedMailId!,
                          _password.text);

                      setState(() {
                        _receiver.clear();
                        _subject.clear();
                        _message.clear();
                        _password.clear();
                        selectedInvoiceItemsId.clear();
                        selectedInvoiceItemsFileId.clear();
                        selectionModeActive = false;
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

  List<Invoice> FilterInvoice() {
    List<Invoice> inv;

    print(widget.SelectedInvoiceTargetAccount);
    inv = _controllerInvoice.invoices
        .where((c) =>
            c.invoiceTargetAccountId == widget.SelectedInvoiceTargetAccount)
        .toList();
    return inv;
  }

  GridView buildPreviewMode() {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useTabletLayout = shortestSide > 600;
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shrinkWrap: true,
        cacheExtent: 100,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: 250,
            maxCrossAxisExtent: useTabletLayout
                ? (Get.height > 1000 ? Get.width / 3 : Get.width / 4)
                : Get.width / 2 - 14,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 8),
        itemCount: FilterInvoice().length,
        itemBuilder: (BuildContext ctx, index) {
          Invoice inv;

          inv = FilterInvoice()[index];

          bool isSelected = selectedInvoiceItemsFileId
              .contains(_controllerInvoice.invoices[index].fileId);

          return GestureDetector(
            onTap: () async {
              if (selectionModeActive) {
                setState(() {
                  if (isSelected) {
                    selectedInvoiceItemsFileId.remove(inv.fileId);
                    selectedInvoiceItemsId.remove(inv.id);
                  } else {
                    selectedInvoiceItemsFileId.add(inv.fileId!);
                    selectedInvoiceItemsId.add(inv.id!);
                  }
                });
                selectionModeActive = selectedInvoiceItemsFileId.length > 0;
              } else {
                setState(() {
                  _loadingFile = true;
                });
                await openFileInvoice(inv);

                setState(() {
                  _loadingFile = false;
                });
              }
            },
            onLongPress: () {
              setState(() {
                if (isSelected) {
                  selectedInvoiceItemsFileId.remove(inv.fileId);
                  selectedInvoiceItemsId.remove(inv.id);
                } else {
                  selectedInvoiceItemsFileId.add(inv.fileId!);
                  selectedInvoiceItemsId.add(inv.id!);
                }

                selectionModeActive = selectedInvoiceItemsFileId.length > 0;
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
                                imageUrl: inv.file!.thumbnailPath!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                placeholder: (context, url) =>
                                    Text("Directory Detail WD"),
                                //  CustomLoadingCircle(),
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              right: 5,
                              child: Image.asset(
                                getImagePathByFileExtension(
                                    inv.file!.fileName!.split('.').last),
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
                                              itemCount: _controllerInvoice
                                                      .invoices[index]
                                                      .todoLabels!
                                                      .result!
                                                      .length ??
                                                  0,
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, a) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 4, left: 4),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.label,
                                                    size: 18,
                                                    color: HexColor(
                                                        _controllerInvoice
                                                            .invoices[index]
                                                            .todoLabels!
                                                            .result![a]
                                                            .labelColor!),
                                                  ),
                                                );
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
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: _controllerInvoice
                                                          .invoices[index]
                                                          .taxFreeAmount ==
                                                      null
                                                  ? Colors.red
                                                  : Colors.green,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          width: 18,
                                          height: 18,
                                          child: Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                            "${AppLocalizations.of(context)!.symbol} ${_controllerInvoice.invoices[index].taxAddAmount == null ? "0,00" : oCcy.format(_controllerInvoice.invoices[index].taxAddAmount)}"),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                                left: 5,
                                top: 5,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: inv.invoiceTargetAccountId == 1
                                          ? Colors.red
                                          : inv.invoiceTargetAccountId == 2
                                              ? Get.theme.primaryColor
                                              : Colors.green,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Center(
                                    child: Icon(
                                      inv.invoiceTargetAccountId == 1
                                          ? Icons.account_balance_wallet
                                          : inv.invoiceTargetAccountId == 2
                                              ? Icons.payments
                                              : Icons.credit_card,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
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

  Future<void> openPdfView(Invoice inv) async {
    setState(() {
      _loadingFile = true;
    });

    switch (inv.file!.fileName!.split('.').last.toLowerCase()) {
      case 'pdf':
        var file;
        try {
          inv.file!.path = inv.file!.path!.replaceAll('\\', '/');
          //  file = await PDFApi.loadNetwork(inv.file.path);
        } catch (e) {}
        break;
      case 'jpg':
        var uplFile;
        uplFile = inv.file!.path!.replaceAll('\\', '/');
        uplFile = uplFile.toString().replaceAll(" ", "%20");
        try {} catch (e, stacktrace) {
          print(stacktrace);
        }
        if (uplFile != null) {
          print(uplFile);
          Get.to(() => JpgView(
                picture: uplFile,
                invoice: inv,
              ));
        } else {
          print("file null");
        }
        break;
      default:
        break;
    }
    setState(() {
      _loadingFile = false;
    });
  }

  List<File> images = [];
  List<Widget> itemsImage = [];
  int imagesLength = 0;

  _imgFromCamera() async {
    Get.to(() => CameraPage())?.then((value) {
      bool isCombine = false;
      InvoiceFileInsertFiles files = new InvoiceFileInsertFiles();
      files.fileInput = <FileInput>[];

      if (value != null) {
        List<int> fileBytes = <int>[];
        isCombine = value.length > 1 ? true : false;

        value.forEach((file) {
          fileBytes = new File(file.path).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          files.fileInput!.add(
              new FileInput(fileName: 'sample.jpg', fileContent: fileContent));
        });

        print("isCombine : " + isCombine.toString());
        uploadInvoiceFile(files);
      }
    });
  }

  Future<void> uploadInvoiceFile(InvoiceFileInsertFiles? files,
      {List<Product>? products,
      int? CreatedForUserId,
      bool? MyCustomer,
      String? InvoiceName,
      String? InvoiceNumber}) async {
    bool isCombine = false;

    /*if (!IsCombine)
      {
        await _controllerInvoice.InvoiceFileInsert(_controllerDB.headers(),
            CustomerId: widget.customerId,
            AccountTypeId: 197, // bakılacak
            Type: 9,
            InvoiceName: "",
            Date: DateTime.now().toString(),
            Year: selectedYear,
            Month: selectedMonth,
            Day: DateTime.now().day,
            Tax: 1401,
            InvoiceBlock: widget.invoiceBlock,
            CreateDate: DateTime.now().toString(),
            CreateUser: widget.customerAdminId,//_controllerDB.user.value.result.id,
            TaxAccountId: 7,
            FileName: 'vir2ell_office.jpg',
            FileContent: files.fileInput.first.fileContent
        );
        await refresh();
        return;
      }*/
    double taxAddAmount = 0;
    double taxFreeAmount = 0;
    double taxAmount = 0;
    if (!products.isNullOrBlank!) {
      products!.forEach((element) {
        taxFreeAmount += element.total;
        taxAddAmount += element.brut;
        taxAmount += element.total * (element.kdv / 100);
      });
    }
    print("HandCreatedInvoice" + products.isNullOrBlank.toString());

    if (files!.fileInput!.length > 1) {
      bool? result = await showModalYesOrNo(
          context,
          AppLocalizations.of(context)!.fileUpload,
          AppLocalizations.of(context)!.doyouwanttocombinefiles);
      isCombine = result!;
    }
    int? targetAccountId;
    if (widget.invoiceBlock == 2 || widget.invoiceBlock == 4) {
      targetAccountId = await showModalTargetAccountList(
          context,
          AppLocalizations.of(context)!.selectTargetAccount,
          AppLocalizations.of(context)!.confirm);
      if (targetAccountId.isNullOrBlank!) {
        return;
      }
    }

    print('commonGroupId : ' + _controllerInvoice.CommonGroupId.toString());

    await _controllerInvoice.InvoiceFileListInsert(_controllerDB.headers(),
            CustomerId: widget.customerId,
            AccountTypeId: 157,
            Type: targetAccountId ?? 1,
            //Date: DateTime.now().toString(),
            Year: selectedYear,
            Month: selectedMonth,
            InvoiceBlock: widget.invoiceBlock,
            InvoiceTargetAccountId: targetAccountId ?? 1,
            CreateDate: DateTime.now().toString(),
            CreateUser: widget.customerAdminId,
            Files: files,
            IsCombine: isCombine,
            CombineFileName: isCombine ? "sample.pdf" : "",
            TaxAddAmount: _controllerInvoice.productType == 1
                ? (-taxAddAmount)
                : taxAddAmount,
            TaxAmount:
                _controllerInvoice.productType == 1 ? (-taxAmount) : taxAmount,
            TaxFreeAmount: _controllerInvoice.productType == 1
                ? (-taxFreeAmount)
                : taxFreeAmount,
            HandCreatedInvoice: products == null ? null : true,
            CreatedForUserId: CreatedForUserId,
            MyCustomer: MyCustomer,
            InvoiceName: InvoiceName,
            InvoiceNumber: InvoiceNumber,
            InvoiceType: widget.invoiceType,
            CommonGroupId: _controllerInvoice.CommonGroupId)
        .then((value) async {
      /*  List<InvoicePosition> _invoicePosition = [];
      await products!.forEach((element) {
      //  print(element);
        _invoicePosition.add(InvoicePosition(
            invoiceId: value,
            positionName: element.productName,
            quantity: double.parse(element.quantity.toStringAsFixed(2)),
            unitPrice: element.price,
            vat: element.kdv,
            quantityType: element.quantityType)
            );
            
      });*/ //! Yukaridaki kodlarin yerine asagidaki kod kullanilacak

      List<InvoicePosition> _invoicePosition = products!
          .map((element) => InvoicePosition(
              invoiceId: value,
              positionName: element.productName,
              quantity: double.parse(element.quantity.toStringAsFixed(2)),
              unitPrice: element.price,
              vat: element.kdv,
              quantityType: element.quantityType))
          .toList();

      _controllerInvoice.AddInvoicePositions(_controllerDB.headers(),
          Invoice: _invoicePosition);
    });

    await refresh();
  }

  void uploadOfferFile(InvoiceFileInsertFiles files,
      {List<Product>? products,
      int? CreatedForUserId,
      bool? MyCustomer,
      String? InvoiceName,
      String? InvoiceNumber}) async {
    bool isCombine = false;
    double taxAddAmount = 0;
    double taxFreeAmount = 0;
    double taxAmount = 0;
    if (!products.isNullOrBlank!) {
      products!.forEach((element) {
        taxFreeAmount += element.total;
        taxAddAmount += element.brut;
        taxAmount += element.total * (element.kdv / 100);
      });
    }

    await _controllerInvoice.InsertOffer(
      _controllerDB.headers(),
      insertOfferItem: InsertOfferItem(
          customerId: widget.customerId,
          files: files,
          createUser: widget.customerAdminId,
          month: selectedMonth,
          year: selectedYear,
          day: DateTime.now().day,
          taxAddAmount: taxAddAmount,
          taxAmount: taxAmount,
          taxFreeAmount: taxFreeAmount,
          createdForUserId: CreatedForUserId,
          myCustomer: MyCustomer,
          offerName: InvoiceName,
          date: DateTime(selectedYear!, selectedMonth!, DateTime.now().day)
              .toString(),
          offerNumber: InvoiceNumber),
    ).then((value) async {
      List<InvoicePosition> _invoicePosition = products!
          .map((element) => InvoicePosition(
              invoiceId: value.result!.id,
              positionName: element.productName,
              quantity: double.parse(element.quantity.toStringAsFixed(2)),
              unitPrice: element.price,
              vat: element.kdv,
              quantityType: element.quantityType))
          .toList();

      /*   List<InvoicePosition> _invoicePosition = [];
      await products.forEach((element) {
        print(element);
        _invoicePosition.add(InvoicePosition(
            invoiceId: value.result!.id,
            positionName: element.productName,
            quantity: double.parse(element.quantity.toStringAsFixed(2)),
            unitPrice: element.price,
            vat: element.kdv,
            quantityType: element.quantityType));
      });
*/

      _controllerInvoice.AddOfferPositions(_controllerDB.headers(),
          Invoice: _invoicePosition);
    });
    await refresh();
  }

  Widget FileViewInListView(Invoice item, int index) {
    var dateFormatter =
        new DateFormat.yMMMMd(AppLocalizations.of(context)!.localeName);
    bool isSelected = selectedInvoiceItemsFileId.contains(item.fileId);

    return GestureDetector(
      onTap: () async {
        if (selectionModeActive) {
          setState(() {
            if (isSelected) {
              selectedInvoiceItemsFileId.remove(item.fileId);
              selectedInvoiceItemsId.remove(item.id);
            } else {
              selectedInvoiceItemsFileId.add(item.fileId!);
              selectedInvoiceItemsId.add(item.id!);
            }
          });
          selectionModeActive = selectedInvoiceItemsFileId.length > 0;
        } else {
          setState(() {
            _loadingFile = true;
          });
          await openFileInvoice(item);
          setState(() {
            _loadingFile = false;
          });
        }
      },
      onLongPress: () {
        setState(() {
          if (isSelected) {
            selectedInvoiceItemsFileId.remove(item.fileId);
            selectedInvoiceItemsId.remove(item.id);
          } else {
            selectedInvoiceItemsFileId.add(item.fileId!);
            selectedInvoiceItemsId.add(item.id!);
          }
          selectionModeActive = selectedInvoiceItemsFileId.length > 0;
        });
      },
      child: Container(
        color: isSelected ? Colors.grey : null,
        width: Get.width,
        height: 80,
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
                          item.file!.fileName!.split('.').last),
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
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  /*if (details.primaryVelocity > 0) {
                    setState(() {
                      openMenuAnimateValue[index] = false;
                    });
                  }*/
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
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
                              item.file!.fileName!.length > 15
                                  ? item.file!.fileName!.substring(
                                      item.file!.fileName!.length - 15)
                                  : item.file!.fileName!,
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
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: Get.width - 145,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: item.taxFreeAmount == null
                                            ? Colors.red
                                            : Colors.green,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    width: 18,
                                    height: 18,
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                      "${AppLocalizations.of(context)!.symbol} ${item.taxAddAmount == null ? "0,0" : oCcy.format(item.taxAddAmount)}"),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*Container(
                        width: 80,
                        height: 70,
                        child: Stack(
                          children: [
                            AnimatedOpacity(
                              opacity: openMenuAnimateValue[index] ? 0 : 1,
                              duration: Duration(milliseconds: 700),
                              curve: Curves.fastOutSlowIn,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    openMenuAnimateValue[index] =
                                    !openMenuAnimateValue[index];
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 15),
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.menu_open,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              height: 70,
                              width: openMenuAnimateValue[index] ? 80 : 0,
                              right: openMenuAnimateValue[index] ? 0 : 0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInBack,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                child: Container(
                                  height: 70,
                                  width: 90,
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                color: Get
                                                    .theme.secondaryHeaderColor
                                                    .withOpacity(0.8),
                                                padding:
                                                EdgeInsets.only(left: 10),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )),
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                color: Get
                                                    .theme.secondaryHeaderColor,
                                                padding:
                                                EdgeInsets.only(left: 10),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.file_upload,
                                                    size: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            color: Colors.white),
                                        width: 15,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )*/
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ListView buildListviewMode() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _controllerInvoice.invoices.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          Invoice inv = _controllerInvoice.invoices[index];
          return FileViewInListView(inv, index);
        });
  }
}
