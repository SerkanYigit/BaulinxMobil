import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:undede/Controller/ControllerDB.dart';
import 'package:undede/Controller/ControllerInvoice.dart';
import 'package:undede/WidgetsV2/CustomAppBar.dart';
import 'package:undede/WidgetsV2/customCardShadow.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvoiceStatistic extends StatefulWidget {
  final int? customerId;
  const InvoiceStatistic({Key? key, this.customerId}) : super(key: key);

  @override
  State<InvoiceStatistic> createState() => _InvoiceStatisticState();
}

class _InvoiceStatisticState extends State<InvoiceStatistic> {
  ControllerDB _controllerDB = Get.put(ControllerDB());
  ControllerInvoice _controllerInvoice = Get.put(ControllerInvoice());

  final List<DropdownMenuItem> dmiPersons = [];
  int? selectedPerson;

  List<SalesData> chartsData = [];

  Map<DateTime, int> buildingChartsData = {};

  // Chart load
  ChartSeriesController? seriesController;
  bool isLoadMoreView = false, isNeedToUpdateView = false, isDataUpdated = false;
  double? oldAxisVisibleMin, oldAxisVisibleMax;
  ZoomPanBehavior? _zoomPanBehavior;
  GlobalKey<State>? globalKey;
  double totalAmountIncomeUnpaid = 0;
  double totalAmountOutgoingUnpaid = 0;
  double totalAmountOutgoingpaid = 0;
  double totalAmountIncomepaid = 0;
  double totalKdv = 0;
  double totalKdvPaid = 0;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fillData(widget.customerId!);
      setState(() {});
    });

    super.initState();
  }

  Future<void> fillData(int selectedPerson) async {
    setState(() {
      chartsData.clear();
      totalAmountIncomeUnpaid = 0;
      totalAmountOutgoingUnpaid = 0;
      totalAmountOutgoingpaid = 0;
      totalAmountIncomepaid = 0;
      totalKdv = 0;
      totalKdvPaid = 0;
    });
    for (int i = 1; i <= 12; i++) {
      await _controllerInvoice.GetInvoiceList(_controllerDB.headers(),
              userId: selectedPerson,
              year: DateTime.now().year,
              month: i,
              page: 0,
              size: 999)
          .then((value) {
        print(DateTime.utc(DateTime.now().year, i));
        chartsData.add(SalesData(
            dateToStringForCharts(DateTime.utc(DateTime.now().year, i)),
            value.result!.invoiceSummary!.totalAmount != null
                ? value.result!.invoiceSummary!.totalAmount!
                : 00.0));

        setState(() {});
      });
    }
    await _controllerInvoice.GetInvoiceSummaryAll(
      _controllerDB.headers(),
      userId: selectedPerson,
      year: 2022,
      month: 12,
    ).then((value) {
      totalAmountIncomeUnpaid +=
          value.result!.invoiceSummariesIncomeUnPaid1Summary!.totalAmount ?? 0.0;
      totalAmountOutgoingUnpaid +=
          value.result!.invoiceSummariesOutGoingUnPaid3Summary!.totalAmount ??
              0.0;
      totalAmountOutgoingpaid +=
          value.result!.invoiceSummariesOutGoingPaid4Summary!.totalAmount ?? 0.0;
      totalAmountIncomepaid +=
          value.result!.invoiceSummariesIncomePaid2Summary!.totalAmount ?? 0.0;
      totalKdv +=
          value.result!.invoiceSummariesIncomeUnPaid1Summary!.totalTax ?? 0.0;
      totalKdv +=
          value.result!.invoiceSummariesOutGoingUnPaid3Summary!.totalTax ?? 0.0;
      totalKdv +=
          value.result!.invoiceSummariesOutGoingPaid4Summary!.totalTax ?? 0.0;

      totalKdv +=
          value.result!.invoiceSummariesIncomePaid2Summary!.totalTax ?? 0.0;
      totalKdvPaid +=
          value.result!.invoiceSummariesIncomePaid2Summary!.totalTax ?? 0.0;
      totalKdvPaid +=
          value.result!.invoiceSummariesOutGoingPaid4Summary!.totalTax ?? 0.0;
      setState(() {});
    });
  }

  String dateToStringForCharts(DateTime time) {
    return "${DateFormat.MMM(AppLocalizations.of(context)!.date).format(time)}";
  }

  @override
  Widget build(BuildContext context) {
    print(chartsData);
    return Scaffold(
      body: Column(
        children: [
          Container(
              height: Get.height * 0.3,
              width: Get.width,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: 
              SfCartesianChart(
                  primaryXAxis:
                   CategoryAxis(
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    initialVisibleMinimum: 0,
                    labelIntersectAction: AxisLabelIntersectAction.hide,
                    initialVisibleMaximum: 6,
                  ),
                  primaryYAxis: NumericAxis(isVisible: false),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                  ),
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                  ),
                  series: <CartesianSeries<SalesData, String>>[
                    ColumnSeries<SalesData, String>(
                        dataSource: chartsData,
                        color: Get.theme.primaryColor.withOpacity(0.3),
                        borderColor: Get.theme.primaryColor.withOpacity(1),
                        borderWidth: 2,
                        xValueMapper: (SalesData sales, _) => sales.year,
                        yValueMapper: (SalesData sales, _) => sales.sales,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)))
                  ])),
          /*
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    moneyCreater(
                        context,
                        totalAmountIncomeUnpaid.toStringAsFixed(2),
                        "Gelen Ödenmemiş",
                        1),
                    moneyCreater(
                        context,
                        totalAmountOutgoingUnpaid.toStringAsFixed(2),
                        "Gelen Ödenmiş",
                        2),
                    moneyCreater(
                        context,
                        (totalAmountIncomeUnpaid - totalAmountOutgoingUnpaid)
                            .toStringAsFixed(2),
                        "Gelen Toplam",
                        4),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    moneyCreater(
                        context,
                        totalAmountOutgoingpaid.toStringAsFixed(2),
                        "Giden Ödenmemiş",
                        1),
                    moneyCreater(
                        context,
                        totalAmountIncomepaid.toStringAsFixed(2),
                        "Giden Ödenmiş",
                        2),
                    moneyCreater(
                        context,
                        (totalAmountIncomepaid - totalAmountOutgoingpaid)
                            .toStringAsFixed(2),
                        "Giden Toplam",
                        4),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    moneyCreater(
                        context, totalKdv.toStringAsFixed(2), "KDV Toplam", 3),
                    moneyCreater(context, totalKdvPaid.toStringAsFixed(2),
                        "KDV Ödeme", 3),
                    moneyCreater(
                        context,
                        (totalKdv - totalKdvPaid).toStringAsFixed(2),
                        "VERGI TOPLAM",
                        3),
                  ],
                ),
              ],
            ),
          ),

           */
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 30),
              children: [
                moneyCreater(
                    context,
                    totalAmountIncomeUnpaid.toStringAsFixed(2),
                    "Gelen Ödenmemiş",
                    1,
                    1),
                moneyCreater(
                    context,
                    totalAmountOutgoingUnpaid.toStringAsFixed(2),
                    "Gelen Ödenmiş",
                    2,
                    1),
                moneyCreater(
                    context,
                    (totalAmountIncomeUnpaid - totalAmountOutgoingUnpaid)
                        .toStringAsFixed(2),
                    "Gelen Toplam",
                    4,
                    1),
                Divider(),
                moneyCreater(
                    context,
                    totalAmountOutgoingpaid.toStringAsFixed(2),
                    "Giden Ödenmemiş",
                    1,
                    2),
                moneyCreater(context, totalAmountIncomepaid.toStringAsFixed(2),
                    "Giden Ödenmiş", 2, 2),
                moneyCreater(
                    context,
                    (totalAmountIncomepaid - totalAmountOutgoingpaid)
                        .toStringAsFixed(2),
                    "Giden Toplam",
                    4,
                    2),
                Divider(),
                moneyCreater(
                    context, totalKdv.toStringAsFixed(2), "KDV Toplam", 3, 3),
                moneyCreater(context, totalKdvPaid.toStringAsFixed(2),
                    "KDV Ödeme", 3, 3),
                moneyCreater(
                    context,
                    (totalKdv - totalKdvPaid).toStringAsFixed(2),
                    "VERGI TOPLAM",
                    3,
                    3),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget moneyCreater(BuildContext context, String money, String typeName,
      int type, int paymentType) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: type == 1
                    ? Colors.red
                    : type == 2
                        ? Colors.green
                        : type == 3
                            ? Colors.amber
                            : Colors.blueAccent,
                borderRadius: BorderRadius.circular(10)),
            child: paymentType == 1
                ? FaIcon(
                    FontAwesomeIcons.fileArrowUp,
                    color: Colors.white,
                    size: 22,
                  )
                : paymentType == 2
                    ? FaIcon(
                        FontAwesomeIcons.fileArrowDown,
                        color: Colors.white,
                        size: 22,
                      )
                    : FaIcon(
                        FontAwesomeIcons.fileCircleQuestion,
                        size: 22,
                        color: Colors.white,
                      ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            typeName,
            style: TextStyle(color: Colors.black),
          ),
          Spacer(),
          Text(
            AppLocalizations.of(context)!.symbol + " " + money,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
