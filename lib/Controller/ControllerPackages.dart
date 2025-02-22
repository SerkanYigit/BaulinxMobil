import 'package:get/get.dart';
import 'package:undede/Services/Packages/PackagesDB.dart';
import 'package:undede/model/Packages/GetPackagesResult.dart';

class ControllerPackages extends GetxController {
  PackageDB _packageDB = PackageDB();

  Future<GetPackagesResult> GetPackages(String Language) async {
    return await _packageDB.GetPackages(<String, String>{
      "content-type": "application/json",
      "accept": "application/json"
    }, Language);
  }
}
