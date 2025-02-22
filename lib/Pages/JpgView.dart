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
import 'package:photo_view/photo_view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/DioDownloader.dart';
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
import 'package:undede/widgets/CustomIconWithBackground.dart';

class JpgView extends StatefulWidget {
  final Invoice? invoice;
  final String? picture;
  final DirectoryItem? privateFile;
  final SearchResultItem? searchItem;

  const JpgView(
      {Key? key,
       this.invoice,
       this.picture,
       this.privateFile,
      this.searchItem})
      : super(key: key);

  @override
  _JpgViewState createState() => _JpgViewState();
}

enum TargetAccount {
  Private,
  Cashbox,
  Bank,
}

class _JpgViewState extends State<JpgView> {
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
  CurrencyTextInputFormatter formatterBrut = CurrencyTextInputFormatter.currency(
    locale: 'tr',
    decimalDigits: 2,
    symbol: '₺',
  );

  
  CurrencyTextInputFormatter formatterNet = CurrencyTextInputFormatter.currency(
    locale: 'tr',
    decimalDigits: 2,
    symbol: '₺',
  );
  CurrencyTextInputFormatter formatterKDV = CurrencyTextInputFormatter.currency(
    locale: 'tr',
    decimalDigits: 2,
    symbol: '₺',
  );
// Mail
  ControllerUser _controllerUser = Get.put(ControllerUser());

  String? selectedMail;
  int? selectedMailId;

  TextEditingController _password = TextEditingController();
  TextEditingController _message = TextEditingController();
  TextEditingController _receiver = TextEditingController();
  TextEditingController _subject = TextEditingController();
  List<DropdownMenuItem> cmbEmails = [];
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
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _prepareSaveDir();
    getLabelByUserId();
    getUserEmailList();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      selectedFileId.add(widget.invoice!.fileId!);
      selectedMailId = 0;
      cmbEmails.add(DropdownMenuItem(
        value: 0,
        child: Text("Baulinx"),
      ));
      for (int i = 0;
          i < _controllerUser.getUserEmailData.value!.result!.length;
          i++) {
        cmbEmails.add(DropdownMenuItem(
          value: _controllerUser.getUserEmailData.value!.result![i].id,
          child:
              Text(_controllerUser.getUserEmailData.value!.result![i].userName!),
          key: Key(_controllerUser.getUserEmailData.value!.result![i].userName!),
        ));
      }
      _txtDescriptionController =
          TextEditingController(text: widget.invoice!.description);
      selectedType = [1, 2].contains(widget.invoice!.invoiceBlock) ? 1 : 2;
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
          _targetAccount = TargetAccount.Private; //! null yerine private yapildi
          break;
      }
