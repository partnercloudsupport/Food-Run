import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Widgets/GroupMembersListItem.dart';

class GroupMembersScreen extends StatelessWidget {
  final Group group;
  final GroupsBloc groupsBloc;
  final UsersBloc usersBloc;
  GroupMembersScreen({this.group, this.groupsBloc, @required this.usersBloc});

  @override
  Widget build(BuildContext context) {
    StreamTransformer<List<String>, List<User>> streamTransformer =
        StreamTransformer<List<String>, List<User>>((stream, onError) {
      if (!onError) {
        stream.last.then((List<String> memberIds) {
          return usersBloc.getUsersFromGroup(memberIds);
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Members of ${group.name}"),
      ),
      body: StreamBuilder(
          stream: usersBloc.getUsers(group.id).asStream(),
          builder: (context, AsyncSnapshot<List<User>> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data
                    .map((user) => GroupMembersListItem(user: user))
                    .toList(),
              );
            }
            return Text("Have no users");
          }),
    );
  }
}
