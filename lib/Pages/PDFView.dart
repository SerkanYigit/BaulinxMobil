import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/DioDownloader.dart';
import 'package:undede/Custom/ExternalFileActions/ExternalInvite.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Services/Invoice/InvoiceDB.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Invoice/GetAccountTypeListResult.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';
import 'package:undede/model/Invoice/GetTaxAccountListResult.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Search/SearchResult.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'PDFCreater/PDFSignature.dart';

class PDFViewerPage extends StatefulWidget {
  final File? file;
  final Invoice? invoice;
  final DirectoryItem? privateFile;
  final SearchResultItem? searchItem;
  final String? fileUrl;

  const PDFViewerPage(
      {Key? key,
      this.file,
      this.invoice,
      this.privateFile,
      this.searchItem,
      this.fileUrl})
      : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

enum TargetAccount {
  Private,
  Cashbox,
  Bank,
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  int pages = 0;
  int indexPage = 0;
  TargetAccount _targetAccount = TargetAccount.Private;
  int? selectedType;
  int? _selectedAccountType;
  int? _selectedTaxAccount;
  int? _selectedPercenteg;
  TaxAccount? _selectedTaxAccountObj;
  TextEditingController _txtKdvController = new TextEditingController();
  TextEditingController _txtNetController = new TextEditingController();
  TextEditingController _txtBrutController = new TextEditingController();
  TextEditingController _txtAccountNumberController =
      new TextEditingController();
  TextEditingController _txtDescriptionController = new TextEditingController();
  DateTime createDate = DateTime.now();

  InvoiceDB _invoiceDb = new InvoiceDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<AccountType> accountTypeList = <AccountType>[];
  final List<DropdownMenuItem> cboAccountTypeList = [];
  List<TaxAccount> taxAccountList = <TaxAccount>[];
  final List<DropdownMenuItem> cboTaxAccountList = [];
  int? selectedTargetAccountId;
  CurrencyTextInputFormatter? formatterBrut;
  CurrencyTextInputFormatter? formatterNet;
  CurrencyTextInputFormatter? formatterKDV;
// Mail
  ControllerUser _controllerUser = Get.put(ControllerUser());

  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  List<int> selectedFileId = [];

  // Delete Private
  List<int> FileIdList = [];
  // insert Label
  final List<DropdownMenuItem> cboLabelsList = [];
  ControllerLabel controllerLabel = Get.put(ControllerLabel());
  List<int> selectedLabels = [];
  List<UserLabel> labelsList = <UserLabel>[];
  List<int> selectedLabelIndexes = [];
  //
  bool visible = true;
  bool pdfReload = false;
  bool _isLoading = true;
  bool _isHandleInvoice = false;
  final ReceivePort _port = ReceivePort();
  var oCcy = new NumberFormat("#,##0.00", "de-DE");

  @override
  void initState() {
    super.initState();

    _prepareSaveDir();
    getLabelByUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = false;
      });

      if (widget.invoice != null) {
        selectedFileId.add(widget.invoice!.fileId!);
        createDate = DateTime.parse(widget.invoice!.date!);
        _txtDescriptionController =
            TextEditingController(text: widget.invoice!.description);
        selectedType = [1, 2].contains(widget.invoice!.invoiceBlock) ? 1 : 2;
      }

      print('selectedType: ' + selectedType.toString());

