import 'package:flutter/material.dart';
import 'package:undede/Controller/ControllerDB.dart';


Color? appBarColor = Colors.grey[50];

const String baseSocketUrl = "http://jettonapp.click:8080";

Future<void> messageRedirect(
    Map<String, dynamic> notification, ControllerDB _controllerDB) async {
  {
    /*case NotificationType.ChatMessage:
      Get.to(
        ChatRoom(id: int.parse(notification['Id'].toString())),
        fullscreenDialog: true,
      );
      break;
    case NotificationType.OfficeRequestOfferUpdate:
      Get.to(
        ReceivedOffer(Request(id: int.parse(notification['RelativeId']))),
        fullscreenDialog: true,
      );
      break;
    case NotificationType.OfficeRequestOfferInsert:
      Get.to(
        ReceivedOffer(Request(id: int.parse(notification['RelativeId']))),
        fullscreenDialog: true,
      );
      break;
    case NotificationType.OfficeRequestOfferAccept:
      OfficeOrder order = await _controllerOffice.getOfficeOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));
      Get.to(
        OfficeOrderDetails(
          order,
          received: false,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );
      break;

    case NotificationType.OfficeRequestOfferDone:
      OfficeOrder order = await _controllerOffice.getOfficeOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));
      Get.to(
        OfficeOrderDetails(
          order,
          received: false,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );
      break;
    case NotificationType.OfficeRequestOfferCancel:
      OfficeOrder order = await _controllerOffice.getOfficeOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));
      Get.to(
        OfficeOrderDetails(
          order,
          received: false,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );
      break;

    case NotificationType.ProductOrderInsert:
      OrderData order = await _controllerProduct.getProductOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        OrderReceivedDetails(order),
        fullscreenDialog: true,
      );

      break;
    case NotificationType.ProductOrderDone:
      OrderData order = await _controllerProduct.getProductOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        _controllerDB.user.value.data.id == order.userId
            ? OrderDetails(order)
            : OrderReceivedDetails(order),
        fullscreenDialog: true,
      );

      break;
    case NotificationType.ProductOrderCancel:
      OrderData order = await _controllerProduct.getProductOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        _controllerDB.user.value.data.id == order.userId
            ? OrderDetails(order)
            : OrderReceivedDetails(order),
        fullscreenDialog: true,
      );

      break;
    case NotificationType.ProductOrderShipBegin:
      OrderData order = await _controllerProduct.getProductOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        OrderDetails(order),
        fullscreenDialog: true,
      );

      break;
    case NotificationType.RecycleOrderTaken:
      RecycleOrder order = await _controllerRecycle.getRecycleOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        RecycleOrderDetails(
          order,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );

      break;

    case NotificationType.RecycleOrderOnTheWay:
      RecycleOrder order = await _controllerRecycle.getRecycleOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        RecycleOrderDetails(
          order,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );

      break;

    case NotificationType.RecycleOrderGiven:
      RecycleOrder order = await _controllerRecycle.getRecycleOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        RecycleOrderDetails(
          order,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );

      break;

    case NotificationType.RecycleOrderDone:
      RecycleOrder order = await _controllerRecycle.getRecycleOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        RecycleOrderDetails(
          order,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );

      break;

    case NotificationType.RecycleOrderFail:
      RecycleOrder order = await _controllerRecycle.getRecycleOrder(
          _controllerDB.headers(), int.parse(notification['RelativeId']));

      Get.to(
        RecycleOrderDetails(
          order,
          isNotification: true,
        ),
        fullscreenDialog: true,
      );

      break;

    default:
      break;

        case NotificationType.ProductFavorite:


          Get.to(
            RecycleOrderDetails(order,isNotification: true,),
            fullscreenDialog: true,
          );

        break;
        case NotificationType.OfficeFavorite:


          Get.to(
            RecycleOrderDetails(order,isNotification: true,),
            fullscreenDialog: true,
          );

        break;*/
  }
}
