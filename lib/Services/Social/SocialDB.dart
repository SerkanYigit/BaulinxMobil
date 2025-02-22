import 'dart:convert';
import 'dart:developer';

import 'package:undede/model/Social/AddOrUpdateSocialReplyResult.dart';
import 'package:undede/model/Social/AddOrUpdateSocialResult.dart';
import 'package:undede/model/Social/SocialResult.dart';

import '../ServiceUrl.dart';
import 'SocialBase.dart';
import 'package:http/http.dart' as http;

class SocialDB implements SocialBase {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<SocialResult> GetSocialList(Map<String, String> header,
      {int? UserId, int? Type, int? CategoryId, String? Search}) async {
    var body = jsonEncode({
      "UserId": UserId,
      "Type": Type,
      "CategoryId": CategoryId,
      "Search": Search,
    });
    var response = await http.post(Uri.parse(_serviceUrl.getSocialList),
        headers: header, body: body);
    log("req GetSocialList" + body);
    log("res GetSocialList" + response.body);
    if (response.body.isEmpty) {
      return SocialResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return SocialResult.fromJson(responseData);
    }
  }

  @override
  Future<AddOrUpdateSocialResult> AddOrUpdateSocial(Map<String, String> header,
      {int? Id, int? UserId, int? Type, int? CategoryId, String? Feed}) async {
    var body = jsonEncode({
      "Id": Id,
      "UserId": UserId,
      "Type": Type,
      "CategoryId": CategoryId,
      "Feed": Feed,
    });
    var response = await http.post(Uri.parse(_serviceUrl.addOrUpdateSocial),
        headers: header, body: body);
    log("req AddOrUpdateSocial" + body);
    log("res AddOrUpdateSocial" + response.body);
    if (response.body.isEmpty) {
      return AddOrUpdateSocialResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return AddOrUpdateSocialResult.fromJson(responseData);
    }
  }

  @override
  Future<AddOrUpdateSocialReplyResult> AddOrUpdateSocialReply(
      Map<String, String> header,
      {int? Id,
      int? UserId,
      int? SocialId,
      String? Feed}) async {
    var body = jsonEncode({
      "Id": Id,
      "UserId": UserId,
      "SocialId": SocialId,
      "Feed": Feed,
    });
    var response = await http.post(
        Uri.parse(_serviceUrl.addOrUpdateSocialReply),
        headers: header,
        body: body);
    log("req AddOrUpdateSocialReply" + body);
    log("res AddOrUpdateSocialReply" + response.body);
    if (response.body.isEmpty) {
      return AddOrUpdateSocialReplyResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return AddOrUpdateSocialReplyResult.fromJson(responseData);
    }
  }

  @override
  Future<bool> DeleteSocial(Map<String, String> header, {int? Id}) async {
    var response = await http.get(
        Uri.parse(_serviceUrl.deleteSocial + "?Id=" + Id.toString()),
        headers: header);
    log("req DeleteSocial" + response.request!.url.toString());
    log("res DeleteSocial" + response.body);
    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }

  @override
  Future<bool> DeleteSocialReply(Map<String, String> header, {int? Id}) async {
    var response = await http.get(
        Uri.parse(_serviceUrl.deleteSocialReply + "?Id=" + Id.toString()),
        headers: header);
    log("req DeleteSocialReply" + response.request!.url.toString());
    log("res DeleteSocialReply" + response.body);
    if (response.body.isEmpty) {
      return false;
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData["Result"];
    }
  }
}
