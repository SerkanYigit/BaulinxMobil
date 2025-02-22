part of event_calendar;

class AppointmentEditor extends StatefulWidget {
  @override
  final int? CalendarId;

  const AppointmentEditor({Key? key, this.CalendarId}) : super(key: key);
  AppointmentEditorState createState() => AppointmentEditorState();
}

class AppointmentEditorState extends State<AppointmentEditor> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  AddCalendarAppointmentResult _addCalendarAppointmentResult =
      AddCalendarAppointmentResult(hasError: false);
  FilesForDirectory _filesForDirectory = FilesForDirectory();
  String _selectedColorforAPI = _colorCollection[_selectedColorIndex]
      .value
      .toRadixString(16)
      .replaceFirst("ff", "#");
  String? _selectedColor;
  Files files = new Files();
  List<int> fileBytesforpdf = <int>[];
  bool loading = true;
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  @override
  void initState() {
    files.fileInput = <FileInput>[];
    if (_id != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await getCalendarfiles();
      });
    } else {
      loading = false;
    }

    super.initState();
  }

  Future<void> postAddCalendarAppoinment(
      int Id,
      String StartDate,
      String EndDate,
      bool AllDay,
      bool IsPrivate,
      String Subject,
      String Description,
      String Color,
      bool isCombine) async {
    await _controllerCalendar.AddCalendarAppointment(_controllerDB.headers(),
            Id: Id,
            UserId: _controllerDB.user.value!.result!.id!,
            CalendarId: widget.CalendarId,
            Type: 1,
            StartDate: StartDate,
            EndDate: EndDate,
            AllDay: AllDay,
            Subject: Subject,
            IsPrivate: IsPrivate,
            Location: "",
            Description: Description,
            Status: 0,
            Label: 0,
            ResourceID: 0,
            RecurrenceInfo: "",
            ReminderInfo: "",
            Color: Color,
            RemindDate: "")
        .then((value) async {
      _addCalendarAppointmentResult = value;
      final List<Meeting> meetings = <Meeting>[];
      meetings.add(Meeting(
          Id: value.result!.id!,
          from: _startDate,
          to: _endDate,
          background: _colorCollection[_selectedColorIndex],
          startTimeZone: _selectedTimeZoneIndex == 0
              ? ''
              : _timeZoneCollection[_selectedTimeZoneIndex],
          endTimeZone: _selectedTimeZoneIndex == 0
              ? ''
              : _timeZoneCollection[_selectedTimeZoneIndex],
          description: _notes,
          isAllDay: _isAllDay,
          isPrivate: _isPrivate,
          eventName: _subject == '' ? '(No title)' : _subject,
          Type: "1"));
      print("isCombine" + isCombine.toString());
      _events.appointments!.add(meetings[0]);
      _events.notifyListeners(CalendarDataSourceAction.add, meetings);
      if (!this.files.fileInput.isBlank!) {
        await _controllerFiles.UploadFiles(_controllerDB.headers(),
            ModuleTypeId: FileManagerType.Calendar.typeId,
            CustomerId: value.result!.id!,
            files: this.files,
            OwnerId: value.result!.id!,
            IsCombine: isCombine,
            CombineFileName: isCombine != null ? "sample.pdf" : null);
      }
    });
  }

  deleteAppointment(int Id) async {
    await _controllerCalendar.DeleteCalendarAppointment(
            _controllerDB.headers(), Id)
        .then((value) => {
              if (value)
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.deleted,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    //backgroundColor: Colors.red,
                    //textColor: Colors.white,
                    fontSize: 16.0)
            });
  }

  getCalendarfiles() async {
    await _controllerFiles.GetFilesByUserIdForDirectory(
      _controllerDB.headers(),
      userId: _controllerDB.user.value!.result!.id!,
      customerId: _id,
      moduleType: 33,
      directory: "",
    ).then((value) {
      _filesForDirectory = value;
    });
    setState(() {
      loading = false;
    });
  }

  deleteCalendarFiles(int FileId) async {
    await _controllerFiles.DeleteFile(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!, FileId: FileId)
        .then((value) {
      _filesForDirectory.result!.result!
          .removeWhere((element) => element.id == FileId);
    });
    setState(() {});
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
                controller:
                    TextEditingController(text: _subject.split("\n").first),
                onChanged: (String value) {
                  _subject = _subject.split("\n").first;
                  _subject = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.addTitle,
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: Icon(
                  Icons.access_time,
                  color: Colors.black54,
                ),
                title: Row(children: <Widget>[
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.alldays),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: _isAllDay,
                            onChanged: (bool value) {
                              setState(() {
                                _isAllDay = value;
                              });
                            },
                          ))),
                ])),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: Icon(
                  Icons.lock_outline,
                  color: Colors.black54,
                ),
                title: Row(children: <Widget>[
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.private),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: _isPrivate,
                            onChanged: (bool value) {
                              setState(() {
                                _isPrivate = value;
                              });
                            },
                          ))),
                ])),
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
                                DateFormat('EEE, MMM dd yyyy',
                                        AppLocalizations.of(context)!.date)
                                    .format(_startDate),
                                textAlign: TextAlign.left),
                            onTap: () async {
                              final DateTime date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  ) ??
                                  DateTime.now();

                              if (date != _startDate) {
                                setState(() {
                                  final Duration difference =
                                      _endDate.difference(_startDate);

                                  _startDate = DateTime(
                                      date.year, date.month, date.day, 0, 0, 0);

                                  _endDate = _startDate.add(difference);
                                  _endTime = TimeOfDay(
                                      hour: _endDate.hour,
                                      minute: _endDate.minute);
                                });
                              }
                            }),
                      ),
                      Expanded(
                          flex: 3,
                          child: _isAllDay
                              ? const Text('')
                              : GestureDetector(
                                  child: Text(
                                    DateFormat.Hm().format(_startDate),
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? time =
                                        await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                                hour: _startTime!.hour ?? 0,
                                                minute:
                                                    _startTime!.minute ?? 0));

                                    if (time != _startTime) {
                                      setState(() {
                                        _startTime = time!;
                                        final Duration difference =
                                            _endDate.difference(_startDate);
                                        _startDate = DateTime(
                                            _startDate.year,
                                            _startDate.month,
                                            _startDate.day,
                                            _startTime!.hour,
                                            _startTime!.minute,
                                            0);
                                        _endDate = _startDate.add(difference);
                                        _endTime = TimeOfDay(
                                            hour: _endDate.hour,
                                            minute: _endDate.minute);
                                      });
                                    }
                                  })),
                    ])),
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
                              DateFormat('EEE, MMM dd yyyy',
                                      AppLocalizations.of(context)!.date)
                                  .format(_endDate),
                              textAlign: TextAlign.left,
                            ),
                            onTap: () async {
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );

                              if (date != _endDate) {
                                setState(() {
                                  final Duration difference =
                                      _endDate.difference(_startDate);
                                  _endDate = DateTime(date!.year, date.month,
                                      date.day, 0, 0, 0);
                                  if (_endDate.isBefore(_startDate)) {
                                    _startDate = _endDate.subtract(difference);
                                    _startTime = TimeOfDay(
                                        hour: _startDate.hour,
                                        minute: _startDate.minute);
                                  }
                                });
                              }
                            }),
                      ),
                      Expanded(
                          flex: 3,
                          child: _isAllDay
                              ? const Text('')
                              : GestureDetector(
                                  child: Text(
                                    DateFormat.Hm().format(_endDate),
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? time =
                                        await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                                hour: _endTime!.hour ?? 0,
                                                minute: _endTime!.minute ?? 0));

                                    if (time != _endTime) {
                                      setState(() {
                                        _endTime = time!;
                                        final Duration difference =
                                            _endDate.difference(_startDate);
                                        _endDate = DateTime(
                                            _endDate.year,
                                            _endDate.month,
                                            _endDate.day,
                                            _endTime!.hour,
                                            _endTime!.minute,
                                            0);
                                        if (_endDate.isBefore(_startDate)) {
                                          _startDate =
                                              _endDate.subtract(difference);
                                          _startTime = TimeOfDay(
                                              hour: _startDate.hour,
                                              minute: _startDate.minute);
                                        }
                                      });
                                    }
                                  })),
                    ])),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(Icons.lens,
                  color: _colorCollection[_selectedColorIndex]),
              title: Text(
                _colorNames[_selectedColorIndex],
              ),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return _ColorPicker();
                  },
                ).then((dynamic value) => setState(() {
                      _selectedColorforAPI =
                          _colorCollection[_selectedColorIndex]
                              .value
                              .toRadixString(16)
                              .replaceFirst("ff", "#");
                    }));
              },
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(5),
              leading: Icon(
                Icons.subject,
                color: Colors.black87,
              ),
              title: TextField(
                controller: TextEditingController(text: _notes),
                onChanged: (String value) {
                  _notes = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.addDescription,
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            Container(
              width: Get.width,
              height: 150,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  _filesForDirectory.result == null
                      ? Container()
                      : _filesForDirectory.result!.result!.length == 0
                          ? Container()
                          : Container(
                              height: 150,
                              margin: EdgeInsets.only(top: 10),
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _filesForDirectory.result!.result!.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, i) {
                                    return Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            _controllerBottomNavigationBar
                                                .lockUI = true;
                                            _controllerBottomNavigationBar
                                                .update();
                                            await openFileMessage(
                                                _filesForDirectory
                                                    .result!.result![i].path!);
                                            _controllerBottomNavigationBar
                                                .lockUI = false;
                                            _controllerBottomNavigationBar
                                                .update();
                                          },
                                          child: Container(
                                            width: 100,
                                            height: 150,
                                            margin: EdgeInsets.only(right: 5),
                                            child: CachedNetworkImage(
                                                imageUrl: (_filesForDirectory
                                                    .result!
                                                    .result![i]
                                                    .thumbnailUrl!),
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                                placeholder: (context, url) =>
                                                    new Text("appointment")
                                                //CustomLoadingCircle(),
                                                ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 7,
                                          child: GestureDetector(
                                            onTap: () {
                                              deleteCalendarFiles(
                                                  _filesForDirectory
                                                      .result!.result![i].id!);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Get.theme.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          getImagePathByFileExtensionWithDot(
                                                _filesForDirectory.result!
                                                    .result![i].extension!,
                                              )))),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                  files.fileInput!.isBlank!
                      ? Container()
                      : Container(
                          height: 150,
                          margin: EdgeInsets.only(top: 10),
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: files.fileInput!.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, i) {
                                print(
                                    p.extension(files.fileInput![i].fileName!));

                                return Stack(
                                  children: [
                                    p.extension(files
                                                .fileInput![i].fileName!) ==
                                            ".pdf"
                                        ? Container(
                                            width: 100,
                                            height: 150,
                                            margin: EdgeInsets.only(right: 5),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/images/file_types/pdf.png"))),
                                            ),
                                          )
                                        : Container(
                                            width: 100,
                                            height: 150,
                                            margin: EdgeInsets.only(right: 5),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: MemoryImage(
                                                        base64Decode(files
                                                            .fileInput![i]
                                                            .fileContent!)))),
                                          ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          files.fileInput!.removeAt(i);
                                          setState(() {});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Get.theme.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.clear,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      getImagePathByFileExtensionWithDot(
                                            p.extension(
                                                files.fileInput![i].fileName!),
                                          )))),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        ),
                ],
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTile()),
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
              if (_id != 0) {
                print(_selectedAppointment);
                _events.appointments!.removeAt(
                    _events.appointments!.indexOf(_selectedAppointment!));
                _events.notifyListeners(CalendarDataSourceAction.remove,
                    <Meeting>[]..add(_selectedAppointment!));
              }

              bool isCombine = false;
              if (files.fileInput!.length > 1) {
                bool? result = await showModalYesOrNo(
                    context,
                    AppLocalizations.of(context)!.fileUpload,
                    AppLocalizations.of(context)!.doyouwanttocombinefiles);
                isCombine = result!;
              }

              await postAddCalendarAppoinment(
                  _id,
                  _startDate.toString(),
                  _endDate.toString(),
                  _isAllDay,
                  _isPrivate,
                  _subject == '' ? '(No title)' : _subject.split("\n").first,
                  _notes,
                  _selectedColorforAPI,
                  isCombine);

              _selectedAppointment = null;
              setState(() {});
              Navigator.pop(context);
            },
            child: Container(
              width: 65,
              margin: EdgeInsets.only(right: 15, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.save,
                ),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? Text("appointment")
          //CustomLoadingCircle()
          : Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Stack(
                children: <Widget>[
                  _getAppointmentEditor(context),
                  _selectedAppointment == null
                      ? Container()
                      : Positioned(
                          bottom: 120,
                          left: 20,
                          child: FloatingActionButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            heroTag: "btn1",
                            onPressed: () async {
                              bool isAccepted =
                                  await confirmDeleteWidget(context);
                              if (isAccepted) {
                                deleteAppointment(_id);
                                _events.appointments!.removeAt(_events
                                    .appointments!
                                    .indexOf(_selectedAppointment!));
                                _events.notifyListeners(
                                    CalendarDataSourceAction.remove,
                                    <Meeting>[]..add(_selectedAppointment!));
                                _selectedAppointment = null;
                                Navigator.pop(context);
                              }
                            },
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                            backgroundColor: Colors.red,
                          ),
                        ),
                  Positioned(
                    bottom: 120,
                    right: 20,
                    child: FloatingActionButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      heroTag: "btn3",
                      onPressed: () async {
                        int? fileUploadType;
                        await selectUploadType(context)
                            .then((value) => fileUploadType = value);
                        if (fileUploadType == 0) {
                          _imgFromCamera();
                        } else if (fileUploadType == 1) {
                          openFile();
                        }
                      },
                      child: const Icon(Icons.attach_file, color: Colors.black),
                      backgroundColor: Get.theme.primaryColor,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  String getTile() {
    return _subject.isEmpty
        ? AppLocalizations.of(context)!.newEvent
        : AppLocalizations.of(context)!.eventDetails;
  }

  void _imgFromCamera() async {
    Get.to(() => CameraPage())?.then((value) async {
      if (value != null) {
        List<int> fileBytes = <int>[];
        value.forEach((file) {
          fileBytes = new File(file.path).readAsBytesSync().toList();
          String fileContent = base64.encode(fileBytes);
          files.fileInput!.add(new FileInput(
              fileName: 'sample.${file.path.split(".").last}',
              directory: "",
              fileContent: fileContent));
        });
        setState(() {});
      }
    });
  }

  Future<void> openFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png'],
          allowMultiple: true);
      List<int> fileBytes = <int>[];
      result!.files.forEach((file) {
        fileBytes = new File(file.path!).readAsBytesSync().toList();
        //todo: crop eklenecek
        String fileContent = base64.encode(fileBytes);
        files.fileInput!.add(new FileInput(
            fileName: 'sample.${file.path!.split(".").last}',
            directory: "",
            fileContent: fileContent));
      });
      setState(() {});

      print('aaa');
    } catch (e) {}
  }
}
