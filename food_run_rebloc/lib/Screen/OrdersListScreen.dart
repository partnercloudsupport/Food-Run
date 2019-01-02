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
                await usersBloc.userVolunteerForGroup(resturant);
                resturantsAndOrdersBloc.updateOrdersForGroup(resturant, user);
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
                          isVolunteer:
                              _isUserVolunteerForGroup(resturant, user),
                          onTap: () {
                            if (Order.canAddEdit(order, user, group)) {
                              _goToAddEditOrder(
                                  isEdit: true,
                                  context: context,
                                  order: order,
                                  fromResturant: resturant);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Must be admin to add/edit orders");
                            }
                          },
                          onLongPress: () {
                            if (group.canRemoveOrders) {
                              _onOrderListItemLongPress(order, resturant);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Must be admin to remove orders");
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
