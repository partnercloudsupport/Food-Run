import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/AddEditGroupScreen.dart';
import 'package:food_run_rebloc/Screen/ResturantsListScreen.dart';
import 'package:food_run_rebloc/Widgets/FoodRunDrawer.dart';
import 'package:food_run_rebloc/Widgets/GroupListItem.dart';
import 'package:food_run_rebloc/Widgets/GroupSearch.dart';

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
  User user;
  Stream<List<Group>> groups;
  GroupsListScreenState({this.usersBloc, this.groupsBloc});

  @override
  void initState() {
    super.initState();
    user = usersBloc.signedInUser;
    usersBloc.userStream.listen((user) {
      if (mounted) {
        setState(() {
          this.user = user;
          groups = groupsBloc.getUsersGroups(user);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FoodRunDrawer(
          SharedPreferencesBloc.getInstance(), usersBloc, groupsBloc),
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
      body: user != null ? _buildGroupsList() : Container(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddEditGroupScreen(
                        isEdit: false, groupsBloc: groupsBloc)));
          }),
    );
  }

  Widget _buildGroupsList() {
    return StreamBuilder(
        stream: groupsBloc.getUsersGroups(user),
        builder: (context, AsyncSnapshot<List<Group>> asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            if (asyncSnapshot.data.length == 0) {
              return _displayEmptyGroupsList();
            }
            return ListView(
              children: asyncSnapshot.data
                  .map((group) => GroupListItem(
                        group: group,
                        onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ResturantsListScreen(
                                user: user,
                                groupsBloc: groupsBloc,
                                usersBloc: usersBloc,
                                sharedPreferencesBloc:
                                    SharedPreferencesBloc.getInstance(),
                                resturantsAndOrdersBloc:
                                    ResturantsAndOrdersBloc(group),
                                group: group,
                                canAddEdit: Resturant.canAddEdit(user, group),
                                canRemove: Resturant.canRemove(user, group),
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
            return _displayEmptyGroupsList();
          }
        });
  }

  Widget _displayEmptyGroupsList() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.clear,
            size: 42.0,
          ),
          Text(
            "Join or make a group",
            style: TextStyle(fontSize: 32.0),
          )
        ],
      ),
    );
  }
}