//! format yerine formatString yapildi
      _txtBrutController.text = formatterBrut.formatString(widget.invoice!.taxFreeAmount.toString());
     
     
     
     
      calcNetAndKDV();
      print('widget.invoice.toJson()');
      print(widget.invoice!.toJson());
      setState(() {});
    });
      FileIdList.add(widget.privateFile!.id!);
  
    FileIdList.add(widget.searchItem!.id!);
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
      SourceOwnerId:
          widget.privateFile!.customerId ?? _controllerDB.user.value!.result!.id,
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
            key: Key(
                controllerLabel.getLabel.value!.result![index].title.toString()),
            value: controllerLabel.getLabel.value!.result![index].title! +
                "+" +
                controllerLabel.getLabel.value!.result![index].color!));
      });
    });
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
                          left: 20,
                          right: 20),
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
                          CustomIconWithBackground(
                              size: 1.2,
                              iconName: 'shareinvoice',
                              color: Colors.black,
                              onPressed: () async {
                                await FileShareFn([widget.picture!], context);
                              }),
                          SizedBox(
                            width: 15,
                          ),
                          CustomIconWithBackground(
                              size: 1.2,
                              iconName: 'downloadInvoice',
                              color: Colors.black,
                              onPressed: () async {
                                await Permission.storage.request();

                                DioDownloader([widget.picture!], context);
                              }),
                          SizedBox(
                            width: 15,
                          ),
                          CustomIconWithBackground(
                              size: 1.2,
                              iconName: 'attach',
                              color: Colors.black,
                              onPressed: () async {
                                _onAlertExternalIntive(context);
                              }),
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
                      decoration: BoxDecoration(
                        color: Get.theme.secondaryHeaderColor,
                      ),
                      child: Row(
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
                                "  ",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // IconButton(
                                //   icon: ImageIcon(
                                //     AssetImage(
                                //         'assets/images/icon/arrowleft.png'),
                                //   ),
                                //   color: Colors.black,
                                //   onPressed: () {
                                //     Navigator.pop(context);
                                //   },
                                // ),
                                // Spacer(),
                                // CustomIconWithBackground(
                                //     iconName:
                                //         'assets/images/icon/shareinvoice.png',
                                //     color: Colors.black54,
                                //     onPressed: () async {
                                //       await FileShareFn(
                                //           [widget.fileUrl], context);
                                //     }),
                                // SizedBox(
                                //   width: 15,
                                // ),
                                // CustomIconWithBackground(
                                //     iconName:
                                //         'assets/images/icon/shareinvoice.png',
                                //     color: Colors.black54,
                                //     onPressed: () async {
                                //       await FileShareFn(
                                //           [widget.fileUrl], context);
                                //     }),
                                // SizedBox(
                                //   width: 15,
                                // ),
                                // CustomIconWithBackground(
                                //     iconName:
                                //         'assets/images/icon/shareinvoice.png',
                                //     color: Colors.black54,
                                //     onPressed: () async {
                                //       await FileShareFn(
                                //           [widget.fileUrl], context);
                                //     }),
                                // SizedBox(
                                //   width: 15,
                                // ),
                                InkWell(
                                    onTap: () async {
                                      await Permission.storage.request();
                                      DioDownloader([widget.picture!], context);
                                    },
                                    child: Icon(Icons.file_download,
                                        color: Colors.black)),
                                InkWell(
                                    onTap: () {
                                      _onAlertExternalLabelInsert(context);
                                    },
                                    child:
                                        Icon(Icons.label, color: Colors.black)),
                                InkWell(
                                    onTap: () {
                                      _onAlertExternalIntive(context);
                                    },
                                    child:
                                        Icon(Icons.abc, color: Colors.black)),
                                InkWell(
                                    onTap: () async {
                                      widget.privateFile!.id != null
                                          ? await DeleteMultiFileAndDirectory(
                                              FileIdList)
                                          : await DeleteMultiFileAndDirectoryForSearch(
                                              FileIdList);

                                      Fluttertoast.showToast(
                                          msg: AppLocalizations.of(context)!
                                              .deleted,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor:
                                              Get.theme.secondaryHeaderColor,
                                          textColor: Get.theme.primaryColor,
                                          fontSize: 16.0);
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Icon(Icons.delete,
                                          color: Colors.black),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
              : Container(
                  width: Get.width,
                  height: 131,
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
                          InkWell(
                              onTap: () async {
                                await Permission.storage.request();
                                DioDownloader(
                                    [widget.invoice!.file!.path!], context);
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Get.theme.primaryColor),
                                child: Icon(Icons.file_download,
                                    size: 19, color: Colors.black),
                              )),
                          InkWell(
                              onTap: () {
                                _onAlertExternalLabelInsert(context);
                              },
                              child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Get.theme.primaryColor),
                                  child: Icon(Icons.label,
                                      size: 19, color: Colors.black))),
                          InkWell(
                              onTap: () {
                                _onAlertExternalIntive(context);
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Get.theme.primaryColor),
                                child: Icon(Icons.attach_email,
                                    size: 19, color: Colors.black),
                              )),
                          InkWell(
                              onTap: () async {
                                if (_controllerInvoice
                                        .getInvoicePeriod.value!.result!
                                        .firstWhere((element) =>
                                            element.month ==
                                            _controllerInvoice.selectedMonth)
                                        .status ==
                                    0) {
                                  await DeleteInvoice(widget.invoice!.id!);
                                  Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)!.deleted,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Get.theme.primaryColor,
                                      fontSize: 16.0);
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _controllerInvoice
                                                  .getInvoicePeriod.value!.result!
                                                  .firstWhere((element) =>
                                                      element.month ==
                                                      _controllerInvoice
                                                          .selectedMonth)
                                                  .status ==
                                              0
                                          ? Get.theme.primaryColor
                                          : Colors.grey),
                                  child: Icon(Icons.delete,
                                      size: 19, color: Colors.black))),
                          InkWell(
                            onTap: () async {
                              Invoice updatedInvoice = widget.invoice!;
                              updatedInvoice.createDate =
                                  DateFormat("yyyy-MM-ddThh:mm:ss")
                                      .format(createDate);
                              if ((widget.invoice!.invoiceBlock == 2 ||
                                  widget.invoice!.invoiceBlock == 4)) {
                                updatedInvoice.invoiceTargetAccountId =
                                    _targetAccount.index + 1;
                              }

                              updatedInvoice.accountTypeId =
                                  _selectedAccountType;
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
                              //if (_selectedTaxAccount != null)
                              //updatedInvoice.taxAddAmount = updatedInvoice.taxFreeAmount * ((100 + _selectedTaxAccount) / 100);
                              updatedInvoice.taxAddAmount =
                                  formatterNet.getUnformattedValue().toDouble();
                              updatedInvoice.tax =
                                  int.parse(_txtAccountNumberController.text);
                              await UpdateInvoice(updatedInvoice);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Get.theme.primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 3),
                                    child:
                                        Icon(Icons.save, color: Colors.black),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 3, right: 5),
                                    child: Text(
                                      AppLocalizations.of(context)!.save,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
          widget.invoice == null
              ? Container()
              : Container(
                  height: 400,
                  width: Get.width,
                  color: Get.theme.scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      buildRadioButtons(context),
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
                                    ? AppLocalizations.of(context)!.inCome
                                    : AppLocalizations.of(context)!.outGoing,
                                enabled: false,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: cboAccountTypeList.length == 0
                                  ? Container()
                                  : SearchableDropdown.single(
                                      color: Colors.white,
                                      height: 45,
                                      displayClearIcon: false,
                                      menuBackgroundColor:
                                          Get.theme.scaffoldBackgroundColor,
                                      items: cboAccountTypeList,
                                      value: _selectedAccountType,
                                      icon: Icon(Icons.expand_more),
                                      hint: AppLocalizations.of(context)!
                                          .accountType,
                                      searchHint: AppLocalizations.of(context)!
                                          .accountType,
                                      onChanged: (value) async {
                                        setState(() {
                                          _selectedAccountType = value;
                                        });
                                      },
                                      doneButton:
                                          AppLocalizations.of(context)!.done,
                                      displayItem: (item, selected) {
                                        return (Row(children: [
                                          selected
                                              ? Icon(
                                                  Icons.radio_button_checked,
                                                  color: Colors.grey,
                                                )
                                              : Icon(
                                                  Icons.radio_button_unchecked,
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
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: Get.width,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(45)),
                                child: CustomTextField(
                                  label: AppLocalizations.of(context)!
                                      .taxFreeAmount,
                                  controller: _txtBrutController,
                                  inputType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    formatterBrut
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
                                      menuBackgroundColor:
                                          Get.theme.scaffoldBackgroundColor,
                                      items: cboTaxAccountList,
                                      value: _selectedTaxAccount,
                                      icon: Icon(Icons.expand_more),
                                      hint: AppLocalizations.of(context)!.tax,
                                      searchHint:
                                          AppLocalizations.of(context)!.tax,
                                      onChanged: (value) async {
                                        setState(() {
                                          _selectedPercenteg = int.parse(
                                              taxAccountList
                                                  .firstWhere(
                                                      (e) => e.id == value)
                                                  .accountName!
                                                  .replaceAll("%", "")
                                                  .trim());
                                          _selectedTaxAccount = value;
                                          _selectedTaxAccountObj =
                                              taxAccountList.firstWhere(
                                                  (e) => e.id == value);
                                          _txtAccountNumberController.text =
                                              _selectedTaxAccountObj!
                                                  .accountNumber
                                                  .toString();

                                          calcNetAndKDV();
                                        });
                                      },
                                      doneButton:
                                          AppLocalizations.of(context)!.done,
                                      displayItem: (item, selected) {
                                        return (Row(children: [
                                          selected
                                              ? Icon(
                                                  Icons.radio_button_checked,
                                                  color: Colors.grey,
                                                )
                                              : Icon(
                                                  Icons.radio_button_unchecked,
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
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: Get.width,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(45)),
                                child: CustomTextField(
                                  label:
                                      AppLocalizations.of(context)!.taxAddAmount,
                                  controller: _txtNetController,
                                  inputFormatters: <TextInputFormatter>[
                                    formatterNet,
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
                              label: AppLocalizations.of(context)!.taxAmount,
                              controller: _txtKdvController,
                              inputType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                formatterKDV,
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
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                    boxShadow: standartCardShadow(),
                                    borderRadius: BorderRadius.circular(45)),
                                child: CustomTextField(
                                  label: AppLocalizations.of(context)!
                                      .accountNumber,
                                  controller: _txtAccountNumberController,
                                  inputType: TextInputType.number,
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
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(45),
                                    boxShadow: standartCardShadow()),
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
                                                    .format(createDate),
                                                textAlign: TextAlign.left),
                                            onTap: () async {
                                              DateTime? t = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2100),
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
                      Flexible(
                        child: Container(
                          height: 45,
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(45),
                              boxShadow: standartCardShadow()),
                          child: CustomTextField(
                            label: AppLocalizations.of(context)!.description,
                            height: 45,
                            controller: _txtDescriptionController,
                            inputType: TextInputType.multiline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            child: Container(
                child: PhotoView(
              loadingBuilder: (context, loadingProgress) {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress?.expectedTotalBytes != null
                        ? loadingProgress!.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              imageProvider: NetworkImage(
                widget.picture!,
              ),
            )),
          ),
        ],
      ),
    );
  }

  void calcNetAndKDV() {
    double brut = formatterBrut.getUnformattedValue().toDouble();
    print('brut : ' + formatterBrut.getFormattedValue());

    double percent = (_selectedPercenteg! + 100) / 100;
    double net = brut / percent;
    _txtNetController.text = formatterNet.formatString(net.toStringAsFixed(2)); //! format yerine formatString yapildi
    _txtKdvController.text =
        formatterKDV.formatString((brut - net).toStringAsFixed(2)); //! format yerine formatString yapildi
    print(_selectedPercenteg);
    print(percent);
    print(net);
    }

  Container buildRadioButtons(BuildContext context) {
    return Container(
      height: 45,
      width: Get.width,
      decoration: BoxDecoration(
        boxShadow: standartCardShadow(),
        color: Colors.white,
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
                    focusColor: Colors.red,
                    hoverColor: Colors.red,
                    activeColor: Colors.red,
                    fillColor:
                        WidgetStateColor.resolveWith((states) => Colors.red),
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
                    style: TextStyle(color: Colors.red),
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
                    focusColor: Get.theme.primaryColor,
                    hoverColor: Get.theme.primaryColor,
                    activeColor: Get.theme.primaryColor,
                    fillColor: WidgetStateColor.resolveWith(
                        (states) => Get.theme.primaryColor),
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
                    style: TextStyle(color: Get.theme.primaryColor),
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
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    activeColor: Colors.green,
                    fillColor: WidgetStateColor.resolveWith(
                        (states) => Colors.green),
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
                    style: TextStyle(color: Colors.green),
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
        showToast('Changes saved succesfully');
      }
    });
  }

  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    _controllerInvoice.refreshIWD = true;
    _controllerInvoice.update();

    _controllerFiles.refreshPrivate = true;
    _controllerFiles.update();
    super.dispose();
  }

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
  }

  SendEMail(String Receivers, String Subject, String Message,
      List<int> Attachtments, int Type, int UserEmailId, String Password) {
    _controllerFiles.SendEMail(_controllerDB.headers(),
        UserId: widget.invoice!.customerId ?? _controllerDB.user.value!.result!.id,
        Receivers: Receivers,
        Subject: Subject,
        Message: Message,
        Attachtments: Attachtments,
        Type: Type,
        UserEmailId: UserEmailId == 0 ? null : UserEmailId,
        Password: Password == 0 ? null : Password);
  }

  _onAlertExternalIntive(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.inviteUsers,
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
                              AppLocalizations.of(context)!.signInEmailLabel,
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
                          selectedFileId.isBlank! ? FileIdList : selectedFileId,
                          0,
                          selectedMailId.isBlank! ? 0 : selectedMailId!,
                          _password.text.isBlank! ? "" : _password.text);

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
                          if (items != null &&
                              keyword.isNotEmpty) {
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

  getUserEmailList() async {
    await _controllerUser.GetUserEmailList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, UserEmailId: 0)
        .then((value) {
      setState(() {
        selectedMail = value.result!.first.userName;
        selectedMailId = 0;
        cmbEmails.add(DropdownMenuItem(
          value: 0,
          child: Text("Baulinx"),
        ));
        for (int i = 0; i < value.result!.length; i++) {
          cmbEmails.add(DropdownMenuItem(
            value: value.result![i].id,
            child: Text(value.result![i].userName!),
            key: Key(value.result![i].userName!),
          ));
        }
      });
    });
  }
}
