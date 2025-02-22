
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'bndBox.dart';
import 'inference_screen.dart';

class CameraDetectionPage extends StatefulWidget {
  final bool isOneClick;
  final bool isScan;
  const CameraDetectionPage({
    Key? key,
    this.isOneClick = false,
    this.isScan = false,
  }) : super(key: key);

  @override
  _CameraDetectionPageState createState() => new _CameraDetectionPageState();
}

class _CameraDetectionPageState extends State<CameraDetectionPage> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
  /*    await Tflite.loadModel(
        model: "assets/ssd_mobilenet_v1_1_metadata_1.tflite",
        labels: "assets/ssd_mobilenet.txt",
      );*/
    });

    setState(() {
      _model = "";
    });
    super.initState();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Camera(
            setRecognitions,
            isOneClick: widget.isOneClick,
            isScan: widget.isScan,
          ),
          BndBox(
              _recognitions == null ? [] : _recognitions,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
              _model),
        ],
      ),
    );
  }
}
