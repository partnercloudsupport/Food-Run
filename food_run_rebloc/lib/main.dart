import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/GroupsListScreen.dart';
import 'package:food_run_rebloc/Screen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SharedPreferencesBloc sharedPreferencesBloc;
  ListPage() {
    sharedPreferencesBloc = SharedPreferencesBloc();
  }

  @override
  Widget build(BuildContext context) {
    //return OrdersListScreen(ordersBloc);
    //return new ResturantsListScreen(resturantsAndOrdersBloc);
    sharedPreferencesBloc.isUserLoggedIn().then((isLoggedIn) {
      if (isLoggedIn) {
        return GroupsListScreen(
          user: sharedPreferencesBloc.user,
          usersBloc: UsersBloc(),
          groupsBloc: GroupsBloc(),
        );
      } else {
        return HomeScreen(
            usersBloc: UsersBloc(),
            sharedPreferencesBloc: sharedPreferencesBloc);
      }
    });

//    return RaisedButton(
//      child: Text("Hello"),
//      onPressed: () => showSearch(context: context, delegate: GroupSearch()),
//    );
  }
}
