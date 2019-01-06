import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/Group.dart';

class GroupListItem extends StatelessWidget {
  final Group group;
  final Function() onTap;
  GroupListItem({this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              group.name,
              style: TextStyle(fontSize: 28.0),
            ),
          ),
          new Divider(
            height: 25.0,
            color: Colors.grey,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
