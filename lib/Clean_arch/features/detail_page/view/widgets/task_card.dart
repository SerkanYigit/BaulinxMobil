import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:undede/Clean_arch/core/constants/constants.dart';
import 'package:undede/Clean_arch/features/detail_page/view/detail_page.dart';
import 'package:undede/Clean_arch/features/detail_page/view/widgets/custom_circle_avatar.dart';
import 'package:undede/model/Common/CommonGroup.dart';
import 'package:undede/model/Common/Commons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String userImage;
  final Color backgroundColor;
  final Color titleColor;

  const TaskCard({
    super.key,
    required this.title,
    required this.userImage,
    required this.backgroundColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userImage),
                radius: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class DashCard extends StatelessWidget {
  final String title;
  final String userImage;
  final Color backgroundColor;
  final Color titleColor;
  final CommonGroup commonGroupSelected;
  final List<CommonBoardListItem> commonBoardListItem;
  ValueNotifier<double>? valueNotifier;
  final double? progressValue;

  DashCard({
    super.key,
    required this.title,
    required this.userImage,
    required this.backgroundColor,
    required this.titleColor,
    required this.commonGroupSelected,
    required this.commonBoardListItem,
    this.valueNotifier,
    this.progressValue,
  });

  String formatTarih(String inputTarih) {
    // DateTime'a çevirme
    DateTime tarih = DateTime.parse(inputTarih);

    // Formatlama
    return DateFormat('dd.MM.yyyy').format(tarih);
  }

  @override
  Widget build(BuildContext context) {
    valueNotifier = ValueNotifier(progressValue ?? 35);
    return SizedBox(
      // width: 380,
      height: 170,
      child: Card(
        elevation: 30,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SimpleCircularProgressBar(
                    backColor: Colors.grey,
                    backStrokeWidth: 5,
                    progressStrokeWidth: 8,
                    size: 60,
                    valueNotifier: valueNotifier,
                    maxValue: 100,
                    startAngle: 0,
                    mergeMode: false,
                    onGetText: (double value) {
                      return Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  /*  CircleAvatar(
                    backgroundImage: NetworkImage(userImage),
                    radius: 24,
                  ), */
                  const SizedBox(width: 26),
                  Expanded(
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined),
                    Text(
                      //   (AppLocalizations.of(context)!.startDate) +
                      " : " +
                          (commonGroupSelected.groupStartDate != null
                              ?
                              //DateFormat("yyyy-MM-ddThh:mm")
                              formatTarih(commonGroupSelected.groupStartDate!)
                              : "Start"),
                      style: TextStyle(color: primaryBlackColor),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.timer_off_outlined),
                    Text(
                      //  (
                      //   AppLocalizations.of(context)!.endDate) +
                      " : " +
                          (commonGroupSelected.groupEndDate != null
                              ? formatTarih(commonGroupSelected.groupEndDate!)
                              : "End"),
                      style: TextStyle(color: primaryBlackColor),
                    ),
                  ],
                ),
              ),

/*
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined),
                  Text(
                    //   (AppLocalizations.of(context)!.startDate) +
                    " : " +
                        (commonGroupSelected.groupStartDate != null
                            ?
                            //DateFormat("yyyy-MM-ddThh:mm")
                            formatTarih(commonGroupSelected.groupStartDate!)
                            : "Start"),
                    style: TextStyle(color: primaryBlackColor),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_off_outlined),
                    Text(
                      //  (
                      //   AppLocalizations.of(context)!.endDate) +
                      " : " +
                          (commonGroupSelected.groupEndDate != null
                              ? formatTarih(commonGroupSelected.groupEndDate!)
                              : "End"),
                      style: TextStyle(color: primaryBlackColor),
                    ),
                  ],
                ),
              ),
             */

              Expanded(
                child: Container(
                  width: 300,
                  // height: 100,
                  //  color: Colors.amber,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: commonBoardListItem.length,
                      itemBuilder: (context, index) {
                        print(
                            "commonBoardListItem[index]: " + index.toString());
                        return CustomCircleAvatar2(
                          urlImage: commonBoardListItem[index].ownerUserPhoto ??
                              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
                          title: "title",
                          backgroundColor: Colors.white,
                          onPressed: () {},
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
