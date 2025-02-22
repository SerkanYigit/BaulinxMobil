import 'dart:async';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Provider/LocaleProvider.dart';

import 'package:undede/Services/Label/LabelBase.dart';
import 'package:undede/Services/Label/LabelDb.dart';

import 'package:undede/model/Files/FileLabel.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Label/GetTodoLabelListResult.dart';

class ControllerLabel extends GetxController implements LabelBase {
  LabelDb _labelDb = LabelDb();
  Rx<GetLabelByUserIdResult?> getLabel = null.obs;
  ControllerDB _controllerDB = Get.put(ControllerDB());

  @override
  Future<GetLabelByUserIdResult> GetLabelByUserId(
    Map<String, String> header, {
    int? Id,
    int? UserId,
    int? CustomerId,
    int? LabelType,
  }) async {
    var value = await _labelDb.GetLabelByUserId(header,
        Id: Id!,
        UserId: _controllerDB.user.value!.result!.id,
        CustomerId: CustomerId,
        LabelType: LabelType);
    update();
    getLabel = value.obs;
    update();

    return value;
  }

  @override
  Future InsertLabel(
    Map<String, String> header, {
    String? Title,
    String? Color,
    int? UserId,
    int? LabelType,
  }) async {
    var value = await _labelDb.InsertLabel(
      header,
      Title: Title!,
      Color: Color!,
      UserId: UserId!,
      LabelType: LabelType!,
    );
    return value;
  }

  @override
  Future DeleteLabel(
    Map<String, String> header, {
    int? LabelId,
    int? UserId,
  }) async {
    var value = await _labelDb.DeleteLabel(
      header,
      LabelId: LabelId!,
      UserId: _controllerDB.user.value!.result!.id,
    );
    return value;
  }

  @override
  Future UpdateLabel(Map<String, String> header,
      {int? Id, String? Title, String? Color, int? UserId}) async {
    var value = await _labelDb.UpdateLabel(
      header,
      Id: Id!,
      Title: Title!,
      Color: Color!,
      UserId: UserId!,
    );
    return value;
  }

  @override
  Future<GetTodoLabelListResult> GetTodoLabelList(Map<String, String> header,
      {int? TodoId, int? UserId}) async {
    return await _labelDb.GetTodoLabelList(
      header,
      TodoId: TodoId!,
      UserId: UserId!,
    );
  }

  @override
  Future InsertTodoLabel(Map<String, String> header,
      {int? TodoId, int? LabelId, int? UserId}) async {
    return await _labelDb.InsertTodoLabel(header,
        TodoId: TodoId!, LabelId: LabelId!, UserId: UserId!);
  }

  @override
  Future InsertTodoLabelList(Map<String, String> header,
      {int? TodoId, List<int>? LabelIds, int? UserId}) async {
    return await _labelDb.InsertTodoLabelList(header,
        TodoId: TodoId!, LabelIds: LabelIds!, UserId: UserId!);
  }

  @override
  Future<bool> InsertFileListLabelList(Map<String, String> header,
      {List<int>? FilesIds, List<int>? LabelIds, int? UserId}) async {
    bool hasError = await _labelDb.InsertFileListLabelList(header,
        FilesIds: FilesIds!, LabelIds: LabelIds!, UserId: UserId!);

    if (hasError)
      showErrorToast(errorInsertFileLabel!);
    else
      showSuccessToast(successInsertFileLabel!);

    return hasError;
  }

  @override
  Future<FileLabel> GetFileLabelList(Map<String, String> header,
      {int? FilesId, int? UserId}) async {
    return await _labelDb.GetFileLabelList(header,
        FilesId: FilesId!, UserId: UserId!);
  }

  ControllerLocal _controllerLocal = Get.put(ControllerLocal());
  String langCode() =>
      _controllerLocal.locale?.value.languageCode ??
      Get.deviceLocale!.languageCode;

  String? get errorInsertFileLabel {
    switch (langCode()) {
      case "en":
        return "Cannot set labels. Please try again later";
      case "tr":
        return "Etiketler eklenemedi. Lütfen daha sonra tekrar deneyiniz";
      case "de":
        return "";
    }
    return null;
  }

  String? get successInsertFileLabel {
    switch (langCode()) {
      case "en":
        return "Labels set successfully";
      case "tr":
        return "Etiketler başarıyla eklendi";
      case "de":
        return "";
    }
    return null;
  }
}
