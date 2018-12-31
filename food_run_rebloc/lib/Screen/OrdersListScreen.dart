import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/FlareData.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/AddEditOrderScreen.dart';
import 'package:food_run_rebloc/Widgets/OrderListItem.dart';

class OrdersListScreen extends StatelessWidget {
  //final User user;
  final UsersBloc usersBloc;
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  final Resturant resturant;
  OrdersListScreen(@required this.resturantsAndOrdersBloc,
      @required this.usersBloc, this.resturant);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Orders for ${resturant.name}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.directions_run),
            onPressed: () async {
              if (resturant.numberOfOrders > 0) {
                await usersBloc.userVolunteerForGroup(resturant);
                resturantsAndOrdersBloc.updateOrdersForGroup(
                    resturant, usersBloc.signedInUser);
              }
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream: resturantsAndOrdersBloc.getOrdersFromFirestore(resturant),
          builder: (BuildContext context, AsyncSnapshot<List<Order>> orders) {
            if (orders.hasData) {
              if (orders.data.length != 0) {
                return ListView(
                  children: orders.data
                      .map((order) => OrderListItem(
                          order: order,
                          isVolunteer: _isUserVolunteerForGroup(
                              resturant, usersBloc.signedInUser),
                          onTap: () =>
                              _onOrderListItemTap(context, order, resturant),
                          onLongPress: () =>
                              _onOrderListItemLongPress(order, resturant)))
                      .toList(),
                );
              }
              return SizedBox(
                child: FlareActor(
                  FlareData.runningMan.filename,
                  animation: FlareData.runningMan.animation,
                  fit: BoxFit.fitWidth,
                ),
              );
            }
            return Container();
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditOrderScreen(
                user: usersBloc.signedInUser,
                resturant: resturant,
                isEdit: false,
                onAdd: resturantsAndOrdersBloc.addOrderToFirestore,
                onEdit: resturantsAndOrdersBloc.updateOrderToFirestore,
                onDelete: resturantsAndOrdersBloc.deleteOrderToFirestore,
              );
            }))
//                .then((dictionary) {
//              ordersBloc.addDataToFirestore(dictionary["order"]);
//            })
                ;
          }),
    );
  }

  _onOrderListItemTap(
      BuildContext context, Order order, Resturant fromResturant) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditOrderScreen(
              user: usersBloc.signedInUser,
              isEdit: true,
              resturant: resturant,
              existingOrder: order,
              onAdd: resturantsAndOrdersBloc.addOrderToFirestore,
              onEdit: resturantsAndOrdersBloc.updateOrderToFirestore,
              onDelete: resturantsAndOrdersBloc.deleteOrderToFirestore),
        ));
  }

  _onOrderListItemLongPress(Order order, Resturant fromResturant) {
    resturantsAndOrdersBloc.deleteOrderToFirestore(order, fromResturant);
  }

  bool _isUserVolunteerForGroup(Resturant resturant, User user) {
    bool isVolunteer = false;
    user.volunteeredGroups.forEach((groupId) {
      if (groupId == resturant.id) {
        isVolunteer = true;
      }
    });
    return isVolunteer;
  }
}
