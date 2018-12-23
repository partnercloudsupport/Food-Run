import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/ResturantsListScreen.dart';
import 'Bloc/OrdersBloc.dart';

void main() {
  final resturantAndOrdersBloc = ResturantsAndOrdersBloc();
  runApp(MyApp(resturantAndOrdersBloc));
}

class AppState {
  List<Order> orders;
  User currentUser;
  AppState(this.orders, this.currentUser);
}

class MyApp extends StatelessWidget {
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  MyApp(this.resturantsAndOrdersBloc);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ListPage(resturantsAndOrdersBloc));
  }
}

class ListPage extends StatelessWidget {
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  ListPage(this.resturantsAndOrdersBloc);

  @override
  Widget build(BuildContext context) {
    //return OrdersListScreen(ordersBloc);
    return new ResturantsListScreen(resturantsAndOrdersBloc);
  }
}
