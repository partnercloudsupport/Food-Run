import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Screen/ResturantsListScreen.dart';
import 'package:food_run_rebloc/Widgets/GroupListItem.dart';

class GroupSearch extends SearchDelegate<Group> {
  GroupsBloc groupsBloc;

  GroupSearch() {
    groupsBloc = GroupsBloc();
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
                          onTap: () => _onGroupListItemTapped(context, group,
                              new ResturantsAndOrdersBloc(group))))
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
                group: group,
                resturantsAndOrdersBloc: resturantsAndOrdersBloc)));
  }
}
