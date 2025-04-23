import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileNoteLabelAdd extends StatefulWidget {
  const ProfileNoteLabelAdd({Key? key}) : super(key: key);

  @override
  _ProfileNoteLabelAddState createState() => _ProfileNoteLabelAddState();
}

class _ProfileNoteLabelAddState extends State<ProfileNoteLabelAdd> {
  int _selectedColorIndex = 0;
  List<Color> _colorCollection = <Color>[];
  List<String> _colorNames = <String>[];
  ControllerDB _controllerDB = Get.put(ControllerDB());
  String? _selectedColorforAPI;
  String _selectedColor = "";

  ControllerLabel controllerLabel = Get.put(ControllerLabel());

  @override
  void initState() {
    _selectedColorforAPI = "#0F8644";
    super.initState();
    timecolor();
  }

  void timecolor() {
    _colorCollection = <Color>[];
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF85461E));
    _colorCollection.add(const Color(0xFFFF00FF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF00FF00));
    _colorCollection.add(const Color(0xFF00FF00));

    _colorNames = <String>[];
    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Magenta');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');
    _colorNames.add('last');
    _colorNames.add('deneme');
  }

  Future<void> addLabel(String Title, String Color) async {
    await controllerLabel.InsertLabel(_controllerDB.headers(),
            Title: Title,
            Color: Color,
            UserId: _controllerDB.user.value!.result!.id,
            LabelType: 1)
        .then((value) async {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.create,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);

        await controllerLabel.GetLabelByUserId(_controllerDB.headers(),
            Id: 0,
            UserId: _controllerDB.user.value!.result!.id,
            CustomerId: 0,
            LabelType: 1);
      }
    });
  }

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: _selectedColor.isEmpty
              ? _colorCollection[0]
              : Color(int.parse(_selectedColor)),
          title: Text(
            AppLocalizations.of(context)!.createLabel,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actions: <Widget>[
            IconButton(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                icon: const Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (!controller.text.isBlank!) {
                    await addLabel(controller.text, _selectedColorforAPI!);
                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.cannotbeblank,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        //backgroundColor: Colors.red,
                        //textColor: Colors.white,
                        fontSize: 16.0);
                  }
                })
          ],
        ),
        body: _getAppointmentEditor(context));
  }

  Widget _getAppointmentEditor(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.labelName,
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                            child: Text(
                                DateFormat('EEE, MMM dd yyyy')
                                    .format(DateTime.now()),
                                textAlign: TextAlign.left),
                            onTap: () async {
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                            }),
                      ),
                    ])),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return _colorPicker(context);
                  },
                ).then((dynamic value) => setState(() {}));
              },
              title: Text(
                AppLocalizations.of(context)!.colors,
                style: TextStyle(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(
                Icons.lens,
                color: _selectedColor.isEmpty
                    ? _colorCollection[0]
                    : Color(int.parse(_selectedColor)),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
          ],
        ));
  }

  Widget _colorPicker(context) {
    return AlertDialog(
      content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: _colorCollection.length - 1,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Icon(
                    index == _selectedColor.isEmpty
                        ? Icons.lens
                        : Icons.trip_origin,
                    color: _colorCollection[index]),
                title: Text(_colorNames[index]),
                onTap: () {
                  setState(() {
                    _selectedColor =
                        _colorCollection[index].value.toRadixString(10);
                    _selectedColorforAPI = _colorCollection[index]
                        .value
                        .toRadixString(16)
                        .replaceFirst("ff", "#");
                    print(_selectedColorforAPI);
                  });

                  // ignore: always_specify_types
                  Future.delayed(const Duration(milliseconds: 200), () {
                    // When task is over, close the dialog
                    Navigator.pop(context);
                  });
                },
              );
            },
          )),
    );
  }
}
