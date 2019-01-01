import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/AddEditGroupScreen.dart';
import 'package:food_run_rebloc/Screen/ResturantsListScreen.dart';
import 'package:food_run_rebloc/Widgets/GroupListItem.dart';
import 'package:food_run_rebloc/Widgets/GroupSearch.dart';
import 'package:rxdart/rxdart.dart';

class GroupsListScreen extends StatefulWidget {
  final UsersBloc usersBloc;
  final GroupsBloc groupsBloc;
  GroupsListScreen({@required this.usersBloc, @required this.groupsBloc});

  @override
  State<StatefulWidget> createState() {
    return GroupsListScreenState(usersBloc: usersBloc, groupsBloc: groupsBloc);
  }
}

class GroupsListScreenState extends State<GroupsListScreen> {
  GroupsBloc groupsBloc;
  UsersBloc usersBloc;
  User user = User();
  GroupsListScreenState({this.usersBloc, this.groupsBloc}) {
    user = usersBloc.signedInUser;
    usersBloc.userStream.listen((user) {
      setState(() {
        this.user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groups"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: GroupSearch(
                      groupsBloc: groupsBloc,
                      usersBloc: usersBloc,
                    ));
              })
        ],
      ),
      body: StreamBuilder(
          stream: groupsBloc.getUsersGroups(user),
          builder: (context, AsyncSnapshot<List<Group>> asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              if (asyncSnapshot.data.length == 0) {
                return Text("Add Resturants");
              }
              return ListView(
                children: asyncSnapshot.data
                    .map((group) => GroupListItem(
                          group: group,
                          onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ResturantsListScreen(
                                  groupsBloc: groupsBloc,
                                  usersBloc: usersBloc,
                                  sharedPreferencesBloc:
                                      SharedPreferencesBloc(),
                                  resturantsAndOrdersBloc:
                                      ResturantsAndOrdersBloc(group),
                                  group: group,
                                );
                              })).then((updatedUser) {
                                if (updatedUser is User) {
                                  groupsBloc.user = updatedUser;
                                }
                              }),
                        ))
                    .toList(),
              );
            } else {
              return Column(
                children: <Widget>[
                  Text("No Groups Available"),
                  RaisedButton(
                    child: Text("Join a group"),
                    onPressed: () => showSearch(
                        context: context,
                        delegate: GroupSearch(
                          usersBloc: usersBloc,
                          groupsBloc: groupsBloc,
                        )),
                  ),
                ],
              );
            }
          }),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddEditGroupScreen(isEdit: false, groupsBloc: groupsBloc)));
      }),
    );
  }
}
