import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Widgets/AvailabilityWidget.dart';
import 'package:food_run_rebloc/Widgets/WillPopForm.dart';

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
  TextEditingController _passwordController;
  TextEditingController _adminPasswordController;
  static final GlobalKey<FormState> _groupsFormsKey = GlobalKey<FormState>();
  static final GlobalKey<AvailabilityWidgetState> _availabilityKey =
      GlobalKey<AvailabilityWidgetState>();
  Group _existingGroup;

  AddEditGroupScreenState(Group group) {
    if (group != null) {
      _existingGroup = group;
      _group = Group.copyWith(group);
    }
    if (group == null) {
      _group = new Group();
      _passwordController = new TextEditingController();
      _adminPasswordController = new TextEditingController();
    } else {
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
              onPressed: () async {
                if (_groupsFormsKey.currentState.validate()) {
                  if (await _availabilityKey.currentState.isAvailable()) {
                    _groupsFormsKey.currentState.save();
                    _availabilityKey.currentState.save();
                    if (widget.isEdit) {
                      widget.groupsBloc.updateGroup(_group);
                    } else {
                      widget.groupsBloc.addNewGroup(_group);
                    }
                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(msg: "Group name is already taken!");
                  }
                }
              },
            )
          ],
        ),
        body: WillPopForm(
          child: _buildForms(),
          didDataChange: _didDataChange,
        ));
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
          onSaved: (groupPassword) {
            setState(() {
              this._group.password = groupPassword;
            });
          },
          decoration: InputDecoration(
              labelText: "Group password",
              contentPadding: EdgeInsets.all(16.0)),
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
                onSaved: (groupPassword) {
                  setState(() {
                    this._group.password = groupPassword;
                  });
                },
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Confirm group password",
                    contentPadding: EdgeInsets.all(16.0)),
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
          onSaved: (adminPassword) {
            setState(() {
              this._group.adminPassword = adminPassword;
            });
          },
          decoration: InputDecoration(
              labelText: "Admin Password",
              contentPadding: EdgeInsets.all(16.0)),
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
                onSaved: (confirmAdminPassword) {
                  this._group.adminPassword = confirmAdminPassword;
                },
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Confirm admin password",
                    contentPadding: EdgeInsets.all(16.0)),
              )
      ],
    );
  }

  Widget _buildForms() {
    return SingleChildScrollView(
      child: Form(
          key: _groupsFormsKey,
          child: Column(
            children: <Widget>[
              AvailabilityWidget(
                key: _availabilityKey,
                isAvailable: (input) {
                  return widget.groupsBloc.isGroupnameAvailable(
                      groupName: input,
                      existingName: widget.existingGroup.name);
                },
                onSaved: (groupName) {
                  setState(() {
                    _group.name = groupName;
                  });
                },
                initialValue: _group != null ? _group.name : null,
                validator: (String groupName) {
                  if (groupName == null || groupName == "") {
                    return "Group name can't be empty";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    labelText: "Group name",
                    contentPadding: EdgeInsets.all(16.0)),
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

  bool _didDataChange() {
    Group currentFieldsGroup = _getGroupUsingControllers();
    if (widget.isEdit) {
      return !groupFieldsAreEqual(currentFieldsGroup, _existingGroup);
    }
    return !Group.isEmpty(currentFieldsGroup);
  }

  _getGroupUsingControllers() {
    return Group(
      name: _availabilityKey.currentState.name(),
      password: _passwordController.text.toString(),
      adminPassword: _adminPasswordController.text.toString(),
    );
  }

  bool groupFieldsAreEqual(Group currentGroup, Group existingGroup) {
    return currentGroup.name == existingGroup.name &&
        currentGroup.password == existingGroup.password &&
        currentGroup.adminPassword == existingGroup.adminPassword;
  }
}
