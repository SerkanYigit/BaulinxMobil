import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:path/path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

DioDownloader(List<String> urls, BuildContext context) async {
  try {
    await Permission.manageExternalStorage.request();
    showSuccessToast(AppLocalizations.of(context)!.fileDownloadStarted);
    for (int i = 0; i < urls.length; i++) {
      final appStorage = await getApplicationDocumentsDirectory();
      final file = File(appStorage.path + "/" + basename(urls[i]));
      //  final file = File("/storage/emulated/0/Download/" + basename(urls[i]));
      final response = await Dio().get(urls[i],
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: const Duration(seconds: 0)),
          onReceiveProgress: (a, i) {});
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 0,
            channelKey: 'download_channel',
            title: basename(urls[i]).split(".").first,
            body: AppLocalizations.of(context)!.fileDownloadedSuccesfully,
            summary: file.path),
      );
      await raf.close();
      return file;
    }
  } catch (e, s) {
    print(e);
    print(s);
    showErrorToast(AppLocalizations.of(context)!.downloadDidNotStart);
  }
}
