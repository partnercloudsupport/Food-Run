import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Widgets/AdminDialog.dart';

class AdminSettingsScreen extends StatefulWidget {
  final UsersBloc usersBloc;
  final Group group;
  final GroupsBloc groupsBloc;
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  AdminSettingsScreen(
      {this.usersBloc,
      this.group,
      this.groupsBloc,
      this.resturantsAndOrdersBloc});
  @override
  State<StatefulWidget> createState() {
    return AdminSettingsScreenState(
        usersBloc: usersBloc,
        groupsBloc: groupsBloc,
        group: group,
        resturantsAndOrdersBloc: resturantsAndOrdersBloc);
  }
}

class AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final UsersBloc usersBloc;
  final Group group;
  final GroupsBloc groupsBloc;
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  AdminSettingsScreenState(
      {this.usersBloc,
      this.group,
      this.groupsBloc,
      this.resturantsAndOrdersBloc});

  @override
  initState() {
    super.initState();
    usersBloc.getUsers(group.id);
  }

  @override
  void dispose() {
    super.dispose();
    groupsBloc.updateAdminSettings(group);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Settings"),
      ),
      body: usersBloc.signedInUser.isAdmin(group)
          ? SingleChildScrollView(
              child: _buildAdminSettings(),
            )
          : _buildBecomeAdmin(context, group),
    );
  }

  Widget _buildAdminSettings() {
    return Column(
      children: <Widget>[
        CheckboxListTile(
          title: Text("Allow all members to add orders"),
          value: group.canAddOrders ?? false,
          onChanged: (canAddOrders) {
            setState(() {
              group.canAddOrders = canAddOrders;
            });
          },
        ),
        CheckboxListTile(
          title: Text("Allow all members to remove orders"),
          value: group.canRemoveOrders ?? false,
          onChanged: (canRemoveOrders) {
            setState(() {
              group.canRemoveOrders = canRemoveOrders;
            });
          },
        ),
        CheckboxListTile(
          title: Text("Allow all members to add resturants"),
          value: group.canAddResturants ?? false,
          onChanged: (canAddResturants) {
            setState(() {
              group.canAddResturants = canAddResturants;
            });
          },
        ),
        CheckboxListTile(
          title: Text("Allow all members to remove resturants"),
          value: group.canRemoveResturants ?? false,
          onChanged: (canRemoveResturants) {
            setState(() {
              group.canRemoveResturants = canRemoveResturants;
            });
          },
        ),
//        RaisedButton(
//          onPressed: () async {
//            await resturantsAndOrdersBloc.ADDTESTORDERSANDRESTURANTS(
//                group, usersBloc.signedInUser);
//            groupsBloc.updateGroup(group);
//          },
//          child: Text("DELETE ME AFTERWARDS"),
//        ),
        RaisedButton(
          child: Text("Retire as Admin"),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(
                        "Are you sure you want to retire as an admin of the group?"),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: Text("Yes"),
                        onPressed: () {
                          usersBloc
                              .removeAsAdmin(usersBloc.signedInUser, group)
                              .then((_) {
                            //Popping twice once for dialog
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          },
        ),
        RaisedButton(
          child: Text("Delete the Group"),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text("Are you sure you want to delete the group?"),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: Text("Yes"),
                        onPressed: () async {
                          await usersBloc
                              .removeGroupFromMembers(Group.copyWith(group));
                          resturantsAndOrdersBloc
                              .deleteResturantsAndOrders(Group.copyWith(group));
                          groupsBloc.deleteGroup(group);
                          Navigator.popUntil(context, ModalRoute.withName("/"));
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          },
        ),
      ],
    );
  }

  Widget _buildBecomeAdmin(BuildContext context, Group group) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
            child: Text(
          "Not an admin for ${group.name}",
          style: TextStyle(fontSize: 24.0),
        )),
        Center(
          child: RaisedButton(
            onPressed: () {
//              TextEditingController adminPasswordController =
//                  TextEditingController();
//              var _adminPasswordKey = GlobalKey<FormState>();
              showDialog(
                  context: context,
                  builder: (context) => AdminDialog(
                        group: group,
                        usersBloc: usersBloc,
                        groupsBloc: groupsBloc,
                      )).then((correctPassword) {
                if (correctPassword) {}
              });
            },
            child: Text("Become Admin"),
          ),
        ),
      ],
    );
  }
}
