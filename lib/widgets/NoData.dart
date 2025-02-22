import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
final String description;

NoData(this.description);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
    /*    SizedBox(height: 75,),
        Padding(
          padding: const EdgeInsets.fromLTRB(100, 20, 100, 0),
          child: Container(
            margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
            child: Image.asset(
              "assets/images/sadFace.png",
              height: 250,
            ),
          ),
        ),
*/

        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Text(
              description,
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),



      ],
    );
  }
}
