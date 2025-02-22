import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerFiles.dart';
import 'package:undede/Custom/FileManagerType.dart';
import 'package:undede/Pages/Private/DirectoryDetail.dart';
import 'package:undede/Services/User/UserDB.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/headerWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:undede/model/Contact/AdminCustomer.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/widgets/MyCircularProgress.dart';

import '../../Custom/CustomLoadingCircle.dart';

class PrivatePage extends StatefulWidget {
  FileManagerType? fileManagerType;

  PrivatePage({
    @required this.fileManagerType,
  });

  @override
  _PrivatePageState createState() => _PrivatePageState();
}

class _PrivatePageState extends State<PrivatePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool isLoading = true;
  FileManagerType? selectedFileManagerType;
  CarouselController _carouselController = new CarouselController();
  CarouselSliderController _carouselSliderController = new CarouselSliderController();
  ControllerFiles _controllerFiles = Get.put(ControllerFiles());
  ControllerDB _controllerDB = Get.put(ControllerDB());
  UserDB userDB = new UserDB();
  AdminCustomerResult customerResultForSalary = new AdminCustomerResult(hasError: false);
  AdminCustomerResult customerResultForReport = new AdminCustomerResult(hasError: false);

  BuildContext? partialContext;

  int? salarySelectedItem;
  final List<DropdownMenuItem> salaryItems = [];
  int? reportSelectedItem;
  final List<DropdownMenuItem> reportItems = [];

  List<bool> openMenuAnimateValue = [];
  FilesForDirectoryData _files = new FilesForDirectoryData();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      selectedFileManagerType = widget.fileManagerType;

      // contact sayfasında da var contactleri çekiyor. --- for salary
      await userDB.GetAdminCustomer(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id,
        administrationId: _controllerDB.user.value!.result!.administrationId,
      ).then((value) {
        customerResultForSalary = value;

        customerResultForSalary.result!.asMap().forEach((index, customer) {
          salaryItems.add(DropdownMenuItem(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: Image.network(
                    customer.photo ??
                        'http://test.vir2ell-office.com/Content/cardpicture/userDefault.png',
                    width: 21,
                    height: 21,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(customer.title!),
              ],
            ),
            value: customer.id,
          ));
        });

        if (salaryItems.isNotEmpty) {
          salarySelectedItem = salaryItems.first.value;
        }
            });

      // contact sayfasında da var contactleri çekiyor.
      await userDB.GetAdminCustomer(
        _controllerDB.headers(),
        userId: _controllerDB.user.value!.result!.id,
        administrationId: _controllerDB.user.value!.result!.administrationId,
      ).then((value) {
        customerResultForReport = value;

        customerResultForReport.result!.asMap().forEach((index, customer) {
          reportItems.add(DropdownMenuItem(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: Image.network(
                    customer.photo ??
                        'http://test.vir2ell-office.com/Content/cardpicture/userDefault.png',
                    width: 21,
                    height: 21,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(customer.title!),
              ],
            ),
            value: customer.id,
          ));
        });

        if (reportItems.isNotEmpty) {
          reportSelectedItem = reportItems.first.value;
        }
            });

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CustomLoadingCircle()
        : Scaffold(
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            appBar:
                CustomAppBar(title: AppLocalizations.of(context)!.privateCloud),
            body: Container(
              width: Get.width,
              height: Get.height,
              child: Column(
                children: [
                  Container(
                    width: Get.width,
                    height: 110,
                    decoration: BoxDecoration(),
                    child: CarouselSlider(
                      carouselController: _carouselSliderController,
                      items: [
                        //CarousalCard('Salary', FileManagerType.Salary),
                        CarousalCard(AppLocalizations.of(context)!.privateCloud,
                            FileManagerType.PrivateDocument, 0),
                        //CarousalCard('Report', FileManagerType.Report),
                        CarousalCard(AppLocalizations.of(context)!.myPicture,
                            FileManagerType.PrivateDocument, 1),
                      ],
                      options: CarouselOptions(
                        initialPage: getPageByFileManagerType(),
                        onPageChanged: (i, reason) {
                          reloadDirectoryDetail(i, FileManagerType.PrivateDocument);
                          //! null yerine FileManagerType.PrivateDocument kullanildi
                        },
                        pageSnapping: true,
                        height: 90,
                        aspectRatio: 4 / 3,
                        viewportFraction: 0.83,
                        enableInfiniteScroll: false,
                        reverse: false,
                        autoPlay: false,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: WillPopScope(
                            onWillPop: () async {
                              _closeMoveAndCopyActions();
                              return true;
                            },
                            child: Navigator(
                              key: _navigatorKey,
                              onGenerateRoute: (RouteSettings settings) {
                                WidgetBuilder builder;
                                print(settings.name);

                                /*switch(settings.name){
          case 'primary/pageone' :
            builder = (BuildContext _) => PrimaryOneScreen();
            break;
          case 'primary/pagetwo' :
            builder = (BuildContext _) => PrimaryTwoScreen();
            break;
          case 'primary/pagethree' :
            builder = (BuildContext _) => PrimaryThreeScreen();
            break;
          default :
            throw Exception('Invalid route: ${settings.name}');
        }*/
                                return MaterialPageRoute(
                                  builder: (context) => DirectoryDetail(
                                    folderName: "",
                                    hideHeader: true,
                                    fileManagerType: selectedFileManagerType,
                                    todoId: null,
                                  ),
                                );
                              },
                            ))),
                  ),
                ],
              ),
            ),
          );
  }

  void _closeMoveAndCopyActions() {
    _controllerFiles.isCopyActionActive = false;
    _controllerFiles.isMoveActionActive = false;
    _controllerFiles.sourceModuleTypeId = null;
    _controllerFiles.sourceDirectory = null;
    _controllerFiles.FileIdList = [];
    _controllerFiles.SourceDirectoryNameList = [];
  }

  void reloadDirectoryDetail(int page, FileManagerType fType) {
    setState(() {
      selectedFileManagerType = getFileManagerByPage(page);
    
      print('reloadDirectoryDetail çağırıldı.');
      //print(getSelectedCustomerByFileManagerType(selectedFileManagerType));
      //Customer selectedCustomer = getSelectedCustomerByFileManagerType(selectedFileManagerType);

      _navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
        builder: (context) => DirectoryDetail(
          folderName: page == 1 ? 'Picture' : '',
          //userId: selectedCustomer.customerAdminId ?? selectedCustomer.id,
          hideHeader: true,
          fileManagerType: selectedFileManagerType,
          todoId: null,
          //customerId: fType != null ? selectedCustomer.id : null
        ),
      ));
    });
  }

  final _navigatorKey = GlobalKey<NavigatorState>();

  Container CarousalCard(String title, FileManagerType fType, int Type) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: Container(
        width: Get.width,
        height: 135,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 22),
        decoration: BoxDecoration(
          color: Type == 1 ? Colors.white : Colors.white.withOpacity(0.15),
          gradient: LinearGradient(
              colors: [
                Type == 1 ? Color(0xFFFFBE2C) : Color(0xFF3366FF),
                Type == 1 ? Color(0xFFf9b51b) : Color(0xFF00CCFF),
              ],
              begin: const FractionalOffset(0.0, 1.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            /*fType != FileManagerType.PrivateDocument ?
            SearchableDropdown.single(
              displayClearIcon: false,
              menuBackgroundColor: Get.theme.scaffoldBackgroundColor,
              items: getItemsByFileManagerType(fType),
              value: getSelectedItemByFileManagerType(fType),
              hint: "Select one",
              searchHint: "Select one",
              onChanged: (value) {
                setState(() {
                  if (fType == FileManagerType.Salary)
                    salarySelectedItem = value;
                  else if (fType == FileManagerType.Report)
                    reportSelectedItem = value;
                });

                reloadDirectoryDetail(null, fType);
              },
              doneButton: "Done",
              displayItem: (item, selected) {
                return (Row(children: [
                  selected
                      ? Icon(
                          Icons.radio_button_checked,
                          color: Colors.grey,
                        )
                      : Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey,
                        ),
                  SizedBox(width: 7),
                  Expanded(
                    child: item,
                  ),
                ]));
              },
              isExpanded: true,
            ) : Container(),*/
          ],
        ),
      ),
    );
  }

  // salary   0
  // private  1
  // report   2
  int getPageByFileManagerType() {
    return 0;
    if (widget.fileManagerType == FileManagerType.Salary)
      return 0;
    else if (widget.fileManagerType == FileManagerType.PrivateDocument)
      return 1;
    else if (widget.fileManagerType == FileManagerType.Report)
      return 2;
    else
      return 0;
  }

  FileManagerType getFileManagerByPage(int page) {
    return FileManagerType.PrivateDocument;
    if (page == 0)
      return FileManagerType.Salary;
    else if (page == 1)
      return FileManagerType.PrivateDocument;
    else if (page == 2)
      return FileManagerType.Report;
    else
      return FileManagerType.Salary;
  }

  /*getSelectedItemByFileManagerType(FileManagerType fType) {
    if (fType == FileManagerType.Salary)
      return salarySelectedItem;
    else if (fType == FileManagerType.Report)
      return reportSelectedItem;
  }

  List<DropdownMenuItem> getItemsByFileManagerType(FileManagerType fType) {
    if (fType == FileManagerType.Salary)
      return salaryItems;
    else if (fType == FileManagerType.Report)
      return reportItems;
  }

  Customer getSelectedCustomerByFileManagerType(FileManagerType fType) {
    if (fType == FileManagerType.Salary)
      return customerResultForSalary.result.firstWhere((x) => x.id == salarySelectedItem);
    else if (fType == FileManagerType.Report)
      return customerResultForReport.result.firstWhere((x) => x.id == reportSelectedItem);
    else
      return null;
  }*/

  getBgImageByFileManagerType(FileManagerType fType) {
    if (fType == FileManagerType.Salary)
      return NetworkImage(
          'http://test.vir2ell-office.com/Content/cardpicture/filemanager/salary.png');
    else if (fType == FileManagerType.Report)
      return NetworkImage(
          'http://test.vir2ell-office.com/Content/cardpicture/filemanager/report.png');
    else if (fType == FileManagerType.PrivateDocument)
      return NetworkImage(
          'http://test.vir2ell-office.com/Content/cardpicture/filemanager/private.png');
  }
}
