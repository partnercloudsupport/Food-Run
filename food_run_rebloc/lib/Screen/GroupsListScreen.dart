import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/AddEditGroupScreen.dart';
import 'package:food_run_rebloc/Screen/ResturantsListScreen.dart';
import 'package:food_run_rebloc/Widgets/GroupListItem.dart';
import 'package:food_run_rebloc/Widgets/GroupSearch.dart';

class GroupsListScreen extends StatelessWidget {
  final UsersBloc usersBloc;
  final GroupsBloc groupsBloc;
  final User user;
  GroupsListScreen(
      {@required this.user,
      @required this.usersBloc,
      @required this.groupsBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groups"),
      ),
      body: StreamBuilder(
          stream: groupsBloc.usersGroups,
          builder: (context, AsyncSnapshot<List<Group>> asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              return ListView(
                children: asyncSnapshot.data
                    .map((group) => GroupListItem(
                          group: group,
                          onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ResturantsListScreen(
                                  user: user,
                                  resturantsAndOrdersBloc:
                                      ResturantsAndOrdersBloc(group),
                                  group: group,
                                );
                              })),
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
                            user: user)),
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
