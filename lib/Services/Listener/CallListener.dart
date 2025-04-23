import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:undede/Pages/Chat/ChatDetailPage.dart';

import '../../Pages/Chat/ChatPage.dart';

class CallListener {
  static void initialize(BuildContext context) {
    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case Event.actionCallAccept:
          _onCallAccept(context, event.body);
          break;
        case Event.actionCallDecline:
          _onCallDecline(context, event.body);
          break;
        default:
          break;
      }
    });
  }

  static void _onCallAccept(BuildContext context, Map<String, dynamic> body) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    print('body : $body');

    Widget chatPage = isTablet
        ? ChatPage(
            Id: int.parse(body['extra']['userId']),
            image: body['extra']['photo'],
            diffentPage: 0,
            isGroup: 0,
            blocked: false,
            online: false,
            directLink: true,
            meetingUrl: body['extra']['meetingUrl'],
          )
        : ChatDetailPage(
            Id: int.parse(body['extra']['userId']),
            image: body['extra']['photo'],
            meetingUrl: body['extra']['meetingUrl'],
            diffentPage: 0,
            isGroup: 0,
            blocked: false,
            online: false,
            directLink: true,
          );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => chatPage),
    );
  }

  static void _onCallDecline(BuildContext context, Map<String, dynamic> body) {
    // Handle call decline
  }
}
