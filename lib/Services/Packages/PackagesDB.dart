import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:undede/model/Packages/GetPackagesResult.dart';
import '../ServiceUrl.dart';

class PackageDB {
  final ServiceUrl _serviceUrl = ServiceUrl();

  @override
  Future<GetPackagesResult> GetPackages(
      Map<String, String> header, String Language) async {
    var reqBody = jsonEncode({
      "Language": Language,
    });

    var response = await http.post(Uri.parse(_serviceUrl.getPackages),
        headers: header, body: reqBody);

    log("req GetPackages = " + reqBody.toString());
    log("res GetPackages = " + response.body);

    if (response.body.isEmpty) {
      return GetPackagesResult(hasError: true);
    } else {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GetPackagesResult.fromJson(responseData);
    }
  }
}
