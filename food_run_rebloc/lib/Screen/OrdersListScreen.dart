import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/AddEditOrderScreen.dart';
import 'package:food_run_rebloc/Widgets/OrderListItem.dart';

class OrdersListScreen extends StatelessWidget {
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  final Resturant resturant;
  User user;
  OrdersListScreen(this.resturantsAndOrdersBloc, this.resturant, this.user);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Orders for ${resturant.name}"),
      ),
      body: StreamBuilder(
          stream: resturantsAndOrdersBloc.getOrdersFromFirestore(resturant),
          builder: (BuildContext context, AsyncSnapshot<List<Order>> orders) {
            if (orders.hasData) {
              return ListView(
                children: orders.data
                    .map((order) => OrderListItem(
                        order: order,
                        onTap: () =>
                            _onOrderListItemTap(context, order, resturant),
                        onLongPress: () =>
                            _onOrderListItemLongPress(order, resturant)))
                    .toList(),
              );
            }
            return Container();
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditOrderScreen(
                user: user,
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
}
