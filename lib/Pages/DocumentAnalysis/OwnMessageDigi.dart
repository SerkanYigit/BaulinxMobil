import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_sheet2/sliding_sheet2.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OwnMessageDigiCard extends StatefulWidget {
  const OwnMessageDigiCard(
      {Key? key,
      this.message,
      this.time,
      this.Selected,
      this.myImage,
      this.FileThumbnail,
      this.File})
      : super(key: key);
  final String? message;
  final String? time;
  final bool? Selected;
  final String? myImage;
  final String? FileThumbnail;
  final String? File;

  @override
  State<OwnMessageDigiCard> createState() => _OwnMessageDigiCardState();
}

class _OwnMessageDigiCardState extends State<OwnMessageDigiCard> {
  StreamController<int> stream_controller = StreamController<int>.broadcast();
  @override
  void initState() {
    super.initState();
    stream_controller = StreamController<int>.broadcast();
  }

  @override
  void dispose() {
    stream_controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Container(
              width: 35,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        widget.myImage!,
                      ))),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: widget.Selected! ? Colors.green.withOpacity(0.5) : null,
            ),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Stack(
                children: [
                  Container(
                    height: 250,
                    width: Get.width - 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            fit: BoxFit.contain,
                            image: NetworkImage(
                              widget.FileThumbnail!,
                            ))),
                  ),
                  Positioned(
                      top: 5,
                      right: 5,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            enableDrag: false,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                height: Get.height * 0.8,
                                child: Scaffold(
                                  appBar: AppBar(
                                    backgroundColor:
                                        Get.theme.primaryColor.withOpacity(0.2),
                                    actions: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      )
                                    ],
                                  ),
                                  body: SfPdfViewer.network(
                                    widget.File!.replaceAll("\\", "/"),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Icon(Icons.file_present),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
