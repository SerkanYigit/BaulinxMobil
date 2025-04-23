part of event_calendar;

class TaskEditor extends StatefulWidget {
  @override
  final int? CalendarId;

  const TaskEditor({Key? key, this.CalendarId}) : super(key: key);
  TaskEditorState createState() => TaskEditorState();
}

class TaskEditorState extends State<TaskEditor> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  CommonDB _commonDB = new CommonDB();
  TodoDB _todoDB = new TodoDB();
  ControllerTodo _controllerTodo = ControllerTodo();

  List<CommonGroup> commonGroupList = <CommonGroup>[];
  final List<DropdownMenuItem> cboCommonGroups = [];
  int? selectedCommonGroup;
  List<CommonBoardListItem> commonBoardList = <CommonBoardListItem>[];
  final List<DropdownMenuItem> cboCommons = [];
  int? selectedcommonBoard;
  ControllerBottomNavigationBar _controllerBottomNavigationBar =
      Get.put(ControllerBottomNavigationBar());
  Future<void> loadGroups() async {
    await _commonDB.GetListCommonGroup(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id)
        .then((value) {
      commonGroupList = value.listOfCommonGroup ?? [];
      commonGroupList.asMap().forEach((index, commonGroup) {
        cboCommonGroups.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(commonGroup.groupName ?? ''),
            ],
          ),
          value: commonGroup.id,
        ));
      });
    });
    setState(() {});
  }

  Future<void> loadBoards(groupId) async {
    await _commonDB.GetAllCommons(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id, groupId: groupId)
        .then((value) {
      commonBoardList = value.result!.commonBoardList ?? [];

      commonBoardList.asMap().forEach((index, commonBoard) {
        cboCommons.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(commonBoard.title ?? ''),
            ],
          ),
          value: commonBoard.id,
        ));
      });
    });
  }

  @override
  void initState() {
    loadGroups();
    super.initState();
  }

  deleteTodo(int TodoId) async {
    await _controllerTodo.DeleteTodo(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id,
      TodoId: TodoId,
    ).then((value) {
      if (value) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.deleted,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            //backgroundColor: Colors.red,
            //textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  InsertCommonTodos(int CommonBoardId, String TodoName, DateTime StartDate,
      DateTime EndDate) async {
    await _controllerTodo.InsertCommonTodos(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CommonBoardId: CommonBoardId,
            TodoName: TodoName,
            StartDate: StartDate,
            EndDate: EndDate,
            ModuleType: 14)
        .then((value) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.create,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          //backgroundColor: Colors.red,
          //textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  Widget _getAppointmentEditor(BuildContext context) {
    return Container(
        child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      children: <Widget>[
        CustomTextField(
          controller: TextEditingController(text: _subject),
          onChanged: (String value) {
            _subject = value;
          },
          hint: AppLocalizations.of(context)!.addTitle,
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          width: 250,
          height: 45,
          decoration: BoxDecoration(
              boxShadow: standartCardShadow(),
              borderRadius: BorderRadius.circular(15)),
          child: SearchableDropdown.single(
            color: Colors.white,
            height: 45,
            displayClearIcon: false,
            menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
            items: cboCommonGroups,
            value: selectedCommonGroup,
            icon: Icon(Icons.expand_more),
            hint: AppLocalizations.of(context)!.selectgroup,
            searchHint: AppLocalizations.of(context)!.selectgroup,
            onChanged: (value) async {
              setState(() {
                cboCommons.clear();
              });
              await loadBoards(value);
              setState(() {
                selectedCommonGroup = value;
              });
            },
            doneButton: AppLocalizations.of(context)!.done,
            displayItem: (item, selected) {
              return (Row(children: [
                selected
                    ? Icon(
                        Icons.radio_button_checked,
                        color: Colors.grey,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey,
                      ),
                SizedBox(width: 7),
                Expanded(
                  child: item,
                ),
              ]));
            },
            isExpanded: true,
            searchFn: dropdownSearchFn,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          width: 250,
          height: 45,
          decoration: BoxDecoration(
              boxShadow: standartCardShadow(),
              borderRadius: BorderRadius.circular(15)),
          child: SearchableDropdown.single(
            color: Colors.white,
            height: 45,
            displayClearIcon: false,
            menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
            items: cboCommons,
            value: selectedcommonBoard,
            icon: Icon(Icons.expand_more),
            hint: AppLocalizations.of(context)!.selectboard,
            searchHint: AppLocalizations.of(context)!.selectboard,
            onChanged: (value) async {
              setState(() {
                selectedcommonBoard = value;
              });
              print(selectedcommonBoard);
            },
            doneButton: AppLocalizations.of(context)!.done,
            displayItem: (item, selected) {
              return (Row(children: [
                selected
                    ? Icon(
                        Icons.radio_button_checked,
                        color: Colors.grey,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey,
                      ),
                SizedBox(width: 7),
                Expanded(
                  child: item,
                ),
              ]));
            },
            isExpanded: true,
            searchFn: dropdownSearchFn,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(45),
                    boxShadow: standartCardShadow()),
                child: Row(
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
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );

                              if (date != _startDate) {
                                setState(() {
                                  final Duration? difference =
                                      _endDate.difference(_startDate);
                                  _startDate = DateTime(
                                      date!.year,
                                      date.month,
                                      date.day,
                                      _startTime!.hour,
                                      _startTime!.minute,
                                      0);
                                  _endDate = _startDate.add(difference!);
                                  _endTime = TimeOfDay(
                                      hour: _endDate.hour,
                                      minute: _endDate.minute);
                                });
                              }
                            }),
                      ),
                      GestureDetector(
                          child: Text(
                            DateFormat.Hm().format(_startDate),
                            textAlign: TextAlign.right,
                          ),
                          onTap: () async {
                            final TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: _startTime!.hour,
                                    minute: _startTime!.minute));

                            if (time != _startTime) {
                              setState(() {
                                _startTime = time;
                                final Duration? difference =
                                    _endDate.difference(_startDate);
                                _startDate = DateTime(
                                    _startDate.year,
                                    _startDate.month,
                                    _startDate.day,
                                    _startTime!.hour,
                                    _startTime!.minute,
                                    0);
                                _endDate = _startDate.add(difference!);
                                _endTime = TimeOfDay(
                                    hour: _endDate.hour,
                                    minute: _endDate.minute);
                              });
                            }
                          })
                    ]),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Container(
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(45),
                    boxShadow: standartCardShadow()),
                child: Row(
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
                                  final Duration? difference =
                                      _endDate.difference(_startDate);
                                  _endDate = DateTime(
                                      date!.year,
                                      date.month,
                                      date.day,
                                      _endTime!.hour,
                                      _endTime!.minute,
                                      0);
                                  if (_endDate.isBefore(_startDate)) {
                                    _startDate = _endDate.subtract(difference!);
                                    _startTime = TimeOfDay(
                                        hour: _startDate.hour,
                                        minute: _startDate.minute);
                                  }
                                });
                              }
                            }),
                      ),
                      GestureDetector(
                          child: Text(
                            DateFormat.Hm().format(_endDate),
                            textAlign: TextAlign.right,
                          ),
                          onTap: () async {
                            final TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: _endTime!.hour,
                                    minute: _endTime!.minute));

                            if (time != _endTime) {
                              setState(() {
                                _endTime = time;
                                final Duration? difference =
                                    _endDate.difference(_startDate);
                                _endDate = DateTime(
                                    _endDate.year,
                                    _endDate.month,
                                    _endDate.day,
                                    _endTime!.hour,
                                    _endTime!.minute,
                                    0);
                                if (_endDate.isBefore(_startDate)) {
                                  _startDate = _endDate.subtract(difference!);
                                  _startTime = TimeOfDay(
                                      hour: _startDate.hour,
                                      minute: _startDate.minute);
                                }
                              });
                            }
                          })
                    ]),
              ),
            ),
          ],
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(getTile()),
          backgroundColor: _colorCollection[_selectedColorIndex],
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () async {
                final List<Meeting> meetings = <Meeting>[];
                _events.appointments?.removeAt(
                    _events.appointments!.indexOf(_selectedAppointment));

                _events.notifyListeners(CalendarDataSourceAction.remove,
                    <Meeting>[]..add(_selectedAppointment!));
                _controllerBottomNavigationBar.lockUI = true;
                _controllerBottomNavigationBar.update();
                print("1");
                await InsertCommonTodos(
                    selectedcommonBoard!, _subject, _startDate, _endDate);
                print("2");
                _controllerBottomNavigationBar.lockUI = false;
                _controllerBottomNavigationBar.update();
                meetings.add(Meeting(
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
                  eventName: _subject == '' ? '(No title)' : _subject,
                ));

                _events.appointments!.add(meetings[0]);

                _events.notifyListeners(CalendarDataSourceAction.add, meetings);
                _selectedAppointment = null;

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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Stack(
            children: <Widget>[_getAppointmentEditor(context)],
          ),
        ),
        floatingActionButton: _selectedAppointment == null
            ? const Text('')
            : FloatingActionButton(
                heroTag: "btn2",
                onPressed: () {
                  deleteTodo(_id);
                  _events.appointments!.removeAt(
                      _events.appointments!.indexOf(_selectedAppointment));
                  _events.notifyListeners(CalendarDataSourceAction.remove,
                      <Meeting>[]..add(_selectedAppointment!));
                  _selectedAppointment = null;
                  Navigator.pop(context);
                },
                child: const Icon(Icons.delete_outline, color: Colors.white),
                backgroundColor: Colors.red,
              ));
  }

  String getTile() {
    return _subject.isEmpty
        ? AppLocalizations.of(context)!.newEvent
        : AppLocalizations.of(context)!.eventDetails;
  }
}
