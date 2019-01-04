import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';

class ResturantListItem extends StatelessWidget {
  final Resturant resturant;
  final Function onTap;
  final Function onLongPress;
  ResturantListItem({this.resturant, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        new ListTile(
          title: Text(resturant.name),
          trailing: new Text(resturant.numberOfOrders.toString()),
          onLongPress: onLongPress,
          onTap: onTap,
        ),
        new Divider(
          height: 25.0,
          color: Colors.grey,
        ),
      ],
    );
  }
}
