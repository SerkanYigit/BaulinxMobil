import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:undede/model/Search/SearchResult.dart';
import '../ServiceUrl.dart';

class SearchDB {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<SearchResult> GetSearchResult(
    Map<String, String> header, {
    int? CustomerId,
    int? UserId,
    String? Keyword,
    String? Labels,
    String? ModuleTypes,
    String? StartDate,
    String? DocumentPaths,
    String? DocumentTypes,
    String? EndDate,
    int? PageIndex,
  }) async {
    var reqBody = jsonEncode({
      "CustomerId": CustomerId,
      "UserId": UserId,
      "Keyword": Keyword,
      "Labels": Labels,
      "ModuleTypes": ModuleTypes,
      "StartDate": StartDate,
      "DocumentPaths": DocumentPaths,
      "DocumentTypes": DocumentTypes,
      "EndDate": EndDate,
      "PageIndex": PageIndex
    });

    var response = await http.post(Uri.parse(_serviceUrl.getSearchResult),
        headers: header, body: reqBody);

    log("req GetSearchResult = " + reqBody.toString());
    log("res GetSearchResult = " + response.body);

    if (response.body.isEmpty) {
      return SearchResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return SearchResult.fromJson(responseData);
    }
  }

  Future<SearchResult> OCRSearch(
    Map<String, String> header, {
    int? UserId,
    int? CustomerId,
    int? ModuleType,
    int? OwnerId,
    List<int>? LabelIds,
    String? Keyword,
    String? Extension,
    String? StartDate,
    String? EndDate,
    int? PageIndex,
  }) async {
    var reqBody = jsonEncode({
      "UserId": UserId,
      "CustomerId": CustomerId,
      "ModuleType": ModuleType,
      "OwnerId": OwnerId,
      "LabelIds": LabelIds,
      "Keyword": Keyword,
      "Extension": Extension,
      "StartDate": StartDate,
      "EndDate": EndDate,
      "PageIndex": PageIndex
    });

    var response = await http.post(Uri.parse(_serviceUrl.oCRSearch),
        headers: header, body: reqBody);

    log("req OCRSearch = " + reqBody.toString());
    log("res OCRSearch = " + response.body);

    if (response.body.isEmpty) {
      return SearchResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return SearchResult.fromJson(responseData);
    }
  }
}
