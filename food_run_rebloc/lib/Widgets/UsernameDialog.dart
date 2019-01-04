import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';

class UsernameDialog extends StatefulWidget {
  final UsersBloc usersBloc;
  final Future Function(String username) onAdd;
  UsernameDialog({
    @required this.usersBloc,
    this.onAdd,
  });

  @override
  State<StatefulWidget> createState() {
    return UsernameDialogState();
  }
}

class UsernameDialogState extends State<UsernameDialog> {
  static final GlobalKey<FormState> _usernameKey = new GlobalKey<FormState>();
  TextEditingController _usernameController = new TextEditingController();
  bool _isUsernameAvailable;
  bool _isLoading;
  String _username;

  UsernameDialogState() {
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Choose your username"),
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
                setState(() {
                  _isLoading = true;
                });
                widget.onAdd(_usernameController.text.toString());
              }
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
                    onSaved: (username) => setState(() {
                          _username = username;
                        }),
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
