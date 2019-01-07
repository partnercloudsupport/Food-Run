import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/LoadingState.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/GroupsListScreen.dart';
import 'package:food_run_rebloc/Screen/HomeScreen.dart';

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
      routes: {
        "/": (context) => ListPage(),
      },
    );
  }
}

class ListPage extends StatefulWidget {
  final SharedPreferencesBloc sharedPreferencesBloc =
      SharedPreferencesBloc.getInstance();
  ListPage();

  @override
  ListPageState createState() {
    return new ListPageState(sharedPreferencesBloc);
  }
}

class ListPageState extends State<ListPage> {
  LoginState loginState = LoginState.init;
  UsersBloc _usersBloc;
  SharedPreferencesBloc sharedPreferencesBloc;

  @override
  void initState() {
    super.initState();
    _usersBloc = UsersBloc();
    loginState = LoginState.loading;
    sharedPreferencesBloc.isLoggedInStream.listen((loginState) {
      print(loginState.toString());
      setState(() {
        this.loginState = loginState;
        if (loginState == LoginState.signedIn) {
          _usersBloc.getUser(sharedPreferencesBloc.user.id);
        }
      });
    });
  }

  @override
  void dispose() {
    sharedPreferencesBloc.isLoggedInStream.close();
    super.dispose();
  }

  ListPageState(this.sharedPreferencesBloc);

  @override
  Widget build(BuildContext context) {
    //return OrdersListScreen(ordersBloc);
    //return new ResturantsListScreen(resturantsAndOrdersBloc);
    if (loginState == LoginState.loading) {
      return _buildLoadingScreen();
    } else if (loginState == LoginState.signedIn) {
      return GroupsListScreen(
        usersBloc: _usersBloc,
        groupsBloc: GroupsBloc(user: _usersBloc.signedInUser),
      );
    } else if (loginState == LoginState.notSignedIn) {
      return HomeScreen(
          usersBloc: _usersBloc,
          sharedPreferencesBloc: widget.sharedPreferencesBloc);
    } else {
      return Text("Shouldnt happen");
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
