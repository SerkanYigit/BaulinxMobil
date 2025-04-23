import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderItem extends StatelessWidget {
  List<String> monthName = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık"
  ];

  String? image;
  String? title;
  String? description;
  Function? onTap;
  String? price;
  String? date;
  Color themeColor = Get.theme.colorScheme.secondary;
  Color backGround = Get.theme.colorScheme.surface;

  OrderItem(
      {this.image,
      this.title,
      this.date,
      this.price,
      this.description,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null ? () => onTap!() : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[100]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                )
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text("Toplam: ", style: TextStyle(color: Colors.grey)),
                      Text(
                        "$price TL",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    dateToString(DateTime.parse(date!)),
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    child: Text(
                      "Tahmini Teslimat:\n" + estDate(DateTime.parse(date!)),overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: themeColor,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String dateToString(DateTime time) {
    return "${time.day}/${time.month}/${time.year}";
  }

  String estDate(DateTime time) {
    DateTime temp = DateTime(time.year, time.month, time.day + 3);
    DateTime temp2 = DateTime(time.year, time.month, time.day + 6);
    return "${temp.day} ${monthName[temp.month-1]} - ${temp2.day} ${monthName[temp2.month-1]}";
  }
}
