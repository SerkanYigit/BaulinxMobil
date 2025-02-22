import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class FavoriteItem extends StatelessWidget {
  String image;
  String title;
  String description;
  String points;
  int comment;

  FavoriteItem(
      {required this.image,
        required this.title,
        required this.description,
        required this.points,
        required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.fromLTRB(5, 10, 2, 10),
      decoration: BoxDecoration(            color: Colors.white,

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
                  image,
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
                        title,
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
                        description,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xFF7A869A),
                            fontWeight: FontWeight.w500),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 2, 5, 10),
                        child: Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RatingBarIndicator(
                                itemSize: 20,
                                rating: double.parse(points),
                                itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                )),

                            Text(
                              "  $points",
                              //   point,
                              style:
                              TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
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
/*{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]),
            boxShadow: [BoxShadow(
              color: Colors.grey[200],
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, 3), //
            )]),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.network(
                      // products[index].images.first ??
                      "https://pcbonlineshop.com/var/photo/product/2000x4000/4/176/4.jpg",
                      fit: BoxFit.cover,

                      //  fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "350 €",
                            style: TextStyle(
                                color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Sifirdan farksiz 5 ay garantili Iphone",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,

                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.grey,
                      )
                    ],
                  ),
                ],
              ),
              Divider(thickness: 1,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.share),
                      Text(
                        "  Paylaş",
                        style: TextStyle(fontSize: 18),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone),
                      Text(
                        "  İletişim",
                        style: TextStyle(fontSize: 18),
                      ),


                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/