      await _invoiceDb.GetAccountTypeList(_controllerDB.headers(),
              UserId: _controllerDB.user.value!.result!.id, Type: selectedType)
          .then((value) {
        accountTypeList = value.result!;

        accountTypeList.asMap().forEach((index, accountType) {
          if (accountType.id == widget.invoice!.accountTypeId) {
            _selectedAccountType = accountType.id;
          }
          cboAccountTypeList.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(accountType.description!),
              ],
            ),
            value: accountType.id,
            key: Key(accountType.description!),
          ));
        });
      });

      await _invoiceDb.GetTaxAccountList(_controllerDB.headers(),
              UserId: _controllerDB.user.value!.result!.id, Type: selectedType)
          .then((value) {
        taxAccountList = value.result!;

        taxAccountList.asMap().forEach((index, taxAccount) {
          if (taxAccount.id == widget.invoice!.taxAccountId) {
            _selectedTaxAccount = taxAccount.id;
            _selectedPercenteg =
                int.parse(taxAccount.accountName!.replaceAll("%", "").trim());
            _txtAccountNumberController.text =
                taxAccount.accountNumber.toString();
          }
          cboTaxAccountList.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(taxAccount.accountName!),
              ],
            ),
            value: taxAccount.id,
            key: Key(taxAccount.accountName!),
          ));
        });

        print('_selectedTaxAccount : ' + _selectedTaxAccount.toString());
      });
      if (widget.invoice != null) {
        if ((widget.invoice!.invoiceBlock == 2 ||
            widget.invoice!.invoiceBlock == 4)) {
          switch (widget.invoice!.invoiceTargetAccountId) {
            case 1:
              _targetAccount = TargetAccount.Private;
              break;
            case 2:
              _targetAccount = TargetAccount.Cashbox;
              break;
            case 3:
              _targetAccount = TargetAccount.Bank;
              break;
            default:
              //! null yerine Private atıyoruz
              _targetAccount =
                  TargetAccount.Private; // Default to Private instead of null
              break;
          }
        } else {
          _targetAccount =
              TargetAccount.Private; // Default to Private instead of null
        }

        _txtBrutController.text = formatterBrut!.formatString(widget
            .invoice!.taxFreeAmount!
            .toStringAsFixed(2)); //! format yerine formatString yapildi
      }

      await calcNetAndKDV();
      if (widget.invoice != null) {
        _txtKdvController =
            TextEditingController(text: oCcy.format(widget.invoice!.taxAmount));
        _txtNetController = TextEditingController(
            text: oCcy.format(widget.invoice!.taxAddAmount));
      }

      setState(() {});
    });
    FileIdList.add(widget.privateFile!.id!);

    widget.privateFile!.labelList?.forEach((label) {
      print(label.title);
      cboLabelsList.asMap().forEach((index, availableLabel) {
        if (availableLabel.key.toString().contains(label.title.toString())) {
          selectedLabelIndexes.add(index);
        }
      });
    });
    FileIdList.add(widget.searchItem?.id ?? 0);
  }

  @override
  void didChangeDependencies() {
    setState(() {
      pdfReload = false;
    });
    changecurrency();

    super.didChangeDependencies();
  }

  String? _localPath;
  void changecurrency() {
    formatterBrut = CurrencyTextInputFormatter.currency(
      locale: AppLocalizations.of(this.context)!.date,
      decimalDigits: 2,
      symbol: AppLocalizations.of(this.context)!.symbol,
    );
    formatterNet = CurrencyTextInputFormatter.currency(
      locale: AppLocalizations.of(this.context)!.date,
      decimalDigits: 2,
      symbol: AppLocalizations.of(this.context)!.symbol,
    );
    formatterKDV = CurrencyTextInputFormatter.currency(
      locale: AppLocalizations.of(this.context)!.date,
      decimalDigits: 2,
      symbol: AppLocalizations.of(this.context)!.symbol,
    );
  }

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

  DeleteInvoice(int InvoiceId) {
    _controllerInvoice.DeleteInvoice(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, InvoiceId: InvoiceId)
        .then((value) {
      if (value) {
        /*
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context).deleted,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Get.theme.secondaryHeaderColor,
              textColor: Get.theme.primaryColor,
              fontSize: 16.0);

           */
      }
    });
  }

  DeleteMultiFileAndDirectory(List<int> FileIdList) {
    _controllerFiles.DeleteMultiFileAndDirectory(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id,
      CustomerId: widget.privateFile!.customerId,
      ModuleTypeId: widget.privateFile!.moduleType,
      FileIdList: FileIdList,
      SourceOwnerId: widget.privateFile!.customerId ??
          _controllerDB.user.value!.result!.id,
    );
  }

  DeleteMultiFileAndDirectoryForSearch(List<int> FileIdList) {
    _controllerFiles.DeleteMultiFileAndDirectory(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id,
      CustomerId: widget.searchItem!.customerId,
      ModuleTypeId: widget.searchItem!.moduleType,
      FileIdList: FileIdList,
      SourceOwnerId:
          widget.searchItem!.customerId ?? _controllerDB.user.value!.result!.id,
    );
  }

  InsertFileListLabelList(List<int> FilesIds, List<int> LabelIds) {
    controllerLabel.InsertFileListLabelList(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        FilesIds: FilesIds,
        LabelIds: LabelIds);
  }

  void getLabelByUserId() async {
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

    if (widget.invoice != null) {
      widget.invoice!.todoLabels!.result!.forEach((label) {
        print(label.labelTitle);
        cboLabelsList.asMap().forEach((index, availableLabel) {
          if (availableLabel.key
              .toString()
              .contains(label.labelTitle.toString())) {
            selectedLabelIndexes.add(index);
          }
        });
      });
    }
  }

  var pdfViewerKey = UniqueKey();

  @override
  void dispose() {
    _txtAccountNumberController.dispose();
    _txtBrutController.dispose();
    _txtDescriptionController.dispose();
    _txtKdvController.dispose();
    _txtNetController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = '${indexPage + 1} of $pages';
    return Scaffold(
      body: Column(
        children: [
          widget.invoice == null
              ? widget.privateFile == null
                  ? Container(
                      width: Get.width,
                      height: 100,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: ImageIcon(
                              AssetImage('assets/images/icon/arrowleft.png'),
                            ),
                            color: Colors.black,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Spacer(),
                          _customIconWithBackground(
                              'assets/images/icon/shareinvoice.png',
                              Colors.black54, () async {
                            await FileShareFn([widget.fileUrl!], context);
                          }, AppLocalizations.of(context)!.share),
                          SizedBox(
                            width: 15,
                          ),
                          _customIconWithBackground(
                              'assets/images/icon/downloadInvoice.png',
                              Colors.black54, () async {
                            await Permission.storage.request();
                            DioDownloader([widget.fileUrl!], context);
                          }, AppLocalizations.of(context)!.fileDownloadStarted),
                          SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: Get.width,
                      height: 100,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: ImageIcon(
                              AssetImage('assets/images/icon/arrowleft.png'),
                            ),
                            color: Colors.black,
                            onPressed: () => Navigator.pop(context),
                          ),
                          Spacer(),
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _customIconWithBackground(
                                      'assets/images/icon/edit.png',
                                      Colors.black54, () async {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) async {
                                      await Get.to(() => PdfSignature(
                                            pdfUrl: widget.fileUrl,
                                            ModuleType:
                                                widget.privateFile!.moduleType,
                                            Id: widget
                                                    .privateFile!.customerId ??
                                                _controllerDB
                                                    .user.value!.result!.id,
                                          ));
                                    });
                                  }, AppLocalizations.of(context)!.edit),
                                  _customIconWithBackground(
                                      'assets/images/icon/shareinvoice.png',
                                      Colors.black54, () async {
                                    await FileShareFn([
                                      widget.privateFile!.path!
                                          .replaceAll(" ", "%20")
                                    ], context);
                                  }, AppLocalizations.of(context)!.share),
                                  _customIconWithBackground(
                                      'assets/images/icon/downloadInvoice.png',
                                      Colors.black54, () async {
                                    await Permission.storage.request();
                                    DioDownloader([widget.fileUrl!], context);
                                  },
                                      AppLocalizations.of(context)!
                                          .fileDownloadStarted),
                                  _customIconWithBackground(
                                      'assets/images/icon/label.png',
                                      Colors.black54, () async {
                                    _onAlertExternalLabelInsert(context);
                                  }, AppLocalizations.of(context)!.labels),
                                  _customIconWithBackground(
                                      'assets/images/icon/attach.png',
                                      Colors.black54, () async {
                                    ExternalInvite(
                                        context,
                                        widget.invoice!.customerId!,
                                        widget.invoice!.fileId!);
                                  }, AppLocalizations.of(context)!.file),
                                  _customIconWithBackground(
                                      'assets/images/icon/delete.png',
                                      Colors.black54, () async {
                                    widget.privateFile!.id != null
                                        ? await DeleteMultiFileAndDirectory(
                                            FileIdList)
                                        : await DeleteMultiFileAndDirectoryForSearch(
                                            FileIdList);
                                    Navigator.pop(context);
                                  }, AppLocalizations.of(context)!.delete),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
              : Container(
                  width: Get.width,
                  height: Get.height > 800 ? 131 : 151,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                margin: EdgeInsets.only(left: 10, right: 20),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                )),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                getInvoiceWithDocumentByPage(
                                    context, widget.invoice!.invoiceBlock!)!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _customIconWithBackground(
                              'assets/images/icon/shareinvoice.png', //iconchangee close
                              Colors.black54, () async {
                            await FileShareFn([widget.fileUrl!], context);
                          }, AppLocalizations.of(context)!.share),
                          _customIconWithBackground(
                              'assets/images/icon/downloadInvoice.png', //iconchangee close
                              Colors.black54, () async {
                            await Permission.storage.request();
                            DioDownloader([widget.fileUrl!], context);
                          }, AppLocalizations.of(context)!.fileDownloadStarted),
                          _customIconWithBackground(
                              'assets/images/icon/label.png', //iconchangee close
                              Colors.black54, () async {
                            _onAlertExternalLabelInsert(context);
                          }, AppLocalizations.of(context)!.labels),
                          _customIconWithBackground(
                              'assets/images/icon/letter.png', //iconchangee close
                              Colors.black54, () async {
                            ExternalInvite(
                                context,
                                widget.invoice!.customerId ??
                                    widget.privateFile!.customerId!,
                                widget.invoice!.fileId ??
                                    widget.privateFile!.id!);
                          }, AppLocalizations.of(context)!.file),
                          _customIconWithBackground(
                              'assets/images/icon/pencil.png', //iconchangee close
                              Colors.black54, () async {
                            Get.to(() => PdfSignature(
                                  pdfUrl: widget.fileUrl,
                                ));
                          }, AppLocalizations.of(context)!.signAndSave),
                          _customIconWithBackground(
                              'assets/images/icon/edit.png', //iconchangee close
                              Colors.black54, () async {
                            setState(() {
                              _isHandleInvoice = !_isHandleInvoice;
                            });
                          }, AppLocalizations.of(context)!.edit),
                          _customIconWithBackground(
                              'assets/images/icon/delete.png', //iconchangee close
                              _controllerInvoice.getInvoicePeriod.value!.result!
                                          .firstWhere((element) =>
                                              element.month ==
                                              _controllerInvoice.selectedMonth)
                                          .status ==
                                      0
                                  ? widget.invoice!.handCreatedInvoice != null
                                      ? Colors.black45
                                      : Colors.black54
                                  : Colors.grey, () async {
                            if (_controllerInvoice
                                    .getInvoicePeriod.value!.result!
                                    .firstWhere((element) =>
                                        element.month ==
                                        _controllerInvoice.selectedMonth)
                                    .status ==
                                0) {
                              //! return buradaydi

                              await DeleteInvoice(widget.invoice!.id!);

                              Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)!.deleted,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor:
                                      Get.theme.secondaryHeaderColor,
                                  textColor: Get.theme.primaryColor,
                                  fontSize: 16.0);
                              Navigator.pop(context);
                              return; //! return yeri degistirildi
                            }
                          }, AppLocalizations.of(context)!.delete),
                          _customIconWithBackground(
                              'assets/images/icon/save.png', //iconchangee close
                              Colors.black54, () async {
                            Invoice updatedInvoice = widget.invoice!;
                            updatedInvoice.date =
                                DateFormat("yyyy-MM-ddThh:mm:ss")
                                    .format(createDate);
                            updatedInvoice.description =
                                _txtDescriptionController.text ?? "";
                            updatedInvoice.accountTypeId = _selectedAccountType;
                            if ((widget.invoice!.invoiceBlock == 2 ||
                                widget.invoice!.invoiceBlock == 4)) {
                              updatedInvoice.invoiceTargetAccountId =
                                  _targetAccount.index + 1;
                            }
                            await UpdateInvoice(updatedInvoice);
                            Navigator.pop(context);
                            return; //! return yeri degismesi gerekebilir asasgidaki kod kapatildi
                            /*                           _txtBrutController.text =
                                formatterBrut.format(_txtBrutController.text);

                            calcNetAndKDV();

                            Invoice? updatedInvoice = widget.invoice;
                            updatedInvoice!.date =
                                DateFormat("yyyy-MM-ddThh:mm:ss")
                                    .format(createDate);
                            if ((widget.invoice.invoiceBlock == 2 ||
                                widget.invoice.invoiceBlock == 4)) {
                              updatedInvoice.invoiceTargetAccountId =
                                  _targetAccount.index + 1;
                            }
                            updatedInvoice.accountTypeId = _selectedAccountType;
                            updatedInvoice.taxFreeAmount =
                                formatterBrut.getUnformattedValue(); //brüt
                            updatedInvoice.taxAccountId =
                                _selectedTaxAccount; // tax yüzde kombosu
                            print('_selectedTaxAccount: ' +
                                _selectedTaxAccount.toString());
                            updatedInvoice.taxAmount =
                                formatterKDV.getUnformattedValue(); //KDV
                            updatedInvoice.description =
                                _txtDescriptionController.text ?? "";
                            updatedInvoice.taxAddAmount =
                                formatterNet.getUnformattedValue();
                            if (!_txtAccountNumberController
                                .text.isNullOrBlank) {
                              updatedInvoice.tax =
                                  int.parse(_txtAccountNumberController.text);
                            }
                            await UpdateInvoice(updatedInvoice);
                            Navigator.pop(context);
                             */
                          }, AppLocalizations.of(context)!.save),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
          widget.invoice == null
              ? Container()
              : Visibility(
                  visible: visible,
                  child: Container(
                    height: _isHandleInvoice ? Get.height / 1.6 : 0,
                    width: Get.width,
                    color: Get.theme.scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        /*
                        Container(
                          width: Get.width,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Container(
                                height: 45,
                                width: 110,
                                decoration: BoxDecoration(
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(45)),
                                child: CustomTextField(
                                  hint: selectedType == 1
                                      ? AppLocalizations.of(context).inCome
                                      : AppLocalizations.of(context).outGoing,
                                  enabled: false,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                         */
                        SizedBox(
                          height: 15,
                        ),
                        _isHandleInvoice
                            ? Column(
                                children: [
                                  buildRadioButtons(context),
                                  Container(
                                    width: Get.width,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                                boxShadow: standartCardShadow(),
                                                borderRadius:
                                                    BorderRadius.circular(45)),
                                            child: CustomTextField(
                                              label:
                                                  AppLocalizations.of(context)!
                                                      .taxFreeAmount,
                                              controller: _txtBrutController,
                                              inputType: TextInputType.number,
                                              readOnly: widget.invoice!
                                                          .handCreatedInvoice ==
                                                      null
                                                  ? false
                                                  : widget.invoice!
                                                      .handCreatedInvoice,
                                              inputFormatters: <TextInputFormatter>[
                                                formatterBrut!
                                              ],
                                              onChanged: (e) {
                                                calcNetAndKDV();
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: _selectedTaxAccount == null
                                              ? Container()
                                              : SearchableDropdown.single(
                                                  color: Colors.white,
                                                  height: 45,
                                                  displayClearIcon: false,
                                                  menuBackgroundColor: Get.theme
                                                      .scaffoldBackgroundColor,
                                                  items: cboTaxAccountList,
                                                  value: _selectedTaxAccount,
                                                  readOnly: widget.invoice!
                                                      .handCreatedInvoice!,
                                                  icon: Icon(Icons.expand_more),
                                                  hint: AppLocalizations.of(
                                                          context)!
                                                      .tax,
                                                  searchHint:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .tax,
                                                  onChanged: (value) async {
                                                    setState(() {
                                                      _selectedPercenteg = int
                                                          .parse(taxAccountList
                                                              .firstWhere((e) =>
                                                                  e.id == value)
                                                              .accountName!
                                                              .replaceAll(
                                                                  "%", "")
                                                              .trim());
                                                      _selectedTaxAccount =
                                                          value;
                                                      _selectedTaxAccountObj =
                                                          taxAccountList
                                                              .firstWhere((e) =>
                                                                  e.id ==
                                                                  value);
                                                      _txtAccountNumberController
                                                              .text =
                                                          _selectedTaxAccountObj!
                                                              .accountNumber
                                                              .toString();
                                                      _txtBrutController.text =
                                                          formatterBrut!
                                                              .formatString(
                                                                  _txtBrutController
                                                                      .text);

                                                      calcNetAndKDV();
                                                    });
                                                  },
                                                  doneButton:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .done,
                                                  displayItem:
                                                      (item, selected) {
                                                    return (Row(children: [
                                                      selected
                                                          ? Icon(
                                                              Icons
                                                                  .radio_button_checked,
                                                              color:
                                                                  Colors.grey,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .radio_button_unchecked,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      SizedBox(width: 7),
                                                      Expanded(
                                                        child: item,
                                                      ),
                                                    ]));
                                                  },
                                                  isExpanded: true,
                                                  searchFn: dropdownSearchFn,
                                                ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: Get.width,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                              boxShadow: standartCardShadow(),
                                              borderRadius:
                                                  BorderRadius.circular(45),
                                            ),
                                            child: CustomTextField(
                                              label:
                                                  AppLocalizations.of(context)!
                                                      .taxAddAmount,
                                              controller: _txtNetController,
                                              readOnly: true,
                                              inputFormatters: <TextInputFormatter>[
                                                formatterNet!,
                                              ],
                                              inputType: TextInputType.number,
                                              onChanged: (e) {
                                                calcNetAndKDV();
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: CustomTextField(
                                          label: AppLocalizations.of(context)!
                                              .taxAmount,
                                          controller: _txtKdvController,
                                          inputType: TextInputType.number,
                                          readOnly: true,
                                          inputFormatters: <TextInputFormatter>[
                                            formatterKDV!,
                                          ],
                                          onChanged: (e) {
                                            calcNetAndKDV();
                                          },
                                        ))
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: Get.width,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                                boxShadow: standartCardShadow(),
                                                borderRadius:
                                                    BorderRadius.circular(45)),
                                            child: CustomTextField(
                                              label:
                                                  AppLocalizations.of(context)!
                                                      .accountNumber,
                                              controller:
                                                  _txtAccountNumberController,
                                              inputType: TextInputType.number,
                                              readOnly: true,
                                              inputFormatters: <TextInputFormatter>[],
                                              onChanged: (e) {},
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 45,
                                            width: 250,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(45),
                                                boxShadow:
                                                    standartCardShadow()),
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 7,
                                                    child: GestureDetector(
                                                        child: Text(
                                                            DateFormat(
                                                                    'EEE, MMM dd yyyy',
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .date)
                                                                .format(createDate ==
                                                                        null
                                                                    ? DateTime
                                                                        .now()
                                                                    : createDate),
                                                            textAlign:
                                                                TextAlign.left),
                                                        onTap: () async {
                                                          if (widget.invoice!
                                                                      .handCreatedInvoice ==
                                                                  null
                                                              ? false
                                                              : widget.invoice!
                                                                  .handCreatedInvoice!) {
                                                            return;
                                                          }
                                                          DateTime? t =
                                                              await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                DateTime.now(),
                                                            firstDate:
                                                                DateTime(1900),
                                                            lastDate:
                                                                DateTime(2100),
                                                          );
                                                          setState(() {
                                                            createDate = t!;
                                                          });
                                                        }),
                                                  ),
                                                ]),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  cboAccountTypeList.length == 0
                                      ? Container()
                                      : Container(
                                          width: Get.width,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: SearchableDropdown.single(
                                            color: Colors.white,
                                            height: 45,
                                            displayClearIcon: false,
                                            menuBackgroundColor: Get
                                                .theme.scaffoldBackgroundColor,
                                            items: cboAccountTypeList,
                                            value: _selectedAccountType,
                                            icon: Icon(Icons.expand_more),
                                            hint: AppLocalizations.of(context)!
                                                .accountType,
                                            searchHint:
                                                AppLocalizations.of(context)!
                                                    .accountType,
                                            onChanged: (value) async {
                                              setState(() {
                                                _selectedAccountType = value;
                                              });
                                            },
                                            doneButton:
                                                AppLocalizations.of(context)!
                                                    .done,
                                            displayItem: (item, selected) {
                                              return (Row(children: [
                                                selected
                                                    ? Icon(
                                                        Icons
                                                            .radio_button_checked,
                                                        color: Colors.grey,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .radio_button_unchecked,
                                                        color: Colors.grey,
                                                      ),
                                                SizedBox(width: 7),
                                                Expanded(
                                                  child: item,
                                                ),
                                              ]));
                                            },
                                            isExpanded: true,
                                            searchFn: dropdownSearchFn,
                                          ),
                                        ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              )
                            : Container(),
                        _isHandleInvoice
                            ? Flexible(
                                child: Container(
                                  height: 45,
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(45),
                                      boxShadow: standartCardShadow()),
                                  child: CustomTextField(
                                    label: AppLocalizations.of(context)!
                                        .description,
                                    height: 45,
                                    controller: _txtDescriptionController,
                                    inputType: TextInputType.multiline,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
          Expanded(
            child: Container(
              height: Get.height,
              width: Get.width,
              child: Stack(
                children: [
                  SfPdfViewer.network(widget.fileUrl!),
                  widget.invoice == null
                      ? Container()
                      : Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                visible = !visible;
                                pdfReload = true;
                              });
                              return; //! asagidaki kod kapatildi dead code oldugu icin
                              /*                              _txtBrutController.text =
                                  formatterBrut.format(_txtBrutController.text);
                              calcNetAndKDV();
                              setState(() {
                                visible = !visible;
                                pdfReload = true;
                              });
                              // for rotations on Android
                              Timer(Duration(milliseconds: 100), () {
                                setState(() {
                                  pdfReload = false;
                                });
                              }); */
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Get.theme.primaryColor),
                              child: Icon(visible
                                  ? Icons.fullscreen
                                  : Icons.fullscreen_exit),
                            ),
                          ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Tooltip _customIconWithBackground(
      String iconPath, Color color, Function onPressed, String tooltip) {
    return Tooltip(
      message: tooltip ?? "",
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          width: 40,
          height: 35,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: primaryColor
              // Get.theme.colorScheme.primary

              ),
          child: IconButton(
            icon: ImageIcon(
              AssetImage(iconPath),
            ),
            color: color,
            onPressed: onPressed as VoidCallback?,
          ),
        ),
      ),
    );
  }

  //! void kaldırıldı
  calcNetAndKDV() {
    num brut = formatterBrut!.getUnformattedValue();
    print('brut : ' + formatterBrut!.getFormattedValue());

    double percent =
        (_selectedPercenteg ?? 0 + 100) / 100; //! null ise yerine 0 ekledim

    double net = brut / percent;
    _txtNetController.text = formatterNet!.formatString(
        net.toStringAsFixed(2)); //! format yerine formatString yapildi
    _txtKdvController.text = formatterKDV!.formatString(
        (brut - net).toStringAsFixed(2)); //! format yerine formatString yapildi
    print(_selectedPercenteg);
    print(percent);
    print(net);
  }

  Container buildRadioButtons(BuildContext context) {
    return Container(
      height: 45,
      width: Get.width,
      decoration: BoxDecoration(
        color: (widget.invoice!.invoiceBlock == 2 ||
                widget.invoice!.invoiceBlock == 4)
            ? Colors.white
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(35),
      ),
      margin: EdgeInsets.fromLTRB(15, 25, 15, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              height: 45,
              child: Row(
                children: [
                  Radio<TargetAccount>(
                    focusColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Colors.red
                        : Colors.grey,
                    hoverColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Colors.red
                        : Colors.grey,
                    activeColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Colors.red
                        : Colors.grey,
                    fillColor: WidgetStateColor.resolveWith((states) =>
                        (widget.invoice!.invoiceBlock == 2 ||
                                widget.invoice!.invoiceBlock == 4)
                            ? Colors.red
                            : Colors.grey),
                    value: TargetAccount.Private,
                    groupValue: _targetAccount,
                    onChanged: (TargetAccount? value) {
                      if (widget.invoice!.invoiceBlock == 2 ||
                          widget.invoice!.invoiceBlock == 4) {
                        setState(() {
                          _targetAccount = value!;
                        });
                      }
                    },
                  ),
                  Text(
                    AppLocalizations.of(context)!.private,
                    style: TextStyle(
                        color: (widget.invoice!.invoiceBlock == 2 ||
                                widget.invoice!.invoiceBlock == 4)
                            ? Colors.red
                            : Colors.grey),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: Container(
              child: Row(
                children: [
                  Radio<TargetAccount>(
                    focusColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Get.theme.primaryColor
                        : Colors.grey,
                    hoverColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Get.theme.primaryColor
                        : Colors.grey,
                    activeColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Get.theme.primaryColor
                        : Colors.grey,
                    fillColor: WidgetStateColor.resolveWith((states) =>
                        (widget.invoice!.invoiceBlock == 2 ||
                                widget.invoice!.invoiceBlock == 4)
                            ? Get.theme.primaryColor
                            : Colors.grey),
                    value: TargetAccount.Cashbox,
                    groupValue: _targetAccount,
                    onChanged: (TargetAccount? value) {
                      if (widget.invoice!.invoiceBlock == 2 ||
                          widget.invoice!.invoiceBlock == 4) {
                        setState(() {
                          _targetAccount = value!;
                        });
                      }
                    },
                  ),
                  Text(
                    AppLocalizations.of(context)!.cashBox,
                    style: TextStyle(
                      color: (widget.invoice!.invoiceBlock == 2 ||
                              widget.invoice!.invoiceBlock == 4)
                          ? Get.theme.primaryColor
                          : Colors.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: Container(
              child: Row(
                children: [
                  Radio<TargetAccount>(
                    focusColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Colors.green
                        : Colors.grey,
                    hoverColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Colors.green
                        : Colors.grey,
                    activeColor: (widget.invoice!.invoiceBlock == 2 ||
                            widget.invoice!.invoiceBlock == 4)
                        ? Colors.green
                        : Colors.grey,
                    fillColor: WidgetStateColor.resolveWith((states) =>
                        (widget.invoice!.invoiceBlock == 2 ||
                                widget.invoice!.invoiceBlock == 4)
                            ? Colors.green
                            : Colors.grey),
                    value: TargetAccount.Bank,
                    groupValue: _targetAccount,
                    onChanged: (TargetAccount? value) {
                      if (widget.invoice!.invoiceBlock == 2 ||
                          widget.invoice!.invoiceBlock == 4) {
                        setState(() {
                          _targetAccount = value!;
                        });
                      }
                    },
                  ),
                  Text(
                    AppLocalizations.of(context)!.bank,
                    style: TextStyle(
                        color: (widget.invoice!.invoiceBlock == 2 ||
                                widget.invoice!.invoiceBlock == 4)
                            ? Colors.green
                            : Colors.grey),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  UpdateInvoice(Invoice updatedInvoice) async {
    await _invoiceDb.InvoiceMultiUpdate(_controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        InvoiceList: [updatedInvoice]).then((value) {
      if (value.hasError!) {
        showToast('Error:' + value.resultMessage!);
      } else {
        int index = _controllerInvoice.invoices
            .indexWhere((e) => e.id == widget.invoice!.id);
        _controllerInvoice.invoices[index] = updatedInvoice;
        _controllerInvoice.update();
      }
    });
  }

  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());

  String? getInvoiceWithDocumentByPage(BuildContext context, int page) {
    print(page);
    if (page == 0)
      return "0";
    else if (page == 1)
      return AppLocalizations.of(context)!.incomeUnpaid;
    else if (page == 2)
      return AppLocalizations.of(context)!.incomePaid;
    else if (page == 3)
      return AppLocalizations.of(context)!.outgoingUnpaid;
    else if (page == 4) return AppLocalizations.of(context)!.outgoingPaid;
    return null; //! return null eklendi
  }

  _onAlertExternalLabelInsert(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      InsertFileListLabelList(
                          widget.invoice != null ? selectedFileId : FileIdList,
                          selectedLabels);
                      Get.back();
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
}
