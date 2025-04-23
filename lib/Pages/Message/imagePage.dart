import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Custom/DioDownloader.dart';
import 'package:undede/Custom/FileShare/FileShareFn.dart';

import '../../Custom/CustomLoadingCircle.dart';

class imagePage extends StatefulWidget {
  final String? image;
  const imagePage({Key? key, this.image}) : super(key: key);

  @override
  _imagePageState createState() => _imagePageState();
}

class _imagePageState extends State<imagePage> {
  final ReceivePort _port = ReceivePort();
  @override
  void initState() {
    super.initState();
    _prepareSaveDir();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.secondaryHeaderColor,
        iconTheme: IconThemeData(color: Get.theme.primaryColor),
        actions: [
          SizedBox(
            width: 15,
          ),
          InkWell(
              onTap: () async {
                await Permission.storage.request();
                DioDownloader([widget.image!], context);
              },
              child: Icon(Icons.file_download, color: Colors.white)),
          SizedBox(
            width: 15,
          ),
          InkWell(
              onTap: () async {
                await FileShareFn([widget.image!], context);
              },
              child: Icon(Icons.share, color: Colors.white)),
          SizedBox(
            width: 15,
          ),
        ],
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        child: CachedNetworkImage(
          imageUrl: widget.image!,
          placeholder: (context, url) => CustomLoadingCircle(),
        ),
      ),
    );
  }
}
