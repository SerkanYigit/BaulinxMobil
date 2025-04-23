import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board DateTime Picker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 235, 235, 241),
        useMaterial3: false,
      ),
      // home: const Home(),
      home: const MySampleApp(),
    );
  }
}

class MySampleApp extends StatefulWidget {
  const MySampleApp({super.key});

  @override
  State<MySampleApp> createState() => _MySampleAppState();
}

class _MySampleAppState extends State<MySampleApp> {
  final scrollController = ScrollController();
  final controller = BoardDateTimeController();

  final ValueNotifier<DateTime> builderDate = ValueNotifier(DateTime.now());

  final List<ValueNotifier<DateTime>> singleDates = [
    ValueNotifier(DateTime.now()),
    ValueNotifier(DateTime.now()),
    ValueNotifier(DateTime.now()),
    ValueNotifier(DateTime.now()),
  ];

  Widget Function(
    BuildContext context,
    bool isModal,
    void Function() onClose,
  )? customCloseButtonBuilder;
  ValueNotifier<DateTime> date = ValueNotifier(DateTime.now());
  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Board DateTime Picker Example'),
        ),
        backgroundColor: const Color.fromARGB(255, 245, 245, 250),
        body: InkWell(
          onTap: () async {
            final result = await showBoardDateTimePicker(
              context: context,
              pickerType: DateTimePickerType.date,
              // initialDate: DateTime.now(),
              // minimumDate: DateTime.now().add(const Duration(days: 1)),
              options: BoardDateTimeOptions(
                languages: const BoardPickerLanguages.de(),
                startDayOfWeek: DateTime.monday,
                pickerFormat: PickerFormat.dmy,

                // pickerMonthFormat: PickerMonthFormat.short,
                // boardTitle: 'Board Picker',
                // boardTitleBuilder: (context, textStyle, selectedDay) => Text(
                //   selectedDay.toString(),
                //   style: textStyle,
                //   maxLines: 1,
                // ),
                // pickerSubTitles: BoardDateTimeItemTitles(year: 'year'),
                withSecond: DateTimePickerType.time == DateTimePickerType.date,

                // separators: BoardDateTimePickerSeparators(
                //   date: PickerSeparator.slash,
                //   dateTimeSeparatorBuilder: (context, defaultTextStyle) {
                //     return Container(
                //       height: 4,
                //       width: 8,
                //       decoration: BoxDecoration(
                //         color: Colors.red,
                //         borderRadius: BorderRadius.circular(2),
                //       ),
                //     );
                //   },
                //   time: PickerSeparator.colon,
                //   timeSeparatorBuilder: (context, defaultTextStyle) {
                //     return Container(
                //       height: 8,
                //       width: 4,
                //       decoration: BoxDecoration(
                //         color: Colors.blue,
                //         borderRadius: BorderRadius.circular(2),
                //       ),
                //     );
                //   },
                // ),
              ),
              // Specify if you want changes in the picker to take effect immediately.
              valueNotifier: date,
              controller: controller,
              customCloseButtonBuilder: customCloseButtonBuilder,
              // onTopActionBuilder: (context) {
              //   return Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     child: Wrap(
              //       alignment: WrapAlignment.center,
              //       spacing: 8,
              //       children: [
              //         IconButton(
              //           onPressed: () {
              //             controller.changeDateTime(
              //                 date.value.add(const Duration(days: -1)));
              //           },
              //           icon: const Icon(Icons.arrow_back_rounded),
              //         ),
              //         IconButton(
              //           onPressed: () {
              //             controller.changeDateTime(DateTime.now());
              //           },
              //           icon: const Icon(Icons.stop_circle_rounded),
              //         ),
              //         IconButton(
              //           onPressed: () {
              //             controller.changeDateTime(
              //                 date.value.add(const Duration(days: 1)));
              //           },
              //           icon: const Icon(Icons.arrow_forward_rounded),
              //         ),
              //       ],
              //     ),
              //   );
              // },
            );
            if (result != null) {
              date.value = result;
              print('result: $result');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateTimePickerType.date.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: date,
                  builder: (context, data, _) {
                    return Text(
                      BoardDateFormat(DateTimePickerType.date.formatter(
                        withSecond:
                            DateTimePickerType.time == DateTimePickerType.date,
                      )).format(data),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        /* 
        SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 560,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  SectionWidget(
                    title: 'Picker (Single Selection)',
                    items: [
                      PickerItemWidget(
                        pickerType: DateTimePickerType.date,
                        date: singleDates[1],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
     */
      );
    }
  }
}

extension DateTimePickerTypeExtension on DateTimePickerType {
  String get title {
    switch (this) {
      case DateTimePickerType.date:
        return 'Date';
      case DateTimePickerType.datetime:
        return 'DateTime';
      case DateTimePickerType.time:
        return 'Time';
    }
  }

  IconData get icon {
    switch (this) {
      case DateTimePickerType.date:
        return Icons.date_range_rounded;
      case DateTimePickerType.datetime:
        return Icons.date_range_rounded;
      case DateTimePickerType.time:
        return Icons.schedule_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DateTimePickerType.date:
        return Colors.blue;
      case DateTimePickerType.datetime:
        return Colors.orange;
      case DateTimePickerType.time:
        return Colors.pink;
    }
  }

  String get format {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return 'HH:mm';
    }
  }

  String formatter({bool withSecond = false}) {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return withSecond ? 'HH:mm:ss' : 'HH:mm';
    }
  }
}
