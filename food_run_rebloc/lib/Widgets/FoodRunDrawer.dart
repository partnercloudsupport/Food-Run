import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';

class FoodRunDrawer extends StatelessWidget {
  SharedPreferencesBloc _sharedPreferences;
  FoodRunDrawer(SharedPreferencesBloc sharedPreferencesBloc) {
    _sharedPreferences = sharedPreferencesBloc;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Text(
            "Food Run",
            style: TextStyle(fontSize: 24.0),
          )),
          ListTile(
            title: Text(
              "Sign Out",
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () async {
              await _sharedPreferences.signOut();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          )
        ],
      ),
    );
  }
}
