class DataLayoutAPI {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  Null header;

  DataLayoutAPI(
      {this.version,
        this.hasError,
        this.resultCode,
        this.resultMessage,
        this.authenticationToken,
        this.header});

  DataLayoutAPI.fromJson(Map<String, dynamic> json) {
    version = json['Version'];
    hasError = json['HasError'];
    resultCode = json['ResultCode'];
    resultMessage = json['ResultMessage'];
    authenticationToken = json['AuthenticationToken'];
    header = json['Header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Version'] = this.version;
    data['HasError'] = this.hasError;
    data['ResultCode'] = this.resultCode;
    data['ResultMessage'] = this.resultMessage;
    data['AuthenticationToken'] = this.authenticationToken;
    data['Header'] = this.header;
    return data;
  }
}
