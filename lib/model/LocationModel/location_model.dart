/// latitude : 43.4648
/// longitude : 43.4648

class LocationModel {
  double? latitude;
  double? longitude;
int? orderId;
  LocationModel({
      this.latitude,
    this.orderId,
      this.longitude});

  LocationModel.fromJson(dynamic json) {
    latitude = json["latitude"];
    longitude = json["longitude"];
    orderId = json["orderId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["orderId"] = orderId;
    return map;
  }

}