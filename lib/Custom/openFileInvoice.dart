import 'package:undede/Pages/FileViewers/GenericFileWebView.dart';
import 'package:undede/Pages/JpgView.dart';
import 'package:undede/Pages/PDFView.dart';
import 'package:get/get.dart';
import 'package:undede/model/Invoice/GetInvoiceListResult.dart';

Future<void> openFileInvoice(Invoice inv) async {
  switch (inv.file!.fileName!.split('.').last.toLowerCase()) {
    case 'pdf':
      inv.file!.path = inv.file!.path!.replaceAll('\\', '/');
      var uplFile;
      try {
        //   uplFile = await PDFApi.loadNetwork(inv.file.path);
      } catch (e, stacktrace) {
        print(stacktrace);
      }
      print("file null değil");
      Get.to(() => PDFViewerPage(
            file: uplFile,
            invoice: inv,
            fileUrl: inv.file!.path!,
          ));
          break;
    case 'jpg':
      var uplFile;
      uplFile = inv.file!.path!.replaceAll('\\', '/');
      uplFile = uplFile.toString().replaceAll(" ", "%20");
      try {} catch (e, stacktrace) {
        print(stacktrace);
      }
      print(uplFile);
      Get.to(() => JpgView(
            picture: uplFile,
            invoice: inv,
          ));
          break;
    case 'jpeg':
      var uplFile;
      uplFile = inv.file!.path!.replaceAll('\\', '/');
      uplFile = uplFile.toString().replaceAll(" ", "%20");
      try {} catch (e, stacktrace) {
        print(stacktrace);
      }
      print(uplFile);
      Get.to(() => JpgView(
            picture: uplFile,
            invoice: inv,
          ));
          break;
    case 'png':
      var uplFile;
      uplFile = inv.file!.path!.replaceAll('\\', '/');
      uplFile = uplFile.toString().replaceAll(" ", "%20");
      try {} catch (e, stacktrace) {
        print(stacktrace);
      }
      print(uplFile);
      Get.to(() => JpgView(
            picture: uplFile,
            invoice: inv,
          ));
          break;
    case 'xls':
    case 'docx':
    case 'xlsx':
    case 'doc':
    case 'mp4':
    case 'm4a':
      var uplFile;
      uplFile = inv.file!.path!.replaceAll('\\', '/');
      uplFile = uplFile.toString().replaceAll(" ", "%20");
      print("uplFile" + uplFile);
      Get.to(() => GenericFileWebView(
            messageUrl: uplFile,
            invoice: inv,
          ));
      break;
    default:
      break;
  }
}
