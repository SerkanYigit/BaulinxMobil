import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/Services/FilesService/FilesBase.dart';
import 'package:undede/Services/FilesService/FilesDB.dart';
import 'package:undede/Services/ServiceUrl.dart';
import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum uploadFileProgres { start, progress, end }

class ControllerFiles extends GetxController implements FilesBase {
  FilesDB _filesService = FilesDB();
  bool refreshPrivate = false;
  bool removeCopyAndMovePage = false;

  List<int> FileIdList = [];
  List<String> SourceDirectoryNameList = [];
  bool isMoveActionActive = false;
  bool isCopyActionActive = false;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  String? sourceDirectory;
  int? sourceModuleTypeId;
  uploadFileProgres progres = uploadFileProgres.start;

  int searchModuleType = 0;
  int searchCommonId = 0;
  int searchCommonTaskId = 0;
  bool searchRefresh = false;
  final ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  bool moveOrCopyActionActive() => isMoveActionActive || isCopyActionActive;

  ControllerLocal _controllerLocal = Get.put(ControllerLocal());
  final ServiceUrl _serviceUrl = ServiceUrl();
  double percenteg = 0;
  @override
  Future<FilesForDirectory> GetFilesByUserIdForDirectory(
      Map<String, String> header,
      {int? userId,
      int? customerId,
      int? moduleType,
      String? directory,
      int? page}) async {
    return await _filesService.GetFilesByUserIdForDirectory(
      header,
      userId: userId!,
      customerId: customerId!,
      moduleType: moduleType!,
      directory: directory!,
      page: page,
    );
  }

  Future<FilesResponse> GetFilesByUserIdForLabels(
    Map<String, String> header, {
    int? userId,
    int? customerId,
    int? moduleType,
    String keyword = "",
    int pageIndex = 0,
    String? endDate,
    String? startDate,
    int isPaid = 0,
    int targetAccount = 0,
    List<int> labelIds = const [5],
  }) async {
    return await _filesService.GetFilesByUserIdForLabels(header,
        userId: userId!,
        customerId: customerId!,
        moduleType: moduleType!,
        keyword: "",
        pageIndex: pageIndex,
        endDate: endDate!,
        startDate: startDate!,
        isPaid: isPaid,
        targetAccount: targetAccount,
        labelIds: labelIds);
  }

