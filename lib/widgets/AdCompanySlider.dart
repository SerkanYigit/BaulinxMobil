import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdCompanySlider extends StatefulWidget {

  AdCompanySlider();

  @override
  State<AdCompanySlider> createState() => _AdCompanySliderState();
}

class _AdCompanySliderState extends State<AdCompanySlider>
{
  int initialPage = 0;
  CarouselSliderController carouselController = CarouselSliderController();
  final List<String> imgList = [
    'https://api.jettonapp.com/media/slider/sliderdashboard/1.png',
    'https://api.jettonapp.com/media/slider/sliderdashboard/2.png',
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return  Container(
      width: Get.width,
      height: 140,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 250,
              viewportFraction: 1,
              initialPage: initialPage,
              enableInfiniteScroll: false,
              reverse: false,
              onPageChanged: (i, r) {
                setState(() {
                  initialPage = i;
                });
              },
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            carouselController: carouselController,
            items: imgList
                .map((item) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(item, fit: BoxFit.fitWidth, width: 1000.0),
            ))
                .toList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [0, 1].map((url) {
                int index = [0, 1].indexOf(url);
                return Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Container(
                    width: index == initialPage ? 6 : 4.0,
                    height: index == initialPage ? 6 : 4.0,
                    margin:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 1.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: initialPage == index ? Get.theme.colorScheme.surface : Get.theme.colorScheme.surface.withOpacity(0.6)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
