import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/Group.dart';

class GroupListItem extends StatelessWidget {
  final Group group;
  final Function() onTap;
  GroupListItem({this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: new Text(group.name),
      onTap: onTap,
    );
  }
}
