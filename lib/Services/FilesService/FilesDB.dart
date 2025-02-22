import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Files/UploadFiles.dart';

import '../ServiceUrl.dart';

import 'FilesBase.dart';

class FilesDB implements FilesBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<FilesForDirectory> GetFilesByUserIdForDirectory(
      Map<String, String> header,
      {int? userId,
      int? customerId,
      int? moduleType,
      String? directory,
      int? page}) async {
    var reqBody = jsonEncode({
      "UserId": userId,
      "CustomerId": customerId,
      "OwnerId": customerId,
      "ModuleType": moduleType,
      "Directory": directory,
      "Page": page
    });

    var response = await http.post(
        Uri.parse(_serviceUrl.GetFilesByUserIdForDirectory),
        headers: header,
        body: reqBody);
    log(reqBody);
    log("res GetFilesByUserIdForDirectory = " + response.body);

    if (response.body.isEmpty) {
      return FilesForDirectory(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return FilesForDirectory.fromJson(responseData);
    }
  }

  @override
  Future<FilesResponse> GetFilesByUserIdForLabels(
    Map<String, String> header, {
    int? userId,
    int? customerId,
    int? moduleType,
    String? keyword = "",
    int? pageIndex = 0,
    String? endDate,
    String? startDate,
    int? isPaid = 0,
    int? targetAccount = 0,
    List<int>? labelIds,
  }) async {
    // Construct the request body as a JSON object
    var reqBody = jsonEncode({
      "UserId": userId,
      "CustomerId": customerId,
      "OwnerId": customerId,
      "ModuleType": moduleType,
      "Keyword": keyword,
      "PageIndex": pageIndex,
      "EndDate": endDate,
      "StartDate": startDate,
      "IsPaid": isPaid,
      "TargetAccount": targetAccount,
      "LabelIds": labelIds,
    });

    try {
      // Make the HTTP POST request
      var response = await http.post(
        Uri.parse(_serviceUrl.GetFilesByUserIdForLabels),
        headers: header,
        body: reqBody,
      );

      // Log the request and response for debugging
      log("Response Bodyyyy: Request Body: $reqBody");
      log("Response Bodyyyyyyyy: ${response.body}");

      // Check if the response is empty
      if (response.body.isEmpty) {
        return FilesResponse(hasError: true);
      } else {
        // Decode the JSON response and map it to a FilesForDirectory object
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        return FilesResponse.fromJson(responseData);
      }
    } catch (e) {
      log("Error: $e");
      return FilesResponse(hasError: true);
    }
  }

  @override
  Future<bool> CreateDirectory(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      int? OwnerId,
      String? DirectoryName}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "ModuleTypeId": ModuleTypeId,
      "OwnerId": OwnerId,
      "DirectoryName": DirectoryName
    });

    var response = await http.post(Uri.parse(_serviceUrl.createDirectory),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("CreateDirectory = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<DirectoryItem> UploadFiles(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      Files? files,
      int? OwnerId,
      bool? IsCombine,
      String? CombineFileName}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "ModuleTypeId": ModuleTypeId,
      "Files": files?.toJson(),
      "OwnerId": OwnerId,
      "IsCombine": IsCombine,
      "CombineFileName": CombineFileName
    });

    var response = await http.post(Uri.parse(_serviceUrl.uploadFiles),
        headers: header, body: reqBody);

    log("req UploadFiles =" + reqBody.toString());
    log("res UploadFiles = " + response.body);

    if (response.body.isEmpty) {
      return DirectoryItem(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> RenameDirectory(Map<String, String> header,
      {int? UserId,
      int? ModuleTypeId,
      String? DirectoryName,
      String? NewDirectoryName,
      int? SourceOwnerId}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "ModuleTypeId": ModuleTypeId,
      "DirectoryName": DirectoryName,
      "NewDirectoryName": NewDirectoryName,
      "SourceOwnerId": SourceOwnerId
    });

    var response = await http.post(Uri.parse(_serviceUrl.renameDirectory),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("RenameDirectory = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> DeleteDirectory(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      String? DirectoryName}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "ModuleTypeId": ModuleTypeId,
      "DirectoryName": DirectoryName
    });

    var response = await http.post(Uri.parse(_serviceUrl.deleteDirectory),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("DeleteDirectory = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> RenameFile(Map<String, String> header,
      {int? UserId, int? FileId, String? NewFileName}) async {
    var responseBody = jsonEncode(
        {"UserId": UserId, "FileId": FileId, "NewFileName": NewFileName});

    var response = await http.post(Uri.parse(_serviceUrl.renameFile),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("RenameFile = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> DeleteFile(Map<String, String> header,
      {int? UserId, int? FileId}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "FileId": FileId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.deleteFile),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("DeleteFile = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> UploadFilesToPrivate(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      Files? files,
      int? OwnerId,
      bool? IsCombine,
      String? CombineFileName}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "ModuleTypeId": ModuleTypeId,
      "Files": files?.toJson(),
      "OwnerId": OwnerId,
      "IsCombine": IsCombine,
      "CombineFileName": CombineFileName
    });

    var response = await http.post(Uri.parse(_serviceUrl.uploadFilesToPrivate),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("UploadFiles = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> DeleteMultiFileAndDirectory(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      List<String>? SourceDirectoryNameList,
      List<int>? FileIdList,
      int? SourceOwnerId}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "ModuleTypeId": ModuleTypeId,
      "SourceDirectoryNameList": SourceDirectoryNameList,
      "FileIdList": FileIdList,
      "SourceOwnerId": SourceOwnerId
    });

    var response = await http.post(
        Uri.parse(_serviceUrl.deleteMultiFileAndDirectory),
        headers: header,
        body: responseBody);

    log("req DeleteMultiFileAndDirectory" + responseBody.toString());
    log("res DeleteMultiFileAndDirectory = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> SendEMail(Map<String, String> header,
      {int? UserId,
      String? Receivers,
      String? Subject,
      String? Message,
      List<int>? Attachtments,
      int? Type,
      int? UserEmailId,
      String? Password}) async {
    var responseBody = jsonEncode({
      "UserId": UserId,
      "Receivers": Receivers,
      "Subject": Subject,
      "Message": Message,
      "Attachtments": Attachtments,
      "Type": Type,
      "UserEmailId": UserEmailId,
      "Password": Password,
    });

    var response = await http.post(Uri.parse(_serviceUrl.sendEMail),
        headers: header, body: responseBody);

    log(response.request.toString());
    log(responseBody.toString());
    log("SendEMail = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<bool> MoveDirectoryAndFile(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? TargetModuleTypeId,
      String? TargetDirectoryName,
      int? SourceModuleTypeId,
      List<String>? SourceDirectoryNameList,
      List<int>? FileIdList,
      int? TargetOwnerId,
      int? SourceOwnerId}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "TargetModuleTypeId": TargetModuleTypeId,
      "TargetDirectoryName": TargetDirectoryName,
      "SourceModuleTypeId": SourceModuleTypeId,
      "SourceDirectoryNameList": SourceDirectoryNameList,
      "FileIdList": FileIdList,
      "TargetOwnerId": TargetOwnerId,
      "SourceOwnerId": SourceOwnerId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.moveDirectoryAndFile),
        headers: header, body: reqBody);

    log(response.request.toString());
    log(reqBody.toString());
    log("MoveDirectoryAndFile = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["HasError"];
    }
  }

  @override
  Future<DataLayoutAPI> CopyDirectoryAndFile(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? TargetModuleTypeId,
      String? TargetDirectoryName,
      int? SourceModuleTypeId,
      List<String>? SourceDirectoryNameList,
      List<int>? FileIdList,
      List<int>? TargetOwnerIdList,
      int? SourceOwnerId}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "TargetModuleTypeId": TargetModuleTypeId,
      "TargetDirectoryName": TargetDirectoryName,
      "SourceModuleTypeId": SourceModuleTypeId,
      "SourceDirectoryNameList": SourceDirectoryNameList,
      "FileIdList": FileIdList,
      "TargetOwnerIdList": TargetOwnerIdList,
      "SourceOwnerId": SourceOwnerId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.copyDirectoryAndFile),
        headers: header, body: reqBody);

    log(response.request.toString());
    log(reqBody.toString());
    log("CopyDirectoryAndFile = " + response.body);

    if (response.body.isEmpty) {
      return DataLayoutAPI(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return DataLayoutAPI.fromJson(responseData);
    }
  }
}
