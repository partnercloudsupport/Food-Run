import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/FlareData.dart';
import 'package:food_run_rebloc/Model/Group.dart';
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
  final Group group;

  final User user;
//  final bool canAddEdit;
//  final bool canRemove;
  OrdersListScreen({
    @required this.resturantsAndOrdersBloc,
    @required this.usersBloc,
    @required this.user,
    this.resturant,
    this.group,
//        this.canAddEdit,
//        this.canRemove,
  });

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
                bool userHasOrder = resturantsAndOrdersBloc.userHasOrder(
                    user: user, resturant: resturant);
                if (userHasOrder) {
                  await usersBloc.userVolunteerForResturant(resturant);
                  resturantsAndOrdersBloc.updateResturantsVolunteers(
                      resturant, usersBloc.signedInUser);
                  resturantsAndOrdersBloc.updateOrdersForGroup(
                      resturant, usersBloc.signedInUser);
                } else {
                  Fluttertoast.showToast(msg: "Make an active order first");
                }
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
                          isVolunteer: _isUserVolunteerForResturant(
                              resturant, order.userAttributes["userId"]),
                          onTap: () {
                            if (Order.canAddEdit(order, user, group)) {
                              _goToAddEditOrder(
                                  isEdit: true,
                                  context: context,
                                  order: order,
                                  fromResturant: resturant);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Must be admin to add/edit other people's orders");
                            }
                          },
                          onLongPress: () {
                            if (Order.canRemove(order, user, group)) {
                              _onDeleteOrder(order, resturant);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Must be admin to remove other people's orders");
                            }
                          }))
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
            _goToAddEditOrder(
                isEdit: false, context: context, fromResturant: resturant);
          }),
    );
  }

  _goToAddEditOrder(
      {bool isEdit,
      BuildContext context,
      Order order,
      Resturant fromResturant}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditOrderScreen(
                user: user,
                isEdit: isEdit,
                resturant: resturant,
                existingOrder: order,
                onAdd: (Order order, Resturant resturant) {
                  resturantsAndOrdersBloc
                      .addOrderToFirestore(
                          order, resturant, usersBloc.signedInUser)
                      .then((order) {
                    usersBloc.addOrderToUser(order.id, order.resturantId);
                  }).catchError((error) => print(error));
                },
                onEdit: resturantsAndOrdersBloc.updateOrderToFirestore,
                onDelete: (Order order, Resturant resturant) {
                  _onDeleteOrder(order, resturant);
                },
              ),
        ));
  }

  _onDeleteOrder(Order order, Resturant fromResturant) {
    resturantsAndOrdersBloc.deleteOrderToFirestore(order, fromResturant);
    usersBloc.removeOrdersFromUser(order.id, order.resturantId);
  }

  bool _isUserVolunteerForResturant(Resturant resturant, String userId) {
    bool isVolunteer = false;
    resturant.volunteers.forEach((volunteerId) {
      if (volunteerId == userId) {
        isVolunteer = true;
      }
    });
    return isVolunteer;
  }
}
