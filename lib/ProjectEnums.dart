import 'package:flutter/widgets.dart';

enum NotificationType {
  ChatMessage,
  OfficeRequestOfferUpdate,
  OfficeRequestOfferInsert,
  OfficeRequestOfferAccept,
  OfficeRequestOfferDone,
  OfficeRequestOfferCancel,
  ProductOrderInsert,
  ProductOrderDone,
  ProductOrderCancel,
  ProductOrderShipBegin,

  RecycleOrderTaken ,
  RecycleOrderOnTheWay ,
  RecycleOrderGiven ,
  RecycleOrderDone ,
  RecycleOrderFail,
  ProductFavorite ,
  OfficeFavorite
}

enum DeviceType { Phone, Tablet }

DeviceType getDeviceType(BuildContext context) {
  //! copilot  tarafindan degistirildi
  final data = MediaQueryData.fromView(View.of(context));
  return data.size.shortestSide < 550 ? DeviceType.Phone : DeviceType.Tablet;
}