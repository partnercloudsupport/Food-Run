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
  final SharedPreferencesBloc sharedPreferencesBloc = SharedPreferencesBloc();
  ListPage();

  @override
  ListPageState createState() {
    return new ListPageState(sharedPreferencesBloc);
  }
}

class ListPageState extends State<ListPage> {
  LoadingState loadingState = LoadingState.init;
  UsersBloc _usersBloc;

  SharedPreferencesBloc sharedPreferencesBloc;

  @override
  void initState() {
    _usersBloc = UsersBloc();
    loadingState = LoadingState.loading;
    sharedPreferencesBloc.isLoggedInStream.listen((isLoggedIn) {
      setState(() {
        if (isLoggedIn) {
          _usersBloc.getUser(sharedPreferencesBloc.user.id);
          loadingState = LoadingState.signedIn;
        } else {
          loadingState = LoadingState.notSignedIn;
        }
      });
    });
    sharedPreferencesBloc.isUserLoggedIn().then((isLoggedIn) async {
      setState(() {
        if (isLoggedIn) {
          _usersBloc.getUser(sharedPreferencesBloc.user.id);
          loadingState = LoadingState.signedIn;
        } else {
          loadingState = LoadingState.notSignedIn;
        }
      });
    });
  }

  ListPageState(this.sharedPreferencesBloc);

  @override
  Widget build(BuildContext context) {
    //return OrdersListScreen(ordersBloc);
    //return new ResturantsListScreen(resturantsAndOrdersBloc);
    if (loadingState == LoadingState.loading) {
      return _buildLoadingScreen();
    } else if (loadingState == LoadingState.signedIn) {
      print("Using groupsBloc in main");
      return GroupsListScreen(
        usersBloc: _usersBloc,
        groupsBloc: GroupsBloc(user: _usersBloc.signedInUser),
      );
    } else {
      return HomeScreen(
          usersBloc: _usersBloc,
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
