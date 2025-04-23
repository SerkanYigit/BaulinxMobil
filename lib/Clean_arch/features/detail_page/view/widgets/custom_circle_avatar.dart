import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Function onPressed;
  final String? urlImage;

  CustomCircleAvatar({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.onPressed,
    this.urlImage,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      child: ClipOval(
        child: Image.network(
          urlImage ??
              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
        ),
      ),
      /*  backgroundImage: NetworkImage(
       
        urlImage ??
            'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
    
      ), */
      //radius: 25,
      backgroundColor: backgroundColor,
      /*  foregroundImage: NetworkImage(
        
          urlImage ??
              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
        ), */
    );

    /*   
    Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      child: SizedBox(
        width: 180,
        height: 100,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

 */
  }
}

class CustomCircleAvatar2 extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Function onPressed;
  final String? urlImage;

  CustomCircleAvatar2({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.onPressed,
    this.urlImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        radius: 25,
        child: ClipOval(
          child: Image.network(
            urlImage ??
                'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
          ),
        ),
        /*  backgroundImage: NetworkImage(
         
          urlImage ??
              'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
      
        ), */
        //radius: 25,
        backgroundColor: backgroundColor,
        /*  foregroundImage: NetworkImage(
          
            urlImage ??
                'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?t=st=1738863165~exp=1738866765~hmac=4edda2637afeeb8700348a491dab74195219452c13922c942a49afe2830ce8e6&w=1060',
          ), */
      ),
    );

    /*   
    Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      child: SizedBox(
        width: 180,
        height: 100,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

 */
  }
}
