import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Todo/CommonTodo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BauzeienplanPage extends StatefulWidget {
  BauzeienplanPage({
    super.key,
    required this.title,
    this.timePeriod,
    this.commonGroupSelected,
    this.customerId,
  });
  CommonGroup? commonGroupSelected = CommonGroup();
  final String title;
  GetCommonTodosResult? timePeriod;
  final int? customerId;

  @override
  _BauzeienplanPageState createState() => _BauzeienplanPageState();
}

class _BauzeienplanPageState extends State<BauzeienplanPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  List<CommonTodo> todos = [];
  late TreeViewController controller;
  AutoScrollController scrollController = AutoScrollController();
  ControllerTodo _controllerTodo = ControllerTodo();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  bool isLoading = false;
  GetCommonTodosResult? timePeriodZone;
  @override
  void initState() {
    _refreshPage();
    super.initState();
  }

  void _refreshPage() async {
    setState(() {}); // Sadece sayfayı yeniden oluşturuyoruz

    await _controllerTodo.GetCommonTodosTreeView(_controllerDB.headers(),
            userId: _controllerDB.user.value!.result!.id!,
            commonId: widget.commonGroupSelected!.id,
            search: null)
        .then((todoResult) {
      timePeriodZone = todoResult;
      setState(() {
        isLoading = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    timePeriodZone != null ? todos = timePeriodZone!.listOfCommonTodo! : null;
    //todos = widget.timePeriod!.listOfCommonTodo!;
    //widget.timePeriod!.listOfCommonTodo!;
    final rootNode = buildTree(todos);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: isLoading == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : TreeView.simple(
              onTreeReady: (controller) {
                this.controller = controller;
                controller.expandAllChildren(rootNode);
              },
              scrollController: scrollController,
              indentation: Indentation(width: 25),
              tree: rootNode,
              expansionBehavior: ExpansionBehavior.none,
              shrinkWrap: true,
              showRootNode: true,
              builder: (context, node) =>
                  node.isRoot ? buildRootItem(node) : buildListItem(node),
            ),
    );
  }

  Widget buildRootItem(TreeNode node) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //    ListTile(title: Text(widget.title)
            // Text("Item ${node.level}-${node.key}"),
            //    subtitle: Text('Level ${node.level}'),
            //  ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildAddItemChildButton(node),
                //   if (node.children.isNotEmpty) buildClearAllItemButton(node)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListItem(TreeNode node) {
    return Card(
      color: Colors.white,
      //colorMapper[node.level.clamp(0, colorMapper.length - 1)]!,
      child: ListTile(
        onTap: () {
          print(node.data!.id.toString() +
              " : " +
              node.data!.parentId.toString());
        },
        title: Text(
          "${node.data!.content}",
          maxLines: 3,
          overflow: TextOverflow.clip,
        ),
        subtitle: Column(
          children: [
            // DateFormat format = DateFormat(node.data!.startDate);
            //  DateFormat("yyyy-MM-ddThh:mm").format(now);
            Text(
              //'Level ${node.level} ' +
              AppLocalizations.of(context)!.startDate +
                  " : " +
                  DateFormat('dd MM yyyy').format(
                    DateTime.parse(
                      node.data!.startDate.toString(),
                    ),
                  ),
            ),
            Text(" " +
                AppLocalizations.of(context)!.endDate +
                " : " +
                DateFormat('dd MM yyyy').format(
                  DateTime.parse(
                    node.data!.endDate.toString(),
                  ),
                )),
          ],
        ),
        dense: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildRemoveItemButton(node),
            buildAddItemButton(node),
          ],
        ),
      ),
    );
  }

  Widget buildAddItemButton(TreeNode item) {
    return IconButton(
      onPressed: () {
        //   item.add(TreeNode());
        print(
            item.data!.id.toString() + " : " + item.data!.parentId.toString());
        showMaterialModalBottomSheet(
            expand: false,
            context: context,
            backgroundColor: Colors.yellow,
            builder: (context) {
              print(item);
              isLoading = false;
              return ModalFit(
                commonGroupSelected: widget.commonGroupSelected!,
                customerId: widget.customerId,
                refreshPage: _refreshPage,
                item: item,
              );
            });
      },
      icon: const Icon(Icons.add_circle_outline,
          color: Color.fromARGB(255, 108, 105, 105)),
    );
  }

  Widget buildRemoveItemButton(TreeNode item) {
    return IconButton(
      onPressed: () {
        deleteTodo(item.data!.id);
      },
      icon: const Icon(Icons.delete_outline,
          color: Color.fromARGB(255, 108, 105, 105)),
    );
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
        _refreshPage();
      }
    });
  }

  Widget buildAddItemChildButton(TreeNode item) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.green[800],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline, color: Colors.black),
        label: const Text("Milestone Hinzufügen",
            style: TextStyle(color: Colors.black)),
        onPressed: () {
          //   item.add(TreeNode());

          showMaterialModalBottomSheet(
              expand: false,
              context: context,
              backgroundColor: Colors.yellow,
              builder: (context) {
                isLoading = false;
                return ModalFit(
                  commonGroupSelected: widget.commonGroupSelected!,
                  customerId: widget.customerId,
                  refreshPage: _refreshPage,
                );
              });
        },
      ),
    );
  }

  Widget buildClearAllItemButton(TreeNode item) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red[800],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text("Clear All", style: TextStyle(color: Colors.red)),
          onPressed: () => item.clear()),
    );
  }
}

