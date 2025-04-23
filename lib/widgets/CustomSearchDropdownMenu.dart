//import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSearchDropDownMenu extends StatelessWidget {
  CustomSearchDropDownMenu(
      {this.list,
      this.labelText,
      this.onChanged,
      this.error,
      this.labelIconExist,
      this.labelIcon,
      this.labelHeader,
      required this.fillColor});

  final List<String>? list;
  final String? labelText;
  final String? error;
  final Function? onChanged;
  final String? labelHeader;
  final bool? labelIconExist;
  final IconData? labelIcon;
  Color fillColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.mediaQuery.size.shortestSide > 600
          ? Get.mediaQuery.size.longestSide / 20
          : Get.mediaQuery.size.longestSide / 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              // Text(
              //   labelText,
              //   style: TextStyle(
              //     fontSize: 11,
              //     fontWeight: FontWeight.w400,
              //     fontStyle: FontStyle.normal,
              //     color: Theme.of(context).cardColor == const Color(0xff1c1b1f)
              //         ? Colors.white
              //         : Colors.blue,
              //   ),
              // ),
              // labelIconExist ?? false
              //     ? Icon(labelIcon, color: Colors.red, size: 10)
              //     : Container(),
            ],
          ),
          /*      Expanded(
            child: DropdownSearch<String>(
              selectedItem: labelHeader,
              popupProps: PopupProps<String>.menu(
                searchDelay: const Duration(milliseconds: 0),
                showSearchBox: true,
                showSelectedItems: true,
                listViewProps: const ListViewProps(
                    scrollDirection: Axis.vertical, shrinkWrap: true),
                itemBuilder: (BuildContext context, String item,
                    bool isSelected, bool isFocused) {
                  return ListTile(
                    title: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.black : Colors.black),
                    ),
                  );
                },
                emptyBuilder: (BuildContext context, String item) {
                  return ListTile(
                    title: Text(
                      error!,
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  );
                },
              ),
               items: list,
              itemAsString: (item) => item,
              decoratorProps: DropDownDecoratorProps(
                baseStyle: TextStyle(color: Colors.black, fontSize: 13),
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintStyle: TextStyle(color: Colors.black, fontSize: 11),
                    isDense: false,
                    filled: true,
                    fillColor: fillColor,
                    focusColor: Colors.black,
                    labelText: labelIconExist ?? false ? '' : labelText,
                    labelStyle: TextStyle(color: Colors.black, fontSize: 11),
                    helperStyle: TextStyle(color: Colors.black, fontSize: 11),
                    border: const OutlineInputBorder(),
                    iconColor: Colors.grey,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 0.6,
                        )),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      gapPadding: 8.0,
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never),
              ),
              onChanged: (String? val) {
                onChanged!(val!);
              },
            ),
          ), */

          Expanded(
            child: DropdownSearch<String>(
              enabled: true,
              popupProps: PopupProps.bottomSheet(
                bottomSheetProps: BottomSheetProps(
                  backgroundColor: Color.fromARGB(255, 70, 135, 209),
                ),
                itemBuilder: (
                  BuildContext context,
                  String item,
                  bool isSelected,
                  bool isExpanded,
                ) {
                  return Container(
                    // color: Color.fromARGB(255, 184, 125, 22),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: !isSelected
                        ? null
                        : BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromARGB(
                                255, 202, 202, 198), //yazının arka rengi
                          ),
                    child: ListTile(
                      //tileColor: Color.fromARGB(255, 52, 138, 230),
                      selected: isSelected,
                      title: Center(
                          child: Text(
                        item,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      )),
                    ),
                  );
                },
                showSelectedItems: true,
                emptyBuilder: (BuildContext context, searchEntry) {
                  return Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Listede Veri Bulunamadı.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: (() => Navigator.of(context).pop()),
                            child: Text("Kapat"),
                          )
                        ],
                      ),
                    ),
                  );
                },
                // disabledItemFn: (String s) =>
                //     s.startsWith('I'),
              ),
              itemAsString: (item) => item,
              items: (f, cs) => list!,
              //  compareFn: (i, s) => i.isEqual(s),
              decoratorProps: DropDownDecoratorProps(
                textAlign: TextAlign.center,
                baseStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  floatingLabelAlignment: FloatingLabelAlignment.start,

                  floatingLabelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),

                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(13),
                    ),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.pink,
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

                  //   suffixIcon: Icon(Icons.abc),
                  //    icon: Icon(Icons.extension),
                  //   disabledBorder: InputBorder.none,
                  labelText: "Durumu",
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 21, 20, 20)),
                ),
              ),
              onChanged: ((value) {
                print(value);
              }),
              //  selectedItem: list!.first,
            ),
          ),
        ],
      ),
    );
  }
}
