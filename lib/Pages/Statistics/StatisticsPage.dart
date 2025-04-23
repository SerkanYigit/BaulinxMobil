import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/l10n/l10n.dart';

class StatisticsPage extends StatefulWidget {
  StatisticsPage();

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  final ControllerLocal cL = Get.put(ControllerLocal());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
  }

  var locale;
  @override
  Widget build(BuildContext context) {
    locale = Localizations.localeOf(context);
    var flag = L10n.getFlag(locale.languageCode);

    return GetBuilder<ControllerLocal>(builder: (controllerLocale) {
      locale = controllerLocale.locale;
      flag = L10n.getFlag(locale.languageCode);
    
      return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        floatingActionButton: FloatingActionButton(
          heroTag: "staticsPage",
          onPressed: () {
            print("deneme");
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
          isExtended: true,
        ),
        body: Column(
          children: [
            Container(
              width: Get.width,
              height: 320,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              decoration: BoxDecoration(
                color: Get.theme.secondaryHeaderColor,
              ),
            ),
            Text('Statistics'),
          ],
        ),
      );
    });
  }
}
