import 'package:undede/Pages/FileViewers/GenericFileWebView.dart';
import 'package:undede/Pages/JpgView.dart';
import 'package:undede/Pages/PDFView.dart';
import 'package:undede/Pages/PdfApi.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:get/get.dart';

Future<void> openFile(DirectoryItem file) async {
  file.path = file.path!.replaceAll('\\', '/');

  print(file.path);
  switch (file.fileName!.split('.').last.toLowerCase()) {
    case 'pdf':
      var uplFile;
      try {
        uplFile = await PDFApi.loadNetwork(file.path!);
      } catch (e, stacktrace) {
        print(stacktrace);
      }
      print("file null değil");
      Get.to(() => PDFViewerPage(
            file: uplFile,
            privateFile: file,
            fileUrl: file.path!,
          ));
      break;
    case 'jpg':
      var uplFile;
      uplFile = file.path.toString().replaceAll(" ", "%20");
      try {} catch (e, stacktrace) {
        print(stacktrace);
      }
      print(uplFile);
      Get.to(() => JpgView(
            picture: uplFile,
            privateFile: file,
          ));
      break;
    case 'jpeg':
      var uplFile;
      uplFile = file.path.toString().replaceAll(" ", "%20");
      try {} catch (e, stacktrace) {
        print(stacktrace);
      }
      print(uplFile);
      Get.to(() => JpgView(
            picture: uplFile,
            privateFile: file,
          ));
      break;
    case 'png':
      var uplFile;
      uplFile = file.path.toString().replaceAll(" ", "%20");
      try {} catch (e, stacktrace) {
        print(stacktrace);
      }
      print(uplFile);
      Get.to(() => JpgView(
            picture: uplFile,
            privateFile: file,
          ));
      break;
    case 'xls':
    case 'xlsm':
    case 'docx':
    case 'xlsx':
    case 'doc':
    case 'mp4':
    case 'm4a':
    case 'mp3':
    case 'txt':
      Get.to(() => GenericFileWebView(
            file: file,
          ));
      break;
    default:
      break;
  }
}
