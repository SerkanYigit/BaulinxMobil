// Define the main response model
class MessageCategory {
  String? version;
  bool? hasError;
  String? resultCode;
  String? resultMessage;
  String? authenticationToken;
  List<ResultItemMessage>? result;
  String? header;

  MessageCategory({
    this.version,
    this.hasError,
    this.resultCode,
    this.resultMessage,
    this.authenticationToken,
    this.result,
    this.header,
  });

  // Factory method to create an MessageCategory from JSON
  factory MessageCategory.fromJson(Map<String, dynamic> json) {
    return MessageCategory(
      version: json['Version'],
      hasError: json['HasError'],
      resultCode: json['ResultCode'],
      resultMessage: json['ResultMessage'],
      authenticationToken: json['AuthenticationToken'],
      result: (json['Result'] as List)
          .map((item) => ResultItemMessage.fromJson(item))
          .toList(),
      header: json['Header'],
    );
  }

  // Convert an MessageCategory to JSON
  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'HasError': hasError,
      'ResultCode': resultCode,
      'ResultMessage': resultMessage,
      'AuthenticationToken': authenticationToken,
      'Result': result!.map((item) => item.toJson()).toList(),
      'Header': header,
    };
  }
}

// Define the model for the Result items
class ResultItemMessage {
  int? id;
  String? text;
  String? languageId;

  ResultItemMessage({
    this.id,
    this.text,
    this.languageId,
  });

  // Factory method to create a ResultItemMessage from JSON
  factory ResultItemMessage.fromJson(Map<String, dynamic> json) {
    return ResultItemMessage(
      id: json['Id'],
      text: json['Text'],
      languageId: json['LanguageId'],
    );
  }

  // Convert a ResultItemMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Text': text,
      'LanguageId': languageId,
    };
  }
}
