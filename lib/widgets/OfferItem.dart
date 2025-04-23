import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfferItem extends StatelessWidget {
  String? title;
  String? description;
  Function? onTap;
  Function? offerAccept;
  String? price;
  String? date;
  Color themeColor = Get.theme.colorScheme.secondary;
  Color backGround = Get.theme.colorScheme.surface;
  String? image;
  bool given;

  OfferItem(
      {this.image,
        this.title,
        this.offerAccept,
        this.date,
        this.price,
        this.description,
        this.onTap, this.given =false});



  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap != null ? () => onTap!() : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  image  ==null?Container():       Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 75,
                        //   height: 85,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text("Teklif: ", style: TextStyle(color: Colors.grey)),
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          Text(
                            "Detaylar",
                            style: TextStyle(),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,

                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              given?Container(): Divider(),
              given?Container():Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: offerAccept != null ? () => offerAccept!() : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.green,

                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                      child: Text("Bu teklifi kabul et",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  String dateToString(DateTime time) {
    return "${time.day}/${time.month}/${time.year}";
  }

}
