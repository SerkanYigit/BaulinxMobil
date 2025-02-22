import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';


class PdfApi {
  Future<String> generateCenteredText(String text) async {
    // making a pdf document to store a text and it is provided by pdf pakage
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    final _controllerFiles = Get.put(ControllerFiles());
    final _controllerDB = Get.put(ControllerDB());
    PdfTextElement(
      text: TurkishCharacterToEnglish(text),
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        18,
      ),
      brush: PdfBrushes.black,
    ).draw(page: page, bounds: Rect.fromLTWH(25, 25, pageSize.width - 25, 0));
    // Text is added here in center

    // passing the pdf and name of the docoment to make a direcotory in  the internal storage
    final appStorage = await getApplicationDocumentsDirectory();

    final path = File(appStorage.path + "/" + 'output.pdf');
    print("" + document.pages.count.toString());
    final file = await File(path.path).writeAsBytes(await document.save());
    OpenFilex.open(
      file.path,
    );
    Files files = new Files();
    files.fileInput = [];
    print(file.path);
    List<int> fileBytes = File(file.path).readAsBytesSync();
    String fileContent = base64.encode(fileBytes);
    files.fileInput!
        .add(new FileInput(fileName: 'sample.pdf', fileContent: fileContent));
    /*
    _controllerFiles.UploadFiles(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value.result.id,
      CustomerId: null,
      ModuleTypeId: FileManagerType.PrivateDocument.index,
      files: files,
      OwnerId: 0,
      IsCombine: files.fileInput.length > 1 ? true : false,
      CombineFileName: "sample.pdf",
    );
*/
    return file.path;
  }

  String TurkishCharacterToEnglish(String text) {
    List<String> turkishChars = [
      'ı',
      'ğ',
      'İ',
      'Ğ',
      'ç',
      'Ç',
      'ş',
      'Ş',
      'ö',
      'Ö',
      'ü',
      'Ü'
    ];
    List<String> englishChars = [
      'i',
      'g',
      'I',
      'G',
      'c',
      'C',
      's',
      'S',
      'o',
      'O',
      'u',
      'U'
    ];

    // Match chars
    for (int i = 0; i < turkishChars.length; i++)
      text = text.replaceAll(turkishChars[i], englishChars[i]);

    return text;
  }
}
