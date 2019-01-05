import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';

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
  static final GlobalKey<FormState> _usernameKey = new GlobalKey<FormState>();
  TextEditingController _usernameController;
  bool _isUsernameAvailable;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    if (widget.currentName == null) {
      _usernameController = new TextEditingController();
    } else {
      _usernameController = new TextEditingController(text: widget.currentName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Edit your username"),
        actions: <Widget>[
          FlatButton(
            child: Text("Check Availability"),
            onPressed: () {
              if (_usernameKey.currentState.validate()) {
                _usernameKey.currentState.save();
                setState(() {
                  _isLoading = true;
                });
                widget.usersBloc
                    .usernameIsAvailable(_usernameController.text.toString())
                    .then((isAvailable) {
                  setState(() {
                    _isUsernameAvailable = isAvailable;
                    if (_usernameController.text.toString() ==
                        widget.currentName) {
                      _isUsernameAvailable = true;
                    }
                    _isLoading = false;
                  });
                });
              }
            },
          ),
          FlatButton(
            child: Text("Submit"),
            onPressed: () {
              if (_usernameKey.currentState.validate()) {
                _usernameKey.currentState.save();
                if (_usernameController.text.toString() != widget.currentName) {
                  setState(() {
                    _isLoading = true;
                  });
                  widget
                      .onAddEdit(_usernameController.text.toString())
                      .then((_) {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                }
                Navigator.pop(context);
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
        content: _isLoading ? LinearProgressIndicator() : _buildCard());
  }

  Widget _trailingWidget() {
    if (_isUsernameAvailable == null) {
      return Container();
    }
    return _isUsernameAvailable
        ? Icon(
            Icons.check,
            color: Colors.green,
          )
        : Icon(
            Icons.clear,
            color: Colors.red,
          );
  }

  Widget _buildCard() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Form(
                  key: _usernameKey,
                  child: TextFormField(
                    autofocus: true,
                    controller: _usernameController,
                    validator: (username) {
                      if (username == null || username == "") {
                        return "Username can't be empty";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              _trailingWidget()
            ],
          )
        ],
      ),
    );
  }
}
