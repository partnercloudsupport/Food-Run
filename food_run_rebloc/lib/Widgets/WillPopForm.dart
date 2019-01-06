import 'package:flutter/material.dart';

class WillPopForm extends StatelessWidget {
  final Widget child;
  final bool Function() didDataChange;
  WillPopForm({this.child, this.didDataChange});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: child,
        onWillPop: () {
          if (didDataChange()) {
            return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                        "Are you sure you want to exit with unsaved data?"),
                    actions: <Widget>[
                      SimpleDialogOption(
                        child: Text("Yes"),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ],
                  );
                }).then((selectedYes) {
              if (selectedYes != null) {
                if (selectedYes) {
                  print("trying to pop again");
                  return true;
                }
              }
              return false;
            });
          } else {
            return Future.value(true);
          }
        });
  }
}
