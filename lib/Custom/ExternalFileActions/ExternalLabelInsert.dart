import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFileView.dart';
import 'package:undede/Controller/ControllerLabel.dart';
import 'package:undede/WidgetsV2/searchableDropDown.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Label/GetLabelByUserId.dart';

ExternalLabelInsert(context) async {
  List<int> selectedLabels = [];
  List<int> selectedLabelIndexes = [];
  final List<DropdownMenuItem> cboLabelsList = [];
  List<UserLabel> labelsList = [];
  ControllerLabel controllerLabel = Get.put(ControllerLabel());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  List<int> FileIdList = [];
  List<int> selectedFileId = [];
  ControllerFileView _contFileView = Get.put(ControllerFileView());

  InsertFileListLabelList(List<int> FilesIds, List<int> LabelIds) async {
    bool hasError = await controllerLabel.InsertFileListLabelList(
        _controllerDB.headers(),
        UserId: _controllerDB.user.value!.result!.id,
        FilesIds: FilesIds,
        LabelIds: LabelIds);

    if (!hasError) {
      
    }
  }

  await controllerLabel.GetLabelByUserId(_controllerDB.headers(),
          Id: 0, CustomerId: 0)
      .then((value) {
    labelsList = value.result!;

    labelsList.forEach((label) {
      cboLabelsList.add(DropdownMenuItem(
          child: Row(
            children: [
              Text(label.title!),
              Icon(
                Icons.lens,
                color: Color(
                    int.parse(label.color!.replaceFirst('#', "FF"), radix: 16)),
              )
            ],
          ),
          key: Key(label.title.toString()),
          value: label.title! + "+" + label.color!));
    });
  });

  _contFileView.invoice!.todoLabels!.result!.forEach((label) {
    cboLabelsList.asMap().forEach((index, availableLabel) {
      if (availableLabel.key
          .toString()
          .contains(label.labelTitle.toString())) {
        selectedLabelIndexes.add(index);
      }
    });
  });

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.selectLabel,
              ),
              content: Container(
                height: Get.height * 0.15,
                width: Get.width,
                child: Column(
                  children: <Widget>[
                    SearchableDropdown.multiple(
                      items: cboLabelsList,
                      selectedItems: selectedLabelIndexes,
                      hint: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(AppLocalizations.of(context)!.labels),
                      ),
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
                      style: Get.theme.inputDecorationTheme.hintStyle!,
                      searchFn: (String keyword, items) {
                        List<int> ret = [];
                        if (items != null &&
                            keyword.isNotEmpty) {
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
                TextButton(
                  onPressed: () async {
                    InsertFileListLabelList(
                        _contFileView.invoice != null
                            ? selectedFileId
                            : FileIdList,
                        selectedLabels);
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
  );
}
