import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AvailabilityWidget extends StatefulWidget {
  final String Function(String groupName) validator;
  final Function(String groupName) onSaved;
  final InputDecoration decoration;
  final String initialValue;
  final Future<bool> Function(String input) isAvailable;
  final GlobalKey<AvailabilityWidgetState> key;
  AvailabilityWidget({
    this.key,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.decoration,
    this.isAvailable,
  });

  @override
  State<StatefulWidget> createState() {
    return AvailabilityWidgetState(initialValue);
  }
}

class AvailabilityWidgetState extends State<AvailabilityWidget> {
  static final GlobalKey<FormState> _usernameKey = new GlobalKey<FormState>();
  TextEditingController _usernameController;
  bool _isUsernameAvailable;
  bool _isLoading;
  String initialValue;

  AvailabilityWidgetState(this.initialValue);

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _usernameController = new TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: _isLoading ? LinearProgressIndicator() : _buildCard());
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
                    key: Key(widget.decoration.hintText.toString()),
                    autofocus: true,
                    controller: _usernameController,
                    validator: (input) {
                      widget.validator(input);
                      if (input == null || input == "") {
                        return "Username can't be empty";
                      }
                      return null;
                    },
                    onSaved: (input) {
                      widget.onSaved(input);
                    },
                    decoration: widget.decoration,
                  ),
                ),
              ),
              _trailingWidget(),
              RaisedButton(
                child: Text("Check Availability"),
                onPressed: () {
                  if (_usernameKey.currentState.validate()) {
                    _usernameKey.currentState.save();
                    setState(() {
                      _isLoading = true;
                    });
                    widget
                        .isAvailable(_usernameController.text.toString())
                        .then((isAvailable) {
                      setState(() {
                        if (initialValue == null) {
                        } else if (_usernameController.text
                                .toString()
                                .toUpperCase() ==
                            initialValue.toUpperCase()) {
                          isAvailable = true;
                          print("Initial value is ${widget.initialValue}");
                          print(
                              "Overriding future since input was same as initial value");
                        }
                        _isUsernameAvailable = isAvailable;
                        _isLoading = false;
                      });
                    });
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<bool> isAvailable() async {
    if (_usernameKey.currentState.validate()) {
      _isUsernameAvailable =
          await widget.isAvailable(_usernameController.text.toString());
      //await compute(widget.isAvailable, _usernameController.text.toString());
      setState(() {
        _isUsernameAvailable;
      });
      return _isUsernameAvailable;
    }
    return false;
  }

  void save() {
    _usernameKey.currentState.save();
  }
}
