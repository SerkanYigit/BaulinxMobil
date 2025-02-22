import 'package:undede/model/Files/FileLabel.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Label/GetTodoLabelListResult.dart';

abstract class LabelBase {
  Future<GetLabelByUserIdResult> GetLabelByUserId(Map<String, String> header,
      {int Id, int UserId, int CustomerId, int LabelType});
  Future InsertLabel(Map<String, String> header,
      {String Title, String Color, int UserId, int LabelType});
  Future UpdateLabel(Map<String, String> header,
      {int Id, String Title, String Color, int UserId});
  Future DeleteLabel(Map<String, String> header, {int LabelId, int UserId});
  Future<GetTodoLabelListResult> GetTodoLabelList(Map<String, String> header,
      {int TodoId, int UserId});
  Future InsertTodoLabel(Map<String, String> header,
      {int TodoId, int LabelId, int UserId});
  Future InsertTodoLabelList(Map<String, String> header,
      {int TodoId, List<int> LabelIds, int UserId});
  Future<bool> InsertFileListLabelList(Map<String, String> header,
      {List<int> FilesIds, List<int> LabelIds, int UserId});
  Future<FileLabel> GetFileLabelList(Map<String, String> header,
      {int FilesId, int UserId});
}
