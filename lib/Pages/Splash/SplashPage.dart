import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:undede/Animation/AnimationScreen.dart';
import 'package:undede/ProjectEnums.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/l10n/l10n.dart';
import 'package:undede/widgets/GradientWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/Listener/CallListener.dart';
import '../../landingPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashPages extends StatefulWidget {
  @override
  _SplashPagesState createState() => _SplashPagesState();
}

class _SplashPagesState extends State<SplashPages> {
  int initialPage = 0;
  CarouselController _carouselController = CarouselController();
  Color background = Get.theme.colorScheme.surface;
  ControllerLocal controllerLocale = Get.put(ControllerLocal());

  bool isLoggedIn = false;
  bool isLoading = true;
  bool a = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      CallListener.initialize(context);

      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      print(prefs.getBool("key"));
      if (prefs.getBool("key") == null) {
        prefs.setBool("key", true);
        a = false;
      } else {
        a = true;
      }
      MySharedPreferences.instance
          .getBooleanValue("isfirstRun")
          .then((value) => setState(() {
                isLoggedIn = value;
              }));

      MySharedPreferences.instance
          .getStringValue("savedLocale")
          .then((value) => setState(() {
                if (value != "") {
                  controllerLocale.setLocale(L10n.getLocaleByLangCode(value));
                  controllerLocale.localCode = value;
                  controllerLocale.update();
                } else {
                  controllerLocale.setLocale(Localizations.localeOf(context));
                  controllerLocale.localCode = value;
                  controllerLocale.update();
                }
              }));

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    print("isLoggedIn :" + isLoggedIn.toString());
    return a
        ? Material(
            child: Stack(
            children: [
              LandingPage(),
              IgnorePointer(child: AnimationScreen(color: Color(0xFFFAF6F3)))
            ],
          ))
        : Material(
            child: Stack(children: <Widget>[
              /*CarouselSlider(
                items: [
                  SplashVideo(getDeviceType() == DeviceType.Phone
                      ? "assets/splash/jetoon_1080x1920_2_1.png"
                      : "assets/splash/jetoon_1080x1920_2_1.png"),
                  SplashVideo(getDeviceType() == DeviceType.Phone
                      ? "assets/splash/jetoon_1080x1920_2_2.png"
                      : "assets/splash/jetoon_1080x1920_2_2.png"),
                  SplashVideo(getDeviceType() == DeviceType.Phone
                      ? "assets/splash/jetoon_1080x1920_2_3.png"
                      : "assets/splash/jetoon_1080x1920_2_3.png"),

                ],
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: height,
                  viewportFraction: 1,
                  initialPage: initialPage,
                  enableInfiniteScroll: false,
                  reverse: false,
                  onPageChanged: (i, r) {
                    setState(() {
                      initialPage = i;
                    });
                  },
                  autoPlay: false,
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                )),*/
              Container(
                width: Get.width,
                height: Get.height,
                child: RotatedBox(
                  quarterTurns: 0,
                  child: PageView(
                    onPageChanged: (i) {
                      setState(() {
                        initialPage = i;
                      });
                    },
                    children: isTablet
                        ? [
                            Image.network(
                              "https://onlinefiles.dsplc.net/splash/0.png",
                              fit: BoxFit.cover,
                            ),
                            Image.network(
                              "https://onlinefiles.dsplc.net/splash/1.png",
                              fit: BoxFit.cover,
                            ),
                            Image.network(
                              "https://onlinefiles.dsplc.net/splash/2.png",
                              fit: BoxFit.cover,
                            ),
                          ]
                        : [
                         // Image(image: AssetImage('assets/splash/0.png')),
                            Image.asset(
                            //  "https://onlinefiles.dsplc.net/splash/tablet0.png",
                            "assets/splash/0.png",
                             // fit: BoxFit.cover,
                            ),
                            Image.asset(
                             'assets/splash/1.png',
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                               'assets/splash/2.png',
                              fit: BoxFit.cover,
                            ),
                          ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.85),
                child: InkWell(
                  onTap: () {
                    Get.offAll(LandingPage());
                  },
                  child: Container(
                    width: Get.width - 60,
                    height: 55,
                    padding: EdgeInsets.only(
                        top: 15, bottom: 15, left: 30, right: 30),
                    decoration: BoxDecoration(
                        color: background.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25)),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.signInSignInButtonText,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'TTNorms',
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              /*  Align(
                alignment: Alignment(0, 0.95),
                child: InkWell(
                  onTap: () {
                    Get.offAll(LandingPage());
                  },
                  child: Container(
                    child: Text(
                      "Şartlar & Koşullar",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),*/
              /*Align(
                    alignment: Alignment(0.8, 0.9),
                    child: InkWell(
                        onTap: () {
                          _carouselController.nextPage();
                        },
                        child: CircleAvatar(
                            backgroundColor: background,
                            radius: 30,
                            child: Icon(
                              Icons.arrow_forward,
                              size: 40,
                              color: Colors.white,
                            ))),
                  )*/
              Align(
                alignment: Alignment(0, 0.65),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [0, 1, 2].map((url) {
                    int index = [0, 1, 2].indexOf(url);
                    return Container(
                      width: index == initialPage ? 10 : 7.0,
                      height: index == initialPage ? 10 : 7.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: initialPage == index
                              ? Colors.white
                              : Colors.grey.shade300),
                    );
                  }).toList(),
                ),
              ),
              IgnorePointer(
                  child: AnimationScreen(color: Theme.of(context).colorScheme.secondary)),
            ]),
            color: Get.theme.primaryColor, //! buttonColor yerine primaryColor kullanıldı
          );
  }
}

class MySharedPreferences {
  MySharedPreferences._privateConstructor();

  static final MySharedPreferences instance =
      MySharedPreferences._privateConstructor();

  Future<bool> getBooleanValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    if (myPrefs.getBool(key) == null) {
      myPrefs.setBool(key, true);
      return false;
    } else {
      return myPrefs.getBool(key) ?? false;
    }
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    if (myPrefs.getString(key) == null) {
      myPrefs.getString(key);
      return "";
    } else {
      return myPrefs.getString(key)!;
    }
  }
}

class SplashVideo extends StatelessWidget {
  String path;

  SplashVideo(this.path);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      child: Image.asset(
        path,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}

/*
class SplashVideo extends StatefulWidget {
  String path;

  SplashVideo(this.path);

  @override
  _SplashVideoState createState() => _SplashVideoState();
}

class _SplashVideoState extends State<SplashVideo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.path)
      ..initialize().then((_) {
        _controller.play();

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.setLooping(true);

    */
/*    _controller.addListener(() {
        setState(() {});
      });

      print("girdi 1");
      await _controller.setLooping(true);
      print("girdi 2");

      _controller.initialize().then((_) =>  setState(() {
        print("girdi 3");
         _controller.play();
        print("girdi 4" );


        //  print("inittiiilaziee" + _controller.value.isInitialized.toString());

      }));

      print("girdi 3.5");

*/
/*

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _controller.value.isInitialized
            ? Stack(
                children: [
                  Container(
                    height: Get.height,
                    width: Get.width + 500,
                    child: VideoPlayer(_controller),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    width: Get.width,
                    height: Get.height,
                  )
                ],
              )
            : Container(),
*/
/*        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        )*/
/*

      ),
    );
  }
}
*/
