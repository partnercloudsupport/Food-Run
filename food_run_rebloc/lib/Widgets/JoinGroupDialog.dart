import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';

class JoinGroupDialog extends StatelessWidget {
  final TextEditingController _passwordController = new TextEditingController();
  final GroupsBloc groupsBloc;
  final UsersBloc usersBloc;
  final Group group;

  JoinGroupDialog({this.usersBloc, this.groupsBloc, this.group});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter the Group's Password"),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: "Group Password"),
            validator: (attempt) {
              if (attempt == null || attempt == "") {
                return "Return must enter text";
              }
              return null;
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    bool isCorrect = groupsBloc.isCorrectGroupPassword(
                        _passwordController.text.toString(), group);
                    if (isCorrect) {
                      if (usersBloc.isMember(usersBloc.signedInUser, group)) {
                        Fluttertoast.showToast(
                            msg: "Already a member of ${group.name}");
                      } else {
                        Fluttertoast.showToast(msg: "Welcome to ${group.name}");
                        usersBloc.addGroupToUser(usersBloc.signedInUser, group);
                        groupsBloc.addUserToGroup(
                            usersBloc.signedInUser, group);
                      }
                      Navigator.pop(context);
                    } else {
                      Fluttertoast.showToast(msg: "Wrong Password");
                    }
                  },
                  child: Text("Ok"),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
