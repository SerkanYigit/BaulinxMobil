/* import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar_example/rows_in_progress_bar_example/row_animation_time_example.dart';
import 'package:simple_circular_progress_bar_example/rows_in_progress_bar_example/row_line_thickness_example.dart';
import 'package:simple_circular_progress_bar_example/rows_in_progress_bar_example/row_merge_mode_example.dart';
import 'package:simple_circular_progress_bar_example/rows_in_progress_bar_example/row_start_angle_example.dart';
import 'package:simple_circular_progress_bar_example/rows_in_progress_bar_example/row_text_example.dart';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import 'rows_in_progress_bar_example/row_color_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Progress bar example app'),
        ),
        body: const ExampleHome(),
      ),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ButtonStyle(
      textStyle: MaterialStateProperty.all(TextStyle(
        foreground: Paint()..color = Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )),
      minimumSize: MaterialStateProperty.all(const Size.fromHeight(60)),
      backgroundColor: MaterialStateProperty.all(
        Colors.black.withOpacity(0.25),
      ),
      alignment: Alignment.center,
    );

    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff0d324d),
          Color(0xff7f5a83),
        ],
      )),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),

            // Create 'Progress bar example' button.
            // -----------------------------------------------------------------
            // Most of the examples of working with the progress bar, you can
            // find in the file: progress_bar_example.dart.
            // -----------------------------------------------------------------
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressBarExample(),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Progress bar example'.toUpperCase()),
                    const Text(
                      'More than 18 examples of bar progress states',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                style: buttonStyle,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // Create 'Value notifier example' button.
            // -----------------------------------------------------------------
            // Examples of working with value notifier, you can see in the file:
            // value_notifier_example.dart.
            // -----------------------------------------------------------------
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ValueNotifierExample(),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Value notifier example'.toUpperCase()),
                    const Text(
                      'An example showing how to work with ValueNotifier',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                style: buttonStyle,
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressBarExample extends StatelessWidget {
  const ProgressBarExample({Key? key}) : super(key: key);

  Widget generateRow({
    required String text,
    required ValueNotifier valueNotifier,
    required List<Widget> children,
  }) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          if (valueNotifier.value == 100.0) {
            valueNotifier.value = 0.0;
          } else {
            valueNotifier.value = 100.0;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff0d324d),
            Color(0xff7f5a83),
          ],
        )),
        alignment: Alignment.center,
        child: ListView(
          children: const [
            SizedBox(
              height: 20,
            ),
            // EXAMPLES CODE 1, 2, 3
            RowColorExample(),
            SizedBox(
              height: 40,
            ),
            // EXAMPLES CODE 4, 5, 6
            RowStartAngleExample(),
            SizedBox(
              height: 40,
            ),
            // EXAMPLES CODE 7, 8, 9
            RowLineThicknessExample(),
            SizedBox(
              height: 40,
            ),
            // EXAMPLES CODE 10, 11, 12
            RowMergeModeExample(),
            SizedBox(
              height: 40,
            ),
            // EXAMPLES CODE 13, 14, 15
            RowAnimationTimeExample(),
            SizedBox(
              height: 40,
            ),
            // EXAMPLES CODE 16, 17
            RowTextExample(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}


class ValueNotifierExample extends StatefulWidget {
  const ValueNotifierExample({Key? key}) : super(key: key);

  @override
  State<ValueNotifierExample> createState() => _ValueNotifierExampleState();
}

class _ValueNotifierExampleState extends State<ValueNotifierExample> {
  final centerTextStyle = const TextStyle(
    fontSize: 64,
    color: Colors.lightBlue,
    fontWeight: FontWeight.bold,
  );

  late ValueNotifier<double> valueNotifier;

  @override
  void initState() {
    super.initState();
    valueNotifier = ValueNotifier(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0d324d),
              Color(0xff7f5a83),
            ],
          )),
          alignment: Alignment.center,
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              SimpleCircularProgressBar(
                size: 200,
                valueNotifier: valueNotifier,
                progressStrokeWidth: 24,
                backStrokeWidth: 24,
                mergeMode: true,
                onGetText: (value) {
                  return Text(
                    '${value.toInt()}',
                    style: centerTextStyle,
                  );
                },
                progressColors: const [Colors.cyan, Colors.purple],
                backColor: Colors.black.withOpacity(0.4),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  keyboardAppearance: Brightness.dark,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.4),
                    hintText: 'Enter value (max 100)',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.9)),
                  ),
                  style: const TextStyle(fontSize: 25, color: Colors.white),
                  onSubmitted: (inputText) {
                    final double newValue = double.parse(inputText);

                    // As soon as we change the value of the valueNotifier
                    // parameter, the function ValueListenableBuilder within
                    // SimpleCircularProgressBar is called.
                    valueNotifier.value = newValue;
                  },
                ),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }
} */
