import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:undede/Controller/ControllerBottomNavigationBar.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/Controller/ControllerTodo.dart';
import 'package:undede/Custom/DebouncerForSearch.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Custom/showModalYesOrNo.dart';
import 'package:undede/Pages/Camera/CameraPage.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/Pages/Private/PrivateCommon.dart';
import 'package:undede/Provider/LocaleProvider.dart';
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

class NotePage extends StatefulWidget {
  final int? collab;

  const NotePage({Key? key, this.collab}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with TickerProviderStateMixin {
  final ControllerLocal cL = Get.put(ControllerLocal());
  TextEditingController _titleController = TextEditingController();
  TextEditingController _takenoteController = TextEditingController();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerLabel _controllerLabel = Get.put(ControllerLabel());
  ControllerTodo _controllerTodo = Get.put(ControllerTodo());
  ControllerBottomNavigationBar _bottom =
      Get.put(ControllerBottomNavigationBar());
  GetGenericTodosResult _todosResult = GetGenericTodosResult(hasError: false);

  List<UserLabel> labelsList = [];
  final List<DropdownMenuItem> cboLabelsList = [];
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
  InsertTodoLabelList(List<int> LabelIds, int TodoId) async {
    await _controllerLabel.InsertTodoLabelList(_controllerDB.headers(),
            TodoId: TodoId,
            LabelIds: LabelIds,
            UserId: _controllerDB.user.value!.result!.id!)
        .then((value) {});
  }

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
        LabelIds: selectedLabelForSearch);

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
  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;
    return GetBuilder(
      builder: (ControllerTodo controller) {
        if (controller.refreshNote) {
          GetNote();
          controller.refreshNote = false;
        }
        return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          appBar: CustomAppBarWithSearch(
            title: AppLocalizations.of(context)!.note,
            onChanged: (value) {
              _debouncer.run(() {
                GetNote(search: value);
              });
            },
            isHomePage: true,
            openBoardFunction: () {},
            openFilterFunction: () {},
          ),
          body: isLoading
              ? CustomLoadingCircle()
              : SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        width: Get.width,
                        height: Get.height,
                        child: Column(
                          children: [
                            // widget.collab != null
                            //     ? Container()
                            // : Container(
                            //     width: Get.width,
                            //     height: isExpanded ? 160 : 115,
                            //     padding: EdgeInsets.only(
                            //       top: MediaQuery.of(context).padding.top,
                            //     ),
                            //     child: Container(
                            //       padding: showSearch
                            //           ? EdgeInsets.fromLTRB(20, 15, 20, 5)
                            //           : EdgeInsets.fromLTRB(20, 15, 20, 10),
                            //       child: Column(
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.center,
                            //         children: [
                            //           // Row(
                            //           //   mainAxisAlignment:
                            //           //       MainAxisAlignment.spaceBetween,
                            //           //   crossAxisAlignment:
                            //           //       CrossAxisAlignment.center,
                            //           //   children: [
                            //           //     showSearch
                            //           //         ? Flexible(
                            //           //             child: Row(
                            //           //               children: [
                            //           //                 Expanded(
                            //           //                   child: Container(
                            //           //                     height: 45,
                            //           //                     child: TextField(
                            //           //                       controller:
                            //           //                           _controller,
                            //           //                       style: TextStyle(
                            //           //                           color: Get
                            //           //                               .theme
                            //           //                               .primaryColor),
                            //           //                       onChanged:
                            //           //                           (as) async {
                            //           //                         _debouncer
                            //           //                             .run(() {
                            //           //                           GetNote(
                            //           //                               search:
                            //           //                                   as);
                            //           //                         });
                            //           //                       },
                            //           //                       decoration:
                            //           //                           InputDecoration(
                            //           //                         prefixIcon:
                            //           //                             Icon(
                            //           //                           Icons
                            //           //                               .search,
                            //           //                           color: Get
                            //           //                               .theme
                            //           //                               .primaryColor,
                            //           //                         ),
                            //           //                         labelText:
                            //           //                             AppLocalizations.of(
                            //           //                                     context)
                            //           //                                 .search,
                            //           //                         labelStyle: TextStyle(
                            //           //                             color: Get
                            //           //                                 .theme
                            //           //                                 .primaryColor),
                            //           //                         enabledBorder: OutlineInputBorder(
                            //           //                             borderSide: BorderSide(
                            //           //                                 color: Get
                            //           //                                     .theme
                            //           //                                     .primaryColor,
                            //           //                                 width:
                            //           //                                     0.7)),
                            //           //                         focusedBorder: OutlineInputBorder(
                            //           //                             borderSide: BorderSide(
                            //           //                                 color: Get
                            //           //                                     .theme
                            //           //                                     .primaryColor,
                            //           //                                 width:
                            //           //                                     0.7)),
                            //           //                       ),
                            //           //                     ),
                            //           //                   ),
                            //           //                 ),
                            //           //               ],
                            //           //             ),
                            //           //           )
                            //           //         : Flexible(
                            //           //             child: Row(
                            //           //               children: [
                            //           //                 GestureDetector(
                            //           //                     onTap: () {

                            //           //                     },
                            //           //                     child: Icon(
                            //           //                       Icons
                            //           //                           .arrow_back,
                            //           //                       color: Get.theme
                            //           //                           .primaryColor,
                            //           //                     )),
                            //           //                 SizedBox(
                            //           //                   width: 20,
                            //           //                 ),
                            //           //                 Flexible(
                            //           //                   child: Text(
                            //           //                     AppLocalizations.of(
                            //           //                             context)
                            //           //                         .note,
                            //           //                     overflow:
                            //           //                         TextOverflow
                            //           //                             .ellipsis,
                            //           //                     style: TextStyle(
                            //           //                         color: Get
                            //           //                             .theme
                            //           //                             .primaryColor,
                            //           //                         fontSize: 20,
                            //           //                         fontWeight:
                            //           //                             FontWeight
                            //           //                                 .w500),
                            //           //                   ),
                            //           //                 )
                            //           //               ],
                            //           //             ),
                            //           //           ),
                            //           //     Row(
                            //           //       children: [
                            //           //         InkWell(
                            //           //           onTap: () {
                            //           //             setState(() {
                            //           //               showSearch =
                            //           //                   !showSearch;
                            //           //             });
                            //           //           },
                            //           //           child: Container(
                            //           //             height: 40,
                            //           //             width: 40,
                            //           //             child: Icon(
                            //           //               Icons.search,
                            //           //               color: Get
                            //           //                   .theme.primaryColor,
                            //           //               size: 27,
                            //           //             ),
                            //           //           ),
                            //           //         ),
                            //           //         Container(
                            //           //           height: 40,
                            //           //           width: 40,
                            //           //           child: RotationTransition(
                            //           //             turns: Tween(
                            //           //                     begin: 0.0,
                            //           //                     end: 1.0)
                            //           //                 .animate(
                            //           //                     _controllerAnimation),
                            //           //             child:
                            //           //                 FloatingActionButton(
                            //           //                     onPressed: () {
                            //           //                       setState(() {
                            //           //                         if (isExpanded) {
                            //           //                           _controllerAnimation
                            //           //                             ..reverse(
                            //           //                                 from:
                            //           //                                     0.5);
                            //           //                           isExpanded =
                            //           //                               !isExpanded;
                            //           //                         } else {
                            //           //                           _controllerAnimation
                            //           //                             ..forward(
                            //           //                                 from:
                            //           //                                     0.0);

                            //           //                           isExpanded =
                            //           //                               !isExpanded;
                            //           //                         }
                            //           //                       });
                            //           //                     },
                            //           //                     child: Icon(Icons
                            //           //                         .expand_more)),
                            //           //           ),
                            //           //         ),
                            //           //       ],
                            //           //     ),
                            //           //   ],
                            //           // ),
                            //           SizedBox(
                            //             height: 50,
                            //           ),
                            //           AnimatedContainer(
                            //             duration:
                            //                 const Duration(milliseconds: 0),
                            //             width: Get.width,
                            //             height: isExpanded ? null : 0,
                            //             padding: EdgeInsets.symmetric(
                            //                 horizontal: 20),
                            //             child: SearchableDropdown.multiple(
                            //               items: cboLabelsList,
                            //               selectedItems:
                            //                   selectedLabelIndexesForSearch
                            //                       .toSet()
                            //                       .toList(),
                            //               hint: Padding(
                            //                 padding:
                            //                     const EdgeInsets.all(0.0),
                            //                 child: Text(
                            //                     AppLocalizations.of(context)
                            //                         .labels),
                            //               ),
                            //               onChanged: (value) async {
                            //                 setState(() {
                            //                   selectedLabelForSearch
                            //                       .clear();
                            //                   selectedLabelIndexesForSearch =
                            //                       value;
                            //                   for (int i = 0;
                            //                       i <
                            //                           selectedLabelIndexesForSearch
                            //                               .length;
                            //                       i++) {
                            //                     selectedLabelForSearch.add(
                            //                         labelsList[
                            //                                 selectedLabelIndexesForSearch[
                            //                                     i]]
                            //                             .id);
                            //                   }
                            //                 });
                            //                 await GetNote();
                            //               },
                            //               displayItem: (item, selected) {
                            //                 return (Row(children: [
                            //                   selected
                            //                       ? Icon(
                            //                           Icons.check,
                            //                           color: Colors.green,
                            //                         )
                            //                       : Icon(
                            //                           Icons
                            //                               .check_box_outline_blank,
                            //                           color: Colors.grey,
                            //                         ),
                            //                   SizedBox(width: 7),
                            //                   Expanded(
                            //                     child: item,
                            //                   ),
                            //                 ]));
                            //               },
                            //               selectedValueWidgetFn: (item) {
                            //                 return Container(
                            //                   decoration: BoxDecoration(
                            //                       color: Color(0xFFdedede),
                            //                       borderRadius:
                            //                           BorderRadius.circular(
                            //                               30)),
                            //                   margin:
                            //                       EdgeInsets.only(right: 5),
                            //                   padding: EdgeInsets.symmetric(
                            //                       horizontal: 9),
                            //                   child: (Row(
                            //                     children: [
                            //                       Text(item
                            //                           .toString()
                            //                           .split("+")
                            //                           .first),
                            //                       SizedBox(
                            //                         width: 5,
                            //                       ),
                            //                       Icon(
                            //                         Icons.lens,
                            //                         color: Color(int.parse(
                            //                             item
                            //                                 .toString()
                            //                                 .split("+")
                            //                                 .last
                            //                                 .replaceFirst(
                            //                                     '#', "FF"),
                            //                             radix: 16)),
                            //                       ),
                            //                     ],
                            //                   )),
                            //                 );
                            //               },
                            //               doneButton: (selectedItemsDone,
                            //                   doneContext) {
                            //                 return (ElevatedButton(
                            //                     onPressed: () {
                            //                       Navigator.pop(
                            //                           doneContext);
                            //                       setState(() {});
                            //                     },
                            //                     child: Text(
                            //                         AppLocalizations.of(
                            //                                 context)
                            //                             .save)));
                            //               },
                            //               closeButton: null,
                            //               style: Get
                            //                   .theme
                            //                   .inputDecorationTheme
                            //                   .hintStyle,
                            //               searchFn:
                            //                   (String keyword, items) {
                            //                 List<int> ret = List<int>();
                            //                 if (keyword != null &&
                            //                     items != null &&
                            //                     keyword.isNotEmpty) {
                            //                   keyword
                            //                       .split(" ")
                            //                       .forEach((k) {
                            //                     int i = 0;
                            //                     items.forEach((item) {
                            //                       if (k.isNotEmpty &&
                            //                           (item.value
                            //                               .toString()
                            //                               .toLowerCase()
                            //                               .contains(k
                            //                                   .toLowerCase()))) {
                            //                         ret.add(i);
                            //                       }
                            //                       i++;
                            //                     });
                            //                   });
                            //                 }
                            //                 if (keyword.isEmpty) {
                            //                   ret = Iterable<int>.generate(
                            //                           items.length)
                            //                       .toList();
                            //                 }
                            //                 return (ret);
                            //               },
                            //               //clearIcon: Icons(null), todo:nullable yap
                            //               icon: Icon(
                            //                 Icons.expand_more,
                            //                 size: 31,
                            //               ),
                            //               underline: Container(
                            //                 height: 0.0,
                            //                 decoration: BoxDecoration(
                            //                     border: Border(
                            //                         bottom: BorderSide(
                            //                             color: Colors.teal,
                            //                             width: 0.0))),
                            //               ),
                            //               iconDisabledColor: Colors.grey,
                            //               iconEnabledColor:
                            //                   Get.theme.backgroundColor,
                            //               isExpanded: true,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            Expanded(
                              child: Container(
                                width: Get.width,
                                child: Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: Get.theme.scaffoldBackgroundColor,
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 100),
                                        child: Column(
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(),
                                              child: Card(
                                                elevation: 1,
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
                                                                color: Colors
                                                                    .white,
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
                                            Expanded(
                                              child: GridView.builder(
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
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (listExpand) {
                                                            listExpand =
                                                                !listExpand;
                                                            noteFocus.unfocus();
                                                          } else if (!listExpand) {
                                                            _editNote(_todosResult
                                                                    .genericTodo![
                                                                index]);
                                                          }
                                                        });
                                                      },
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                45,
                                                            minHeight: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.1),
                                                        child: Card(
                                                          elevation: 1,
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
                                                                  vertical: 5),
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
                                                                    _todosResult
                                                                            .genericTodo![
                                                                                index]
                                                                            .checkList
                                                                            .isNullOrBlank!
                                                                        ? Container()
                                                                        : CheckLists(
                                                                            _todosResult.genericTodo![index].checkList!,
                                                                            _todosResult.genericTodo![index].id!),
                                                                    _todosResult
                                                                            .genericTodo![
                                                                                index]
                                                                            .labelList
                                                                            .isNullOrBlank!
                                                                        ? Container()
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
                                                      ),
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
                      // Positioned.fill(
                      //     top: widget.collab != null ? 999 : 999,
                      //     child: Container(
                      //       color: Colors.grey.withOpacity(0.5),
                      //       child: Center(
                      //           child: Text(
                      //         AppLocalizations.of(context).isComing,
                      //         style: TextStyle(
                      //             fontWeight: FontWeight.bold, fontSize: 50),
                      //       )),
                      //     ))
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
        top: 10,
        bottom: 5,
      ),
      child: Text(
        a,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
      ),
    );
  }

  Widget DescriptionWidget(String a) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 30,
        top: 5,
        bottom: 20,
      ),
      child: Text(
        a.isNullOrBlank! ? "" : a,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      ),
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
                : Colors.green,
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
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Get.theme.primaryColor,
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
