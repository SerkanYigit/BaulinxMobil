import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../Controller/ControllerDB.dart';
import '../../Controller/ControllerFiles.dart';
import '../../model/Files/UploadFiles.dart';
import '../HomePage/Provider/HomePageProvider.dart';

class PdfSignature extends StatefulWidget {
  final String? pdfUrl;
  final int? ModuleType;
  final int? Id;

  const PdfSignature({Key? key, this.pdfUrl, this.ModuleType, this.Id})
      : super(key: key);

  @override
  State<PdfSignature> createState() => _PdfSignatureState();
}

class _PdfSignatureState extends State<PdfSignature> {
  Offset _offset = Offset(150, 150); // Initialize with a default value
  File? file;
  final _signatureController = SignatureController();
  Uint8List? _signatureBytes;
  int currentPage = 0;
  Size _pdfPageSize = Size(0, 0); // Size of the current PDF page

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<DraggableSheetController>(context);

    int ownerId = homeProvider.ownerId;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            InkWell(
              onTap: () {
                // User is done drawing, trigger PDF saving
                processPdf(ownerId);
              },
              child: Icon(Icons.save),
            ),
            SizedBox(width: 10),
          ],
        ),
        body: Stack(
          children: [
            // Display the PDF file
            SfPdfViewer.network(widget.pdfUrl!,
                controller: PdfViewerController(), onPageChanged: (page) {
              currentPage = page.newPageNumber;
            }),
            // Add Signature Widget directly on the PDF
            Positioned(
              top: 50, // Adjust the position according to your design
              left: 20,
              right: 20,
              bottom: 50, // Adjust as needed
              child: Signature(
                controller: _signatureController,
                width: double.infinity,
                height: double.infinity,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Process the PDF: Sign and Upload
  Future<void> processPdf(int ownerId) async {
    try {
      // Fetch the PDF file from the URL
      final response = await http.get(Uri.parse(widget.pdfUrl!));
      if (response.statusCode != 200) {
        throw Exception('Failed to load PDF file');
      }

      final _controllerFiles = Get.put(ControllerFiles());
      final _controllerDB = Get.put(ControllerDB());

      // Get the temporary directory and write the PDF file to it
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Load the PDF document
      final PdfDocument document =
          PdfDocument(inputBytes: await file.readAsBytes());

      // Ensure the current page is valid (PDF is 0-indexed)
      if (currentPage <= document.pages.count) {
        var page = document.pages[currentPage];

        // Check if signature exists
        if (_signatureController.isNotEmpty) {
          _signatureBytes = await _signatureController.toPngBytes();

          final PdfBitmap image = PdfBitmap(_signatureBytes!);

          // Dynamically calculate the position for the signature
          Offset pdfOffset = convertOffsetToPdfPage(
            _offset,
            MediaQuery.of(context).size,
            page.size,
          );

          // Draw the image (signature) on the page
          page.graphics.drawImage(
            image,
            Rect.fromLTWH(
              pdfOffset.dx,
              pdfOffset.dy,
              image.width.toDouble(),
              image.height.toDouble(),
            ),
          );

          // Save the modified PDF document
          List<int> bytes = await document.save();
          document.dispose();

          // Write the modified PDF to the file
          await file.writeAsBytes(bytes);

          // Convert file to base64 for upload
          String fileContent = base64.encode(bytes);

          // Create the file object
          Files files = Files();
          files.fileInput = [
            FileInput(fileName: 'sample.pdf', fileContent: fileContent),
          ];

          // Call the UploadFiles method to upload the file
          await _controllerFiles.UploadFiles(
            _controllerDB.headers(), // Authentication headers
            UserId: _controllerDB.user.value!.result!.id, // User ID
            CustomerId: widget.Id, // Customer ID
            ModuleTypeId: widget.ModuleType, // Module Type ID
            files: files,
            OwnerId: ownerId, // Owner ID
            IsCombine: files.fileInput!.length > 1, // Check if combining files
            CombineFileName: "sample.pdf", // Combine file name
          );

          print("PDF uploaded and saved successfully.");
                } else {
          print("No signature to save.");
        }
      } else {
        print("Invalid page number: $currentPage");
      }

      // Clear the signature controller after use
      _signatureController.clear();
    } catch (e) {
      print('Error processing PDF: $e');
    }
  }

  // Convert the Offset based on the screen size and PDF page size
  Offset convertOffsetToPdfPage(
      Offset widgetOffset, Size screenSize, Size pdfPageSize) {
    double xRatio = widgetOffset.dx / screenSize.width;
    double yRatio = widgetOffset.dy / screenSize.height;

    double xOffset = xRatio * pdfPageSize.width;
    double yOffset = yRatio * pdfPageSize.height;

    return Offset(xOffset, yOffset);
  }
}
