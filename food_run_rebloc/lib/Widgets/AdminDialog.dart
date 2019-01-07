import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';

/*
  static final GlobalKey<FormState> _adminPasswordKey = GlobalKey<FormState>();
  vs
  var GlobalKey<FormState> _adminPasswordKey = GlobalKey<FormState>();

  Not making it static and final causes it to be recreated on each rebuild
  This means we're making a new key each time






  TEXTFORMFIELD STATE MUST BE WRAPPED IN FORM
  Each individual form field should be wrapped in a FormField widget, with the Form widget as a common ancestor of all of those.
   */

class AdminDialog extends StatelessWidget {
  final TextEditingController _adminController = TextEditingController();
  static final GlobalKey<FormState> _adminPasswordKey = GlobalKey<FormState>();
  final Group group;
  final UsersBloc usersBloc;
  final GroupsBloc groupsBloc;
  AdminDialog({this.groupsBloc, this.group, this.usersBloc});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        FlatButton(
          onPressed: () {
            if (_adminPasswordKey.currentState.validate()) {
              if (_adminController.text.toString() == group.adminPassword) {
                Fluttertoast.showToast(msg: "Welcome new admin!");
                usersBloc.makeAdmin(group);
                groupsBloc.addUserToAdminIds(usersBloc.signedInUser, group);
                Navigator.pop(context, true);
              } else {
                Fluttertoast.showToast(msg: "Wrong password");
              }
            }
          },
          child: Text("Submit"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Form(
            key: _adminPasswordKey,
            child: TextFormField(
              controller: _adminController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Admin Password"),
              validator: (attempt) {
                if (attempt == null || attempt == "") {
                  return "Can't be empty";
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
