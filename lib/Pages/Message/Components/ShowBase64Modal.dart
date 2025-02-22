import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

// Function to show modal for base64 PDF or Image
void showBase64Modal(BuildContext context, String base64Data, String fileType) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          child: fileType == 'pdf'
              ? PdfViewer(base64Data: base64Data)
              : ImageViewer(base64Data: base64Data),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the modal
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

// Widget to view the base64 PDF
class PdfViewer extends StatefulWidget {
  final String? base64Data;

  const PdfViewer({Key? key, this.base64Data}) : super(key: key);

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  Widget build(BuildContext context) {
    Uint8List pdfBytes =
        base64Decode(widget.base64Data!); // Decode base64 to bytes

    return PDFView(
      pdfData: pdfBytes, // Display the PDF from bytes
      autoSpacing: true,
      enableSwipe: true,
      swipeHorizontal: false,
    );
  }
}

// Widget to view the base64 image
class ImageViewer extends StatelessWidget {
  final String? base64Data;

  const ImageViewer({Key? key, this.base64Data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      Uint8List imageBytes = base64Decode(base64Data!); // Decode base64 to bytes

    return Image.memory(
      imageBytes, // Display the image from bytes
      fit: BoxFit.contain,
    );
  }
}
