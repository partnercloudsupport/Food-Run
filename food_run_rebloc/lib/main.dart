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

class ListPage extends StatefulWidget {
  SharedPreferencesBloc sharedPreferencesBloc;
  ListPage() {
    sharedPreferencesBloc = SharedPreferencesBloc();
  }

  @override
  ListPageState createState() {
    return new ListPageState(sharedPreferencesBloc);
  }
}

class ListPageState extends State<ListPage> {
  bool _isLoggedIn = null;

  ListPageState(SharedPreferencesBloc sharedPreferencesBloc) {
    sharedPreferencesBloc.isUserLoggedIn().then((isLoggedIn) => setState(() {
          _isLoggedIn = isLoggedIn;
        }));
  }

  @override
  Widget build(BuildContext context) {
    //return OrdersListScreen(ordersBloc);
    //return new ResturantsListScreen(resturantsAndOrdersBloc);
    if (_isLoggedIn == null) {
      return _buildLoadingScreen();
    } else if (_isLoggedIn == true) {
      return GroupsListScreen(
        user: widget.sharedPreferencesBloc.user,
        usersBloc: UsersBloc(),
        groupsBloc: GroupsBloc(user: widget.sharedPreferencesBloc.user),
      );
    } else {
      return HomeScreen(
          usersBloc: UsersBloc(),
          sharedPreferencesBloc: widget.sharedPreferencesBloc);
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Run"),
      ),
      body: CircularProgressIndicator(),
    );
  }
}