  @override
  Future<bool> CreateDirectory(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      int? OwnerId,
      String? DirectoryName}) async {
    bool result = await _filesService.CreateDirectory(header,
        UserId: UserId!,
        CustomerId: CustomerId!,
        ModuleTypeId: ModuleTypeId!,
        OwnerId: OwnerId!,
        DirectoryName: DirectoryName!);

    print(_controllerLocal..toString());
    if (result)
      showToast('${DirectoryName} ${errorMsgCreateDirectory()}');
    else
      showToast('${DirectoryName} ${successMsgCreateDirectory()}');

    return result;
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
      "Files": files!.toJson(),
      "OwnerId": OwnerId,
      "IsCombine": IsCombine,
      "CombineFileName": CombineFileName
    });

    var dio = Dio();
    final response = await dio.post(
      (_serviceUrl.uploadFiles),
      options: Options(headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer " + _controllerDB.token.value
      }),
      data: reqBody,
      onSendProgress: (i, j) async {
        percenteg = (i / j * 100).roundToDouble();
        update();
        if (i == j) {
          percenteg = 99;
          update();
        }
        print("i değeri :" + i.toString() + "j değeri :" + j.toString());
      },
      onReceiveProgress: (i, j) async {
        print("i değeri :" + i.toString() + "j değeri :" + j.toString());

        percenteg = 100;
        update();
        percenteg = 0;
        update();
      },
    );
    print("log UploadFiles response" + response.toString());
    if (response.data["HasError"])
      showToast(AppLocalizations.of(Get.context!)!.fileisnotuploaded);
    else
      showToast(AppLocalizations.of(Get.context!)!.fileisuploaded);
    print(response.data["Result"][0]["Id"]);
    refreshPrivate = true;
    update();
    return DirectoryItem(
        hasError: response.data["HasError"],
        id: response.data["Result"][0]["Id"],
        thumbnailUrl: response.data["Result"][0]["ThumbnailUrl"],
        path: response.data["Result"][0]["Path"]);
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
      "Files": files!.toJson(),
      "OwnerId": OwnerId,
      "IsCombine": IsCombine,
      "CombineFileName": CombineFileName
    });
    var dio = Dio();
    final response = await dio.post(
      (_serviceUrl.uploadFilesToPrivate),
      options: Options(headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer " + _controllerDB.token.value
      }),
      data: responseBody,
      onSendProgress: (i, j) async {
        percenteg = (i / j * 100).roundToDouble();
        update();
        if (i == j) {
          percenteg = 99;
          update();
        }
        print("i değeri :" + i.toString() + "j değeri :" + j.toString());
      },
      onReceiveProgress: (i, j) async {
        print("i değeri :" + i.toString() + "j değeri :" + j.toString());
        percenteg = 100;
        update();
        percenteg = 0;
        update();
      },
    );
    print("log UploadFilesToPrivate responseBody" + responseBody.toString());
    print("log UploadFilesToPrivate response" + response.toString());

    if (response.data["HasError"])
      showToast(errorUpload!);
    else
      showToast(successUpload!);

    return response.data["HasError"];
  }

  @override
  Future<bool> RenameDirectory(Map<String, String> header,
      {int? UserId,
      int? ModuleTypeId,
      String? DirectoryName,
      String? NewDirectoryName,
      int? SourceOwnerId}) async {
    return await _filesService.RenameDirectory(header,
        UserId: UserId!,
        ModuleTypeId: ModuleTypeId!,
        DirectoryName: DirectoryName!,
        NewDirectoryName: NewDirectoryName!,
        SourceOwnerId: SourceOwnerId!);
  }

  @override
  Future<bool> DeleteDirectory(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      String? DirectoryName}) async {
    return await _filesService.DeleteDirectory(header,
        UserId: UserId!,
        CustomerId: CustomerId!,
        ModuleTypeId: ModuleTypeId!,
        DirectoryName: DirectoryName!);
  }

  @override
  Future<bool> DeleteFile(Map<String, String> header,
      {int? UserId, int? FileId}) async {
    return await _filesService.DeleteFile(header,
        UserId: UserId!, FileId: FileId!);
  }

  @override
  Future<bool> RenameFile(Map<String, String> header,
      {int? UserId, int? FileId, String? NewFileName}) async {
    return await _filesService.RenameFile(header,
        UserId: UserId!, FileId: FileId!, NewFileName: NewFileName!);
  }

  @override
  Future<bool> DeleteMultiFileAndDirectory(Map<String, String> header,
      {int? UserId,
      int? CustomerId,
      int? ModuleTypeId,
      List<String>? SourceDirectoryNameList,
      List<int>? FileIdList,
      int? SourceOwnerId}) async {
    bool hasError = await _filesService.DeleteMultiFileAndDirectory(
      header,
      UserId: UserId!,
      CustomerId: CustomerId!,
      ModuleTypeId: ModuleTypeId!,
      SourceDirectoryNameList: SourceDirectoryNameList!,
      FileIdList: FileIdList!,
      SourceOwnerId: SourceOwnerId!,
    );

    if (hasError)
      showErrorToast(errorDeleteMultiFileAndDirectory!);
    else
      showSuccessToast(successDeleteMultiFileAndDirectory!);
    SourceDirectoryNameList.clear();
    update();
    return hasError;
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
    bool hasError = await _filesService.SendEMail(header,
        UserId: UserId!,
        Receivers: Receivers!,
        Subject: Subject!,
        Message: Message!,
        Attachtments: Attachtments!,
        Type: Type!,
        UserEmailId: UserEmailId!,
        Password: Password!);

    if (hasError)
      showErrorToast(errorSendEmail()!);
    else
      showSuccessToast(successSendEmail()!);

    return hasError;
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
    bool result = await _filesService.MoveDirectoryAndFile(header,
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: CustomerId!,
        TargetModuleTypeId: TargetModuleTypeId!,
        TargetDirectoryName: TargetDirectoryName!,
        SourceModuleTypeId: SourceModuleTypeId!,
        SourceDirectoryNameList: SourceDirectoryNameList!,
        FileIdList: FileIdList!,
        TargetOwnerId: TargetOwnerId!,
        SourceOwnerId: SourceOwnerId!);

    if (result)
      showToast(errorMove!);
    else {
      showToast(successMove!);
      this.isMoveActionActive = false;
      this.SourceDirectoryNameList.clear();
      this.FileIdList.clear();
      update();
    }

    return result;
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
    DataLayoutAPI result = await _filesService.CopyDirectoryAndFile(header,
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: CustomerId!,
        TargetModuleTypeId: TargetModuleTypeId!,
        TargetDirectoryName: TargetDirectoryName!,
        SourceModuleTypeId: SourceModuleTypeId!,
        SourceDirectoryNameList: SourceDirectoryNameList!,
        FileIdList: FileIdList!,
        TargetOwnerIdList: TargetOwnerIdList!,
        SourceOwnerId: SourceOwnerId!);

    if (result.hasError!)
      showToast(errorCopyDirectoryAndFile()!);
    else {
      showToast(successCopyDirectoryAndFile()!);

      this.isCopyActionActive = false;
      this.SourceDirectoryNameList.clear();
      this.FileIdList.clear();
      update();
    }

    return result;
  }

  errorMsgCreateDirectory() {
    switch (langCode()) {
      case "en":
        return "cannot create. Please try again.";
      case "tr":
        return "oluşturulamadı. Lütfen daha sonra tekrar deneyiniz.";
      case "de":
        return "";
    }
  }

  successMsgCreateDirectory() {
    switch (langCode()) {
      case "en":
        return "created successfully.";
      case "tr":
        return "başarıyla oluşturuldu.";
      case "de":
        return "";
    }
  }

  String langCode() =>
      _controllerLocal.locale!.value.languageCode ??
      Get.deviceLocale!.languageCode;

  String? successCopyDirectoryAndFile() {
    switch (langCode()) {
      case "en":
        return "Copied successfully.";
      case "tr":
        return "Başarıyla kopyalandı.";
      case "de":
        return "";
    }
    return null;
  }

  String? errorCopyDirectoryAndFile() {
    switch (langCode()) {
      case "en":
        return "Cannot copied. Please try again.";
      case "tr":
        return "kopylamada sorun oluştu. Lütfen daha sonra tekrar deneyiniz.";
      case "de":
        return "";
    }
    return null;
  }

  String? errorSendEmail() {
    switch (langCode()) {
      case "en":
        return "Cannot send email. Please try again later";
      case "tr":
        return "Mail gönderimde sorun oluştu. Lütfen daha sonra tekrar deneyiniz";
      case "de":
        return "";
    }
    return null;
  }

  String? successSendEmail() {
    switch (langCode()) {
      case "en":
        return "Email has sent successfully";
      case "tr":
        return "Email başarıyla gönderildi";
      case "de":
        return "";
    }
    return null;
  }

  String? get successDeleteMultiFileAndDirectory {
    switch (langCode()) {
      case "en":
        return "Deleted successfully";
      case "tr":
        return "Silme işlemi başarılı";
      case "de":
        return "";
    }
    return null;
  }

  String? get errorDeleteMultiFileAndDirectory {
    switch (langCode()) {
      case "en":
        return "Could not delete. Please try again later.";
      case "tr":
        return "Silme işlemi yapılamadı. Daha sonra tekrar deneyiniz";
      case "de":
        return "";
    }
    return null;
  }

  String? get successMove {
    switch (langCode()) {
      case "en":
        return "The migration was successful.";
      case "tr":
        return "Taşıma işlemi başarılı.";
      case "de":
        return "";
    }
    return null;
  }

  String? get errorMove {
    switch (langCode()) {
      case "en":
        return "ERROR: Failed to migrate. Try again later.";
      case "tr":
        return "HATA: Taşıma işlemi yapılamadı. Daha sonra tekrar deneyiniz.";
      case "de":
        return "";
    }
    return null;
  }

  String? get successUpload {
    switch (langCode()) {
      case "en":
        return "Files uploaded successfully.";
      case "tr":
        return 'Dosyalar başarıyla yüklendi.';
      case "de":
        return "";
    }
    return null;
  }

  String? get errorUpload {
    switch (langCode()) {
      case "en":
        return "ERROR: There was a problem uploading the files. Try again";
      case "tr":
        return 'HATA: Dosyalar yüklenirken bir sorun oluştu. Tekrar deneyin.';
      case "de":
        return "";
    }
    return null;
  }
}
