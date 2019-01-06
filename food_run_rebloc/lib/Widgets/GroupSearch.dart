import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Widgets/GroupListItem.dart';
import 'package:food_run_rebloc/Widgets/JoinGroupDialog.dart';

class GroupSearch extends SearchDelegate<Group> {
  GroupsBloc groupsBloc;
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
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    //The results shown after the user submits a search from the search page.
    return FutureBuilder(
      future: groupsBloc.getResults(query).last,
      builder: (context, AsyncSnapshot<List<Group>> groupsSnapshot) {
        if (groupsSnapshot.hasData) {
          ListView(
            children: groupsSnapshot.data
                .map((group) => GroupListItem(
                    group: group,
                    onTap: () => showDialog(
                        context: context,
                        builder: (context) => JoinGroupDialog(
                            usersBloc: usersBloc,
                            groupsBloc: groupsBloc,
                            group: group))))
                .toList(),
          );
        }
      },
    );
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
                          onTap: () => showDialog(
                              context: context,
                              builder: (context) => JoinGroupDialog(
                                  usersBloc: usersBloc,
                                  groupsBloc: groupsBloc,
                                  group: group))))
                      .toList(),
                )
              : Container();
        });
  }
}
