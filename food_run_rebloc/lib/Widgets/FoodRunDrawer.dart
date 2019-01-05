import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Widgets/UsernameDialog.dart';

class FoodRunDrawer extends StatelessWidget {
  final SharedPreferencesBloc sharedPreferencesBloc;
  final UsersBloc usersBloc;
  FoodRunDrawer(this.sharedPreferencesBloc, this.usersBloc);

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
              "Change Name",
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () async {
              await showDialog(
                  context: context,
                  builder: (context) => UsernameDialog(
                      usersBloc: usersBloc,
                      currentName: usersBloc.signedInUser.name,
                      isEdit: true,
                      onAddEdit: (editedName) {
                        usersBloc.updateUsername(
                            editedName, usersBloc.signedInUser);
                      }));
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          ),
          ListTile(
            title: Text(
              "Sign Out",
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () async {
              await sharedPreferencesBloc.signOut();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          ),
        ],
      ),
    );
  }
}
