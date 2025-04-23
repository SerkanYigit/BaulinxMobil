import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchListItem extends StatelessWidget {
  String? image;
  String? title;
  String? description;
  String? points;
  int? comment;
  bool showMore = false;
  Color background = Get.theme.colorScheme.surface;

  SearchListItem(
      {required this.image,
      required this.title,
      required this.description,
      required this.points,
      required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 10, 2, 10),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )]),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 75,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "https://api.jettonapp.com" + image!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title!,
                        style: TextStyle(
                            color: Get.theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  /*            Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "The Power of emotional yazilim teknolojileri",
                        style: TextStyle(
                            color: catNameColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 22),
                      )),
                  SizedBox(
                    height: 15,
                  ),*/
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        description!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xFF7A869A),
                            fontWeight: FontWeight.w500),
                      )
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  /*Align(
                    alignment: Alignment(0.9, 0),
                    child: new InkWell(
                        child: Text(
                          showMore ? '' : 'Daha fazla...',
                          style: TextStyle(color: background),
                        ),
                        onTap: () {
                          showMore = !showMore;
                          print("sadasd");
                        }
                    ),
                  ),
                  //   :Container()
                  SizedBox(
                    height: 10,
                  ),*/
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          Text(
                            points!,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/comment/comment.png",
                            width: 26,
                            height: 26,
                          ),
                          Text(
                            "$comment" + "   yorum",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
