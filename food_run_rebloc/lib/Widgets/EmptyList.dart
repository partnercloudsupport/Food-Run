import 'dart:math';

import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final List<String> messages;
  EmptyList({@required this.messages});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              _pickMessage(messages),
              maxLines: 5,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0),
            ),
          ],
        ),
      ),
    );
  }

  String _pickMessage(List<String> messages) {
    Random rand = Random();
    int randomNumber = rand.nextInt(messages.length);
    return messages[randomNumber];
  }
}
