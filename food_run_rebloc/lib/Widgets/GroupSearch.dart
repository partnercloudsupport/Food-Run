import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/ResturantsListScreen.dart';
import 'package:food_run_rebloc/Widgets/GroupListItem.dart';

class GroupSearch extends SearchDelegate<Group> {
  GroupsBloc groupsBloc;
  TextEditingController _passwordController = new TextEditingController();
  UsersBloc usersBloc;
  User user;
  GroupSearch({
    @required this.groupsBloc,
    @required this.usersBloc,
  }) {
    user = usersBloc.signedInUser;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for the query
    //Like clear
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    //The results shown after the user submits a search from the search page.
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return StreamBuilder(
        stream: groupsBloc.getResults(query),
        builder: (context, AsyncSnapshot<List<Group>> groupsSnap) {
          return groupsSnap.hasData
              ? ListView(
                  children: groupsSnap.data
                      .map((group) => GroupListItem(
                          group: group,
                          onTap: () => _groupDialog(context, group)))
                      .toList(),
                )
              : Container();
        });
  }

  _onGroupListItemTapped(BuildContext context, Group group,
      ResturantsAndOrdersBloc resturantsAndOrdersBloc) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => ResturantsListScreen(
                usersBloc: usersBloc,
                sharedPreferencesBloc: SharedPreferencesBloc(),
                group: group,
                resturantsAndOrdersBloc: resturantsAndOrdersBloc)));
  }

  _groupDialog(BuildContext context, Group group) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Enter the Group's Password"),
              content: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(hintText: "Group Password"),
                    validator: (attempt) {
                      if (attempt == null || attempt == "") {
                        return "Return must enter text";
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          bool isCorrect = groupsBloc.isCorrectGroupPassword(
                              _passwordController.text.toString(), group);
                          if (isCorrect) {
                            if (usersBloc.isMember(user, group)) {
                              Fluttertoast.showToast(
                                  msg: "Already a member of ${group.name}");
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Welcome to ${group.name}");
                              usersBloc.addGroupToUser(user, group);
                            }
                            close(context, null);
                          } else {
                            Fluttertoast.showToast(msg: "Wrong Password");
                          }
                        },
                        child: Text("Ok"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          close(context, null);
                        },
                        child: Text("Cancel"),
                      ),
                    ],
                  )
                ],
              ),
            ));
  }
}
