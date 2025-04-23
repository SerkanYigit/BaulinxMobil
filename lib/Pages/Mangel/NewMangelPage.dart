import 'dart:convert';
import 'dart:io';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_richtext/expandable_rich_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/DebouncerForSearch.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/removeAllHtmlTags.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Mangel/MangelDetailPage.dart';
import 'package:undede/Pages/Mangel/MangelPage.dart';
import 'package:undede/Pages/Mangel/NewMangelPage.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/Services/TodoService/TodoDB.dart';
import 'package:undede/WidgetsV2/CustomAppBarWithSearch.dart';
import 'package:undede/WidgetsV2/Helper.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:undede/WidgetsV2/customTextField.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:undede/model/Todo/GetGenericTodosResult.dart';
import 'package:undede/model/Todo/GetTodoCheckListResult.dart';
import 'package:undede/model/Todo/InsertGenericTodosResult.dart';
import 'package:undede/model/Todo/ResultCheckListUpdate.dart';
import 'package:undede/widgets/MyCircularProgress.dart';
import 'package:string_validator/string_validator.dart';

import '../../Custom/CustomLoadingCircle.dart';
import '../../widgets/CustomIconWithBackground.dart';

class NewMangel extends StatefulWidget {
  NewMangel({
    required this.Base64Image,
    required this.listExpand,
    required this.titleController,
    required this.takenoteController,
    required this.noteFocus,
    // required this.checkedItems2,
    required this.labelTapCheck,
    required this.cboLabelsList,
    required this.selectedLabelIndexes,
    required this.selectedLabels,
    required this.labelsList,
    required this.labelItems,
    required this.bottom,
    required this.ownerId,
    required this.selectedLabelForSearch,
    required this.refreshPage,
    super.key,
  });
  Function() refreshPage;
  String Base64Image = "";
  bool listExpand = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController takenoteController = TextEditingController();
  FocusNode noteFocus = FocusNode();
  List<CheckedItem> checkedItems2 = <CheckedItem>[];
  bool labelTapCheck = false;
  List<DropdownMenuItem> cboLabelsList = [];
  List<int> selectedLabelIndexes = [];
  List<int> selectedLabels = [];
  List<UserLabel> labelsList = [];
  List<String> labelItems = [];
  ControllerBottomNavigationBar bottom;
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerLabel _controllerLabel = Get.put(ControllerLabel());
  GetGenericTodosResult _todosResult = GetGenericTodosResult(hasError: false);

  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
  List<int> selectedLabelForSearch = [];
  int? ownerId;
  @override
  State<NewMangel> createState() => _NewMangelState();
}

class _NewMangelState extends State<NewMangel> {
  TodoDB _todoDB = TodoDB();
  HtmlEditorController _replyTextcontroller = HtmlEditorController();
  String initialText = "";
  ValueNotifier<DateTime> startDate = ValueNotifier(DateTime.now());
  ValueNotifier<DateTime> endDate = ValueNotifier(DateTime.now());

  final startController = BoardDateTimeController();
  final endController = BoardDateTimeController();
  String htmlMessageSubject = "";
  int? statusValue;

