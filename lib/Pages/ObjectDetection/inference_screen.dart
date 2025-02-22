import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';
import 'package:undede/Controller/ControllerDB.dart';

import '../../Controller/ControllerFiles.dart';
import '../../Custom/FileManagerType.dart';
import '../../Custom/showModalYesOrNo.dart';
import '../../WidgetsV2/customCardShadow.dart';
import '../../main.dart';
import '../../model/Files/UploadFiles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  bool isOneClick;
  bool isScan;
  final Callback setRecognitions;
  Camera(this.setRecognitions, {this.isOneClick = false, this.isScan = false});

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? controller;
  bool isDetecting = false;
  List<int> _capturedImage = [];
  Rect? _boundingBox;
  bool _isCapturing = false;
  List<List<dynamic>> _previousRecognitions = [];
  List<dynamic> _recentRecognitions = [];
  List<CameraImage> images = [];
  List<File> fileImages = [];

  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  @override
  void initState() {
    super.initState();
    Cameras();
  }

  Future<void> Cameras() async {
    print("images::" + images.length.toString());
    controller = new CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      controller!.startImageStream((CameraImage img) async {
        if (!isDetecting) {
          isDetecting = true;
          int startTime = new DateTime.now().millisecondsSinceEpoch;
          var recognitions =[];
          recognitions = recognitions
              .where((element) =>
                  element["detectedClass"] == "bed" ||
                  element["detectedClass"] == "book" ||
                  element["detectedClass"] == "laptop")
              .toList();

          int endTime = new DateTime.now().millisecondsSinceEpoch;
          print("Detection took ${endTime - startTime}");
          widget.setRecognitions(recognitions, img.height, img.width);

          if (recognitions.isNotEmpty) {
            var data = findSimilarObjects(recognitions, 0.95, img);
            if (data.isNotEmpty) {
              if (data.length >= 5) {
                print("datas : " + data.toString());
                widget.setRecognitions([], img.height, img.width);
                  controller!.stopImageStream();
                startTime = DateTime.now().millisecondsSinceEpoch;
                _capturedImage = await _convertYUV420(images);
                endTime = DateTime.now().millisecondsSinceEpoch;
                print("convert took ${endTime - startTime}");

       //!         imglib.Image image2 = imglib.decodeImage(_capturedImage);
       //!         image2 = imglib.copyRotate(image2, 90);
       //! asagidaki kod ile calistirildi

                imglib.Image? image2 = imglib.decodeImage(Uint8List.fromList(_capturedImage));
                if (image2 != null) {
                  image2 = imglib.copyRotate(image2, angle: 90);
                }

                double xAverage = data.isEmpty
                    ? 0
                    : data
                            .map((frameData) => frameData["rect"]["x"])
                            .reduce((a, b) => a + b) /
                        data.length;
                double yAverage = data.isEmpty
                    ? 0
                    : data
                            .map((frameData) => frameData["rect"]["y"])
                            .reduce((a, b) => a + b) /
                        data.length;
                double wAverage = data.isEmpty
                    ? 0
                    : data
                            .map((frameData) => frameData["rect"]["w"])
                            .reduce((a, b) => a + b) /
                        data.length;
                double hAverage = data.isEmpty
                    ? 0
                    : data
                            .map((frameData) => frameData["rect"]["h"])
                            .reduce((a, b) => a + b) /
                        data.length;
                //  _capturedImage = convertYUV420(img);

                _createBoundingBox(
                  xAverage,
                  yAverage,
                  wAverage,
                  hAverage,
                  image2!.width,
                  image2.height,
                );

                _cropAndSaveImage(image2, _boundingBox!);
              }
            }
            _previousRecognitions.add(recognitions);
            if (_recentRecognitions.length > 5) {
              _previousRecognitions.removeAt(0);
            }
          }
          isDetecting = false;
        }
      });
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
      tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _previousRecognitions = [];
            _recentRecognitions = [];
            images = [];
            _capturedImage = [];
          });
          Cameras();
        },
        child: Icon(Icons.camera_alt_outlined),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          icon: Icon(Icons.chevron_left),
        ),
        actions: [
          fileImages.isEmpty
              ? Container()
              : InkWell(
                  onTap: () async {
                    if (widget.isOneClick || widget.isScan) {
                      await uploadImages();
                    } else {
                      Navigator.pop(context, fileImages);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    height: 35,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: standartCardShadow()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Center(
                          child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500),
                      )),
                    ),
                  ),
                )
        ],
      ),
      body: OverflowBox(
        maxHeight: screenRatio > previewRatio
            ? screenH
            : screenW / previewW * previewH,
        maxWidth: screenRatio > previewRatio
            ? screenH / previewH * previewW
            : screenW,
        child: Stack(
          children: [
            CameraPreview(controller!),
            Positioned(
              bottom: 50,
              left: 55,
              right: 55,
              child: Container(
                width: Get.width,
                height: 100,
                color: Colors.grey.withOpacity(0.05),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: fileImages.length,
                    shrinkWrap: true,
                    controller: ScrollController(keepScrollOffset: false),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Container(
                            width: 65,
                            height: 65,
                            child: Image.file(
                              fileImages[index],
                              fit: BoxFit.cover,
                            )),
                      ); //categoryItem(index);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createBoundingBox(
      double x, double y, double w, double h, int imgWidth, int imgHeight) {
    final left = x * imgWidth;
    final top = y * imgHeight;
    final width = w * imgWidth;
    final height = h * imgHeight;

    setState(() {
      _boundingBox = Rect.fromLTWH(left, top, width, height);
    });
  }

  Future<void> _cropAndSaveImage(imglib.Image image, Rect boundingBox) 
  async {
    int left = boundingBox.left.toInt();
    int top = boundingBox.top.toInt();
    int right = boundingBox.right.toInt();
    int bottom = boundingBox.bottom.toInt();

    imglib.Image croppedImage =
        imglib.copyCrop(image, x:left, y:top, width:right - left, height:bottom - top);

    // Görüntüyü düzeltmek için aşağıdaki satırı ekleyin (0 derece döndürme).

    Uint8List croppedBytes = Uint8List.fromList(imglib.encodePng(croppedImage));
    Directory tempDir = await getTemporaryDirectory();
    File file = File(
        '${tempDir.path}/temp_image${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(croppedBytes);

    setState(() {
      fileImages.add(file);
    });
  }

  Future<Uint8List> _convertYUV420(List<CameraImage> images) async {
    var img =
        imglib.Image(width:images[0].width, height:images[0].height); // Create Image buffer

    for (var image in images) {
      Plane plane = image.planes[0];
      const int shift = (0xFF << 24);

      for (int i = 0; i < plane.bytes.length; i++) {
        final pixelColor = plane.bytes[i];
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
            print("newVal : $newVal");
            //! img.data[i] = newVal; yerine asagidaki kod kullanildi
        img.data = newVal as imglib.ImageData?;
      }
    }

    imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: imglib.PngFilter.none); //! filter:0 yerine imglib.PngFilter.none kullanildi
    Uint8List png = await pngEncoder.encode(img);
    //! encodeImage(img); yerine encode kullanildi
    return png;
  }

  List<dynamic> findSimilarObjects(List<dynamic> currentRecognitions,
      double similarityThreshold, CameraImage img) {
    for (dynamic currentObject in currentRecognitions) {
      for (List<dynamic> recent in _previousRecognitions) {
        for (dynamic previousObject in recent) {
          if (currentObject["detectedClass"] ==
              previousObject["detectedClass"]) {
            double currentX = currentObject["rect"]["x"];
            double currentY = currentObject["rect"]["y"];
            double currentW = currentObject["rect"]["w"];
            double currentH = currentObject["rect"]["h"];

            double previousX = previousObject["rect"]["x"];
            double previousY = previousObject["rect"]["y"];
            double previousW = previousObject["rect"]["w"];
            double previousH = previousObject["rect"]["h"];

            double similarity = calculateSimilarity(
              currentX,
              currentY,
              currentW,
              currentH,
              previousX,
              previousY,
              previousW,
              previousH,
            );

            if (similarity > similarityThreshold) {
              _recentRecognitions.add(currentObject);
              images.add(img);
              break;
            }
          }
        }
      }
    }

    return _recentRecognitions;
  }

  // Benzerlik hesaplama fonksiyonu
  double calculateSimilarity(double x1, double y1, double w1, double h1,
      double x2, double y2, double w2, double h2) {
    double iouX = math.max(x1, x2);
    double iouY = math.max(y1, y2);
    double iouW = math.min(x1 + w1, x2 + w2) - iouX;
    double iouH = math.min(y1 + h1, y2 + h2) - iouY;
    if (iouW <= 0 || iouH <= 0) {
      return 0.0;
    }
    double iouArea = iouW * iouH;
    double area1 = w1 * h1;
    double area2 = w2 * h2;
    double iou = iouArea / (area1 + area2 - iouArea);
    return iou;
  }

  uploadImages() async {
    Files files = new Files();
    files.fileInput = <FileInput>[];

    if (images.length > 0) {
      List<int> fileBytes = <int>[];

      fileImages.forEach((file) {
        fileBytes = new File(file.path).readAsBytesSync().toList();
        String fileContent = base64.encode(fileBytes);
        files.fileInput!.add(new FileInput(
            fileName: widget.isOneClick ? 'sample.jpeg' : 'sample.jpg',
            directory: widget.isOneClick ? "Picture" : "",
            fileContent: fileContent));
      });
    }

    bool isCombine = false;
    if (widget.isScan) {
      if (files.fileInput!.length > 1) {
        bool? result = await showModalYesOrNo(
            context,
            AppLocalizations.of(context)!.fileUpload,
            AppLocalizations.of(context)!.doyouwanttocombinefiles);
        print("Combine işlemi boş bırakıldı metod geri döndü : " +
            result.toString());
        isCombine = result!;
      }
    }

    await uploadFilesToPrivate(files, isCombine);
    Navigator.of(context).pop();
  }

  Future<void> uploadFilesToPrivate(Files files, bool isCombine) async {
    print("files.fileInput.length : " + files.fileInput!.length.toString());

    if (widget.isOneClick) {
      await _controllerFiles.UploadFilesToPrivate(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: null,
        ModuleTypeId: FileManagerType.PrivateDocument.typeId,
        files: files,
        IsCombine: isCombine,
        CombineFileName: 'vir2ell_office.jpg',
      );
    } else if (widget.isScan) {
      await _controllerFiles.UploadFiles(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: null,
        ModuleTypeId: FileManagerType.PrivateDocument.typeId,
        files: files,
        IsCombine: isCombine,
        CombineFileName: 'vir2ell_office.pdf',
      );
    }
  }
}
