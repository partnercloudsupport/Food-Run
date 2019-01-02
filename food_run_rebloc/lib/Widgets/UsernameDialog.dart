import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';

class UsernameDialog extends StatefulWidget {
  final UsersBloc usersBloc;

  UsernameDialog({@required this.usersBloc});

  @override
  State<StatefulWidget> createState() {
    return UsernameDialogState();
  }
}

class UsernameDialogState extends State<UsernameDialog> {
  static final GlobalKey<FormState> _usernameKey = new GlobalKey<FormState>();
  TextEditingController _usernameController = new TextEditingController();
  bool _isUsernameAvailable;
  String _username;

  UsernameDialogState() {
    if (_username != null) {
      widget.usersBloc.usernameIsAvailable(_username).then((isAvailable) {
        setState(() {
          _isUsernameAvailable = isAvailable;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Choose your username"),
        actions: <Widget>[
          FlatButton(
            child: Text("Submit"),
            onPressed: () {
              if (_usernameKey.currentState.validate()) {
                _usernameKey.currentState.save();
                widget.usersBloc
                    .usernameIsAvailable(_usernameController.text.toString())
                    .then((isAvailable) {
                  setState(() {
                    _isUsernameAvailable = isAvailable;
                  });
                });
              }
            },
          ),
          FlatButton(
            child: Text("Cancel"),
            onPressed: null,
          ),
        ],
        content: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Form(
                      key: _usernameKey,
                      child: TextFormField(
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
                        onFieldSubmitted: (username) => setState(() {
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
        ));
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
}
