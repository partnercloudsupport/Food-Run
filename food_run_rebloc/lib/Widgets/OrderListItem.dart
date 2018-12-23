import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/Order.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final Function onTap;
  final Function onLongPress;
  OrderListItem({this.order, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            order.order,
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: new Column(
            children: <Widget>[
              order.user.isVolunteer
                  ? new Icon(
                      Icons.directions_run,
                      size: 40.0,
                    )
                  : new Icon(
                      Icons.fastfood,
                      size: 40.0,
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(order.timeOfDay.format(context)),
              )
            ],
          ),
          //order.user.name ??
          subtitle: Text("user is null"),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
        new Divider(
          height: 25.0,
          color: Colors.grey,
        ),
      ],
    );
  }
}
