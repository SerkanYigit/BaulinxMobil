import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CallController extends GetxController {
  int? id;
  String? image;
  int? diffentPage;
  bool? isDirectCall = false;

  CallController({this.id, this.image, this.diffentPage, this.isDirectCall});
}
