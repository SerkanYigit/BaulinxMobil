import 'dart:convert';
import 'dart:typed_data';
import 'package:undede/Pages/FileViewers/GenericFileWebView.dart';
import 'package:undede/Pages/JpgView.dart';
import 'package:undede/Pages/PDFView.dart';
import 'package:get/get.dart';

Future<void> openFileMessage(String file) async {
  print(file);

  // Check if the file is base64
  bool isBase64 = file.contains('base64,');
  String? base64Data = isBase64 ? file.split(',').last : null;

  // Decode base64 if needed
  Uint8List? decodedBytes;
  if (isBase64) {
    decodedBytes = base64Decode(base64Data!);
  }

  switch (file.split('.').last.toLowerCase()) {
    case 'pdf':
      file = file.replaceAll('\\', '/');
      var uplFile;
      try {
        // Handle base64 case
        if (isBase64) {
          uplFile = decodedBytes;
        } else {
          // uplFile = await PDFApi.loadNetwork(file);
        }
      } catch (e, stacktrace) {
        print(stacktrace);
      }
      if (uplFile != null || file != null) {
        print("file is not null");
        Get.to(() => PDFViewerPage(
              file: uplFile,
              fileUrl: file,
            ));
      } else {
        print("file is null");
      }
      break;

    case 'jpg':
    case 'jpeg':
    case 'png':
      var uplFile;
      try {
        if (isBase64) {
          uplFile = decodedBytes;
        }
      } catch (e, stacktrace) {
        print(stacktrace);
      }
      if (uplFile != null || file != null) {
        print(uplFile);
        Get.to(() => JpgView(
              picture: uplFile != null
                  ? base64Data!
                  : file, // If base64, pass decoded data
            ));
      } else {
        print("file is null");
      }
      break;

    case 'xls':
    case 'docx':
    case 'xlsx':
    case 'doc':
    case 'mp4':
    case 'm4a':
      Get.to(() => GenericFileWebView(
            messageUrl: file,
          ));
      break;

    default:
      break;
  }
}
