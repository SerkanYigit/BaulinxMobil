import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as a;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/testcore/awesome_notification/test1/noti1.dart';
import 'package:undede/testcore/awesome_notification/test1/notification_service.dart';
import 'package:undede/l10n/l10n.dart';
import 'package:undede/widgets/FloatingNavigationBar.dart';
import 'package:undede/widgets/buildBottomNavigationBar.dart';
import 'Pages/HomePage/Provider/HomePageProvider.dart';
import 'Pages/Splash/SplashPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'Provider/LocaleProvider.dart';
import 'Vir2ellNotification.dart';
import 'firebaseNotificationService.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras = [];

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = new MyHttpOverrides();

  await Permission.microphone.request();
  await Permission.camera.request();
  await Permission.notification.request();
  await Firebase.initializeApp();
  FirebaseNotificationService().initialize();
  FirebaseMessaging.instance.getToken().then((token) {
    print("FCM Token: $token");
  });

  // bool isTablet = Get.mediaQuery.size.shortestSide > 600;

  // if (isTablet) {
  //   // Allow all orientations for tablets
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //     DeviceOrientation.landscapeLeft,
  //     DeviceOrientation.landscapeRight,
  //   ]);
  // } else {
  //   // Restrict to portrait mode for phones
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ]);
  // }

  await getPermissionStatus();
  if (Platform.isAndroid) {
    await a.InAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await a.WebViewFeature.isFeatureSupported(
        a.WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await a.WebViewFeature.isFeatureSupported(
        a.WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      a.ServiceWorkerController serviceWorkerController =
          a.ServiceWorkerController.instance();

      serviceWorkerController.setServiceWorkerClient(a.ServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));

/*  serviceWorkerController.serviceWorkerClient =
          a.ServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ); */
    }
  }

  FirebaseMessaging.onBackgroundMessage(Vir2ellBackGrounMessageHandler);

//!  await initializeNotification();

/*   AwesomeNotifications().initialize('resource://mipmap/ic_launcher', [



    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel 123 123',
      ledColor: Colors.yellow,
      importance: NotificationImportance.High,
      defaultColor: Color(0xFF050606),
    ),
    NotificationChannel(
        channelKey: "custom_sound",
        channelName: "Custom sound notifications",
        channelDescription: "Notifications with custom sound",
        playSound: true,
        ledColor: Colors.orange,
        channelShowBadge: true,
        vibrationPattern: highVibrationPattern,
        importance: NotificationImportance.High,
        enableVibration: true,
        locked: true,
        defaultColor: Color(0xFF050606),
        defaultRingtoneType: DefaultRingtoneType.Ringtone),
    NotificationChannel(
      channelKey: 'notificationType8',
      channelName: 'notificationType8',
      channelDescription: 'notificationType8',
      ledColor: Colors.yellow,
      importance: NotificationImportance.High,
      defaultColor: Color(0xFF050606),
    ),
    NotificationChannel(
      channelKey: 'notificationType9',
      channelName: 'notificationType9',
      channelDescription: 'notificationType9',
      ledColor: Colors.yellow,
      importance: NotificationImportance.High,
      defaultColor: Color(0xFF050606),
    ),
    NotificationChannel(
      channelKey: 'download_channel',
      channelName: 'download notifications',
      channelDescription: 'download channel',
      ledColor: Colors.yellow,
      importance: NotificationImportance.High,
      defaultColor: Color(0xFF050606),
    ),
 
 
 
  ],
  debug: true , //! debug eklendi
  ); */

  /* WidgetsFlutterBinding.ensureInitialized();
  FlutterBackgroundService.initialize(onCalling);
*/

  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();

    WidgetsFlutterBinding.ensureInitialized();

    // Set the background messaging handler early on, as a named top-level function

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.setAutoInitEnabled(true);
  } on CameraException catch (e) {
    print("error code = " +
        e.code.toString() +
        "  Eror descp = " +
        e.description!);
  }

  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => DraggableSheetController(),
      child: MyApp(),
    ),
  );
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  Color themeColor = primaryBlackColor;
  // Color(0xFF27d1df);
  Color secondaryColor = Color(0xFFeef8f9);
  Color onPrimaryContainer = Color(0xFFff5281);
  Color onSecondartContainer = Color(0xFF8c52ff);
  Color onThirdContainer = Color(0xFFff9f52);
  //Color yellowColor = Color(0xFFFFC727);
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  ControllerLocal con = Get.put(ControllerLocal());

  /*if(_controller.locale == null) {
        _controller.setLocale(L10n.all[2]);
        _controller.update();
      }*/

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();

    return GetBuilder<ControllerLocal>(builder: (controllerLocale) {
      return GetMaterialApp(
        routes: <String, WidgetBuilder>{
          '/BottomNavigate': (BuildContext context) =>
              // new BuildBottomNavigationBar(),
              FloatingNavigationBar(),
        },
        supportedLocales: L10n.all,
        locale: controllerLocale.locale?.value,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          SfGlobalLocalizations.delegate,
        ],
        color: themeColor,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w100,
              fontFamily: 'TTNorms',
            ),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionColor: themeColor,
            selectionHandleColor: themeColor,
          ),
          inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black),
              focusColor: Colors.transparent,
              hoverColor: themeColor,
              fillColor: themeColor),
          primaryColor: themeColor,
          scaffoldBackgroundColor: HexColor('#f4f5f7'),
          secondaryHeaderColor: Color(0xFF050606),
          appBarTheme: AppBarTheme(
              shadowColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              titleTextStyle: TextStyle(
                backgroundColor: Colors.transparent,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              )),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          fontFamily: 'TTNorms',
          focusColor: themeColor,
          indicatorColor: themeColor,
          colorScheme: theme.colorScheme
              .copyWith(
                  secondary: secondaryColor,
                  primary: themeColor,
                  onPrimaryContainer: onPrimaryContainer,
                  onSecondaryContainer: onSecondartContainer,
                  onTertiaryContainer: onThirdContainer,
                  //! copyWith(primarSwatch  copyWith(primary: ile değiştirildi
                  surface: themeColor)
              .copyWith(primary: Colors.lime, secondary: themeColor)
              .copyWith(surface: themeColor),
        ),
        home: SplashPages(),
      );
    });
  }
}

//! void kaldırıldı
Future<void> getPermissionStatus() async {
  bool permission = await Permission.storage.isDenied;

  if (permission == PermissionStatus.granted) {
  } // ideally you should specify another condition if permissions is denied
  else if (!permission) {
    await Permission.storage.request();
  }
}
