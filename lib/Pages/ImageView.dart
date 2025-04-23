import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImageView extends StatefulWidget {
  List<Widget> items;
  int initialPage;

  ImageView(this.items, this.initialPage);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myPicture),
      ),
      body: Stack(
        children: [
          CarouselSlider(
              items: widget.items,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                aspectRatio: 16 / 9,
                viewportFraction: 1,
                initialPage: widget.initialPage,
                enableInfiniteScroll: false,
                reverse: false,
                onPageChanged: (index, a) {
                  setState(() {});
                  widget.initialPage = index;
                },
                autoPlay: false,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              )),
          Align(
            alignment: Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.items.map((url) {
                int index = widget.items.indexOf(url);
                return Container(
                  width: index == widget.initialPage ? 15 : 10.0,
                  height: index == widget.initialPage ? 15 : 10.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.initialPage == index
                          ? Get.theme.colorScheme.surface
                          : Colors.grey),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
