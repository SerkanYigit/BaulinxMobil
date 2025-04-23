import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';

class CopyAndMovePage extends StatefulWidget {
  String? folderName;
  int? userId; // report ve salary' de gelicek
  bool hideHeader;
  FileManagerType? fileManagerType;
  int? todoId;
  int? customerId;

  CopyAndMovePage({
    this.folderName,
    this.userId,
    this.hideHeader = false,
    this.fileManagerType,
    this.todoId,
    this.customerId,
  });

  @override
  _CopyAndMovePageState createState() => _CopyAndMovePageState();
}

class _CopyAndMovePageState extends State<CopyAndMovePage> {

  final _navigatorKey = GlobalKey<NavigatorState>();
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerFiles>(builder: (c) {
      if (c.removeCopyAndMovePage) {
        c.removeCopyAndMovePage = false;
        Navigator.pop(context);
        print("removeCopyAndMovePage calisti. Sayfa kapandı.");
      }
      return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (RouteSettings settings) {
              WidgetBuilder builder;
              print(settings.name);
              return MaterialPageRoute(
                builder: (context) =>
                    DirectoryDetail(
                      userId: widget.userId!,
                      customerId: widget.customerId!,
                      folderName: "",
                      hideHeader: widget.hideHeader,
                      fileManagerType: widget.fileManagerType!,
                      todoId: null,
                      canViewFolders: true,
                    ),
              );
            },
          ));
    });
  }

  @override
  void dispose() {
    _controllerFiles.refreshPrivate = true;
    _controllerFiles.update();
    _controllerFiles.isCopyActionActive = false;
    _controllerFiles.isMoveActionActive = false;
    _controllerFiles.SourceDirectoryNameList = [];
    _controllerFiles.FileIdList = [];
    super.dispose();
  }
}