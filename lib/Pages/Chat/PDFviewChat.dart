import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Custom/DioDownloader.dart';
import 'package:undede/Custom/ExternalFileActions/ExternalInvite.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';
import 'package:undede/model/Invoice/GetAccountTypeListResult.dart';
import 'package:undede/model/Invoice/GetTaxAccountListResult.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFviewChat extends StatefulWidget {
  final File file;
  final String? thumNail;
  final String? pdf;

  const PDFviewChat({Key? key, required this.file, this.thumNail, this.pdf})
      : super(key: key);

  @override
  _PDFviewChatState createState() => _PDFviewChatState();
}

class _PDFviewChatState extends State<PDFviewChat> {
  // PDFViewController controller;
  int pages = 0;
  int indexPage = 0;
  int? selectedType;
  DateTime createDate = DateTime.now();
  List<AccountType> accountTypeList = <AccountType>[];
  final List<DropdownMenuItem> cboAccountTypeList = [];
  List<TaxAccount> taxAccountList = <TaxAccount>[];
  final List<DropdownMenuItem> cboTaxAccountList = [];
  int? selectedTargetAccountId;
  CurrencyTextInputFormatter? formatterBrut;
  CurrencyTextInputFormatter? formatterNet;
  CurrencyTextInputFormatter? formatterKDV;
// Mail
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
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _isLoading = false;
      });
    });
    _prepareSaveDir();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        final dir = "/storage/emulated/0/Download/";

        externalStorageDirPath = dir;
        print(dir);
      } catch (e, stack) {
        print(stack);
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      final downloadsDirectory = await getExternalStorageDirectory();
      externalStorageDirPath = downloadsDirectory!.path;
    }
    return externalStorageDirPath;
  }

  late String _localPath;

  var pdfViewerKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    print(widget.pdf);
    final text = '${indexPage + 1} of $pages';
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: Get.width,
            height: 100,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, left: 15, right: 15),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      child: Icon(
                    Icons.close,
                    color: Colors.black,
                  )),
                ),
                Spacer(),
                InkWell(
                    onTap: () async {
                      await FileShareFn([widget.pdf!], context, url: false);
                    },
                    child: Icon(Icons.share, color: Colors.black)),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                    onTap: () async {
                      await Permission.storage.request();
                      DioDownloader([widget.pdf!], context);
                    },
                    child: Icon(Icons.file_download, color: Colors.black)),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                    onTap: () async {
                      //onAlertExternalIntive(context);
                      ExternalInvite(context, 8, 5);
                    },
                    child: Icon(Icons.attach_email, color: Colors.black)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: Get.height,
              width: Get.width,
              child: SfPdfViewer.network(widget.pdf!),
            ),
          ),
        ],
      ),
    );
  }
}
