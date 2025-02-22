import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:undede/model/Files/FileLabel.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Label/GetTodoLabelListResult.dart';
import '../../model/Label/GetInvoiceModel.dart';
import '../ServiceUrl.dart';
import 'LabelBase.dart';

class LabelDb implements LabelBase {
  final ServiceUrl _serviceUrl = ServiceUrl();


 @override
  Future<GetInvoiceModel> GetInvoiceCompany(Map<String, String> header,
      {int? UserId}) async {
    var response = await http.get(Uri.parse(_serviceUrl.getInvoiceCompany+UserId.toString()),
        headers: header);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print('responseData :::: '+ responseData.toString());
      return GetInvoiceModel.fromJson(responseData);
  }

  @override
  Future<GetLabelByUserIdResult> GetLabelByUserId(Map<String, String> header,
      {int? Id, int? UserId, int? CustomerId, int? LabelType}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getLabelByUserId),
        headers: header,
        body: jsonEncode({
          "Id": Id,
          "UserId": UserId,
          "CustemerId": CustomerId,
          "LabelType": LabelType
        }));
    log("GetLabelByUserId" + response.body);
    if (response.body.isEmpty) {
      return GetLabelByUserIdResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetLabelByUserIdResult.fromJson(responseData);
    }
  }

  @override
  Future InsertLabel(Map<String, String> header,
      {String? Title, String? Color, int? UserId, int? LabelType}) async {
    var body = jsonEncode({
      "LabelType": LabelType,
      "Title": Title,
      "Color": Color,
      "UserId": UserId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.insertLabel),
        headers: header, body: body);

    log("req AddLabel = " + body.toString());
    log("req AddLabel = " + response.body);

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future DeleteLabel(Map<String, String> header,
      {int? LabelId, int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.deleteLabel),
        headers: header,
        body: jsonEncode({
          "LabelId": LabelId,
          "UserId": UserId,
        }));

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future UpdateLabel(Map<String, String> header,
        {int? Id, String? Title, String? Color, int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.updateLabel),
        headers: header,
        body: jsonEncode({
          "Id": Id,
          "Title": Title,
          "Color": Color,
          "UserId": UserId,
        }));

    //log("req GetAllCommons = " + response.request.url.toString());

    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print(responseData);
      return true;
    }
  }

  @override
  Future<GetTodoLabelListResult> GetTodoLabelList(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    var response = await http.post(Uri.parse(_serviceUrl.getTodoLabelList),
        headers: header,
        body: jsonEncode({
          "TodoId": TodoId,
          "UserId": UserId,
        }));

    if (response.body.isEmpty) {
      return GetTodoLabelListResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetTodoLabelListResult.fromJson(responseData);
    }
  }

  @override
  Future InsertTodoLabel(Map<String, String> header,
      {int? TodoId, int? LabelId, int? UserId}) async {
    var body = jsonEncode({
      "LabelId": LabelId,
      "TodoId": TodoId,
      "UserId": UserId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.insertTodoLabel),
        headers: header, body: body);
    print(body.toString());
    print(response.body);
    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return true;
    }
  }

  @override
  Future InsertTodoLabelList(Map<String, String> header,
      {int? TodoId, List<int>? LabelIds, int? UserId}) async {
    var body = jsonEncode({
      "TodoId": TodoId,
      "LabelIds": LabelIds,
      "UserId": UserId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.insertTodoLabelList),
        headers: header, body: body);
    print(body.toString());
    print(response.body);
    if (response.body.isEmpty) {
      return null;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData;
    }
  }

  @override
  Future<bool> InsertFileListLabelList(Map<String, String> header,
      {List<int>? FilesIds, List<int>? LabelIds, int? UserId}) async {
    var body = jsonEncode({
      "FilesIds": FilesIds,
      "LabelIds": LabelIds,
      "UserId": UserId,
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.insertFileListLabelList),
        headers: header,
        body: body);

    print("req InsertFileListLabelList:" + body.toString());
    print("req InsertFileListLabelList:" + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<FileLabel> GetFileLabelList(Map<String, String> header,
      {int? FilesId, int? UserId}) async {
    var body = jsonEncode({
      "FilesId": FilesId,
      "UserId": UserId,
    });
    var response = await http.post(Uri.parse(_serviceUrl.getFileLabelList),
        headers: header, body: body);
    print(body.toString());
    print(response.body);
    if (response.body.isEmpty) {
      return FileLabel(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return FileLabel.fromJson(responseData);
    }
  }
}
