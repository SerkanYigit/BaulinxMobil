library event_calendar;

import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Controller/ControllerGetCalendarByUserId.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/FileTypesEnum.dart';
import 'package:undede/Custom/dropdownSearchFn.dart';
import 'package:undede/Custom/openFileFormessage.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Collaboration/CommonDetailsPage.dart';
import 'package:undede/Clean_arch/features/collobration_page/detail_page/view/CommonDetailsPage2.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/Services/Common/CommonDB.dart';
import 'package:undede/Services/TodoService/TodoDB.dart';
import 'package:undede/WidgetsV2/confirmDeleteWidget.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Calendar/AddCalendarAppointmentResult.dart';
import 'package:undede/model/Calendar/GetCalendarByUserIdResult.dart';
import 'package:undede/model/Calendar/GetCalendarDetailResult.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Files/UploadFiles.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:typed_data';

import '../../Custom/CustomLoadingCircle.dart';

part 'color-picker.dart';
part 'timezone-picker.dart';
part 'appointment-editor.dart';
part 'taskEditor.dart';

//ignore: must_be_immutable
class EventCalendar extends StatefulWidget {
  final int? Id;
  final String? Name;
  final bool? IsTodo;
  final bool? ShowOnlyMy;
  const EventCalendar(
      {Key? key, this.Id, this.Name, this.IsTodo, this.ShowOnlyMy})
      : super(key: key);

  @override
  EventCalendarState createState() => EventCalendarState();
}

List<Color> _colorCollection = <Color>[];
List<String> _colorNames = <String>[];
int _selectedColorIndex = 0;
int _selectedTimeZoneIndex = 0;
List<String> _timeZoneCollection = <String>[];
DataSource _events =
    DataSource(<Meeting>[]); //! DataSource(<Meeting>[]) olarak degistirildi
Meeting? _selectedAppointment;
DateTime _startDate = DateTime.now();
TimeOfDay? _startTime;
DateTime _endDate = DateTime.now();
TimeOfDay? _endTime;
bool _isAllDay = false;
bool _isPrivate = false;
String _subject = '';
String _notes = '';
int _id = 0;
int selectedAppointmentId = 0;
String? _type;
int commonId = 0;

