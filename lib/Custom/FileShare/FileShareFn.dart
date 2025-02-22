import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:get/get.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

FileShareFn(List<String> filePaths, context, {url = false}) async {
  if (!(filePaths.length > 0)) {
    showWarningToast(AppLocalizations.of(context)!.onlyFilesCanBeShareable);
    return;
  }

  print("İndirilecek dosya pathleri : \n");
  filePaths.forEach((e) {
    print(e.toString() + "\n");
  });
  print("--------------------------------------------");

  final ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  _controllerBottomNavigationBar.lockUI = true;
  _controllerBottomNavigationBar.update();

  final temp = await getTemporaryDirectory();
  List<XFile> downloadedFilePaths = [];

  try {
    if (!url) {
      for (int i = 0; filePaths.length > i; i++) {
        final url = Uri.parse(filePaths[i]);
        final response = await http.get(url);
        final bytes = response.bodyBytes;

        String path =
            '${temp.path}/tempFile${i.toString()}.${filePaths[i].split('.').last.toLowerCase()}';
     //!alt satir iptal edildi. ve XFile kullanildi.
      //  File(path).writeAsBytesSync(bytes);
        downloadedFilePaths.add(XFile(path));
      }
    }

    url
        ? await Share.share(filePaths.first, subject: "Baulinx")
        : await Share.shareXFiles(downloadedFilePaths, subject: "Baulinx");
        //! SShare de bir problem var.
  
  
  } catch (error) {
    showErrorToast(AppLocalizations.of(context)!.anErrorHasOccured);
  } finally {
    _controllerBottomNavigationBar.lockUI = false;
    _controllerBottomNavigationBar.update();
  }
}
