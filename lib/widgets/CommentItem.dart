import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {

  final String image;
  final String title;
  final String comment;
  final String rate;

  CommentItem(this.image, this.title, this.comment, this.rate);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 30,
          backgroundImage: Image.network(image)
              .image,
        ),
        title: Text(title),
        subtitle: Text(comment),
        trailing: Container(
          width: 50,
          child: Row(
            children: [
              Text("$rate "),
              Icon(
                Icons.star,
                color: Colors.yellow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
