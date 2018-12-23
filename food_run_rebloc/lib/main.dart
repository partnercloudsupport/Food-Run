import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/ResturantsListScreen.dart';
import 'package:food_run_rebloc/Widgets/GroupSearch.dart';
import 'Bloc/OrdersBloc.dart';

void main() {
  runApp(MyApp());
}

class AppState {
  List<Order> orders;
  User currentUser;
  AppState(this.orders, this.currentUser);
}

class MyApp extends StatelessWidget {
  MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ListPage());
  }
}

class ListPage extends StatelessWidget {
  ListPage();

  @override
  Widget build(BuildContext context) {
    //return OrdersListScreen(ordersBloc);
    //return new ResturantsListScreen(resturantsAndOrdersBloc);
    return RaisedButton(
      child: Text("Hello"),
      onPressed: () => showSearch(context: context, delegate: GroupSearch()),
    );
  }
}
