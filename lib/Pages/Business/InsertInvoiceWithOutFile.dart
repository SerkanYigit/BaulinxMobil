import 'dart:async';
import 'dart:io';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerUser.dart';
import 'package:undede/Custom/ExternalFileActions/ExternalInvite.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
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

class InsertInvoiceWithOutFile extends StatefulWidget {
  final Invoice? invoice;
  final int? CustomerId;
  const InsertInvoiceWithOutFile({Key? key, this.invoice, this.CustomerId})
      : super(key: key);

  @override
  _InsertInvoiceWithOutFileState createState() =>
      _InsertInvoiceWithOutFileState();
}

enum TargetAccount {
  Private,
  Cashbox,
  Bank,
}

class _InsertInvoiceWithOutFileState extends State<InsertInvoiceWithOutFile> {
  int pages = 0;
  int indexPage = 0;
  TargetAccount _targetAccount = TargetAccount.Private;
  int selectedType = 1;
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
  TextEditingController _txtTitleController = new TextEditingController();
  DateTime createDate = DateTime.now();

  InvoiceDB _invoiceDb = new InvoiceDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<AccountType> accountTypeList = <AccountType>[];
  final List<DropdownMenuItem> cboAccountTypeList = [];
  List<TaxAccount> taxAccountList = <TaxAccount>[];
  final List<DropdownMenuItem> cboTaxAccountList = [];
  int? selectedTargetAccountId;
  List<DropdownMenuItem> cboInvoiceBlock = [];
  int selectedInvoiceBlock = 1;

  CurrencyTextInputFormatter? formatterBrut;
  CurrencyTextInputFormatter? formatterNet;
  CurrencyTextInputFormatter? formatterKDV;
// Mail
  ControllerUser _controllerUser = Get.put(ControllerUser());

  ControllerFiles _controllerFiles = Get.put(ControllerFiles());

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

