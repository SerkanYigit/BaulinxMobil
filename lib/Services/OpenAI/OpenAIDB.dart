import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Services/OpenAI/OpenAIBase.dart';

import '../ServiceUrl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/OpenAI/GetOpenAIChatMessagesResult.dart';
import 'package:undede/model/OpenAI/InsertOpenAIChatResult.dart';

class OpenAIDB implements OpenAIBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<GetOpenAIChatMessagesResult> GetOpenAIChatMessages(
      Map<String, String> header,
      {int? UserId}) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getOpenAIChatMessages),
        headers: header, body: reqBody);
    log("reqBody GetOpenAIChatMessages = " + reqBody);
    log("res GetOpenAIChatMessages = " + response.body);

    if (response.body.isEmpty) {
      return GetOpenAIChatMessagesResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return GetOpenAIChatMessagesResult.fromJson(responseData);
    }
  }

  @override
  Future<InsertOpenAIChatResult> InsertOpenAIChat(Map<String, String> header,
      {int? SenderId,
      String? Message,
      int? FileId,
      String? SelectedMessages}) async {
    var reqBody = jsonEncode({
      "SenderId": SenderId,
      "Message": Message,
      "FileId": FileId,
      "SelectedMessages": SelectedMessages,
    });

    var response = await http.post(Uri.parse(_serviceUrl.insertOpenAIChat),
        headers: header, body: reqBody);
    log("reqBody InsertOpenAIChat = " + reqBody);
    log("res InsertOpenAIChat = " + response.body);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (responseData["HasError"]) {
      if (responseData["ResultCode"] == "006") {
        //  showErrorToast(AppLocalizations.of(Get.context!)!.ocrResultWaiting);
      }
      if (responseData["ResultCode"] == "007" ||
          responseData["ResultCode"] == "010") {
        //  showErrorToast(AppLocalizations.of(Get.context!)!
        //    .weAreUnableToProcessYourTransactionAtThisTimePleaseTryAgainLater);
      }
      return InsertOpenAIChatResult.fromJson(responseData);
    } else {
      return InsertOpenAIChatResult.fromJson(responseData);
    }
  }

  @override
  Future<bool> DeleteOpenAIChatMessage(Map<String, String> header,
      {int? id}) async {
    var response = await http.get(
      Uri.parse(_serviceUrl.deleteOpenAIChatMessage + "?id=$id"),
      headers: header,
    );
    log("reqBody DeleteOpenAIChat = " + response.request!.url.toString());
    log("res DeleteOpenAIChat = " + response.body);

    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return responseData["Result"];
    }
  }
}
