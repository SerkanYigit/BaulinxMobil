import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';

class BoardCloudPage extends StatefulWidget {
  final int? boardId;
  final String? boardTitle;
  const BoardCloudPage({Key? key, this.boardId, this.boardTitle})
      : super(key: key);

  @override
  _BoardCloudPageState createState() => _BoardCloudPageState();
}

class _BoardCloudPageState extends State<BoardCloudPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.boardTitle!),
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Get.theme.secondaryHeaderColor,
        child: Column(
          children: [
            Expanded(
              child: Navigator(
                  key: Key('xx'),
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(builder: (context) {
                      return DirectoryDetail(
                        folderName: "",
                        hideHeader: true,
                        fileManagerType: FileManagerType.CommonDocument,
                        todoId: widget.boardId!, //widget.todoId,
                      );
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