class EventCalendarState extends State<EventCalendar> {
  CalendarView _calendarView = CalendarView.month;
  List<String> eventNameCollection = <String>[];
  List<Meeting> appointments = <Meeting>[];
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerCalendar _controllerCalendar = Get.put(ControllerCalendar());
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());

  GetCalendarDetailResult _getCalendarDetailResult =
      GetCalendarDetailResult(hasError: false);

  @override
  void initState() {
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _selectedTimeZoneIndex = 0;
    _subject = '';
    _notes = '';
    _id = 0;
    super.initState();

    timecolor();
    getCalenderDetail(int.parse(DateFormat('yyyy').format(DateTime.now())),
        int.parse(DateFormat('M').format(DateTime.now())), true);
  }

  getCalenderDetail(int Year, int Month, bool IsTodo,
      {bool showOnlyMine = false}) async {
    await _controllerCalendar.GetCalendarDetail(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id!,
            CalendarId: widget.Id,
            Year: Year,
            Month: Month,
            IsTodo: widget.IsTodo)
        .then((value) => {});
    setState(() {
      appointments = getMeetingDetails();
      if (widget.ShowOnlyMy ?? false) {
        appointments = appointments
            .where((element) =>
                element.userId == _controllerDB.user.value!.result!.id!)
            .toList();
      }
      _events = DataSource(appointments);
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerCalendar>(builder: (c) {
      if (c.refreshCalendarDetail) {
        c.refreshCalendarDetail = false;
        c.update();
        //! buraya da bak, tarih kisminda null olmazsa atama sorunu olabilir
        getCalenderDetail(_startDate.year ?? DateTime.now().year,
            _startDate.month ?? DateTime.now().month, widget.IsTodo ?? false,
            showOnlyMine: widget.ShowOnlyMy ?? false);
      }
      return Stack(
        children: [
          Container(
            child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: getEventCalendar(_calendarView, _events,
                    onCalendarLongPress, onCalendarTapDetails)),
          ),
          Positioned(
              bottom: 50,
              right: 20,
              height: Get.height / 7,
              width: Get.width / 7,
              child: SpeedDial(
                childMargin: EdgeInsets.only(bottom: 20, top: 18),
                //   marginEnd: 18,  marginBottom: 20, //! yerine childMargin kullanildi
                icon: Icons.add,
                iconTheme: IconThemeData(color: Colors.black),
                activeIcon: Icons.remove,
                heroTag: "event-calendar",
                backgroundColor: primaryYellowColor,
                visible: true,
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18.0))),
                closeManually: false,
                buttonSize:
                    Size(56.0, 56.0), //! 56.0 yerine Size widget kullanildi
                renderOverlay: false,
                curve: Curves.bounceIn,
                overlayColor: Colors.transparent,
                overlayOpacity: 0.01,
                children: [
                  SpeedDialChild(
                    child: Icon(
                      Icons.add_task,
                      color: const Color.fromARGB(255, 213, 23, 23),
                    ),
                    backgroundColor: primaryYellowColor,
                    label: AppLocalizations.of(context)!.task,
                    labelBackgroundColor: Colors.black45,
                    labelStyle: TextStyle(fontSize: 18.0, color: Colors.white),
                    onTap: () {
                      setState(() {
                        _selectedAppointment = null;
                        _isAllDay = false;
                        _selectedColorIndex = 0;
                        _selectedTimeZoneIndex = 0;
                        _subject = '';
                        _notes = '';
                        _id = 0;

                        if (_calendarView == CalendarView.month) {
                          _calendarView = CalendarView.day;
                        } else {
                          _startDate = DateTime.now();
                          _endDate = DateTime.now();
                          _startTime = TimeOfDay(
                              hour: _startDate.hour, minute: _startDate.minute);
                          _endTime = TimeOfDay(
                              hour: _endDate.hour, minute: _endDate.minute);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  TaskEditor(CalendarId: widget.Id ?? 0)));
                        }
                      });
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(
                      Icons.event,
                      color: Colors.black,
                    ),
                    backgroundColor: primaryYellowColor,
                    label: AppLocalizations.of(context)!.event,
                    labelStyle: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                    labelBackgroundColor: Colors.black45,
                    onTap: () {
                      _selectedAppointment = null;
                      _isAllDay = false;
                      _selectedColorIndex = 0;
                      _selectedTimeZoneIndex = 0;
                      _subject = '';
                      _notes = '';
                      _id = 0;

                      _calendarView = CalendarView.day;

                      setState(() {});
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              AppointmentEditor(CalendarId: widget.Id)));
                    },
                  ),
                ],
              )

              /*FloatingActionButton(
            heroTag: "event-calendar",
            onPressed: () {
              setState(() {
                _selectedAppointment = null;
                _isAllDay = false;
                _selectedColorIndex = 0;
                _selectedTimeZoneIndex = 0;
                _subject = '';
                _notes = '';
                _id = 0;

                if (_calendarView == CalendarView.month) {
                  _calendarView = CalendarView.day;
                } else {
                  _startDate = DateTime.now();
                  _endDate = DateTime.now();
                  _startTime = TimeOfDay(
                      hour: _startDate.hour, minute: _startDate.minute);
                  _endTime =
                      TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
                  Get.to(() => AppointmentEditor(CalendarId: widget.Id));
                }
              });
              //   _onAlertWithCustomContentPressed(context);
            },
            backgroundColor: Get.theme.primaryColor,
            child: Icon(Icons.add),
          ),
          * */

              ),
        ],
      );
    });
  }

  SfCalendar getEventCalendar(
      CalendarView _calendarView,
      CalendarDataSource _calendarDataSource,
      CalendarLongPressCallback calendarLongPressCallback,
      CalendarTapCallback calendarTapDetails) {
    return SfCalendar(
      allowedViews: const [
        CalendarView.month,
        CalendarView.workWeek,
        CalendarView.week,
        CalendarView.day,
      ],
      todayHighlightColor: Colors.blue,
      cellBorderColor: Colors.amber,
      allowViewNavigation: true,
      view: _calendarView,
      dataSource: _calendarDataSource,
      onLongPress: calendarLongPressCallback,
      onTap: calendarTapDetails,
      onViewChanged: viewChanged,
      firstDayOfWeek: 1,
      initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 0, 0, 0),
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: true,
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
          minimumAppointmentDuration: const Duration(minutes: 60),
          timeFormat: "Hm"),
      appointmentTimeTextFormat: "Hm",
    );
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) async {
      await getCalenderDetail(
          int.parse(DateFormat('yyyy').format(viewChangedDetails
              .visibleDates[viewChangedDetails.visibleDates.length ~/ 2])),
          int.parse(DateFormat('M').format(viewChangedDetails
              .visibleDates[viewChangedDetails.visibleDates.length ~/ 2])),
          true);
      setState(() {});
      _startDate = viewChangedDetails
          .visibleDates[viewChangedDetails.visibleDates.length ~/ 2];
      print(int.parse(DateFormat('yyyy').format(viewChangedDetails
          .visibleDates[viewChangedDetails.visibleDates.length ~/ 2])));
      print(int.parse(DateFormat('M').format(viewChangedDetails
          .visibleDates[viewChangedDetails.visibleDates.length ~/ 2])));
    });
  }

  void onCalendarViewChange(String value) {
    if (value == 'Day') {
      _calendarView = CalendarView.day;
    } else if (value == 'Week') {
      _calendarView = CalendarView.week;
    } else if (value == 'Work week') {
      _calendarView = CalendarView.workWeek;
    } else if (value == 'Month') {
      _calendarView = CalendarView.month;
    } else if (value == 'Timeline day') {
      _calendarView = CalendarView.timelineDay;
    } else if (value == 'Timeline week') {
      _calendarView = CalendarView.timelineWeek;
    } else if (value == 'Timeline work week') {
      _calendarView = CalendarView.timelineWorkWeek;
    }

    setState(() {});
  }

  void onCalendarTapDetails(CalendarTapDetails calendarTapDetails) async {
    print(CalendarElement.appointment);
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      if (calendarTapDetails.appointments!.length == 0) {
        setState(() {
          _startDate = calendarTapDetails.date!;
          _endDate = calendarTapDetails.date!;
          _startTime = TimeOfDay(
              hour: DateTime.now().hour, minute: DateTime.now().minute);
          _endTime = TimeOfDay(
              hour: DateTime.now().hour, minute: DateTime.now().minute);
        });

        return;
      }
      final Meeting meetingDetails = calendarTapDetails.appointments![0];
      _id = meetingDetails.Id ?? 0;
      _startDate = meetingDetails.from!;
      _endDate = meetingDetails.to!;
      return;
    }
    setState(() {
      _selectedAppointment = null;
      _isAllDay = false;
      _selectedTimeZoneIndex = 0;
      _subject = '';
      _notes = '';
      _id = 0;
    });

    if (_calendarView == CalendarView.month) {
      _calendarView = CalendarView.day;
    } else {
      if (calendarTapDetails.targetElement != CalendarElement.calendarCell) {
        setState(() {
          final Meeting meetingDetails = calendarTapDetails.appointments![0];
          _selectedColorIndex = _colorCollection.indexWhere(
              (element) => element.value == meetingDetails.background.value);
          if (_selectedColorIndex == -1) {
            _selectedColorIndex = 0;
          }
          print(_selectedColorIndex);

          _startDate = meetingDetails.from!;
          _endDate = meetingDetails.to!;
          _isAllDay = meetingDetails.isAllDay;
          _selectedTimeZoneIndex = meetingDetails.startTimeZone == ''
              ? 0
              : _timeZoneCollection.indexOf(meetingDetails.startTimeZone);
          _subject = meetingDetails.eventName == '(No title)'
              ? ''
              : meetingDetails.eventName.split("\\n+").first;
          _notes = meetingDetails.description;
          _selectedAppointment = meetingDetails;
          _id = meetingDetails.Id ?? 0;
          _type = meetingDetails.Type;
          commonId = meetingDetails.commonId ?? 0;
        });
      } else {
        final DateTime date = calendarTapDetails.date!;
        setState(() {
          _startDate = calendarTapDetails.date!;
          _endDate = calendarTapDetails.date!;
          _startTime = TimeOfDay(
              hour: DateTime.now().hour, minute: DateTime.now().minute);
          _endTime = TimeOfDay(
              hour: DateTime.now().hour, minute: DateTime.now().minute);
        });
      }

      if (_type == "Task") {
        CommonTodo? notificationTodo =
            (await _controllerTodo.GetTodo(_controllerDB.headers(), _id))
                .commonTodo;

        Get.to(() => CommonDetailsPage(
              todoId: _id,
              commonBoardId: commonId,
              selectedTab: 0,
              commonTodo: notificationTodo!,
              commonBoardTitle: notificationTodo.content!,
              calendarId: _id,
              cloudPerm: true,
            ));
      } else {
        print(_id);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AppointmentEditor(CalendarId: widget.Id)));
      }
    }
  }

  Future<void> onCalendarLongPress(
      CalendarLongPressDetails calendarTapDetails) async {
    print(calendarTapDetails.targetElement);
    print(CalendarElement.calendarCell);
    print(CalendarElement.appointment);
    setState(() {
      _selectedAppointment = null;
      _isAllDay = false;
      _selectedColorIndex = 0;
      _selectedTimeZoneIndex = 0;
      _subject = '';
      _notes = '';
      _id = 0;
      _type = "";
    });

    if (_calendarView == CalendarView.month) {
      _calendarView = CalendarView.day;
    } else {
      if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
        final Meeting meetingDetails = calendarTapDetails.appointments![0];
        setState(() {
          _startDate = meetingDetails.from!;
          _endDate = meetingDetails.to!;
          _isAllDay = meetingDetails.isAllDay;
          _selectedTimeZoneIndex = meetingDetails.startTimeZone == ''
              ? 0
              : _timeZoneCollection.indexOf(meetingDetails.startTimeZone);
          _subject = meetingDetails.eventName == '(No title)'
              ? ''
              : meetingDetails.eventName.split("\\n+").first;
          _notes = meetingDetails.description;
          _selectedAppointment = meetingDetails;
          _id = meetingDetails.Id ?? 0;
          _type = meetingDetails.Type;
          commonId = meetingDetails.commonId ?? 0;
        });
      } else {
        final DateTime date = calendarTapDetails.date!;
        final Meeting meetingDetails = calendarTapDetails.appointments![0];
        setState(() {
          _id = meetingDetails.Id ?? 0;
          _type = meetingDetails.Type;
          commonId = meetingDetails.commonId ?? 0;
          _startDate = date;
          _endDate = date.add(const Duration(hours: 1));
        });
      }
      setState(() {
        _startTime =
            TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
        _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
      });
      if (calendarTapDetails.appointments!.length > 1) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AppointmentEditor(CalendarId: widget.Id)));
        return;
      }
      if (_type == "Todo") {
        CommonTodo? notificationTodo =
            (await _controllerTodo.GetTodo(_controllerDB.headers(), _id))
                .commonTodo;

        Get.to(() => CommonDetailsPage(
              todoId: _id,
              commonBoardId: commonId,
              selectedTab: 0,
              commonTodo: notificationTodo!,
              commonBoardTitle: "Calendar",
              calendarId: _id,
              cloudPerm: true,
            ));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AppointmentEditor(CalendarId: widget.Id)));
      }
    }
  }

  void timecolor() {
    eventNameCollection = <String>[];
    eventNameCollection.add('General Meeting');
    eventNameCollection.add('Plan Execution');
    eventNameCollection.add('Project Plan');
    eventNameCollection.add('Consulting');
    eventNameCollection.add('Support');
    eventNameCollection.add('Development Meeting');
    eventNameCollection.add('Scrum');
    eventNameCollection.add('Project Completion');
    eventNameCollection.add('Release updates');
    eventNameCollection.add('Performance Check');

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
    _colorCollection.add(const Color(0xFF40606F));

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
    _colorNames.add('Deep Blue');

    _timeZoneCollection = <String>[];
    _timeZoneCollection.add('Default Time');
    _timeZoneCollection.add('AUS Central Standard Time');
    _timeZoneCollection.add('AUS Eastern Standard Time');
    _timeZoneCollection.add('Afghanistan Standard Time');
    _timeZoneCollection.add('Alaskan Standard Time');
    _timeZoneCollection.add('Arab Standard Time');
    _timeZoneCollection.add('Arabian Standard Time');
    _timeZoneCollection.add('Arabic Standard Time');
    _timeZoneCollection.add('Argentina Standard Time');
    _timeZoneCollection.add('Atlantic Standard Time');
    _timeZoneCollection.add('Azerbaijan Standard Time');
    _timeZoneCollection.add('Azores Standard Time');
    _timeZoneCollection.add('Bahia Standard Time');
    _timeZoneCollection.add('Bangladesh Standard Time');
    _timeZoneCollection.add('Belarus Standard Time');
    _timeZoneCollection.add('Canada Central Standard Time');
    _timeZoneCollection.add('Cape Verde Standard Time');
    _timeZoneCollection.add('Caucasus Standard Time');
    _timeZoneCollection.add('Cen. Australia Standard Time');
    _timeZoneCollection.add('Central America Standard Time');
    _timeZoneCollection.add('Central Asia Standard Time');
    _timeZoneCollection.add('Central Brazilian Standard Time');
    _timeZoneCollection.add('Central Europe Standard Time');
    _timeZoneCollection.add('Central European Standard Time');
    _timeZoneCollection.add('Central Pacific Standard Time');
    _timeZoneCollection.add('Central Standard Time');
    _timeZoneCollection.add('China Standard Time');
    _timeZoneCollection.add('Dateline Standard Time');
    _timeZoneCollection.add('E. Africa Standard Time');
    _timeZoneCollection.add('E. Australia Standard Time');
    _timeZoneCollection.add('E. South America Standard Time');
    _timeZoneCollection.add('Eastern Standard Time');
    _timeZoneCollection.add('Egypt Standard Time');
    _timeZoneCollection.add('Ekaterinburg Standard Time');
    _timeZoneCollection.add('FLE Standard Time');
    _timeZoneCollection.add('Fiji Standard Time');
    _timeZoneCollection.add('GMT Standard Time');
    _timeZoneCollection.add('GTB Standard Time');
    _timeZoneCollection.add('Georgian Standard Time');
    _timeZoneCollection.add('Greenland Standard Time');
    _timeZoneCollection.add('Greenwich Standard Time');
    _timeZoneCollection.add('Hawaiian Standard Time');
    _timeZoneCollection.add('India Standard Time');
    _timeZoneCollection.add('Iran Standard Time');
    _timeZoneCollection.add('Israel Standard Time');
    _timeZoneCollection.add('Jordan Standard Time');
    _timeZoneCollection.add('Kaliningrad Standard Time');
    _timeZoneCollection.add('Korea Standard Time');
    _timeZoneCollection.add('Libya Standard Time');
    _timeZoneCollection.add('Line Islands Standard Time');
    _timeZoneCollection.add('Magadan Standard Time');
    _timeZoneCollection.add('Mauritius Standard Time');
    _timeZoneCollection.add('Middle East Standard Time');
    _timeZoneCollection.add('Montevideo Standard Time');
    _timeZoneCollection.add('Morocco Standard Time');
    _timeZoneCollection.add('Mountain Standard Time');
    _timeZoneCollection.add('Mountain Standard Time (Mexico)');
    _timeZoneCollection.add('Myanmar Standard Time');
    _timeZoneCollection.add('N. Central Asia Standard Time');
    _timeZoneCollection.add('Namibia Standard Time');
    _timeZoneCollection.add('Nepal Standard Time');
    _timeZoneCollection.add('New Zealand Standard Time');
    _timeZoneCollection.add('Newfoundland Standard Time');
    _timeZoneCollection.add('North Asia East Standard Time');
    _timeZoneCollection.add('North Asia Standard Time');
    _timeZoneCollection.add('Pacific SA Standard Time');
    _timeZoneCollection.add('Pacific Standard Time');
    _timeZoneCollection.add('Pacific Standard Time (Mexico)');
    _timeZoneCollection.add('Pakistan Standard Time');
    _timeZoneCollection.add('Paraguay Standard Time');
    _timeZoneCollection.add('Romance Standard Time');
    _timeZoneCollection.add('Russia Time Zone 10');
    _timeZoneCollection.add('Russia Time Zone 11');
    _timeZoneCollection.add('Russia Time Zone 3');
    _timeZoneCollection.add('Russian Standard Time');
    _timeZoneCollection.add('SA Eastern Standard Time');
    _timeZoneCollection.add('SA Pacific Standard Time');
    _timeZoneCollection.add('SA Western Standard Time');
    _timeZoneCollection.add('SE Asia Standard Time');
    _timeZoneCollection.add('Samoa Standard Time');
    _timeZoneCollection.add('Singapore Standard Time');
    _timeZoneCollection.add('South Africa Standard Time');
    _timeZoneCollection.add('Sri Lanka Standard Time');
    _timeZoneCollection.add('Syria Standard Time');
    _timeZoneCollection.add('Taipei Standard Time');
    _timeZoneCollection.add('Tasmania Standard Time');
    _timeZoneCollection.add('Tokyo Standard Time');
    _timeZoneCollection.add('Tonga Standard Time');
    _timeZoneCollection.add('Turkey Standard Time');
    _timeZoneCollection.add('US Eastern Standard Time');
    _timeZoneCollection.add('US Mountain Standard Time');
    _timeZoneCollection.add('UTC');
    _timeZoneCollection.add('UTC+12');
    _timeZoneCollection.add('UTC-02');
    _timeZoneCollection.add('UTC-11');
    _timeZoneCollection.add('Ulaanbaatar Standard Time');
    _timeZoneCollection.add('Venezuela Standard Time');
    _timeZoneCollection.add('Vladivostok Standard Time');
    _timeZoneCollection.add('W. Australia Standard Time');
    _timeZoneCollection.add('W. Central Africa Standard Time');
    _timeZoneCollection.add('W. Europe Standard Time');
    _timeZoneCollection.add('West Asia Standard Time');
    _timeZoneCollection.add('West Pacific Standard Time');
    _timeZoneCollection.add('Yakutsk Standard Time');
  }

  List<Meeting> getMeetingDetails() {
    final List<Meeting> meetingCollection = <Meeting>[];
    int prev;
    for (int a = 0;
        a <
            _controllerCalendar
                .userCalendar.value!.result!.calendarEventList!.length;
        a++) {
      meetingCollection.add(Meeting(
          from: DateTime.parse(_controllerCalendar
              .userCalendar.value!.result!.calendarEventList![a].start!),
          to: DateTime.parse(_controllerCalendar
              .userCalendar.value!.result!.calendarEventList![a].end!),
          background: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].color == null
              ? Get.theme.secondaryHeaderColor
              : Color(int.parse(
                  _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].color!
                      .replaceFirst('#', "FF"),
                  radix: 16)),
          //(int.parse(_getCalendarDetailResult.result.calendarEventList[i].color.replaceAll("#", "0xff"))),
          startTimeZone: '',
          endTimeZone: '',
          description: _controllerCalendar.userCalendar.value!.result!
                          .calendarEventList![a].userId !=
                      _controllerDB.user.value!.result!.id &&
                  _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].isPrivate!
              ? AppLocalizations.of(context)!.private
              : _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].description ?? "",
          isAllDay: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].allDay!,
          eventName: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].title!.split("\\n+").first,
          Id: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].id!,
          appointmentId: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].id!,
          Type: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].type!,
          commonId: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].commonId!,
          userId: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].userId!,
          isPrivate: _controllerCalendar.userCalendar.value!.result!.calendarEventList![a].isPrivate!));
    }

    setState(() {});
    return meetingCollection;
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  String getStartTimeZone(int index) => appointments![index].startTimeZone;

  @override
  String getNotes(int index) => appointments![index].description;

  @override
  String getEndTimeZone(int index) => appointments![index].endTimeZone;

  @override
  Color getColor(int index) => appointments![index].background;

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;
}

class Meeting {
  Meeting(
      {this.from,
      this.to,
      this.background = Colors.green,
      this.isAllDay = false,
      this.eventName = '',
      this.startTimeZone = '',
      this.endTimeZone = '',
      this.description = '',
      this.Id,
      this.appointmentId,
      this.Type,
      this.commonId,
      this.userId,
      this.isPrivate});

  final String eventName;
  final DateTime? from;
  final DateTime? to;
  final Color background;
  final bool isAllDay;
  final String startTimeZone;
  final String endTimeZone;
  final String description;
  final int? Id;
  final int? appointmentId;
  final String? Type;
  final int? commonId;
  final int? userId;
  final bool? isPrivate;
}
