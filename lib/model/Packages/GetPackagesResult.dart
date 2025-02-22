class GetPackagesResult {
  List<Result>? result;

  GetPackagesResult({this.result, required bool hasError});

  GetPackagesResult.fromJson(Map<String, dynamic> json) {
    if (json['Result'] != null) {
      result = <Result>[];
      json['Result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Result {
  int? id;
  String? title;
  String? photo;
  int? packageType;
  double? monthlyPrice;
  double? discountedMonthlyPrice;
  double? yearlyPrice;
  double? discountedYearlyPrice;
  String? description;

  Result(
      {this.id,
      this.title,
      this.photo,
      this.packageType,
      this.monthlyPrice,
      this.discountedMonthlyPrice,
      this.yearlyPrice,
      this.discountedYearlyPrice,
      this.description});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    photo = json['Photo'];
    packageType = json['PackageType'];
    monthlyPrice = json['MonthlyPrice'];
    discountedMonthlyPrice = json['DiscountedMonthlyPrice'];
    yearlyPrice = json['YearlyPrice'];
    discountedYearlyPrice = json['DiscountedYearlyPrice'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    data['Photo'] = this.photo;
    data['PackageType'] = this.packageType;
    data['MonthlyPrice'] = this.monthlyPrice;
    data['DiscountedMonthlyPrice'] = this.discountedMonthlyPrice;
    data['YearlyPrice'] = this.yearlyPrice;
    data['DiscountedYearlyPrice'] = this.discountedYearlyPrice;
    data['Description'] = this.description;
    return data;
  }
}