class ModalFit extends StatelessWidget {
  CommonGroup commonGroupSelected = CommonGroup();
  Function() refreshPage;
  TreeNode? item;
  ModalFit({
    super.key,
    required this.commonGroupSelected,
    this.customerId,
    required this.refreshPage,
    this.item,
  });
  TextEditingController contentTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  int? customerId;
  ValueNotifier<DateTime> startDate = ValueNotifier(DateTime.now());
  ValueNotifier<DateTime> endDate = ValueNotifier(DateTime.now());

  final startController = BoardDateTimeController();
  final endController = BoardDateTimeController();

  Widget Function(
    BuildContext context,
    bool isModal,
    void Function() onClose,
  )? customCloseButtonBuilder;
  @override
  Widget build(BuildContext context) {
    if (item != null) {
      contentTextController.text = item!.data.content;
      descriptionTextController.text = item!.data.description;
      DateTime tempStartDate =
          new DateFormat("yyyy-MM-ddThh:mm:ss").parse(item!.data.startDate);
      DateTime tempEndDate =
          new DateFormat("yyyy-MM-ddThh:mm:ss").parse(item!.data.endDate);
      startDate = ValueNotifier(tempStartDate);
      endDate = ValueNotifier(tempEndDate);
    }

    Size size = MediaQuery.of(context).size;
    return Material(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.07),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: false,
                    textAlign: TextAlign.center,
                    controller: contentTextController,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color.fromARGB(255, 190, 195, 193),
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color.fromARGB(255, 190, 195, 193),
                        ),
                      ),
                      //    suffixText: "vhjvjvhv",

                      //   disabledBorder: InputBorder.none,
                      labelText: "Content",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 32, 30, 30)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: 3,
                    readOnly: false,
                    textAlign: TextAlign.center,
                    controller: descriptionTextController,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color.fromARGB(255, 190, 195, 193),
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color.fromARGB(255, 190, 195, 193),
                        ),
                      ),
                      //    suffixText: "vhjvjvhv",

                      //   disabledBorder: InputBorder.none,
                      labelText: "Description",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 32, 30, 30)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final result = await showBoardDateTimePicker(
                      barrierColor: Colors.white,

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
                        withSecond:
                            DateTimePickerType.time == DateTimePickerType.date,

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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green[800],
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          icon: const Icon(
                            Icons.date_range_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          label: Text(AppLocalizations.of(context)!.startDate,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black)),
                          onPressed: () {},
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        ValueListenableBuilder(
                          valueListenable: startDate,
                          builder: (context, data, _) {
                            return Text(
                              BoardDateFormat(DateTimePickerType.date.formatter(
                                withSecond: DateTimePickerType.time ==
                                    DateTimePickerType.date,
                              )).format(data),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final result = await showBoardDateTimePicker(
                      barrierColor: Colors.white,

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
                        withSecond:
                            DateTimePickerType.time == DateTimePickerType.date,

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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green[800],
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          icon: const Icon(
                            Icons.date_range_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          label: Text(AppLocalizations.of(context)!.endDate,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black)),
                          onPressed: () {},
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        ValueListenableBuilder(
                          valueListenable: endDate,
                          builder: (context, data, _) {
                            return Text(
                              BoardDateFormat(DateTimePickerType.date.formatter(
                                withSecond: DateTimePickerType.time ==
                                    DateTimePickerType.date,
                              )).format(data),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    item == null
                        ? TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[800],
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            icon: const Icon(
                              Icons.save_alt_outlined,
                              color: Colors.black,
                              size: 30,
                            ),
                            label: const Text("Save",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                            onPressed: () async {
                              print(contentTextController.text);
                              print(descriptionTextController.text);
                              print(startDate.value);
                              print(endDate.value);
                              await InsertCommonTodosTreeView(
                                      context,
                                      contentTextController.text,
                                      descriptionTextController.text,
                                      startDate.value,
                                      endDate.value,
                                      item != null ? item!.data.id : 0)
                                  .then((value) {
                                contentTextController.clear();
                                descriptionTextController.clear();
                                Navigator.pop(context);
                                refreshPage();
                              });
                            },
                          )
                        : TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[800],
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            icon: const Icon(
                              Icons.refresh_outlined,
                              color: Colors.black,
                              size: 30,
                            ),
                            label: const Text("Update",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                            onPressed: () async {
                              print(contentTextController.text);
                              print(descriptionTextController.text);
                              print(startDate.value);
                              print(endDate.value);
                              await UpdateCommonTodosTreeView(
                                context,
                                contentTextController.text,
                                descriptionTextController.text,
                                startDate.value,
                                endDate.value,
                                item!.data.id,
                                item!.data.parentId,
                              ).then((value) {
                                contentTextController.clear();
                                descriptionTextController.clear();
                                Navigator.pop(context);
                                refreshPage();
                              });
                            },
                          ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green[800],
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      icon: const Icon(
                        Icons.close_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                      label: const Text("Close",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  UpdateCommonTodosTreeView(
      BuildContext context,
      String Todocontent,
      String TodoDesc,
      DateTime startDate,
      DateTime endDate,
      int todoId,
      int parentId) async {
    ControllerDB _controllerDB = Get.put(ControllerDB());
    ControllerTodo _controllerTodo = ControllerTodo();
    await _controllerTodo.UpdateCommonTodosTreeView(
      _controllerDB.headers(),
      UserId: commonGroupSelected.userId,
      ownerId: commonGroupSelected.personalId,
      CommonBoardId: commonGroupSelected.id,
      TodoId: todoId,
      TodoName: Todocontent,
      Description: TodoDesc,
      StartDate: startDate,
      ModuleType: 99,
      EndDate: endDate,
      parentId: parentId,
    ).then((value) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.update,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          //backgroundColor: Colors.red,
          //textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  InsertCommonTodosTreeView(
      BuildContext context,
      String Todocontent,
      String TodoDesc,
      DateTime startDate,
      DateTime endDate,
      int parentId) async {
    ControllerDB _controllerDB = Get.put(ControllerDB());
    ControllerTodo _controllerTodo = ControllerTodo();
    await _controllerTodo.InsertCommonTodosTreeView(
      _controllerDB.headers(),
      UserId: commonGroupSelected.userId,
      ownerId: commonGroupSelected.personalId,
      CommonBoardId: commonGroupSelected.id,
      TodoName: Todocontent,
      Description: TodoDesc,
      StartDate: startDate,
      ModuleType: 99,
      EndDate: endDate,
      parentId: parentId,
    ).then((value) {
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
        //   return 'yyyy/MM/dd';

        return 'dd/MM/yyyy';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return withSecond ? 'HH:mm:ss' : 'HH:mm';
    }
  }
}

TreeNode<CommonTodo> buildTree(List<CommonTodo> todos) {
  final parentMap = <int, List<CommonTodo>>{};

  // ParentId'ye göre grupla
  for (final todo in todos) {
    parentMap.update(
      todo.parentId!,
      (list) => list..add(todo),
      ifAbsent: () => [todo],
    );
  }

  // Kök node'ları parentId=0 olanlar
  final rootTodos = parentMap[0] ?? [];
  print("Root Node Sayısı: ${rootTodos.length}"); // 7 çıkmalı!

  // Tüm kök node'ları tek bir root altına ekle
  final rootNode = TreeNode<CommonTodo>(
    key: "root",
  )..addAll(
      rootTodos.map((rootTodo) => _buildTreeNode(rootTodo, parentMap)),
    );

  return rootNode;
}

TreeNode<CommonTodo> _buildTreeNode(
  CommonTodo todo,
  Map<int, List<CommonTodo>> parentMap,
) {
  final node = TreeNode<CommonTodo>(
    key: todo.id.toString(), // Key String olmalı
    data: todo,
  );

  // Çocukları ekle
  final children = parentMap[todo.id] ?? [];
  node.addAll(children.map((child) => _buildTreeNode(child, parentMap)));

  return node;
}
