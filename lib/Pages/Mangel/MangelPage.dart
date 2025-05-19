import 'dart:convert';
import 'dart:io';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_richtext/expandable_rich_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_selectable_list/flutter_selectable_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:selectable_search_list/selectable_search_list.dart';
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

class MangelPage extends StatefulWidget {
  final int? collab;
  final int? ownerId;

  const MangelPage({
    Key? key,
    this.collab,
    this.ownerId,
  }) : super(key: key);

  @override
  _MangelPageState createState() => _MangelPageState();
}

class _MangelPageState extends State<MangelPage> with TickerProviderStateMixin {
  final ControllerLocal cL = Get.put(ControllerLocal());
  TextEditingController _titleController = TextEditingController();
  TextEditingController _takenoteController = TextEditingController();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerLabel _controllerLabel = Get.put(ControllerLabel());
  GetGenericTodosResult _todosResult = GetGenericTodosResult(hasError: false);

  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
  ControllerBottomNavigationBar _bottom =
      Get.put(ControllerBottomNavigationBar());
  final ScrollController _scrollController = ScrollController();
  List<UserLabel> labelsList = [];
  final List<DropdownMenuItem> cboLabelsList = [];
  final List<ListItem> cboLabelsList2 = [];
  List<int> selectedLabelIndexes = [];
  List<int> selectedLabels = [];
  TextEditingController _controller = TextEditingController();
  bool isLoading = true;
  AnimationController? _controllerAnimation;
  bool isExpanded = false;
  List<int> selectedLabelIndexesForSearch = [];
  List<int> selectedLabelForSearch = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controllerAnimation = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        upperBound: 0.5,
      );
      await GetNote();
      await _controllerLabel.GetLabelByUserId(_controllerDB.headers(),
              Id: 0,
              UserId: _controllerDB.user.value!.result!.id!,
              CustomerId: 0,
              LabelType: 1)
          .then((value) {
        labelsList = value.result!;
        List.generate(_controllerLabel.getLabel.value!.result!.length, (index) {
          cboLabelsList.add(DropdownMenuItem(
              child: Row(
                children: [
                  Text(_controllerLabel.getLabel.value!.result![index].title!),
                  Icon(
                    Icons.lens,
                    color: Color(int.parse(
                        _controllerLabel.getLabel.value!.result![index].color!
                            .replaceFirst('#', "FF"),
                        radix: 16)),
                  )
                ],
              ),
              key: Key(_controllerLabel.getLabel.value!.result![index].title!
                  .toString()),
              value: _controllerLabel.getLabel.value!.result![index].title! +
                  "+" +
                  _controllerLabel.getLabel.value!.result![index].color!));
        });
        List.generate(_controllerLabel.getLabel.value!.result!.length, (index) {
          cboLabelsList2.add(ListItem(
            title: _controllerLabel.getLabel.value!.result![index].title!,
            id: int.parse(
                    _controllerLabel.getLabel.value!.result![index].color!
                        .replaceFirst('#', "FF"),
                    radix: 16)
                .toString(),
            isSelected: false,
          ));
        });
        _checkedStates = List.generate(cboLabelsList.length, (index) => false);
      });

      setState(() {
        isLoading = false;
      });
    });
  }

  List<String> checkedItemList = ['Green', 'Yellow'];
  List<String> selectedItemList = [];
  var locale;
  String Base64Image = "";
  DateTime startDate = DateTime.now();

  // AnimationControllers

  bool listExpand = false;

  List<CheckedItem> checkedItems = <CheckedItem>[];
  List<noteItems> _notesItems = <noteItems>[];
  FocusNode noteFocus = FocusNode();
  List<String> labelItems = [];
  TextEditingController myTextFieldControllerLabel = TextEditingController();
  bool labelTapCheck = false;
  bool isFilter = false;
  ValueNotifier<DateTime> startDateNotifier = ValueNotifier(DateTime.now());
  ValueNotifier<DateTime> endDateNotifier = ValueNotifier(DateTime.now());
  ValueNotifier<DateTime> remindDateNotifier = ValueNotifier(DateTime.now());
  bool isRemind = false;
  final startController = BoardDateTimeController();
  final endController = BoardDateTimeController();
  final remindDateController = BoardDateTimeController();

  Future<ResultCheckListUpdate> InsertOrUpdateTodoCheckList(
      int Id, int todoId, String Title, bool IsDone) async {
    return await _controllerTodo.InsertOrUpdateTodoCheckList(
        _controllerDB.headers(),
        Id: Id,
        UserId: _controllerDB.user.value!.result!.id!,
        TodoId: todoId,
        Title: Title,
        IsDone: IsDone);
  }

  Future<void> GetNote({String search = ""}) async {
    _todosResult = await _controllerTodo.GetGenericTodos(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id!,
        ModuleType: 35,
        search: search,
        LabelIds: selectedLabelForSearch,
        ownerId: widget.ownerId);

    for (int i = 0; i < _todosResult.genericTodo!.length; i++) {
      await _controllerTodo.GetTodoCheckList(_controllerDB.headers(),
              UserId: _controllerDB.user.value!.result!.id!,
              TodoId: _todosResult.genericTodo![i].id!)
          .then((value) {
        setState(() {
          _todosResult.genericTodo![i].checkList = value;
        });
      });
    }
    setState(() {});
  }

  void _refreshPage() async {
    setState(() {}); // Sadece sayfayı yeniden oluşturuyoruz

    await GetNote();
  }

  Future<void> UpdateNotes(int TodoId,
      {DateTime? ReminderDate, String? title, String? description}) async {
    await _controllerTodo.UpdateCommonTodos(
      _controllerDB.headers(),
      UserId: _controllerDB.user.value!.result!.id!,
      TodoId: TodoId,
      BackgroundImageBase64: Base64Image.isEmpty ? null : Base64Image,
      RemindDate: ReminderDate.toString(),
      TodoName: title,
      Description: description,
      ModuleType: 35,
    ).then((value) {
      setState(() {
        Base64Image = "";
        _todosResult.genericTodo!
            .firstWhere((element) => element.id == TodoId)
            .backgroundImage = value.genericTodoUpdate!.backgroundImage;
        _todosResult.genericTodo!
            .firstWhere(
              (element) => element.id == TodoId,
              //! orElse: () {}
            )
            .remindDate = value.genericTodoUpdate!.remindDate;
      });
    });
    setState(() {
      Base64Image = "";
    });
  }

  final _debouncer = DebouncerForSearch();
  bool showSearch = false;
  var remindDateList;
  void handleDelete(BuildContext context, GenericTodo msg) {
    deleteMessageFunc(msg);
  }

  deleteMessage(int MessageId) async {
    bool? confirm = await showModalYesOrNo(
        context,
        AppLocalizations.of(context)!.delete,
        AppLocalizations.of(context)!.areYouSurefile);
    if (confirm!) {
      _controllerTodo.DeleteTodo(_controllerDB.headers(),
          UserId: _controllerDB.user.value!.result!.id!, TodoId: MessageId);
      setState(() {
        _todosResult.genericTodo!
            .removeWhere((element) => element.id == MessageId);
      });
    }
  }

  Future<void> deleteMessageFunc(GenericTodo messageList) async {
    await deleteMessage(messageList.id!);
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)!.deleted,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
  }

  Slidable MessageListItemNew(BuildContext context, GenericTodo msg) {
    if (msg.startDate != null) {
      DateTime tempStartDate =
          new DateFormat("yyyy-MM-ddThh:mm:ss").parse(msg.startDate!);
      startDateNotifier = ValueNotifier(tempStartDate);
    } else {
      startDateNotifier = ValueNotifier(DateTime.now());
    }
    if (msg.endDate != null) {
      DateTime tempEndDate =
          new DateFormat("yyyy-MM-ddThh:mm:ss").parse(msg.endDate!);

      endDateNotifier = ValueNotifier(tempEndDate);
    } else {
      endDateNotifier = ValueNotifier(DateTime.now());
    }
    if (msg.remindDate != null) {
      DateTime tempRemindDate =
          new DateFormat("yyyy-MM-ddThh:mm:ss").parse(msg.remindDate!);

      remindDateNotifier = ValueNotifier(tempRemindDate);
    }
    /*  else {
      remindDateNotifier = ValueNotifier(DateTime.now());
    } */

    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        /* dismissible: DismissiblePane(onDismissed: () {
          handleDelete(context, msg);
        }), */
        children: [
          SlidableAction(
            onPressed: (context) => handleDelete(context, msg),
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // SlidableAction(
          //   // An action can be bigger than the others.
          //   onPressed: (context) => replyMessage(context, msg),
          //   backgroundColor: const Color(0xFF7BC043),
          //   foregroundColor: Colors.white,
          //   icon: Icons.reply,
          //   label: '',
          // ),
          // SlidableAction(
          //   onPressed: (context) => replyAllMessage(context, msg),
          //   backgroundColor: const Color(0xFF0392CF),
          //   foregroundColor: Colors.white,
          //   icon: Icons.reply_all,
          //   label: '',
          // ),
          // SlidableAction(
          //   onPressed: (context) => forwardMessage(context, msg),
          //   backgroundColor: Color(0xFF21B7CA),
          //   foregroundColor: Colors.white,
          //   icon: Icons.forward,
          //   label: '',
          // ),
        ],
      ),

      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MangelDetailPage(
                msg: msg,
                ownerId: widget.ownerId,
                checkedItems: checkedItems,
                cboLabelsList: [...cboLabelsList],
                labelsList: [...labelsList],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 0, 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*    Text("ID " + msg.id.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold)), */
                msg.content.isNullOrBlank!
                    ? Container()
                    : TitleWidget(msg.content!),
                msg.description!.isNullOrBlank!
                    ? Container()
                    : DescriptionWidget(msg.description!),
//? Dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          ValueListenableBuilder(
                            valueListenable: startDateNotifier,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          ValueListenableBuilder(
                            valueListenable: endDateNotifier,
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
                    ),
                  ],
                ),

                //  ImageWidget(msg.backgroundImage!, msg.id!, context),

                /* msg.checkList!.checkListItem!.length == 0
                ? Container(color: Colors.purple)
                : CheckLists(msg.checkList!, msg.id!), */
                msg.labelList!.length == 0
                    ? Container(color: Colors.blue)
                    : TagsWidgetListed(msg.labelList!),
                SizedBox(
                  height: 10,
                ),

                msg.remindDate != null
                    ? Row(
                        children: [
                          SizedBox(
                            width: Get.width / 3,
                          ),
                          Icon(
                            Icons.notifications_off_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          ValueListenableBuilder(
                            valueListenable: remindDateNotifier,
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
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(),
                )
              ]

              /*     
            [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                child: Text(
                  msg.content ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Text(
                  removeAllHtmlTags((msg.description).toString()),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              //! Labellar gelecek, start-end date,notification date eklenecek
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Text(
                  msg.startDate != null ? msg.startDate! : "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Text(
                  msg.endDate != null ? msg.endDate! : "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Text(
                  msg.remindDate != null ? msg.remindDate! : "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              )
            ],
                 
          */
              ),
        ),
      ),
    );
  }

  Color _currentColor = Colors.blue;

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text("Bir renk seçin"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }),
        ],
      ),
    );
  }

  Widget MessageWidget(
      BuildContext context, List<GenericTodo> generalTodoList) {
    return Column(
      children: [
        Expanded(
          child: Container(
            height: Get.height * 0.75,
            child: Column(
              children: [
                /*  isFilter
                    ? SearchableDropdown.multiple(
                        clearIcon: Icon(
                          Icons.car_crash,
                        ),
                        dialogBox: true,
                        items: cboLabelsList,
                        selectedItems: selectedLabelIndexes.toSet().toList(),
                        hint: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(AppLocalizations.of(context)!.labels),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedLabels.clear();
                            selectedLabelIndexes = value;

                            labelsList.asMap().forEach((index, value) {
                              selectedLabelIndexes
                                  .forEach((selectedLabelIndex) {
                                if (selectedLabelIndex == index) {
                                  selectedLabels.add(value.id!);
                                }
                              });
                            });
                            print(labelsList);
                            print(selectedLabels);
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
                      )
                    : Container(
                        color: Colors.amber,
                      ), */

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: generalTodoList.length ?? 0,
                    itemBuilder: (ctx, i) {
                      if (generalTodoList[i].labelList != null) {
                        for (var xx = 0;
                            xx < generalTodoList[i].labelList!.length;
                            xx++) {
                          var abc = generalTodoList[i].labelList![xx].labelId;

                          print(abc);
                        }
                      }

                      /*       List<int> matchingIdsFunctional = aListMap
    .where((aMap) => (aMap['Labellist'] as List<Map<String, dynamic>>?)?.any((labelMap) =>
        labelMap['LabelId'] != null && selectedlabels.contains(labelMap['LabelId'])) ?? false)
    .map((aMap) => aMap['Id'] as int)
    .toList();

print(matchingIdsFunctional); // Çıktı: [1, 2, 4]

 */
                      var msg;
                      ;
                      var matchingLabelId;

                      if (selectedLabels.isNotEmpty) {
                        for (var labelMap in generalTodoList[i].labelList!) {
                          int? labelId = labelMap.labelId;
                          if (labelId != null &&
                              selectedLabels.contains(labelId)) {
                            matchingLabelId = generalTodoList[
                                i]; // Eşleşme varsa A listesinin Id'sini atıyoruz

                            msg = matchingLabelId;
                            return MessageListItemNew(context, msg);
                            //  break; // İlk eşleşmede döngüden çıkabiliriz
                          }
                        }
                      } else {
                        msg = generalTodoList[i];
                        return MessageListItemNew(context, msg);
                      }
                      return null;

                      //  var msg = _todosResult.genericTodo![i];
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();

  late List<bool> _checkedStates;
  bool isChecked = false;
  TextEditingController labelNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    var generalTodo;
    if (_todosResult.genericTodo != null) {
      generalTodo = _todosResult.genericTodo!;
    }

    bool isTablet = shortestSide > 600;
    return GetBuilder(
      builder: (ControllerTodo controller) {
        if (controller.refreshNote) {
          GetNote();
          controller.refreshNote = false;
        }
        return Scaffold(
          endDrawer: Drawer(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: Get.width,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Scaffold.of(context).closeEndDrawer();
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                          Text("Mängel"),
                        ],
                      ),
                    ),
                    /* 
                    SearchableDropdown.multiple(
                      dialogBox: true,
                      items: cboLabelsList,
                      selectedItems: selectedLabelIndexes.toSet().toList(),
                      hint: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Text(AppLocalizations.of(context)!.labels),
                      ),
                      closeButton: (value) {
                        setState(() {
                          selectedLabels.clear();
                          selectedLabelIndexes = value;

                          labelsList.asMap().forEach((index, value) {
                            selectedLabelIndexes.forEach((selectedLabelIndex) {
                              if (selectedLabelIndex == index) {
                                selectedLabels.add(value.id!);
                              }
                            });
                          });
                          print(labelsList);
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          selectedLabels.clear();
                          selectedLabelIndexes = value;

                          labelsList.asMap().forEach((index, value) {
                            selectedLabelIndexes.forEach((selectedLabelIndex) {
                              if (selectedLabelIndex == index) {
                                selectedLabels.add(value.id!);
                              }
                            });
                          });
                          print(labelsList);
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
                      iconDisabledColor: const Color.fromARGB(255, 206, 11, 11),
                      iconEnabledColor: Get.theme.colorScheme.surface,
                      isExpanded: true,
                    ),
                     */

                    ExpansionTileCard(
                      baseColor: Colors.white,
                      expandedColor: Colors.white,
                      key: cardA,
                      //  leading: const CircleAvatar(child: Text('A')),
                      title: const Text('Add Label'),
                      children: <Widget>[
                        const Divider(
                          thickness: 1.0,
                          height: 1.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            readOnly: false,
                            textAlign: TextAlign.center,
                            controller: labelNameController,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              //   fontWeight: FontWeight.w100,
                            ),
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15),
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
                              labelText: "Label Name",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 32, 30, 30)),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _showColorPicker,
                          child: Text("Color"),
                        ),
                        TextButton(
                          onPressed: _showColorPicker,
                          child: Text(AppLocalizations.of(context)!.add),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 40,
                          color: Colors.lightGreen,
                          child: Row(
                            children: [
                              Icon(Icons.filter_alt_outlined),
                              Text("Filter"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: cboLabelsList.length,
                        itemBuilder: (ctx, i) {
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _checkedStates[i] = !_checkedStates[i];
                                });
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                    activeColor: primaryYellowColor,
                                    checkColor: Colors.white,
                                    value: _checkedStates[i],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _checkedStates[i] = value!;
                                        /*  selectedLabelIndexes.add(i);
                                        selectedLabels.add(
                                            cboLabelsList[i].value.toString());
                                        print(selectedLabelIndexes);
                                        print(selectedLabels); */
                                      });
                                    },
                                  ),
                                  Text(cboLabelsList[i]
                                      .value
                                      .toString()
                                      .split("+")
                                      .first),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.lens,
                                    color: Color(int.parse(
                                        cboLabelsList[i]
                                            .value
                                            .toString()
                                            .split("+")
                                            .last
                                            .replaceFirst('#', "FF"),
                                        radix: 16)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                    /* 
                    Container(
                      height: Get.height * 0.8,
                      child: SelectableListAnchor.single(
                        backgroundColor: Colors.white,
                        items: cboLabelsList,
                        itemTitle: (e) => e.value,
                        elevation: 6,
                        enableDefaultSearch: true,
                        //   formFieldKey:
                        //_formFieldKey,
                        pinSelectedValue: true,
                        onConfirm: (val) {
                          //  _formFieldKey.currentState?.validate();
                        },
                        /*   validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          return null;
                        }, */
                        builder: (controller, state) {
                          return TextButton(
                            onPressed: () async {
                              controller.openDialog();
                            },
                            child: const Text('Open view'),
                          );
                        },
                      ),
                      /*   MultiSelectListWidget(
                        selectAllTextStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        itemTitleStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        items: cboLabelsList2,
                        onItemsSelect: (selectedItems) {
                          print('Selected Items: ${selectedItems.length}');
                        },
                      ), */
                    ),
                */
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text("Mängel Management"),
            //Text(AppLocalizations.of(context)!.note),
            backgroundColor: Colors.white,
            actions: [
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.search_off_outlined),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                      setState(() {
                        isFilter = true;
                      });
                    },
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  if (isRemind) {
                    setState(() {
                      remindDateList = null;
                      isRemind = false;
                    });
                  } else {
                    setState(() {
                      remindDateList = generalTodo
                          .where((element) => element.remindDate != null)
                          .toList();
                      isRemind = true;
                    });
                  }

                  print(remindDateList);
                },
                icon: Icon(
                  Icons.notification_important_outlined,
                  color: isRemind ? Colors.amber : Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewMangel(
                                Base64Image: Base64Image,
                                listExpand: listExpand,
                                titleController: _titleController,
                                takenoteController: _takenoteController,
                                noteFocus: noteFocus,
                                //   checkedItems2: checkedItems,
                                labelTapCheck: labelTapCheck,
                                cboLabelsList: cboLabelsList,
                                selectedLabelIndexes: selectedLabelIndexes,
                                selectedLabels: selectedLabels,
                                labelsList: labelsList,
                                labelItems: labelItems,
                                bottom: _bottom,
                                ownerId: widget.ownerId,
                                selectedLabelForSearch: selectedLabelForSearch,
                                refreshPage: _refreshPage,
                              )));
                },
                icon: Icon(Icons.add_outlined),
              ),
            ],
          ),
          body: isLoading
              ? CustomLoadingCircle()
              : SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.10),
                        width: MediaQuery.of(context).size.width,
                        height: Get.height,
                        child: Column(children: [
                          // newMangel(context),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: HexColor('#f4f5f7'),
                                ),
                                child: MessageWidget(
                                    context,
                                    remindDateList == null
                                        ? generalTodo
                                        : remindDateList),
                              ),
                            ),
                          ),
                        ]),
                      ),

                      /* 
                      Positioned(
                        bottom: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? Get.height * 0.25
                            : Get.height * 0.2,
                        right: MediaQuery.of(context).size.width * 0.05,
                        child: FloatingActionButton.extended(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          heroTag: "MangelPage",
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NewMangelPage(
                                  type: 0,
                                ),
                              ),
                            );
                          },
                          backgroundColor: Get.theme.primaryColor,
                          icon: Icon(
                            Icons.mail_outlined,
                            color: primaryYellowColor,
                          ),
                          /*    Image.asset(
                          'assets/images/icon/newMail.png',
                          height: Get.height / 35,
                          width: Get.height / 35,
                        ), */
                          label: Text(
                            AppLocalizations.of(context)!
                                .note, // Your label text here
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryYellowColor, // Adjust as necessary
                            ),
                          ),
                        ),
                      ),
 */
                      /*      Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        width: Get.width,
                        height: Get.height,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.pink,
                                width: Get.width,
                                child: Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      //Get.theme.scaffoldBackgroundColor,
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 100),
                                        child: Column(
                                          children: [
                                            //?  TAKE A NOTE

                                            ConstrainedBox(
                                              constraints: BoxConstraints(),
                                              child: Card(
                                                elevation: 10,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                color: Colors.white,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Visibility(
                                                          visible: !(Base64Image
                                                              .isBlank!),
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.2,
                                                            decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: MemoryImage(
                                                                        base64Decode(
                                                                            Base64Image))),
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            15),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            15))),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 0,
                                                          bottom: 25,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Base64Image = "";
                                                              setState(() {});
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Get
                                                                      .theme
                                                                      .primaryColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30)),
                                                              child: Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.pink,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    // AnimatedContainer(
                                                    //   duration: Duration(
                                                    //       milliseconds: 300),
                                                    //   height:
                                                    //       listExpand ? null : 0,
                                                    //   padding:
                                                    //       EdgeInsets.symmetric(
                                                    //           horizontal: 10),
                                                    //   margin:
                                                    //       EdgeInsets.symmetric(
                                                    //           vertical:
                                                    //               listExpand
                                                    //                   ? 3
                                                    //                   : 0),
                                                    //   child: Column(
                                                    //     children: [
                                                    //       TextField(
                                                    //         controller:
                                                    //             _titleController,
                                                    //         decoration:
                                                    //             InputDecoration(
                                                    //           hintText:
                                                    //               AppLocalizations.of(
                                                    //                       context)
                                                    //                   .title,
                                                    //           border:
                                                    //               OutlineInputBorder(
                                                    //             borderSide:
                                                    //                 BorderSide
                                                    //                     .none,
                                                    //             borderRadius:
                                                    //                 BorderRadius
                                                    //                     .zero,
                                                    //           ),
                                                    //         ),
                                                    //         maxLines: null,
                                                    //       ),
                                                    //       Divider(),
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                    //? TextBox Take A Note
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: TextField(
                                                        controller:
                                                            _takenoteController,
                                                        focusNode: noteFocus,
                                                        onTap: () {
                                                          setState(() {
                                                            if (!listExpand) {
                                                              listExpand =
                                                                  !listExpand;
                                                            }
                                                          });
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .takeANote,
                                                          border:
                                                              OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero),
                                                        ),
                                                        maxLines: null,
                                                      ),
                                                    ),
                                                    AnimatedContainer(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      height:
                                                          listExpand ? null : 0,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  listExpand
                                                                      ? 3
                                                                      : 0),
                                                      child: Column(
                                                        children: [
                                                          ListView.builder(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom: 5,
                                                                      top: 5),
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  checkedItems
                                                                      .length,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              itemBuilder:
                                                                  (context, i) {
                                                                return Container(
                                                                  width:
                                                                      Get.width,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      left: 10,
                                                                      right: 30,
                                                                      top: 5,
                                                                      bottom: 5,
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              checkedItems[i].checked = !checkedItems[i].checked;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                20,
                                                                            width:
                                                                                20,
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(width: 1.0)),
                                                                            child: checkedItems[i].checked
                                                                                ? Icon(Icons.clear, size: 18)
                                                                                : Container(),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              15,
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                TextField(
                                                                          style:
                                                                              TextStyle(fontSize: 18),
                                                                          controller:
                                                                              checkedItems[i].text,
                                                                          focusNode:
                                                                              checkedItems[i].focus,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            border:
                                                                                OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.zero),
                                                                          ),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                          labelTapCheck
                                                              ? Container()
                                                              : SearchableDropdown
                                                                  .multiple(
                                                                  items:
                                                                      cboLabelsList,
                                                                  selectedItems:
                                                                      selectedLabelIndexes
                                                                          .toSet()
                                                                          .toList(),
                                                                  hint: Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            0.0),
                                                                    child: Text(
                                                                        AppLocalizations.of(context)!
                                                                            .labels),
                                                                  ),
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      selectedLabels
                                                                          .clear();
                                                                      selectedLabelIndexes =
                                                                          value;

                                                                      labelsList
                                                                          .asMap()
                                                                          .forEach((index,
                                                                              value) {
                                                                        selectedLabelIndexes
                                                                            .forEach((selectedLabelIndex) {
                                                                          if (selectedLabelIndex ==
                                                                              index) {
                                                                            selectedLabels.add(value.id!);
                                                                          }
                                                                        });
                                                                      });
                                                                    });
                                                                  },
                                                                  displayItem:
                                                                      (item,
                                                                          selected) {
                                                                    return (Row(
                                                                        children: [
                                                                          selected
                                                                              ? Icon(
                                                                                  Icons.check,
                                                                                  color: Colors.green,
                                                                                )
                                                                              : Icon(
                                                                                  Icons.check_box_outline_blank,
                                                                                  color: Colors.grey,
                                                                                ),
                                                                          SizedBox(
                                                                              width: 7),
                                                                          Expanded(
                                                                            child:
                                                                                item,
                                                                          ),
                                                                        ]));
                                                                  },
                                                                  selectedValueWidgetFn:
                                                                      (item) {
                                                                    return Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Color(
                                                                              0xFFdedede),
                                                                          borderRadius:
                                                                              BorderRadius.circular(30)),
                                                                      margin: EdgeInsets.only(
                                                                          right:
                                                                              5),
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              9),
                                                                      child:
                                                                          (Row(
                                                                        children: [
                                                                          Text(item
                                                                              .toString()
                                                                              .split("+")
                                                                              .first),
                                                                          SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Icon(
                                                                            Icons.lens,
                                                                            color:
                                                                                Color(int.parse(item.toString().split("+").last.replaceFirst('#', "FF"), radix: 16)),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                    );
                                                                  },
                                                                  doneButton:
                                                                      (selectedItemsDone,
                                                                          doneContext) {
                                                                    return (ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              doneContext);
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child: Text(
                                                                            AppLocalizations.of(context)!.save)));
                                                                  },
                                                                  closeButton:
                                                                      null,
                                                                  style: Get
                                                                      .theme
                                                                      .inputDecorationTheme
                                                                      .hintStyle,
                                                                  searchFn: (String
                                                                          keyword,
                                                                      items) {
                                                                    List<int>
                                                                        ret =
                                                                        <int>[];
                                                                    if (items !=
                                                                            null &&
                                                                        keyword
                                                                            .isNotEmpty) {
                                                                      keyword
                                                                          .split(
                                                                              " ")
                                                                          .forEach(
                                                                              (k) {
                                                                        int i =
                                                                            0;
                                                                        items.forEach(
                                                                            (item) {
                                                                          if (k.isNotEmpty &&
                                                                              (item.value.toString().toLowerCase().contains(k.toLowerCase()))) {
                                                                            ret.add(i);
                                                                          }
                                                                          i++;
                                                                        });
                                                                      });
                                                                    }
                                                                    if (keyword
                                                                        .isEmpty) {
                                                                      ret = Iterable<int>.generate(
                                                                              items.length)
                                                                          .toList();
                                                                    }
                                                                    return (ret);
                                                                  },
                                                                  //clearIcon: Icons(null), todo:nullable yap
                                                                  icon: Icon(
                                                                    Icons
                                                                        .expand_more,
                                                                    size: 31,
                                                                  ),
                                                                  underline:
                                                                      Container(
                                                                    height: 0.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            border:
                                                                                Border(bottom: BorderSide(color: Colors.teal, width: 0.0))),
                                                                  ),
                                                                  iconDisabledColor:
                                                                      Colors
                                                                          .grey,
                                                                  iconEnabledColor: Get
                                                                      .theme
                                                                      .colorScheme
                                                                      .surface,
                                                                  isExpanded:
                                                                      true,
                                                                ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Tags(
                                                            itemCount:
                                                                labelItems
                                                                    .length,
                                                            itemBuilder: (i) {
                                                              return ItemTags(
                                                                alignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                index: i,
                                                                title:
                                                                    labelItems[
                                                                        i],
                                                                removeButton:
                                                                    ItemTagsRemoveButton(
                                                                  onRemoved:
                                                                      () {
                                                                    // Remove the item from the data source.
                                                                    setState(
                                                                        () {
                                                                      // required
                                                                    });
                                                                    //required
                                                                    return true;
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5,
                                                              bottom: 15,
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                CustomIconWithBackground(
                                                                  color: Colors
                                                                      .transparent, //! color eklendi
                                                                  onPressed:
                                                                      () {}, //! onPressed eklendi
                                                                  iconName:
                                                                      'notification',
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                CustomIconWithBackground(
                                                                  color: Colors
                                                                      .transparent, //! color eklendi

                                                                  iconName:
                                                                      'image',
                                                                  onPressed:
                                                                      () async {
                                                                    int?
                                                                        fileUploadType;
                                                                    await selectUploadType(
                                                                            context)
                                                                        .then((value) =>
                                                                            fileUploadType =
                                                                                value);
                                                                    if (fileUploadType ==
                                                                        0) {
                                                                      await _imgFromCamera();
                                                                      setState(
                                                                          () {});
                                                                    } else if (fileUploadType ==
                                                                        1) {
                                                                      await openFile();
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                CustomIconWithBackground(
                                                                  color: Colors
                                                                      .transparent, //! color eklendi

                                                                  iconName:
                                                                      'clipboard',
                                                                  onPressed:
                                                                      () async {
                                                                    if (!checkedItems
                                                                        .isBlank!) {
                                                                      if (checkedItems
                                                                          .last
                                                                          .text
                                                                          .text
                                                                          .isEmpty) {
                                                                        return;
                                                                      }
                                                                    }
                                                                    setState(
                                                                        () {
                                                                      checkedItems.add(CheckedItem(
                                                                          TextEditingController(),
                                                                          false,
                                                                          FocusNode()));
                                                                      checkedItems
                                                                          .last
                                                                          .focus
                                                                          .requestFocus();
                                                                    });
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                CustomIconWithBackground(
                                                                  color: Colors
                                                                      .transparent, //! color eklendi
                                                                  iconName:
                                                                      'label',
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      labelTapCheck =
                                                                          !labelTapCheck;
                                                                    });
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Spacer(),
                                                                Flexible(
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      try {
                                                                        noteFocus
                                                                            .unfocus();
                                                                        _bottom.lockUI =
                                                                            true;
                                                                        _bottom
                                                                            .update();
                                                                        setState(
                                                                            () {
                                                                          listExpand =
                                                                              false;
                                                                        });

                                                                        await _controllerTodo.InsertCommonTodos(_controllerDB.headers(),
                                                                                UserId: _controllerDB.user.value!.result!.id!,
                                                                                ModuleType: 35,
                                                                                TodoName: _titleController.text,
                                                                                Description: _takenoteController.text,
                                                                                StartDate: DateTime.now(),
                                                                                EndDate: DateTime.now(),
                                                                                BackgroundImageBase64: Base64Image)
                                                                            .then((value) async {
                                                                          print(
                                                                              value);
                                                                          await InsertTodoLabelList(
                                                                              selectedLabels,
                                                                              value.result!.id!);
                                                                          checkedItems
                                                                              .forEach((element) async {
                                                                            await InsertOrUpdateTodoCheckList(
                                                                                0,
                                                                                value.result!.id!,
                                                                                element.text.text,
                                                                                element.checked);
                                                                          });
                                                                        });
                                                                        await GetNote();
                                                                        _bottom.lockUI =
                                                                            false;
                                                                        _bottom
                                                                            .update();

                                                                        setState(
                                                                            () {
                                                                          listExpand =
                                                                              false;

                                                                          _titleController
                                                                              .clear();
                                                                          _takenoteController
                                                                              .clear();
                                                                          Base64Image =
                                                                              "";
                                                                          checkedItems
                                                                              .clear();
                                                                          labelItems
                                                                              .clear();
                                                                          selectedLabels
                                                                              .clear();
                                                                          selectedLabelIndexes
                                                                              .clear();
                                                                        });
                                                                      } catch (_) {
                                                                        _bottom.lockUI =
                                                                            false;
                                                                        _bottom
                                                                            .update();
                                                                        setState(
                                                                            () {
                                                                          listExpand =
                                                                              false;
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        CustomIconWithBackground(
                                                                      color: Colors
                                                                          .transparent, //! color eklendi
                                                                      iconName:
                                                                          'check',
                                                                      onPressed:
                                                                          () {},
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                CustomIconWithBackground(
                                                                  color: Colors
                                                                      .transparent, //! color eklendi
                                                                  iconName:
                                                                      'delete',
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

//? INCOMING DATA
                                            Expanded(
                                              child:

                                                  /*    GridView.builder(
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount:
                                                              isTablet
                                                                  ? (Get.height >
                                                                          850
                                                                      ? 2
                                                                      : 3)
                                                                  : 1),
                                                  padding: EdgeInsets.only(
                                                      top: 5, bottom: 100),
                                                  itemCount: _todosResult
                                                      .genericTodo!.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                     */

                                                  ListView.builder(
                                                      itemCount: _todosResult
                                                          .genericTodo!.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              if (listExpand) {
                                                                listExpand =
                                                                    !listExpand;
                                                                noteFocus
                                                                    .unfocus();
                                                              } else if (!listExpand) {
                                                                _editNote(
                                                                    _todosResult
                                                                            .genericTodo![
                                                                        index]);
                                                              }
                                                            });
                                                          },
                                                          /*   child: ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                                maxHeight: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.3,
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    45,
                                                                minHeight: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.1), */
                                                          child: Card(
                                                            elevation: 10,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15)),
                                                            color: Colors.white,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        5),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      ImageWidget(
                                                                          _todosResult
                                                                              .genericTodo![
                                                                                  index]
                                                                              .backgroundImage!,
                                                                          _todosResult
                                                                              .genericTodo![index]
                                                                              .id!,
                                                                          context),
                                                                      _todosResult
                                                                              .genericTodo![
                                                                                  index]
                                                                              .content
                                                                              .isNullOrBlank!
                                                                          ? Container()
                                                                          : TitleWidget(_todosResult
                                                                              .genericTodo![index]
                                                                              .content!),
                                                                      _todosResult
                                                                              .genericTodo![
                                                                                  index]
                                                                              .description!
                                                                              .isNullOrBlank!
                                                                          ? Container()
                                                                          : DescriptionWidget(_todosResult
                                                                              .genericTodo![index]
                                                                              .description!),
                                                                      _todosResult.genericTodo![index].checkList!.checkListItem!.length ==
                                                                              0
                                                                          ? Container(
                                                                              color: Colors
                                                                                  .purple)
                                                                          : CheckLists(
                                                                              _todosResult.genericTodo![index].checkList!,
                                                                              _todosResult.genericTodo![index].id!),
                                                                      _todosResult.genericTodo![index].labelList!.length ==
                                                                              0
                                                                          ? Container(
                                                                              color: Colors
                                                                                  .blue)
                                                                          : TagsWidget(_todosResult
                                                                              .genericTodo![index]
                                                                              .labelList!),
                                                                    ]),
                                                                BottomIcons(
                                                                    _todosResult
                                                                            .genericTodo![
                                                                        index]),
                                                              ],
                                                            ),
                                                          ),
                                                          //  ),
                                                        );
                                                      }),
                                            ),
                                          ],
                                        ))),
                              ),
                            ),
                          ],
                        ),
                      ),
                   
                  */
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget ImageWidget(String a, int noteId, BuildContext context) {
    bool exten = GetStringUtils(a)
        .isURL; //! a.isURL yerine GetStringUtils(a).isURL kullanildi

    return a.isNullOrBlank == true
        ? Container()
        : Stack(
            children: [
              exten
                  ? CachedNetworkImage(
                      imageUrl: a,
                      imageBuilder: (context, imageProvider) => Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Container(),
                    )
                  : isBase64(a)
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(base64Decode(a))),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15))),
                        )
                      : Container(),
              Container(),
              Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      _controllerTodo.UpdateCommonTodos(_controllerDB.headers(),
                          UserId: _controllerDB.user.value!.result!.id!,
                          TodoId: noteId,
                          ModuleType: 35,
                          DeleteBackgroundImage: true);
                      setState(() {
                        _todosResult.genericTodo!
                            .firstWhere((element) => element.id == noteId)
                            .backgroundImage = "";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        Icons.delete_outlined,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ))
            ],
          );
  }

  Widget TitleWidget(String a) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 30,
        top: 0,
        bottom: 5,
      ),
      child: Text(
        a,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget DescriptionWidget(String a) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 30,
        top: 5,
        bottom: 0,
      ),
      child: Html(
        data: a.isNullOrBlank! ? "" : a,
      ),

      /*    ExpandableRichText(a.isNullOrBlank! ? "" : a,
          expandText: AppLocalizations.of(context)!.more,
          collapseText: AppLocalizations.of(context)!.less,
          style: TextStyle(color: Colors.black, fontSize: 18),
          toggleTextStyle: TextStyle(color: Color.fromARGB(255, 230, 192, 24))

          // style: TextStyle(fontSize: 25),
          ), */

      /* Text(
        a.isNullOrBlank! ? "" : a,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      ), */
    );
  }

  Widget CheckLists(GetTodoCheckListResult a, int todoId) {
    return ListView.builder(
        padding: EdgeInsets.only(bottom: 5, top: 5),
        shrinkWrap: true,
        itemCount: a.checkListItem!.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return Container(
            width: Get.width,
            height: 35,
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
                      InsertOrUpdateTodoCheckList(
                          a.checkListItem![i].id!,
                          a.checkListItem![i].todoId!,
                          a.checkListItem![i].title!,
                          !(a.checkListItem![i].isDone!));
                      setState(() {
                        _todosResult.genericTodo!
                            .firstWhere((element) => element.id == todoId)
                            .checkList!
                            .checkListItem!
                            .firstWhere((element) =>
                                element.id == a.checkListItem![i].id!)
                            .isDone = !(a.checkListItem![i].isDone!);
                      });
                    },
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(border: Border.all(width: 1.0)),
                      child: a.checkListItem![i].isDone!
                          ? Center(child: Icon(Icons.clear))
                          : Container(),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(a.checkListItem![i].title!)
                ],
              ),
            ),
          );
        });
  }

  Widget TagsWidget(List<LabelList> a) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 20,
      ),
      child: Tags(
        itemCount: a.length,
        itemBuilder: (int index) {
          return Tooltip(
              message: a[index].labelTitle,
              child: ItemTags(
                color: HexColor(a[index].labelColor!),
                activeColor: HexColor(a[index].labelColor!),
                alignment: MainAxisAlignment.start,
                index: index,
                title: a[index].labelTitle!,
              ));
        },
      ),
    );
  }

  Widget TagsWidgetListed(List<LabelList> a) {
    return Container(
      height: 35,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: a.length,
        itemBuilder: (context, index) {
          return Container(
              height: 40,
              padding: EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: HexColor(a[index].labelColor!),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                boxShadow: standartCardShadow(),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    Text(
                      a[index].labelTitle.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    // Add spacing between chips
                  ],
                ),
              ));

          /*  
        
          return Row(
            children: [
              Tooltip(
                  message: a[index].labelTitle,
                  child: ItemTags(
                    color: HexColor(a[index].labelColor!),
                    activeColor: HexColor(a[index].labelColor!),
                    alignment: MainAxisAlignment.start,
                    index: index,
                    title: a[index].labelTitle!,
                  )),
              SizedBox(width: 10), // Add spacing between chips
            ],
          );
      
      
       */
        },
      ),
    );
  }

  Widget BottomIcons(GenericTodo listOfGenericTodo) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomIconWithBackground(
            iconName: 'notification',
            color: listOfGenericTodo.remindDate == null
                ? Colors.black
                : primaryYellowColor,
            onPressed: () {
              _reminder(listOfGenericTodo.id!, listOfGenericTodo.remindDate!);
            },
          ),

          CustomIconWithBackground(
            iconName: 'image',
            color: Colors.black,
            onPressed: () async {
              int? fileUploadType;
              await selectUploadType(context)
                  .then((value) => fileUploadType = value);
              if (fileUploadType == 2) {
                await _imgFromCamera();
                if (Base64Image.isNotEmpty) {
                  UpdateNotes(listOfGenericTodo.id!);
                }
              } else if (fileUploadType == 1) {
                await openFile();
                if (Base64Image.isNotEmpty) {
                  UpdateNotes(listOfGenericTodo.id!);
                }
              }
            },
          ),

          CustomIconWithBackground(
            iconName: 'add-list',
            color: Colors.black,
            onPressed: () async {
              _checkList(listOfGenericTodo.id!);
            },
          ),

          CustomIconWithBackground(
            iconName: 'label',
            color: Colors.black,
            onPressed: () async {
              setState(() {
                _label(listOfGenericTodo.id!, listOfGenericTodo.labelList!);
              });
            },
          ),

          CustomIconWithBackground(
            iconName: 'cloud4',
            color: Colors.black,
            onPressed: () async {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => DirectoryDetail(
                            folderName: "",
                            hideHeader: false,
                            fileManagerType: FileManagerType.CommonTask,
                            todoId: listOfGenericTodo.id!,
                            headerTitle: listOfGenericTodo.content!,
                            //widget.todoId,
                          )));
            },
          ),
          // GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //           context,
          //           new MaterialPageRoute(
          //               builder: (BuildContext context) => DirectoryDetail(
          //                     folderName: "",
          //                     hideHeader: false,
          //                     fileManagerType: FileManagerType.CommonTask,
          //                     todoId: listOfGenericTodo.id,
          //                     headerTitle: listOfGenericTodo.content,
          //                     //widget.todoId,
          //                   )));
          //     },
          //     child: Stack(
          //       children: [
          //         Icon(Icons.cloud_outlined),
          //         Positioned(
          //             top: 0,
          //             right: 0,
          //             child: Text(
          //               listOfGenericTodo.fileCount.toString(),
          //               style: TextStyle(
          //                   fontSize: 14,
          //                   color: Get.theme.primaryColor,
          //                   fontWeight: FontWeight.bold),
          //             ))
          //       ],
          //     )),

          CustomIconWithBackground(
            iconName: 'history',
            color: Colors.black,
            onPressed: () async {},
          ),

          CustomIconWithBackground(
            iconName: 'delete',
            color: Colors.black,
            onPressed: () async {
              bool? confirm = await showModalYesOrNo(
                  context,
                  AppLocalizations.of(context)!.delete,
                  AppLocalizations.of(context)!.areYouSurefile);
              if (confirm!) {
                _controllerTodo.DeleteTodo(_controllerDB.headers(),
                    UserId: _controllerDB.user.value!.result!.id!,
                    TodoId: listOfGenericTodo.id);
                setState(() {
                  _todosResult.genericTodo!.removeWhere(
                      (element) => element.id == listOfGenericTodo.id);
                });
              }
            },
          )
        ],
      ),
    );
  }

  void _label(
    int noteId,
    List<LabelList> labelList,
  ) {
    bool _firtsrun = true;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (_firtsrun) {
              selectedLabelIndexes.clear();
              labelList.forEach((label) {
                cboLabelsList.asMap().forEach((index, availableLabel) {
                  if (availableLabel.key
                      .toString()
                      .contains(label.labelTitle.toString())) {
                    selectedLabelIndexes.add(index);
                    setState(() {});
                  }
                });
              });
              _firtsrun = false;
            }
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.selectLabel,
                ),
                content: Container(
                  height: Get.height * 0.06,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
                      SearchableDropdown.multiple(
                        items: cboLabelsList,
                        selectedItems: selectedLabelIndexes.toSet().toList(),
                        hint: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(AppLocalizations.of(context)!.labels),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedLabels.clear();

                            selectedLabelIndexes = value;

                            labelsList.asMap().forEach((index, value) {
                              selectedLabelIndexes
                                  .forEach((selectedLabelIndex) {
                                if (selectedLabelIndex == index) {
                                  selectedLabels.add(value.id!);
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
                          return (ElevatedButton(
                              onPressed: () {
                                Navigator.pop(doneContext);
                                setState(() {});
                              },
                              child: Text(AppLocalizations.of(context)!.save)));
                        },
                        closeButton: null,
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
                        iconDisabledColor: Colors.grey,
                        iconEnabledColor: Get.theme.colorScheme.surface,
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      InsertTodoLabelList(selectedLabels, noteId);
                      _todosResult.genericTodo!
                          .firstWhere((element) => element.id == noteId)
                          .labelList!
                          .clear();
                      labelsList.forEach((labelAll) {
                        selectedLabels.forEach((v) {
                          if (labelAll.id == v) {
                            _todosResult.genericTodo!
                                .firstWhere((element) => element.id == noteId)
                                .labelList!
                                .add(LabelList(
                                  labelTitle: labelAll.title,
                                  labelColor: labelAll.color,
                                ));
                          }
                        });
                      });

                      setState(() {
                        selectedLabels.clear();
                        selectedLabelIndexes.clear();
                      });

                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    ).then((value) => setState(() {
          selectedLabels.clear();
          selectedLabelIndexes.clear();
        }));
  }

  Future<void>? _checkList(
    int noteId,
  ) {
    bool _checked = false;
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.addCheckListItem,
                ),
                content: Container(
                  height: Get.height * 0.092,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: Get.width,
                        child: Padding(
                          padding: const EdgeInsets.only(),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _checked = !_checked;
                                  });
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1.0)),
                                  child: _checked
                                      ? Center(child: Icon(Icons.clear))
                                      : Container(),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                  child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: TextField(
                                  style: TextStyle(fontSize: 18),
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .addCheckListItem,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(),
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      if (_controller.text.isNotEmpty) {
                        await InsertOrUpdateTodoCheckList(
                                0, noteId, _controller.text, _checked)
                            .then((value) {
                          setState(() {
                            _todosResult.genericTodo!
                                .firstWhere((element) => element.id == noteId)
                                .checkList!
                                .checkListItem!
                                .add(CheckListItem(
                                    id: value.result!.id!,
                                    userId: value.result!.userId!,
                                    isDone: value.result!.isDone!,
                                    title: value.result!.title!,
                                    todoId: value.result!.todoId!));
                          });
                        });
                      }

                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    ).then((value) => setState(() {}));
    return null;
  }

  void _reminder(
    int noteId,
    String remindDate,
  ) {
    bool _checked = false;
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.addReminder,
                ),
                content: Container(
                  height: Get.height * 0.15,
                  width: Get.width,
                  child: Column(
                    children: <Widget>[
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
                                          DateFormat(
                                                  'EEE, MMM dd yyyy',
                                                  AppLocalizations.of(context)!
                                                      .date)
                                              .format(remindDate != null
                                                  ? DateTime.parse(remindDate)
                                                  : startDate == null
                                                      ? DateTime.now()
                                                      : startDate),
                                          textAlign: TextAlign.left),
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: startDate == null
                                              ? DateTime.now()
                                              : startDate,
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != startDate) {
                                          setState(() {
                                            startDate = picked!;
                                          });
                                        }
                                      }),
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      final TimeOfDay? time =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                  hour: DateTime.now().hour,
                                                  minute:
                                                      DateTime.now().minute));
                                      print(time);
                                      startDate = startDate.add(Duration(
                                          hours: time!.hour,
                                          minutes: time.hour));
                                    },
                                    child: Text(DateTime.now().hour.toString() +
                                        ":" +
                                        DateTime.now().minute.toString()))
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  DialogButton(
                    onPressed: () async {
                      UpdateNotes(noteId, ReminderDate: startDate);

                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]);
          },
        );
      },
    ).then((value) => setState(() {}));
  }

  void _editNote(GenericTodo genericTodo) {
    bool _firtsrun = true;
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) {
        _titleController = TextEditingController(text: genericTodo.content);
        _takenoteController = TextEditingController(
            text: genericTodo.description!.isNullOrBlank!
                ? " "
                : genericTodo.description!);
        if (_firtsrun) {
          selectedLabelIndexes.clear();
          genericTodo.labelList!.forEach((label) {
            cboLabelsList.asMap().forEach((index, availableLabel) {
              if (availableLabel.key
                  .toString()
                  .contains(label.labelTitle.toString())) {
                selectedLabelIndexes.add(index);
              }
            });
          });
          genericTodo.checkList!.checkListItem!.forEach((element) {
            _notesItems.add(noteItems(
                TextEditingController(text: element.title), element.isDone!));
          });
          _firtsrun = false;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              title: Text(
                AppLocalizations.of(context)!.edit +
                    " " +
                    AppLocalizations.of(context)!.note,
              ),
              contentPadding: EdgeInsets.all(10),
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              content: Container(
                height: Get.height * 0.55,
                width: Get.width,
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Visibility(
                              visible: !(Base64Image.isBlank!),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: MemoryImage(
                                            base64Decode(Base64Image))),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15))),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 25,
                              child: GestureDetector(
                                onTap: () {
                                  Base64Image = "";
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Get.theme.primaryColor,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.title,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              maxLines: null,
                            ),
                            Divider(),
                          ],
                        ),
                        TextField(
                          controller: _takenoteController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.takeANote,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.zero),
                          ),
                          maxLines: null,
                        ),
                        Column(
                          children: [
                            ListView.builder(
                                padding: EdgeInsets.only(top: 5),
                                shrinkWrap: true,
                                itemCount: _notesItems.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {
                                  return Container(
                                    width: Get.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 30,
                                        bottom: 5,
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _notesItems[i].checked =
                                                    !_notesItems[i].checked;
                                              });
                                            },
                                            child: Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                  border:
                                                      Border.all(width: 1.0)),
                                              child: _notesItems[i].checked
                                                  ? Container(
                                                      child: Icon(
                                                      Icons.clear,
                                                      size: 18,
                                                    ))
                                                  : Container(),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                              child: TextField(
                                            controller: _notesItems[i].text,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.zero),
                                            ),
                                          ))
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            ListView.builder(
                                padding: EdgeInsets.only(bottom: 5),
                                shrinkWrap: true,
                                itemCount: checkedItems.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {
                                  return Container(
                                    width: Get.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 30,
                                        bottom: 5,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1.0)),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                              child: TextField(
                                            controller: checkedItems[i].text,
                                            focusNode: checkedItems[i].focus,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.zero),
                                            ),
                                          ))
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            labelTapCheck
                                ? Container()
                                : SearchableDropdown.multiple(
                                    items: cboLabelsList,
                                    selectedItems:
                                        selectedLabelIndexes.toSet().toList(),
                                    hint: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Text(
                                          AppLocalizations.of(context)!.labels),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLabels.clear();
                                        selectedLabelIndexes = value;

                                        labelsList
                                            .asMap()
                                            .forEach((index, value) {
                                          selectedLabelIndexes
                                              .forEach((selectedLabelIndex) {
                                            if (selectedLabelIndex == index) {
                                              selectedLabels.add(value.id!);
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
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        margin: EdgeInsets.only(right: 5),
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 9),
                                        child: (Row(
                                          children: [
                                            Text(item
                                                .toString()
                                                .split("+")
                                                .first),
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
                                    doneButton:
                                        (selectedItemsDone, doneContext) {
                                      return (ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(doneContext);
                                            setState(() {});
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .save)));
                                    },
                                    closeButton: null,
                                    style: Get
                                        .theme.inputDecorationTheme.hintStyle,
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
                                                    .contains(
                                                        k.toLowerCase()))) {
                                              ret.add(i);
                                            }
                                            i++;
                                          });
                                        });
                                      }
                                      if (keyword.isEmpty) {
                                        ret =
                                            Iterable<int>.generate(items.length)
                                                .toList();
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
                                                  color: Colors.teal,
                                                  width: 0.0))),
                                    ),
                                    iconDisabledColor: Colors.grey,
                                    iconEnabledColor:
                                        Get.theme.colorScheme.surface,
                                    isExpanded: true,
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Tags(
                              itemCount: labelItems.length,
                              itemBuilder: (i) {
                                return ItemTags(
                                  alignment: MainAxisAlignment.start,
                                  index: i,
                                  title: labelItems[i],
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
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 5,
                                bottom: 15,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.notifications_active_outlined),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        int? fileUploadType;
                                        await selectUploadType(context).then(
                                            (value) => fileUploadType = value);
                                        if (fileUploadType == 0) {
                                          await _imgFromCamera();
                                          setState(() {});
                                        } else if (fileUploadType == 1) {
                                          await openFile();
                                          setState(() {});
                                        }
                                      },
                                      child: Icon(Icons.image_outlined)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (!checkedItems.isBlank!) {
                                        if (checkedItems
                                            .last.text.text.isEmpty) {
                                          return;
                                        }
                                      }

                                      setState(() {
                                        checkedItems.add(CheckedItem(
                                            TextEditingController(),
                                            false,
                                            FocusNode()));

                                        checkedItems.last.focus.requestFocus();
                                      });
                                    },
                                    child:
                                        Icon(Icons.playlist_add_check_outlined),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        labelTapCheck = !labelTapCheck;
                                      });
                                    },
                                    child: Icon(Icons.label_outlined),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Spacer(),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await UpdateNotes(genericTodo.id!,
                                            title: _titleController.text,
                                            description:
                                                _takenoteController.text);
                                        checkedItems.forEach((element) async {
                                          if (element.text.text.isNotEmpty) {
                                            await InsertOrUpdateTodoCheckList(
                                                0,
                                                genericTodo.id!,
                                                element.text.text,
                                                element.checked);
                                          }
                                        });
                                        for (int i = 0;
                                            i <
                                                genericTodo.checkList!
                                                    .checkListItem!.length;
                                            i++) {
                                          await InsertOrUpdateTodoCheckList(
                                              genericTodo.checkList!
                                                  .checkListItem![i].id!,
                                              genericTodo.id!,
                                              _notesItems[i].text.text.isEmpty
                                                  ? genericTodo.checkList!
                                                      .checkListItem![i].title!
                                                  : _notesItems[i].text.text,
                                              _notesItems[i].checked);
                                        }

                                        await InsertTodoLabelList(
                                            selectedLabels, genericTodo.id!);
                                        await GetNote();

                                        setState(() {
                                          _titleController.clear();
                                          _takenoteController.clear();
                                          Base64Image = "";
                                          checkedItems.clear();
                                          labelItems.clear();
                                          selectedLabels.clear();
                                          selectedLabelIndexes.clear();
                                        });
                                        Get.back();
                                      },
                                      child: Container(
                                        //     color: Colors.pink,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: primaryYellowColor,
                                            //Get.theme.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .done)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.delete_outlined),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((value) => setState(() {
          checkedItems.clear();
          _titleController.clear();
          _takenoteController.clear();
          selectedLabelIndexes.clear();
          labelItems.clear();
          _notesItems.clear();
        }));
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
    Base64Image = fileContent;
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
      Base64Image = fileContent;
      setState(() {});

      print('aaa');
    } catch (e) {}
  }

  InsertTodoLabelList(List<int> LabelIds, int TodoId) async {
    await _controllerLabel.InsertTodoLabelList(_controllerDB.headers(),
            TodoId: TodoId,
            LabelIds: LabelIds,
            UserId: _controllerDB.user.value!.result!.id!)
        .then((value) {});
  }
  /* 
  ConstrainedBox newMangel(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.yellow[50],
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Visibility(
                  visible: !(Base64Image.isBlank!),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: MemoryImage(base64Decode(Base64Image))),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 25,
                  child: GestureDetector(
                    onTap: () {
                      Base64Image = "";
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
                )
              ],
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: listExpand ? null : 0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: listExpand ? 3 : 0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.title,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    maxLines: null,
                  ),
                  Divider(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _takenoteController,
                focusNode: noteFocus,
                onTap: () {
                  setState(() {
                    if (!listExpand) {
                      listExpand = !listExpand;
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.takeANote,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.zero),
                ),
                maxLines: null,
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: listExpand ? null : 0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: listExpand ? 3 : 0),
              child: Column(
                children: [
                  ListView.builder(
                      padding: EdgeInsets.only(bottom: 5, top: 5),
                      shrinkWrap: true,
                      itemCount: checkedItems.length,
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
                                      checkedItems[i].checked =
                                          !checkedItems[i].checked;
                                    });
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 1.0)),
                                    child: checkedItems[i].checked
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
                                  controller: checkedItems[i].text,
                                  focusNode: checkedItems[i].focus,
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
                  labelTapCheck
                      ? Container()
                      : SearchableDropdown.multiple(
                          items: cboLabelsList,
                          selectedItems: selectedLabelIndexes.toSet().toList(),
                          hint: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(AppLocalizations.of(context)!.labels),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedLabels.clear();
                              selectedLabelIndexes = value;

                              labelsList.asMap().forEach((index, value) {
                                selectedLabelIndexes
                                    .forEach((selectedLabelIndex) {
                                  if (selectedLabelIndex == index) {
                                    selectedLabels.add(value.id!);
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
                            return (ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(doneContext);
                                  setState(() {});
                                },
                                child:
                                    Text(AppLocalizations.of(context)!.save)));
                          },
                          closeButton: null,
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
                              ret =
                                  Iterable<int>.generate(items.length).toList();
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
                          iconDisabledColor: Colors.grey,
                          iconEnabledColor: Get.theme.colorScheme.surface,
                          isExpanded: true,
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Tags(
                    itemCount: labelItems.length,
                    itemBuilder: (i) {
                      return ItemTags(
                        alignment: MainAxisAlignment.start,
                        index: i,
                        title: labelItems[i],
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
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 5,
                      bottom: 15,
                    ),
                    child: Row(
                      children: [
                        //? NOTIFICATION
                        CustomIconWithBackground(
                          color: Colors.transparent, //! color eklendi
                          onPressed: () {}, //! onPressed eklendi
                          iconName: 'notification',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        //? IMAGE
                        CustomIconWithBackground(
                          color: Colors.transparent, //! color eklendi

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
                          color: Colors.transparent, //! color eklendi

                          iconName: 'clipboard',
                          onPressed: () async {
                            if (!checkedItems.isBlank!) {
                              if (checkedItems.last.text.text.isEmpty) {
                                return;
                              }
                            }
                            setState(() {
                              checkedItems.add(CheckedItem(
                                  TextEditingController(), false, FocusNode()));
                              checkedItems.last.focus.requestFocus();
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        //? LABEL
                        CustomIconWithBackground(
                          color: Colors.transparent, //! color eklendi
                          iconName: 'label',
                          onPressed: () {
                            setState(() {
                              labelTapCheck = !labelTapCheck;
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Spacer(),
                        //? CHECK
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                noteFocus.unfocus();
                                _bottom.lockUI = true;
                                _bottom.update();
                                setState(() {
                                  listExpand = false;
                                });

                                await _controllerTodo.InsertCommonTodos(
                                        _controllerDB.headers(),
                                        UserId: _controllerDB
                                            .user.value!.result!.id!,
                                        ModuleType: 35,
                                        TodoName: _titleController.text,
                                        Description: _takenoteController.text,
                                        StartDate: DateTime.now(),
                                        EndDate: DateTime.now(),
                                        BackgroundImageBase64: Base64Image)
                                    .then((value) async {
                                  print(value);
                                  await InsertTodoLabelList(
                                      selectedLabels, value.result!.id!);
                                  checkedItems.forEach((element) async {
                                    await InsertOrUpdateTodoCheckList(
                                        0,
                                        value.result!.id!,
                                        element.text.text,
                                        element.checked);
                                  });
                                });
                                await GetNote();
                                _bottom.lockUI = false;
                                _bottom.update();

                                setState(() {
                                  listExpand = false;

                                  _titleController.clear();
                                  _takenoteController.clear();
                                  Base64Image = "";
                                  checkedItems.clear();
                                  labelItems.clear();
                                  selectedLabels.clear();
                                  selectedLabelIndexes.clear();
                                });
                              } catch (_) {
                                _bottom.lockUI = false;
                                _bottom.update();
                                setState(() {
                                  listExpand = false;
                                });
                              }
                            },
                            child: CustomIconWithBackground(
                              color: Colors.transparent, //! color eklendi
                              iconName: 'check',
                              onPressed: () {},
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        //? DELETE
                        CustomIconWithBackground(
                          color: Colors.transparent, //! color eklendi
                          iconName: 'delete',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 */
}

class noteItems {
  final TextEditingController text;
  bool checked;

  noteItems(this.text, this.checked);
}

class CheckedItem {
  final TextEditingController text;
  final FocusNode focus;
  bool checked;

  CheckedItem(this.text, this.checked, this.focus);
}
