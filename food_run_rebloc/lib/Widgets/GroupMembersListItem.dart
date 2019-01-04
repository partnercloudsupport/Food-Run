import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/User.dart';

class GroupMembersListItem extends StatelessWidget {
  final User user;
  GroupMembersListItem({this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
    );
  }
}
