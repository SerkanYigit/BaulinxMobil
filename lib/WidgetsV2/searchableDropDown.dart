import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const EdgeInsetsGeometry _kAlignedButtonPadding =
    EdgeInsetsDirectional.only(start: 16.0, end: 4.0);
const EdgeInsets _kUnalignedButtonPadding = EdgeInsets.zero;

class NotGiven {
  const NotGiven();
}

Widget prepareWidget(
  dynamic object, {
  dynamic parameter = const NotGiven(),
  BuildContext? context,
  Function? stringToWidgetFunction,
}) {
  if (object == null) {
    return SizedBox.shrink();
  }
  if (object is Widget) {
    return (object);
  }
  if (object is String) {
    return stringToWidgetFunction != null
        ? (stringToWidgetFunction(object))
        : Text("");
  }
  if (object is Function) {
    if (parameter is NotGiven) {
      return (prepareWidget(object(context),
          stringToWidgetFunction: stringToWidgetFunction));
    }
    return (prepareWidget(object(parameter, context),
        stringToWidgetFunction: stringToWidgetFunction));
  }
  return (Text("Unknown type: ${object.runtimeType.toString()}"));
}

class SearchableDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Function? onChanged;
  final T? value;
  final TextStyle? style;
  final dynamic searchHint;
  final dynamic hint;
  final dynamic disabledHint;
  final dynamic icon;
  final dynamic underline;
  final dynamic doneButton;
  final dynamic label;
  final dynamic closeButton;
  final bool? displayClearIcon;
  final Icon? clearIcon;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? iconSize;
  final bool? isExpanded;
  final bool? isCaseSensitiveSearch;
  final Function? searchFn;
  final Function? onClear;
  final Function? selectedValueWidgetFn;
  final TextInputType? keyboardType;
  final Function? validator;
  final bool? multipleSelection;
  final List<int>? selectedItems;
  final Function? displayItem;
  final bool? dialogBox;
  final BoxConstraints? menuConstraints;
  final bool? readOnly;
  final Color? menuBackgroundColor;
  final Color? color;
  final double? height;

  /// Search choices Widget with a single choice that opens a dialog or a menu to let the user do the selection conveniently with a search.
  ///
  /// @param items with __child__: [Widget] displayed ; __value__: any object with .toString() used to match search keyword.
  /// @param onChanged [Function] with parameter: __value__ not returning executed after the selection is done.
  /// @param value value to be preselected.
  /// @param style used for the hint if it is given is [String].
  /// @param searchHint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed at the top of the search dialog box.
  /// @param hint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed before any value is selected or after the selection is cleared.
  /// @param disabledHint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed instead of hint when the widget is displayed.
  /// @param icon [String]|[Widget]|[Function] with parameter: __value__ returning [String]|[Widget] displayed next to the selected item or the hint if none.
  /// @param underline [String]|[Widget]|[Function] with parameter: __value__ returning [String]|[Widget] displayed below the selected item or the hint if none.
  /// @param doneButton [String]|[Widget]|[Function] with parameter: __value__ returning [String]|[Widget] displayed at the top of the search dialog box.
  /// @param label [String]|[Widget]|[Function] with parameter: __value__ returning [String]|[Widget] displayed above the selected item or the hint if none.
  /// @param closeButton [String]|[Widget]|[Function] with parameter: __value__ returning [String]|[Widget] displayed at the bottom of the search dialog box.
  /// @param displayClearIcon whether or not to display an icon to clear the selected value.
  /// @param clearIcon [Icon] to be used for clearing the selected value.
  /// @param iconEnabledColor [Color] to be used for enabled icons.
  /// @param iconDisabledColor [Color] to be used for disabled icons.
  /// @param iconSize for the icons next to the selected value (icon and clearIcon).
  /// @param isExpanded can be necessary to avoid pixel overflows (zebra symptom).
  /// @param isCaseSensitiveSearch only used when searchFn is not specified.
  /// @param searchFn [Function] with parameters: __keyword__, __items__ returning [List<int>] as the list of indexes for the items to be displayed.
  /// @param onClear [Function] with no parameter not returning executed when the clear icon is tapped.
  /// @param selectedValueWidgetFn [Function] with parameter: __item__ returning [Widget] to be used to display the selected value.
  /// @param keyboardType used for the search.
  /// @param validator [Function] with parameter: __value__ returning [String] displayed below selected value when not valid and null when valid.
  /// @param assertUniqueValue whether to run a consistency check of the list of items.
  /// @param displayItem [Function] with parameters: __item__, __selected__ returning [Widget] to be displayed in the search list.
  /// @param dialogBox whether the search should be displayed as a dialog box or as a menu below the selected value if any.
  /// @param menuConstraints [BoxConstraints] used to define the zone where to display the search menu. Example: BoxConstraints.tight(Size.fromHeight(250)) . Not to be used for dialogBox = true.
  /// @param readOnly [bool] whether to let the user choose the value to select or just present the selected value if any.
  /// @param menuBackgroundColor [Color] background color of the menu whether in dialog box or menu mode.
  factory SearchableDropdown.single({
    Key? key,
    required List<DropdownMenuItem<T>> items,
    required Function onChanged,
    T? value,
    TextStyle? style,
    dynamic searchHint,
    dynamic hint,
    dynamic disabledHint,
    dynamic icon = const Icon(Icons.arrow_drop_down),
    dynamic underline,
    dynamic doneButton,
    dynamic label,
    dynamic closeButton = "Close",
    bool displayClearIcon = true,
    Icon clearIcon = const Icon(Icons.clear),
    Color? iconEnabledColor,
    Color? iconDisabledColor,
    double iconSize = 24.0,
    bool isExpanded = false,
    bool isCaseSensitiveSearch = false,
    Function? searchFn,
    Function? onClear,
    Function? selectedValueWidgetFn,
    TextInputType keyboardType = TextInputType.text,
    Function? validator,
    bool assertUniqueValue = true,
    Function? displayItem,
    bool dialogBox = true,
    BoxConstraints? menuConstraints,
    bool readOnly = false,
    Color? color,
    Color? menuBackgroundColor,
    double? height,
  }) {
    return (SearchableDropdown._(
      key: key,
      items: items,
      onChanged: onChanged,
      value: value,
      style: style,
      searchHint: searchHint,
      hint: hint,
      disabledHint: disabledHint,
      icon: icon,
      underline: underline,
      iconEnabledColor: iconEnabledColor,
      iconDisabledColor: iconDisabledColor,
      iconSize: iconSize,
      isExpanded: isExpanded,
      isCaseSensitiveSearch: isCaseSensitiveSearch,
      closeButton: closeButton,
      displayClearIcon: displayClearIcon,
      clearIcon: clearIcon,
      onClear: onClear,
      selectedValueWidgetFn: selectedValueWidgetFn,
      keyboardType: keyboardType,
      validator: validator,
      label: label,
      searchFn: searchFn,
      multipleSelection: false,
      doneButton: doneButton,
      displayItem: displayItem,
      dialogBox: dialogBox,
      menuConstraints: menuConstraints,
      readOnly: readOnly,
      menuBackgroundColor: menuBackgroundColor,
      color: color,
      height: height,
    ));
  }

  /// Search choices Widget with a multiple choice that opens a dialog or a menu to let the user do the selection conveniently with a search.
  ///
  /// @param items with __child__: [Widget] displayed ; __value__: any object with .toString() used to match search keyword.
  /// @param onChanged [Function] with parameter: __selectedItems__ not returning executed after the selection is done.
  /// @param selectedItems indexes of items to be preselected.
  /// @param style used for the hint if it is given is [String].
  /// @param searchHint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed at the top of the search dialog box.
  /// @param hint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed before any value is selected or after the selection is cleared.
  /// @param disabledHint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed instead of hint when the widget is displayed.
  /// @param icon [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed next to the selected items or the hint if none.
  /// @param underline [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed below the selected items or the hint if none.
  /// @param doneButton [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed at the top of the search dialog box. Cannot be null in multiple selection mode.
  /// @param label [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed above the selected items or the hint if none.
  /// @param closeButton [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed at the bottom of the search dialog box.
  /// @param displayClearIcon whether or not to display an icon to clear the selected values.
  /// @param clearIcon [Icon] to be used for clearing the selected values.
  /// @param iconEnabledColor [Color] to be used for enabled icons.
  /// @param iconDisabledColor [Color] to be used for disabled icons.
  /// @param iconSize for the icons next to the selected values (icon and clearIcon).
  /// @param isExpanded can be necessary to avoid pixel overflows (zebra symptom).
  /// @param isCaseSensitiveSearch only used when searchFn is not specified.
  /// @param searchFn [Function] with parameters: __keyword__, __items__ returning [List<int>] as the list of indexes for the items to be displayed.
  /// @param onClear [Function] with no parameter not returning executed when the clear icon is tapped.
  /// @param selectedValueWidgetFn [Function] with parameter: __item__ returning [Widget] to be used to display the selected values.
  /// @param keyboardType used for the search.
  /// @param validator [Function] with parameter: __selectedItems__ returning [String] displayed below selected values when not valid and null when valid.
  /// @param displayItem [Function] with parameters: __item__, __selected__ returning [Widget] to be displayed in the search list.
  /// @param dialogBox whether the search should be displayed as a dialog box or as a menu below the selected values if any.
  /// @param menuConstraints [BoxConstraints] used to define the zone where to display the search menu. Example: BoxConstraints.tight(Size.fromHeight(250)) . Not to be used for dialogBox = true.
  /// @param readOnly [bool] whether to let the user choose the value to select or just present the selected value if any.
  /// @param menuBackgroundColor [Color] background color of the menu whether in dialog box or menu mode.
  factory SearchableDropdown.multiple({
    Key? key,
    required List<DropdownMenuItem<T>> items,
    required Function? onChanged,
    List<int> selectedItems = const [],
    TextStyle? style,
    dynamic searchHint,
    dynamic hint,
    dynamic disabledHint,
    dynamic icon = const Icon(Icons.expand_more),
    dynamic underline,
    dynamic doneButton = "Done",
    dynamic label,
    dynamic closeButton = "Close",
    bool displayClearIcon = true,
    Icon clearIcon = const Icon(Icons.clear),
    Color? iconEnabledColor,
    Color? iconDisabledColor,
    double iconSize = 24.0,
    bool isExpanded = false,
    bool isCaseSensitiveSearch = false,
    Function? searchFn,
    Function? onClear,
    Function? selectedValueWidgetFn,
    TextInputType keyboardType = TextInputType.text,
    Function? validator,
    Function? displayItem,
    bool dialogBox = true,
    BoxConstraints? menuConstraints,
    bool readOnly = false,
    Color? menuBackgroundColor,
  }) {
    return (SearchableDropdown._(
      key: key,
      items: items,
      style: style,
      searchHint: searchHint,
      hint: hint,
      disabledHint: disabledHint,
      icon: icon,
      underline: underline,
      iconEnabledColor: iconEnabledColor,
      iconDisabledColor: iconDisabledColor,
      iconSize: iconSize,
      isExpanded: isExpanded,
      isCaseSensitiveSearch: isCaseSensitiveSearch,
      closeButton: closeButton,
      displayClearIcon: displayClearIcon,
      clearIcon: clearIcon,
      onClear: onClear,
      selectedValueWidgetFn: selectedValueWidgetFn,
      keyboardType: keyboardType,
      validator: validator,
      label: label,
      searchFn: searchFn,
      multipleSelection: true,
      selectedItems: selectedItems,
      doneButton: doneButton,
      onChanged: onChanged,
      displayItem: displayItem,
      dialogBox: dialogBox,
      menuConstraints: menuConstraints,
      readOnly: readOnly,
      menuBackgroundColor: menuBackgroundColor,
    ));
  }

  SearchableDropdown._({
    Key? key,
    required this.items,
    required this.onChanged,
    this.value,
    this.style,
    this.searchHint,
    this.hint,
    this.disabledHint,
    this.icon,
    this.underline,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.iconSize = 24.0,
    this.isExpanded = false,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.displayClearIcon = true,
    this.clearIcon = const Icon(Icons.clear),
    this.onClear,
    this.selectedValueWidgetFn,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.label,
    this.searchFn,
    this.multipleSelection = false,
    this.selectedItems = const [],
    this.doneButton,
    this.displayItem,
    this.dialogBox,
    this.menuConstraints,
    this.readOnly = false,
    this.menuBackgroundColor,
    this.color,
    this.height,
  })  : assert(!multipleSelection! || doneButton != null),
        assert(dialogBox!),
        super(key: key);

  SearchableDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.value,
    this.style,
    this.searchHint,
    this.hint,
    this.disabledHint,
    this.icon = const Icon(Icons.arrow_drop_down),
    this.underline,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.iconSize = 24.0,
    this.isExpanded = false,
    this.isCaseSensitiveSearch = false,
    this.closeButton = "Close",
    this.displayClearIcon = false,
    this.clearIcon = const Icon(Icons.clear),
    this.onClear,
    this.selectedValueWidgetFn,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.label,
    this.searchFn,
    this.multipleSelection = false,
    this.selectedItems = const [],
    this.doneButton,
    this.displayItem,
    this.dialogBox = false, //! true yerine false yapildi
    this.menuConstraints,
    this.readOnly = false,
    this.menuBackgroundColor,
    this.color,
    this.height,
  })  : assert(!multipleSelection! || doneButton != null),
        assert(!dialogBox!),
        super(key: key);

  @override
  _SearchableDropdownState<T> createState() => new _SearchableDropdownState();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  List<int>? selectedItems;
  List<bool> displayMenu = [false];

  TextStyle? get _textStyle =>
      widget.style ??
      (_enabled && !(widget.readOnly ?? false)
          ? Theme.of(context).textTheme.titleMedium
          : Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: _disabledIconColor));

  bool get _enabled => widget.items.isNotEmpty;

  Color? get _enabledIconColor {
    return widget.iconEnabledColor;
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        return Colors.grey.shade700;
      case Brightness.dark:
        return Colors.white70;
    }
    return Colors.grey.shade700;
  }

  Color? get _disabledIconColor {
    return widget.iconDisabledColor;
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        return Colors.grey.shade400;
      case Brightness.dark:
        return Colors.white10;
    }
    return Colors.grey.shade400;
  }

  Color? get _iconColor {
    // These colors are not defined in the Material Design spec.
    return (_enabled && !(widget.readOnly ?? false)
        ? _enabledIconColor
        : _disabledIconColor);
  }

  bool? get valid {
    return (widget.validator == null //! sorgu eklendi
        ? false
        : widget.validator!(selectedResult) == null);
  }

  bool? get hasSelection {
    if (selectedItems != null) {
      return (selectedItems!.isNotEmpty);
    }
    return false;
  }

  dynamic get selectedResult {
    return (widget.multipleSelection!
        ? selectedItems
        : selectedItems?.isNotEmpty ?? false
            ? widget.items[selectedItems!.first].value
            : null);
  }

  int indexFromValue(T value) {
    return (widget.items.indexWhere((item) {
      return (item.value == value);
    }));
  }

  @override
  void initState() {
    if (widget.multipleSelection!) {
      selectedItems = List<int>.from(widget.selectedItems ?? []);
    } else if (widget.value != null) {
      int i = indexFromValue(widget.value!);
      if (i != -1) {
        selectedItems = [i];
      }
    }
    super.initState();
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget get menuWidget {
    return (DropdownDialog(
      items: widget.items,
      hint: prepareWidget(widget.searchHint),
      isCaseSensitiveSearch: widget.isCaseSensitiveSearch!,
      closeButton: AppLocalizations.of(context)!.close,
      keyboardType: widget.keyboardType,
      searchFn: widget.searchFn,
      multipleSelection: widget.multipleSelection,
      selectedItems: selectedItems,
      doneButton: AppLocalizations.of(context)!.done,
      displayItem: widget.displayItem,
      validator: widget.validator,
      dialogBox: widget.dialogBox,
      displayMenu: displayMenu,
      menuConstraints: widget.menuConstraints,
      menuBackgroundColor: widget.menuBackgroundColor,
      callOnPop: () {
        if (!widget.dialogBox!) {
          widget.onChanged!(selectedResult);
        }
        setState(() {});
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items =
        _enabled ? List<Widget>.from(widget.items) : <Widget>[];
    int? hintIndex;
    if (widget.hint != null || (!_enabled)) {
      final Widget emplacedHint = _enabled
          ? prepareWidget(widget.hint)
          : DropdownMenuItem<Widget>(
              child: prepareWidget(widget.disabledHint) ??
                  prepareWidget(widget.hint));
      hintIndex = items.length;
      items.add(DefaultTextStyle(
        style: _textStyle!.copyWith(color: Theme.of(context).hintColor),
        child: IgnorePointer(
          child: emplacedHint,
          ignoringSemantics: false,
        ),
      ));
    }
    Widget innerItemsWidget;
    List<Widget> list = <Widget>[];
    //! TODO:
    if (selectedItems != null) {
      selectedItems!.forEach((item) {
        list.add(widget.selectedValueWidgetFn != null
            ? widget.selectedValueWidgetFn!(widget.items[item].value)
            : items[item]);
      });
    }

    if (list.isEmpty) {
      innerItemsWidget = items[hintIndex!];
    } else {
      innerItemsWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 35,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: list,
            ),
          ),
        ),
      );
    }
    final EdgeInsetsGeometry padding = ButtonTheme.of(context).alignedDropdown
        ? _kAlignedButtonPadding
        : _kUnalignedButtonPadding;

    Widget clickable = InkWell(
        key: Key(
            "clickableResultPlaceHolder"), //this key is used for running automated tests
        onTap: (widget.readOnly ?? false) || !_enabled
            ? null
            : () async {
                if (widget.dialogBox!) {
                  await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return (menuWidget);
                      });
                  widget.onChanged!(selectedResult);
                } else {
                  displayMenu.first = true;
                }
                setState(() {});
              },
        child: Row(
          children: <Widget>[
            widget.isExpanded!
                ? Expanded(child: innerItemsWidget)
                : innerItemsWidget,
            IconTheme(
              data: IconThemeData(
                color: _iconColor,
                size: widget.iconSize,
              ),
              child: prepareWidget(widget.icon, parameter: selectedResult) ??
                  SizedBox.shrink(),
            ),
          ],
        ));

    Widget result = DefaultTextStyle(
      style: _textStyle!,
      child: Container(
        padding: padding.resolve(Directionality.of(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            widget.isExpanded! ? Expanded(child: clickable) : clickable,
            !widget.displayClearIcon!
                ? SizedBox()
                : InkWell(
                    onTap: hasSelection! && _enabled && !widget.readOnly!
                        ? () {
                            clearSelection();
                          }
                        : null,
                    child: Container(
                      padding: padding.resolve(Directionality.of(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconTheme(
                            data: IconThemeData(
                              color:
                                  hasSelection! && _enabled && !widget.readOnly!
                                      ? _enabledIconColor
                                      : _disabledIconColor,
                              size: widget.iconSize,
                            ),
                            child: widget.clearIcon ?? Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );

    final double bottom = 8.0;
    var validatorOutput;
    widget.validator == null
        ? CircularProgressIndicator(
            backgroundColor: Colors.pink,
          )
        : validatorOutput = widget.validator!(selectedResult);
    var labelOutput = prepareWidget(widget.label, parameter: selectedResult,
        stringToWidgetFunction: (string) {
      return (Text(string,
          style: TextStyle(color: Colors.blueAccent, fontSize: 13)));
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        labelOutput ?? SizedBox.shrink(),
        Container(
          width: Get.width,
          height: widget.height ?? 45,
          decoration: BoxDecoration(
            color: widget.color ?? Colors.white,
            boxShadow: standartCardShadow(),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: result,
          ),
        ),
        valid!
            ? SizedBox.shrink()
            : validatorOutput == null
                ? Container()
                : validatorOutput is String
                    ? Text(
                        validatorOutput,
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      )
                    : validatorOutput,
        displayMenu.first ? menuWidget : SizedBox.shrink(),
      ],
    );
  }

  clearSelection() {
    selectedItems!.clear();
    widget.onChanged!(selectedResult);
    widget.onClear;
    setState(() {});
  }
}

class DropdownDialog<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>>? items;
  final Widget? hint;
  final bool isCaseSensitiveSearch;
  final dynamic closeButton;
  final TextInputType? keyboardType;
  final Function? searchFn;
  final bool? multipleSelection;
  final List<int>? selectedItems;
  final Function? displayItem;
  final dynamic doneButton;
  final Function? validator;
  final bool? dialogBox;
  final List<bool>? displayMenu;
  final BoxConstraints? menuConstraints;
  final Function? callOnPop;
  final Color? menuBackgroundColor;

  DropdownDialog({
    Key? key,
    this.items,
    this.hint,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.keyboardType,
    this.searchFn,
    this.multipleSelection,
    this.selectedItems,
    this.displayItem,
    this.doneButton,
    this.validator,
    this.dialogBox,
    this.displayMenu,
    this.menuConstraints,
    this.callOnPop,
    this.menuBackgroundColor,
  }) : super(key: key);

  _DropdownDialogState<T> createState() => new _DropdownDialogState<T>();
}

class _DropdownDialogState<T> extends State<DropdownDialog> {
  TextEditingController txtSearch = new TextEditingController();
  TextStyle defaultButtonStyle =
      new TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  List<int?> shownIndexes = <int>[];
  Function searchFn = () {};

  _DropdownDialogState();

  dynamic get selectedResult {
    return (widget.multipleSelection!
        ? widget.selectedItems
        : widget.selectedItems!.isNotEmpty ?? false
            ? widget.items![widget.selectedItems!.first].value
            : null);
  }

  void _updateShownIndexes(String keyword) {
    print(searchFn);
    shownIndexes = searchFn(keyword, widget.items) ?? <int>[];
  }

  @override
  void initState() {
    searchFn = widget.searchFn!;
    print(searchFn);
    _updateShownIndexes('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: new Card(
        color: widget.menuBackgroundColor,
        margin: EdgeInsets.symmetric(
            vertical: widget.dialogBox! ? 10 : 5,
            horizontal: widget.dialogBox! ? 10 : 4),
        child: new Container(
          constraints: widget.menuConstraints ??
              BoxConstraints(), //! BoxConstraints() eklendi
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleBar(),
              searchBar(),
              list(),
              closeButtonWrapper(),
            ],
          ),
        ),
      ),
    );
  }

  bool get valid {
    if (widget.validator != null) {
      return (widget.validator!(selectedResult) == null);
    } else
      return false;
  }

  Widget titleBar() {
    var validatorOutput;
    validatorOutput = widget.validator != null
        ? widget.validator != null
            ? widget.validator
            : null
        : null;

    Widget validatorOutputWidget = valid
        ? SizedBox.shrink()
        : validatorOutput != null
            ? validatorOutput is String
                ? Text(
                    validatorOutput,
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  )
                : validatorOutput
            : Text("");
    Widget doneButtonWidget =
        widget.multipleSelection! || widget.doneButton != null
            ? prepareWidget(widget.doneButton,
                parameter: selectedResult,
                context: context, stringToWidgetFunction: (string) {
                return (ElevatedButton.icon(
                    onPressed: !valid
                        ? null
                        : () {
                            pop();
                            setState(() {});
                          },
                    icon: Icon(Icons.check),
                    label: Text(string)));
              })
            : SizedBox.shrink();
    return widget.hint != null
        ? new Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  prepareWidget(widget.hint),
                  Column(
                    children: <Widget>[doneButtonWidget, validatorOutputWidget],
                  ),
                ]),
          )
        : new Container(
            child: Column(
              children: <Widget>[doneButtonWidget, validatorOutputWidget],
            ),
          );
  }

  Widget searchBar() {
    return new Container(
      child: new Stack(
        children: <Widget>[
          new TextField(
            controller: txtSearch,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            autofocus: true,
            onChanged: (value) {
              _updateShownIndexes(value);
              setState(() {});
            },
            keyboardType: widget.keyboardType,
          ),
          new Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: new Center(
              child: new Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
          txtSearch.text.isNotEmpty
              ? new Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: new Center(
                    child: new InkWell(
                      onTap: () {
                        _updateShownIndexes('');
                        setState(() {
                          txtSearch.text = '';
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: new Container(
                        width: 32,
                        height: 32,
                        child: new Center(
                          child: new Icon(
                            Icons.close,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }

  pop() {
    if (widget.dialogBox!) {
      Navigator.pop(context);
    } else {
      widget.displayMenu!.first = false;
      widget.callOnPop!();
    }
  }

  Widget list() {
    return new Expanded(
      child: Scrollbar(
        child: new ListView.builder(
          itemBuilder: (context, index) {
            DropdownMenuItem item = widget.items![shownIndexes[index]!];
            return new InkWell(
              onTap: () {
                if (widget.multipleSelection!) {
                  setState(() {
                    if (widget.selectedItems!.contains(shownIndexes[index])) {
                      widget.selectedItems!.remove(shownIndexes[index]);
                    } else {
                      widget.selectedItems!.add(shownIndexes[index]!);
                    }
                  });
                } else {
                  widget.selectedItems!.clear();
                  widget.selectedItems!.add(shownIndexes[index]!);
                  if (widget.doneButton == null) {
                    pop();
                  } else {
                    setState(() {});
                  }
                }
              },
              child: widget.multipleSelection!
                  ? widget.displayItem == null
                      ? (Row(children: [
                          Icon(
                            widget.selectedItems!.contains(shownIndexes[index])
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Flexible(child: item),
                        ]))
                      : widget.displayItem!(item,
                          widget.selectedItems!.contains(shownIndexes[index]))
                  : widget.displayItem == null
                      ? item
                      : widget.displayItem!(item, item.value == selectedResult),
            );
          },
          itemCount: shownIndexes.length,
        ),
      ),
    );
  }

  Widget closeButtonWrapper() {
    return (prepareWidget(widget.closeButton, parameter: selectedResult,
            stringToWidgetFunction: (string) {
          return (Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    pop();
                  },
                  child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 2),
                      child: Text(
                        string,
                        style: defaultButtonStyle,
                        overflow: TextOverflow.ellipsis,
                      )),
                )
              ],
            ),
          ));
        }) ??
        SizedBox.shrink());
  }
}
