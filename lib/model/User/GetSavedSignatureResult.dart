class EmailSignatureResponse {
  final String? version;
  final bool? hasError;
  final String? resultCode;
  final String? resultMessage;
  final String? authenticationToken;
  final Result? result;
  final dynamic header;

  EmailSignatureResponse({
    this.version,
    this.hasError,
    this.resultCode,
    this.resultMessage,
    this.authenticationToken,
    this.result,
    this.header,
  });

  // Factory constructor to create an instance from JSON
  factory EmailSignatureResponse.fromJson(Map<String, dynamic> json) {
    return EmailSignatureResponse(
      version: json['Version'],
      hasError: json['HasError'],
      resultCode: json['ResultCode'],
      resultMessage: json['ResultMessage'],
      authenticationToken: json['AuthenticationToken'],
      result: json['Result'] != null ? Result.fromJson(json['Result']) : null,
      header: json['Header'],
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'HasError': hasError,
      'ResultCode': resultCode,
      'ResultMessage': resultMessage,
      'AuthenticationToken': authenticationToken,
      'Result': result!.toJson(),
      'Header': header,
    };
  }
}

class Result {
  final int? id;
  final int? userId;
  final String? signatureContent;

  Result({
    this.id,
    this.userId,
    this.signatureContent,
  });

  // Factory constructor to create an instance from JSON
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['Id'],
      userId: json['UserId'],
      signatureContent: json['SignatureContent'],
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'UserId': userId,
      'SignatureContent': signatureContent,
    };
  }
}
