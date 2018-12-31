import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';

class AddEditGroupScreen extends StatefulWidget {
  final GroupsBloc groupsBloc;
  final Group existingGroup;
  final bool isEdit;
  AddEditGroupScreen(
      {this.groupsBloc, @required this.isEdit, this.existingGroup});

  @override
  AddEditGroupScreenState createState() {
    return new AddEditGroupScreenState(isEdit ? existingGroup : null);
  }
}

class AddEditGroupScreenState extends State<AddEditGroupScreen> {
  Group _group;
  TextEditingController _nameController;
  TextEditingController _passwordController;
  TextEditingController _adminPasswordController;

  GlobalKey<FormState> _groupsFormsKey = GlobalKey<FormState>();

  AddEditGroupScreenState(Group group) {
    _group = group;
    if (group == null) {
      _group = new Group();
      _nameController = new TextEditingController();
      _passwordController = new TextEditingController();
      _adminPasswordController = new TextEditingController();
    } else {
      _nameController = new TextEditingController(text: group.name);
      _passwordController = new TextEditingController(text: group.password);
      _adminPasswordController =
          new TextEditingController(text: group.adminPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEdit ? Text("Edit Group") : Text("Add Group"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (_groupsFormsKey.currentState.validate()) {
                _groupsFormsKey.currentState.save();
                widget.groupsBloc
                    .addNewGroup(_group)
                    .then((doesGroupAlreadyExist) {
                  if (doesGroupAlreadyExist) {
                    Fluttertoast.showToast(msg: "Group name is already taken");
                  } else {
                    Fluttertoast.showToast(msg: "Group was created!");
                    Navigator.pop(context);
                  }
                });
              }
            },
          )
        ],
      ),
      body: Form(
          key: _groupsFormsKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _group == null ? _group.name : null,
                validator: (groupName) {
                  if (groupName == null || groupName == "") {
                    return "Group name can't be empty";
                  }
                  return null;
                },
                onSaved: (groupName) => this._group.name = groupName,
                decoration: InputDecoration(hintText: "Group name"),
              ),
              Text(
                "Password members must know to join",
              ),
              _buildGroupPasswordFields(widget.isEdit),
              Text("Password to allow members to become admin"),
              _buildAdminPasswordFields(widget.isEdit),
            ],
          )),
    );
  }

  Widget _buildGroupPasswordFields(bool isEdit) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _passwordController,
          validator: (groupPassword) {
            if (groupPassword == null || groupPassword == "") {
              return "Group password can't be empty";
            }
            return null;
          },
          onSaved: (groupPassword) => this._group.password = groupPassword,
          decoration: InputDecoration(hintText: "Group password"),
        ),
        isEdit
            ? Container()
            : TextFormField(
                validator: (groupConfirmPassword) {
                  if (groupConfirmPassword !=
                      _passwordController.text.toString()) {
                    return "Password must match";
                  }
                  if (groupConfirmPassword == null ||
                      groupConfirmPassword == "") {
                    return "Confirmation of group password can't be empty";
                  }
                  return null;
                },
                onSaved: (groupPassword) =>
                    this._group.password = groupPassword,
                decoration: InputDecoration(hintText: "Confirm group password"),
              )
      ],
    );
  }

  Widget _buildAdminPasswordFields(bool isEdit) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _adminPasswordController,
          validator: (adminPassword) {
            if (adminPassword == null || adminPassword == "") {
              return "Admin password can't be empty";
            }
            return null;
          },
          onSaved: (adminPassword) => this._group.adminPassword = adminPassword,
          decoration: InputDecoration(hintText: "Admin Password"),
        ),
        isEdit
            ? Container()
            : TextFormField(
                validator: (confirmAdminPassword) {
                  if (confirmAdminPassword !=
                      _adminPasswordController.text.toString()) {
                    return "Password must match";
                  }
                  if (confirmAdminPassword == null ||
                      confirmAdminPassword == "") {
                    return "Can't be empty";
                  }
                  return null;
                },
                onSaved: (confirmAdminPassword) =>
                    this._group.adminPassword = confirmAdminPassword,
                decoration: InputDecoration(hintText: "Confirm admin password"),
              )
      ],
    );
  }
}
