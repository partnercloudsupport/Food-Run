import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/FlareData.dart';
import 'package:food_run_rebloc/Model/Order.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final Function onTap;
  final Function onLongPress;
  final bool isVolunteer;
  OrderListItem({this.order, this.onTap, this.onLongPress, this.isVolunteer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            order.order,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          trailing: new Column(
            children: <Widget>[
              isVolunteer
                  ? SizedBox(
                      width: 50.0,
                      height: 55.0,
                      child: FlareActor(
                        FlareData.runningMan.filename,
                        fit: BoxFit.fitHeight,
                        animation: FlareData.runningMan.animation,
                      ),
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
          subtitle: Text(order.user.toString()),
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