  @override
  void initState() {
    super.initState();
    //   selectedType=
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cboInvoiceBlock = [
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(1, context)),
            ],
          ),
          value: 1,
          key: Key(getTitleByInvoiceBlock(1, context)),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(2, context)),
            ],
          ),
          value: 2,
          key: Key(getTitleByInvoiceBlock(2, context)),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(3, context)),
            ],
          ),
          value: 3,
          key: Key(getTitleByInvoiceBlock(3, context)),
        ),
        DropdownMenuItem(
          child: Row(
            children: [
              Text(getTitleByInvoiceBlock(4, context)),
            ],
          ),
          value: 4,
          key: Key(getTitleByInvoiceBlock(4, context)),
        )
      ];
      //Todo
      await getAccountType(selectedType);
      await _invoiceDb.GetTaxAccountList(_controllerDB.headers(),
              UserId: _controllerDB.user.value!.result!.id, Type: selectedType)
          .then((value) {
        taxAccountList = value.result!;
        _selectedTaxAccount = value.result!.first.id;
        _selectedPercenteg = int.parse(
            value.result!.first.accountName!.replaceAll("%", "").trim());
        _txtAccountNumberController.text =
            value.result!.first.accountNumber.toString();

        taxAccountList.asMap().forEach((index, taxAccount) {
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
      setState(() {});

      setState(() {
        _isLoading = false;
      });
      selectedInvoiceBlock = widget.invoice!.invoiceBlock!;
      createDate = DateTime.parse(widget.invoice!.date!);
      _selectedAccountType = widget.invoice!.accountTypeId;
      _txtDescriptionController =
          TextEditingController(text: widget.invoice!.description);
      _txtTitleController =
          TextEditingController(text: widget.invoice!.invoiceName);
      _txtAccountNumberController =
          TextEditingController(text: widget.invoice!.taxAccountId.toString());
      selectedType = [1, 2].contains(widget.invoice!.invoiceBlock) ? 1 : 2;
      print('selectedType: ' + selectedType.toString());
      setState(() {
        _selectedTaxAccount = cboTaxAccountList
            .firstWhere((element) =>
                element.key.toString().contains(widget.invoice!.tax.toString()))
            .value;
        _selectedTaxAccountObj =
            taxAccountList.firstWhere((e) => e.id == _selectedTaxAccount);
        _txtAccountNumberController.text =
            _selectedTaxAccountObj!.accountNumber.toString();

        _txtBrutController.text = formatterBrut!.formatString(
            _txtBrutController.text); //! format yerine formatString yapildi
        print(formatterBrut!
            .formatString('2000')); //! format yerine formatString yapildi

        _selectedPercenteg = int.parse(taxAccountList
            .firstWhere((e) => e.id == _selectedTaxAccount)
            .accountName!
            .replaceAll("%", "")
            .trim());
      });

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
          default: //! Null yerine private kullanıldı
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

      _txtKdvController.text = formatterKDV!.formatString(widget
          .invoice!.taxAmount!
          .toStringAsFixed(2)); //! format yerine formatString yapildi
      _txtNetController.text = formatterNet!.formatString(widget
          .invoice!.taxAddAmount!
          .toStringAsFixed(2)); //! format yerine formatString yapildi
      calcNetAndKDV();

      setState(() {});
    });
  }

  Future<void> getAccountType(int type) async {
    cboAccountTypeList.clear();
    await _invoiceDb.GetAccountTypeList(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, Type: type)
        .then((value) {
      accountTypeList = value.result!;
      _selectedAccountType = value.result!.first.id;
      setState(() {
        accountTypeList.asMap().forEach((index, accountType) {
          cboAccountTypeList.add(DropdownMenuItem(
            child: Row(
              children: [
                Text(accountType.accountNumber.toString() +
                    " " +
                    accountType.description!),
              ],
            ),
            value: accountType.id,
            key: Key(accountType.description!),
          ));
        });
      });
    });
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

  DeleteInvoice(int InvoiceId) {
    _controllerInvoice.DeleteInvoice(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id, InvoiceId: InvoiceId)
        .then((value) {
      if (value) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = '${indexPage + 1} of $pages';
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "insertdirectoryWithOut",
        key: Key("insertdirectoryWithOut"),
        onPressed: () async {
          _txtBrutController.text = formatterBrut!.formatString(
              _txtBrutController.text); //! format yerine formatString yapildi

          calcNetAndKDV();
          _controllerInvoice.InvoiceMultiUpdate(_controllerDB.headers(),
              UserId: widget.CustomerId,
              InvoiceList: [
                Invoice(
                    id: widget.invoice!.id,
                    createUser: widget.CustomerId,
                    customerId: widget.CustomerId,
                    date: createDate.toIso8601String(),
                    year: _controllerInvoice.selectedYear,
                    month: _controllerInvoice.selectedMonth,
                    invoiceBlock: selectedInvoiceBlock,
                    invoiceTargetAccountId: _targetAccount == null
                        ? null
                        : _targetAccount.index + 1,
                    accountTypeId: _selectedAccountType,
                    invoiceName: _txtTitleController.text,
                    tax: _selectedPercenteg,
                    description: _txtDescriptionController.text,
                    taxFreeAmount: formatterBrut!.getUnformattedValue(),
                    taxAccountId: int.parse(_selectedTaxAccount.toString()),
                    taxAddAmount:
                        formatterNet!.getUnformattedValue().toDouble(),
                    taxAmount: formatterKDV!.getUnformattedValue())
              ]);

          Navigator.pop(context);
        },
        child: Icon(Icons.done),
      ),
      body: Column(
        children: [
          Container(
            width: Get.width,
            height: 100,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            decoration: BoxDecoration(
              color: Get.theme.secondaryHeaderColor,
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
                            color: Colors.white,
                          )),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          widget.invoice != null
                              ? getTitleByInvoiceBlock(
                                  widget.invoice!.invoiceBlock!, context)
                              : "  Insert Invoice  ",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: Get.width,
              color: Get.theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  buildRadioButtons(context),
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
                  Container(
                    width: Get.width,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: SearchableDropdown.single(
                      color: Colors.white,
                      height: 45,
                      displayClearIcon: false,
                      menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
                      items: cboInvoiceBlock,
                      value: selectedInvoiceBlock,
                      icon: Icon(Icons.expand_more),
                      hint: AppLocalizations.of(context)!.accountType,
                      searchHint: AppLocalizations.of(context)!.accountType,
                      onChanged: (value) async {
                        setState(() {
                          selectedInvoiceBlock = value;
                        });
                        print(value);
                        if (value == 1 || value == 3) {
                          await getAccountType(2);
                        } else {
                          await getAccountType(1);
                        }
                      },
                      doneButton: AppLocalizations.of(context)!.done,
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
                                  AppLocalizations.of(context)!.taxFreeAmount,
                              controller: _txtBrutController,
                              inputType: TextInputType.number,
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
                                  menuBackgroundColor:
                                      Get.theme.scaffoldBackgroundColor,
                                  items: cboTaxAccountList,
                                  value: _selectedTaxAccount,
                                  icon: Icon(Icons.expand_more),
                                  hint: AppLocalizations.of(context)!.tax,
                                  searchHint: AppLocalizations.of(context)!.tax,
                                  onChanged: (value) async {
                                    setState(() {
                                      _selectedPercenteg = int.parse(
                                          taxAccountList
                                              .firstWhere((e) => e.id == value)
                                              .accountName!
                                              .replaceAll("%", "")
                                              .trim());
                                      _selectedTaxAccount = value;
                                      _selectedTaxAccountObj = taxAccountList
                                          .firstWhere((e) => e.id == value);
                                      _txtAccountNumberController.text =
                                          _selectedTaxAccountObj!.accountNumber
                                              .toString();
                                      _txtBrutController.text = formatterBrut!
                                          .formatString(_txtBrutController
                                              .text); //! format yerine formatString yapildi

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
                              borderRadius: BorderRadius.circular(45),
                            ),
                            child: CustomTextField(
                              label: AppLocalizations.of(context)!.taxAddAmount,
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
                          label: AppLocalizations.of(context)!.taxAmount,
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
                                  AppLocalizations.of(context)!.accountNumber,
                              controller: _txtAccountNumberController,
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
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(45),
                                boxShadow: standartCardShadow()),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                  cboAccountTypeList.length == 0
                      ? Container()
                      : Container(
                          width: Get.width,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: SearchableDropdown.single(
                            color: Colors.white,
                            height: 45,
                            displayClearIcon: false,
                            menuBackgroundColor:
                                Get.theme.scaffoldBackgroundColor,
                            items: cboAccountTypeList,
                            value: _selectedAccountType,
                            icon: Icon(Icons.expand_more),
                            hint: AppLocalizations.of(context)!.accountType,
                            searchHint:
                                AppLocalizations.of(context)!.accountType,
                            onChanged: (value) async {
                              setState(() {
                                _selectedAccountType = value;
                              });
                            },
                            doneButton: AppLocalizations.of(context)!.done,
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
                        label: AppLocalizations.of(context)!.title,
                        height: 45,
                        controller: _txtTitleController,
                        inputType: TextInputType.multiline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void calcNetAndKDV() {
    num brut = formatterBrut!.getUnformattedValue();
    print('brut : ' + formatterBrut!.getFormattedValue());

    double percent = (_selectedPercenteg! + 100) / 100;
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
    return widget.invoice == null
        ? Container(
            height: 45,
            width: Get.width,
            decoration: BoxDecoration(
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
                          fillColor: WidgetStateColor.resolveWith(
                              (states) => (Colors.red)),
                          value: TargetAccount.Private,
                          groupValue: _targetAccount,
                          onChanged: (TargetAccount? value) {
                            setState(() {
                              _targetAccount = value!;
                            });
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
                            (states) => Get.theme.primaryColor,
                          ),
                          value: TargetAccount.Cashbox,
                          groupValue: _targetAccount,
                          onChanged: (TargetAccount? value) {
                            setState(() {
                              _targetAccount = value!;
                            });
                          },
                        ),
                        Text(
                          AppLocalizations.of(context)!.cashBox,
                          style: TextStyle(
                            color: Get.theme.primaryColor,
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
                          focusColor: Colors.green,
                          hoverColor: Colors.green,
                          activeColor: Colors.green,
                          fillColor: WidgetStateColor.resolveWith(
                              (states) => Colors.green),
                          value: TargetAccount.Bank,
                          groupValue: _targetAccount,
                          onChanged: (TargetAccount? value) {
                            setState(() {
                              _targetAccount = value!;
                            });
                          },
                        ),
                        Text(
                          AppLocalizations.of(context)!.bank,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
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
  @override
  void dispose() {
    super.dispose();
  }
}