  Widget Function(
    BuildContext context,
    bool isModal,
    void Function() onClose,
  )? customCloseButtonBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("New Mängel"),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(),
        child: Container(
          color: Colors.white,
          //  height: Get.height / 1.3,
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                Visibility(
                  visible: !(widget.Base64Image.isBlank!),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                MemoryImage(base64Decode(widget.Base64Image))),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                  ),
                ),
                Visibility(
                  visible: !(widget.Base64Image.isBlank!),
                  child: Positioned(
                    right: 0,
                    bottom: 25,
                    child: GestureDetector(
                      onTap: () {
                        widget.Base64Image = "";
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.delete,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: widget.titleController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.title,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                //?HTML EDITOR
                Expanded(
                  flex: 5,
                  child: Listener(
                    onPointerDown: (_) {
                      print('HtmlEditor tapped via Listener!');
                      // Perform your action on tap (e.g., removing focus)
                      FocusScope.of(context).unfocus();
                    },
                    child: HtmlEditor(
                      controller: _replyTextcontroller,
                      htmlToolbarOptions: HtmlToolbarOptions(
                        toolbarPosition: ToolbarPosition.aboveEditor,
                        defaultToolbarButtons: [
                          FontButtons(),
                          ColorButtons(),
                          ListButtons(),
                          ParagraphButtons(),
                        ],
                      ),
                      htmlEditorOptions: HtmlEditorOptions(
                        hint: 'Enter your message here...',
                        autoAdjustHeight: true,
                        initialText: initialText,
                      ),
                      otherOptions: OtherOptions(
                        height: Get.height *
                            0.6, // Adjust height for better visibility
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                    padding: EdgeInsets.only(bottom: 5, top: 5),
                    shrinkWrap: true,
                    itemCount: widget.checkedItems2.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      return Container(
                        width: Get.width,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 30,
                            top: 5,
                            bottom: 5,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.checkedItems2[i].checked =
                                        !widget.checkedItems2[i].checked;
                                  });
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1.0)),
                                  child: widget.checkedItems2[i].checked
                                      ? Icon(Icons.clear, size: 18)
                                      : Container(),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                  child: TextField(
                                style: TextStyle(fontSize: 18),
                                controller: widget.checkedItems2[i].text,
                                focusNode: widget.checkedItems2[i].focus,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.zero),
                                ),
                              ))
                            ],
                          ),
                        ),
                      );
                    }),
                widget.labelTapCheck
                    ? Container()
                    : SearchableDropdown.multiple(
                        items: widget.cboLabelsList,
                        selectedItems:
                            widget.selectedLabelIndexes.toSet().toList(),
                        hint: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(AppLocalizations.of(context)!.labels),
                        ),
                        onChanged: (value) {
                          setState(() {
                            widget.selectedLabels.clear();
                            widget.selectedLabelIndexes = value;

                            widget.labelsList.asMap().forEach((index, value) {
                              widget.selectedLabelIndexes
                                  .forEach((selectedLabelIndex) {
                                if (selectedLabelIndex == index) {
                                  widget.selectedLabels.add(value.id!);
                                }
                              });
                            });
                          });
                        },
                        displayItem: (item, selected) {
                          return (Row(children: [
                            selected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                  ),
                            SizedBox(width: 7),
                            Expanded(
                              child: item,
                            ),
                          ]));
                        },
                        selectedValueWidgetFn: (item) {
                          return Container(
                            decoration: BoxDecoration(
                                color: Color(0xFFdedede),
                                borderRadius: BorderRadius.circular(30)),
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: (Row(
                              children: [
                                Text(item.toString().split("+").first),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.lens,
                                  color: Color(int.parse(
                                      item
                                          .toString()
                                          .split("+")
                                          .last
                                          .replaceFirst('#', "FF"),
                                      radix: 16)),
                                ),
                              ],
                            )),
                          );
                        },
                        doneButton: (selectedItemsDone, doneContext) {
                          return SizedBox.shrink();
                        },

                        //closeButton: (value) {
                        //  print("Close button pressed $value");
                        //},
                        /*
                        doneButton: (selectedItemsDone, doneContext) {
                          return (ElevatedButton(
                              onPressed: () {
                                Navigator.pop(doneContext);
                                setState(() {});
                              },
                              child: Text(AppLocalizations.of(context)!.save)));
                        },
                        closeButton: (value) {
                          print("Close button pressed $value");
                        },
                         */
                        style: Get.theme.inputDecorationTheme.hintStyle,
                        searchFn: (String keyword, items) {
                          List<int> ret = <int>[];
                          if (items != null && keyword.isNotEmpty) {
                            keyword.split(" ").forEach((k) {
                              int i = 0;
                              items.forEach((item) {
                                if (k.isNotEmpty &&
                                    (item.value
                                        .toString()
                                        .toLowerCase()
                                        .contains(k.toLowerCase()))) {
                                  ret.add(i);
                                }
                                i++;
                              });
                            });
                          }
                          if (keyword.isEmpty) {
                            ret = Iterable<int>.generate(items.length).toList();
                          }
                          return (ret);
                        },
                        //clearIcon: Icons(null), todo:nullable yap
                        icon: Icon(
                          Icons.expand_more,
                          size: 31,
                        ),
                        underline: Container(
                          height: 0.0,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.teal, width: 0.0))),
                        ),
                        iconDisabledColor:
                            const Color.fromARGB(255, 206, 11, 11),
                        iconEnabledColor: Get.theme.colorScheme.surface,
                        isExpanded: true,
                      ),

                SizedBox(
                  height: 10,
                ),
                Tags(
                  itemCount: widget.labelItems.length,
                  itemBuilder: (i) {
                    return ItemTags(
                      alignment: MainAxisAlignment.start,
                      index: i,
                      title: widget.labelItems[i],
                      removeButton: ItemTagsRemoveButton(
                        onRemoved: () {
                          // Remove the item from the data source.
                          setState(() {
                            // required
                          });
                          //required
                          return true;
                        },
                      ),
                    );
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        final result = await showBoardDateTimePicker(
                          //  barrierColor: Colors.white,

                          context: context,
                          pickerType: DateTimePickerType.date,
                          // initialDate: DateTime.now(),
                          // minimumDate: DateTime.now().add(const Duration(days: 1)),
                          options: BoardDateTimeOptions(
                            languages: const BoardPickerLanguages.de(),
                            startDayOfWeek: DateTime.monday,
                            pickerFormat: PickerFormat.dmy,
                            backgroundColor: Colors.white,
                            foregroundColor: primaryYellowColor,
                            // pickerMonthFormat: PickerMonthFormat.short,
                            // boardTitle: 'Board Picker',
                            // boardTitleBuilder: (context, textStyle, selectedDay) => Text(
                            //   selectedDay.toString(),
                            //   style: textStyle,
                            //   maxLines: 1,
                            // ),
                            // pickerSubTitles: BoardDateTimeItemTitles(year: 'year'),
                            withSecond: DateTimePickerType.time ==
                                DateTimePickerType.date,

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
                          valueNotifier: startDate,
                          controller: startController,
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
                          startDate.value = result;
                          print('result: $result');
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[800],
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            /*  icon: const Icon(
                              Icons.date_range_outlined,
                              color: Colors.black,
                              size: 20,
                            ), */
                            label: Text(AppLocalizations.of(context)!.startDate,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                    color: Colors.black)),
                            onPressed: () {},
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                              ValueListenableBuilder(
                                valueListenable: startDate,
                                builder: (context, data, _) {
                                  return Text(
                                    BoardDateFormat(
                                        DateTimePickerType.date.formatter2(
                                      withSecond: DateTimePickerType.time ==
                                          DateTimePickerType.date,
                                    )).format(data),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.normal,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                    ),
                    InkWell(
                      onTap: () async {
                        final result = await showBoardDateTimePicker(
                          // barrierColor: Colors.white,

                          context: context,
                          pickerType: DateTimePickerType.date,
                          // initialDate: DateTime.now(),
                          // minimumDate: DateTime.now().add(const Duration(days: 1)),
                          options: BoardDateTimeOptions(
                            languages: const BoardPickerLanguages.de(),
                            startDayOfWeek: DateTime.monday,
                            pickerFormat: PickerFormat.dmy,
                            backgroundColor: Colors.white,
                            foregroundColor: primaryYellowColor,
                            // pickerMonthFormat: PickerMonthFormat.short,
                            // boardTitle: 'Board Picker',
                            // boardTitleBuilder: (context, textStyle, selectedDay) => Text(
                            //   selectedDay.toString(),
                            //   style: textStyle,
                            //   maxLines: 1,
                            // ),
                            // pickerSubTitles: BoardDateTimeItemTitles(year: 'year'),
                            withSecond: DateTimePickerType.time ==
                                DateTimePickerType.date,

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
                          valueNotifier: endDate,
                          controller: endController,
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
                          endDate.value = result;
                          print('result: $result');
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[800],
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            /*    icon: const Icon(
                              Icons.date_range_outlined,
                              color: Colors.black,
                              size: 20,
                            ), */
                            label: Text(AppLocalizations.of(context)!.endDate,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                    color: Colors.black)),
                            onPressed: () {},
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                              ValueListenableBuilder(
                                valueListenable: endDate,
                                builder: (context, data, _) {
                                  return Text(
                                    BoardDateFormat(
                                        DateTimePickerType.date.formatter2(
                                      withSecond: DateTimePickerType.time ==
                                          DateTimePickerType.date,
                                    )).format(data),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.normal,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Row(
                    children: [
                      Text("Status", style: TextStyle(fontSize: 18)),
                      SizedBox(
                        width: 40,
                      ),
                      //? STATUS
                      DropdownButton(
                          value: statusValue,
                          dropdownColor: Colors.amber,
                          items: [
                            DropdownMenuItem(child: Text("Aktif"), value: 0),
                            DropdownMenuItem(child: Text("Pasif"), value: 1),
                            DropdownMenuItem(
                                child: Text("Beklemede"), value: 2),
                          ],
                          onChanged: (value) {
                            setState(() {
                              statusValue = value;
                            });
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 5,
                    bottom: 125,
                  ),
                  child: Row(
                    children: [
                      //? NOTIFICATION
                      CustomIconWithBackground(
                        color: Colors.black, //! color eklendi
                        onPressed: () {}, //! onPressed eklendi
                        iconName: 'notification',
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      //? IMAGE
                      CustomIconWithBackground(
                        color: Colors.black, //! color eklendi

                        iconName: 'image',
                        onPressed: () async {
                          int? fileUploadType;
                          await selectUploadType(context)
                              .then((value) => fileUploadType = value);
                          if (fileUploadType == 0) {
                            await _imgFromCamera();
                            setState(() {});
                          } else if (fileUploadType == 1) {
                            await openFile();
                            setState(() {});
                          }
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      //? CLIPBOARD
                      CustomIconWithBackground(
                        color: Colors.black, //! color eklendi

                        iconName: 'clipboard',
                        onPressed: () async {
                          if (!widget.checkedItems2.isBlank!) {
                            if (widget.checkedItems2.last.text.text.isEmpty) {
                              return;
                            }
                          }
                          setState(() {
                            widget.checkedItems2.add(CheckedItem(
                                TextEditingController(), false, FocusNode()));
                            widget.checkedItems2.last.focus.requestFocus();
                          });
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      //? LABEL
                      /*       CustomIconWithBackground(
                        color: Colors.black, //! color eklendi
                        iconName: 'label',
                        onPressed: () {
                          setState(() {
                            widget.labelTapCheck = !widget.labelTapCheck;
                          });
                        },
                      ), */
                      SizedBox(
                        width: 10,
                      ),
                      Spacer(),
                      //? SAVE
                      CustomIconWithBackground(
                        color: Colors.black, //! color eklendi
                        iconName: 'save',
                        onPressed: () async {
                          htmlMessageSubject =
                              await _replyTextcontroller.getText();
                          try {
                            widget.noteFocus.unfocus();
                            widget.bottom.lockUI = true;
                            widget.bottom.update();
                            setState(() {
                              widget.listExpand = false;
                            });

                            /*   await widget._controllerTodo
                                    .InsertCommonTodos(
                                        widget._controllerDB.headers(),
                                        UserId: widget._controllerDB.user
                                            .value!.result!.id!,
                                        ModuleType: 35,
                                        TodoName:
                                            widget.titleController.text,
                                        Description:
                                            widget.takenoteController.text,
                                        StartDate: DateTime.now(),
                                        EndDate: DateTime.now(),
                                        BackgroundImageBase64:
                                            widget.Base64Image) */
                            await _todoDB.InsertCommonTodos(
                              widget._controllerDB.headers(),
                              UserId:
                                  widget._controllerDB.user.value!.result!.id!,
                              CustomerId: null,
                              CommonBoardId: widget.ownerId,
                              TodoName: widget.titleController.text,
                              Description: htmlMessageSubject,
                              //widget.takenoteController.text,
                              StartDate: startDate.value,
                              EndDate: endDate.value,
                              ModuleType: 35,
                              BackgroundImageBase64: widget.Base64Image,
                              BackgroundImage: null,
                              status: statusValue,
                            ).then((value) async {
                              print(value);
                              await InsertTodoLabelList(
                                  widget.selectedLabels, value.result!.id!);
                              widget.checkedItems2.forEach((element) async {
                                await InsertOrUpdateTodoCheckList(
                                    0,
                                    value.result!.id!,
                                    element.text.text,
                                    element.checked);
                              });
                            });
                            await GetNote();
                            widget.bottom.lockUI = false;
                            widget.bottom.update();

                            setState(() {
                              widget.listExpand = false;

                              widget.titleController.clear();
                              widget.takenoteController.clear();
                              widget.Base64Image = "";
                              widget.checkedItems2.clear();
                              widget.labelItems.clear();
                              widget.selectedLabels.clear();
                              widget.selectedLabelIndexes.clear();
                            });
                          } catch (_) {
                            widget.bottom.lockUI = false;
                            widget.bottom.update();
                            setState(() {
                              widget.listExpand = false;
                            });
                            Navigator.of(context).pop();
                            widget.refreshPage();
                          }
                          Navigator.of(context).pop();
                          widget.refreshPage();
                        },
                      ),

                      /* 
                      Flexible(
                        child: InkWell(
                          onTap: () async {
                            try {
                              widget.noteFocus.unfocus();
                              widget.bottom.lockUI = true;
                              widget.bottom.update();
                              setState(() {
                                widget.listExpand = false;
                              });
            
                              /*   await widget._controllerTodo
                                    .InsertCommonTodos(
                                        widget._controllerDB.headers(),
                                        UserId: widget._controllerDB.user
                                            .value!.result!.id!,
                                        ModuleType: 35,
                                        TodoName:
                                            widget.titleController.text,
                                        Description:
                                            widget.takenoteController.text,
                                        StartDate: DateTime.now(),
                                        EndDate: DateTime.now(),
                                        BackgroundImageBase64:
                                            widget.Base64Image) */
                              await _todoDB.InsertCommonTodos(
                                widget._controllerDB.headers(),
                                UserId: widget
                                    ._controllerDB.user.value!.result!.id!,
                                CustomerId: null,
                                CommonBoardId: widget.ownerId,
                                TodoName: widget.titleController.text,
                                Description:
                                    _replyTextcontroller.getText().toString(),
                                //widget.takenoteController.text,
                                StartDate: DateTime.now(),
                                EndDate: DateTime.now(),
                                ModuleType: 35,
                                BackgroundImageBase64: widget.Base64Image,
                                BackgroundImage: null,
                              ).then((value) async {
                                print(value);
                                await InsertTodoLabelList(
                                    widget.selectedLabels, value.result!.id!);
                                widget.checkedItems2.forEach((element) async {
                                  await InsertOrUpdateTodoCheckList(
                                      0,
                                      value.result!.id!,
                                      element.text.text,
                                      element.checked);
                                });
                              });
                              await GetNote();
                              widget.bottom.lockUI = false;
                              widget.bottom.update();
            
                              setState(() {
                                widget.listExpand = false;
            
                                widget.titleController.clear();
                                widget.takenoteController.clear();
                                widget.Base64Image = "";
                                widget.checkedItems2.clear();
                                widget.labelItems.clear();
                                widget.selectedLabels.clear();
                                widget.selectedLabelIndexes.clear();
                              });
                            } catch (_) {
                              widget.bottom.lockUI = false;
                              widget.bottom.update();
                              setState(() {
                                widget.listExpand = false;
                              });
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text("Save"),
                          /* CustomIconWithBackground(
                              color: Colors.blue, //! color eklendi
                              iconName: 'check',
                              onPressed: () {},
                            ), */
                        ),
                      ),
                      */
                      SizedBox(
                        width: 10,
                      ),
                      //? DELETE
                      CustomIconWithBackground(
                        color: Colors.black, //! color eklendi
                        iconName: 'delete',
                        onPressed: () async {
                          String htmlMessageSubject =
                              await _replyTextcontroller.getText();
                          print('MessageSubject: $htmlMessageSubject');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InsertTodoLabelList(List<int> LabelIds, int TodoId) async {
    await widget._controllerLabel
        .InsertTodoLabelList(widget._controllerDB.headers(),
            TodoId: TodoId,
            LabelIds: LabelIds,
            UserId: widget._controllerDB.user.value!.result!.id!)
        .then((value) {});
  }

  Future<ResultCheckListUpdate> InsertOrUpdateTodoCheckList(
      int Id, int todoId, String Title, bool IsDone) async {
    return await widget._controllerTodo.InsertOrUpdateTodoCheckList(
        widget._controllerDB.headers(),
        Id: Id,
        UserId: widget._controllerDB.user.value!.result!.id!,
        TodoId: todoId,
        Title: Title,
        IsDone: IsDone);
  }

  Future<void> GetNote({String search = ""}) async {
    widget._todosResult = await widget._controllerTodo.GetGenericTodos(
        widget._controllerDB.headers(),
        userId: widget._controllerDB.user.value!.result!.id!,
        ModuleType: 35,
        search: search,
        LabelIds: widget.selectedLabelForSearch,
        ownerId: widget.ownerId);

    for (int i = 0; i < widget._todosResult.genericTodo!.length; i++) {
      await widget._controllerTodo
          .GetTodoCheckList(widget._controllerDB.headers(),
              UserId: widget._controllerDB.user.value!.result!.id!,
              TodoId: widget._todosResult.genericTodo![i].id!)
          .then((value) {
        setState(() {
          widget._todosResult.genericTodo![i].checkList = value;
        });
      });
    }
    setState(() {});
  }

  //! void kaldirildi
  _imgFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    XFile profileImage = pickedFile!;

    List<int> fileBytes = <int>[];
    fileBytes = new File(profileImage.path).readAsBytesSync().toList();
    //todo: crop eklenecek
    String fileContent = base64.encode(fileBytes);
    widget.Base64Image = fileContent;
    setState(() {});
  }

  Future<void> openFile() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      XFile profileImage = pickedFile!;

      List<int> fileBytes = <int>[];
      fileBytes = new File(profileImage.path).readAsBytesSync().toList();
      //todo: crop eklenecek
      String fileContent = base64.encode(fileBytes);
      widget.Base64Image = fileContent;
      setState(() {});

      print('aaa');
    } catch (e) {}
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

  String formatter2({bool withSecond = false}) {
    switch (this) {
      case DateTimePickerType.date:
        //   return 'yyyy/MM/dd';

        return 'dd/MM/yyyy';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return withSecond ? 'HH:mm:ss' : 'HH:mm';
    }
  }
}
