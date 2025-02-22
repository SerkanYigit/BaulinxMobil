import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Custom/showToast.dart';
import 'package:undede/Provider/LocaleProvider.dart';
import 'package:undede/Services/Search/SearchDB.dart';
import 'package:undede/model/Search/SearchResult.dart';

class ControllerGeneralSearch extends GetxController {
  String? searchText;
  DateTime? startDate ;
  DateTime? endDate ;
  bool? closeDate ;
  String selectedFileTypes = "";
  List<int> selectedLabels = [];
  int CustomerId = 0;
  int? ModuleType ;
  int OwnerId = 0;
  String Extension = "";
  bool isDetailInput = false;
  bool isListView = false;
  int page = 0;
  SearchDB _searchDb = new SearchDB();
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerLocal _controllerLocal = Get.put(ControllerLocal());

  Result? searchResult ;
  bool morePageExist = false;
  bool loadMore = false;
  ControllerGeneralSearch() {
    searchResult?.result
     ;
  }

  Future<void> GetSearchResult({
    String? searchText,
    int? CustomerId,
    int? ModuleType,
    int? OwnerId,
    List<int>? LabelIds,
    String? Extension,
    String? StartDate,
    String? EndDate,
  }) async {
    if (Extension == null &&
        StartDate == null &&
        EndDate == null &&
        ModuleType == null &&
        LabelIds!.length == 0) {
      if (searchText!.isBlank!) {
        print("burda");
        searchResult = new Result();
        searchResult!.result = [];
        update();

        return;
      }
    }

    if (page > 1) {
      loadMore = true;
      update();
    }

    await _searchDb.OCRSearch(_controllerDB.headers(),
            UserId: _controllerDB.user.value!.result!.id,
            CustomerId: CustomerId!,
            OwnerId: OwnerId!,
            LabelIds: LabelIds!,
            Extension:  Extension!.isEmpty
                    ? ""
                    : "." + Extension,
            StartDate: StartDate! == EndDate
            //! Burada ? sonra null vardi 
            ?  DateTime.now().toString().substring(0, 10)
            : StartDate,
            EndDate: EndDate! == StartDate   //! Burada ? sonra null vardi 
            ?  DateTime.now().toString().substring(0, 10): EndDate,
            Keyword: searchText!,
            ModuleType: ModuleType!,
            PageIndex: page)
        .then((value) {
      if (!value.hasError!) {
        if (searchResult!.totalCount == 0) {
          showToast(noItemsToShow()!);
        }

        if (page == 0) {
          searchResult = value.result;
        } else {
          searchResult!.result!.addAll(value.result!.result!);
          searchResult!.totalPage = value.result!.totalPage!;
          searchResult!.totalCount = value.result!.totalCount!;
        }

        if (value.result!.totalPage! > 1)
          morePageExist = true;
        else
          morePageExist = false;
        if (value.result!.result!.length == 0) morePageExist = false;
      } else {
        showToast("Error: " + value.resultMessage!);
      }
    });
    loadMore = false;
    update();
  }

  String langCode() =>
      _controllerLocal.locale?.value.languageCode ??
      Get.deviceLocale!.languageCode;
  String? noItemsToShow() {
    switch (langCode()) {
      case "en":
        return "No items to show";
      case "tr":
        return "Gösterilecek öğe yok";
      case "de":
        return "";
    }
  }
}
