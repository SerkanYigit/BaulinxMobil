import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileNoteLabelUpdate extends StatefulWidget {
  final int? labelId;
  final String? labelTitle;
  final String? labelColor;
  const ProfileNoteLabelUpdate(
      {Key? key, this.labelId, this.labelTitle, this.labelColor})
      : super(key: key);

  @override
  _ProfileNoteLabelUpdateState createState() => _ProfileNoteLabelUpdateState();
}

class _ProfileNoteLabelUpdateState extends State<ProfileNoteLabelUpdate> {
  TextEditingController? controller;
  String? _selectedColor;
  List<Color> _colorCollection = <Color>[];
  List<String> _colorNames = <String>[];
  String _selectedColorforAPI = "";

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.labelTitle);
    _selectedColor = widget.labelColor;
    _selectedColorforAPI = widget.labelColor!.replaceFirst("FF", "#");
    timecolor();
  }

  ControllerDB _controllerDB = Get.put(ControllerDB());

  ControllerLabel _controllerLabel = Get.put(ControllerLabel());

  Future<void> updateLabel(int Id, String Title, String Color) async {
    await _controllerLabel.UpdateLabel(
      _controllerDB.headers(),
      Id: Id,
      Title: Title,
      Color: Color,
      UserId: _controllerDB.user.value!.result!.id,
    ).then((value) async {
      if (value)
        Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.updated,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      await _controllerLabel.GetLabelByUserId(_controllerDB.headers(),
          Id: 0,
          UserId: _controllerDB.user.value!.result!.id,
          CustomerId: 0,
          LabelType: 1);
    });
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

  @override
  Widget build(BuildContext context) {
    print(widget.labelColor);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: _selectedColor!.isEmpty
              ? Colors.red
              : Color(int.parse(_selectedColor!, radix: 16)),
          title: Text(
            AppLocalizations.of(context)!.updateLabel,
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
                onPressed: () {
                  Navigator.pop(context);
                  updateLabel(
                      widget.labelId!, controller!.text, _selectedColorforAPI);
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
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return _colorPicker(context);
                    ;
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
                color: _selectedColor!.isEmpty
                    ? Colors.red
                    : Color(int.parse(_selectedColor!, radix: 16)),
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
                    index == _selectedColor!.isEmpty
                        ? Icons.lens
                        : Icons.trip_origin,
                    color: _colorCollection[index]),
                title: Text(_colorNames[index]),
                onTap: () {
                  setState(() {
                    _selectedColor =
                        _colorCollection[index].value.toRadixString(16);
                    _selectedColorforAPI = _colorCollection[index]
                        .value
                        .toRadixString(16)
                        .replaceFirst("ff", "#");
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
