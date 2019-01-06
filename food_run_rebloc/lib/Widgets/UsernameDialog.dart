import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Widgets/AvailabilityWidget.dart';

class UsernameDialog extends StatefulWidget {
  final UsersBloc usersBloc;
  final Future Function(String username) onAddEdit;
  final bool isEdit;
  final String currentName;
  UsernameDialog(
      {@required this.currentName,
      @required this.usersBloc,
      this.onAddEdit,
      @required this.isEdit});

  @override
  State<StatefulWidget> createState() {
    return UsernameDialogState();
  }
}

class UsernameDialogState extends State<UsernameDialog> {
  static final GlobalKey<AvailabilityWidgetState> _usernameKey =
      new GlobalKey<AvailabilityWidgetState>();
  bool _isUsernameAvailable;
  bool _isLoading;
  String currentName;
  String _username;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    currentName = widget.currentName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Edit your username"),
        actions: <Widget>[
          FlatButton(
            child: Text("Submit"),
            onPressed: () async {
              _isUsernameAvailable =
                  await _usernameKey.currentState.isAvailable();
              if (_usernameKey.currentState.validate()) {
                if (_isUsernameAvailable) {
                  _usernameKey.currentState.save();
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.onAddEdit(_username);
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(msg: "Username is taken");
                }
              }
            },
          ),
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        content: _isLoading ? LinearProgressIndicator() : _buildForm());
  }

  Widget _buildForm() {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: AvailabilityWidget(
                  key: _usernameKey,
                  validator: (name) {
                    if (name == null || name == "") {
                      return "Username can't be empty";
                    }
                  },
                  decoration: InputDecoration(hintText: "Username"),
                  initialValue: widget.currentName,
                  onSaved: (username) {
                    _username = username;
                  },
                  isAvailable: (username) {
                    return widget.usersBloc.usernameIsAvailable(username);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
