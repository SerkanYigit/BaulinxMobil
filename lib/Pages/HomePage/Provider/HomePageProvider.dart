import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/utils/utils.dart';

import '../../../model/Common/Commons.dart';
import '../../../model/Todo/CommonTodo.dart';

class DraggableSheetController extends ChangeNotifier {
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();
  bool _isSheetOpen = false;
  bool _isSheetAttached = false;
  CommonTodo _boardTodo = CommonTodo();
  CommonBoardListItem _commonBoardListItem = CommonBoardListItem();
  bool _isDirectCall = false;
  int _callId = 0;
  String _imagePath = '';
  int _ownerId = 0;

  DraggableScrollableController get draggableScrollableController =>
      _draggableScrollableController;
  bool get isSheetOpen => _isSheetOpen;
  CommonTodo get boardTodo => _boardTodo;
  CommonBoardListItem get commonBoardListItem => _commonBoardListItem;

  bool get isDirectCall => _isDirectCall;
  set isDirectCall(bool isDirectCall) => _isDirectCall = isDirectCall;
  int get callId => _callId;
  set callId(int callId) => _callId = callId;
  String get imagePath => _imagePath;
  set imagePath(String imagePath) => _imagePath = imagePath;
  int get ownerId => _ownerId;
  set ownerId(int ownerId) => _ownerId = ownerId;

  void setSheetAttached(bool attached) {
    _isSheetAttached = attached;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached && _isSheetOpen) {
        _draggableScrollableController.animateTo(
          0.8,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      notifyListeners();
    });
  }

  void toggleSheet() {
    if (!_isSheetAttached) {
      _isSheetOpen = !_isSheetOpen;
      notifyListeners();
      return;
    }

/*   if (draggableSheetContext != null) {
    setState(() {
      initialExtent = isExpanded ? minExtent : maxExtent;
    });
    DraggableScrollableActuator.reset(draggableSheetContext);
  }
 */

    _isSheetOpen = !_isSheetOpen;
    notifyListeners();
    if (_isSheetOpen) {
      _draggableScrollableController.animateTo(
        0.8,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _draggableScrollableController.animateTo(
        0.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void closeSheet() {
    if (!_isSheetAttached) {
      _isSheetOpen = false;
      notifyListeners();
      return;
    }

    _isSheetOpen = false;
    notifyListeners();
    _draggableScrollableController.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void updateBoardTodoAndListItem(
      CommonTodo boardTodo, CommonBoardListItem commonBoardListItem) {
    _boardTodo = boardTodo;
    _commonBoardListItem = commonBoardListItem;
    notifyListeners();
  }
}
