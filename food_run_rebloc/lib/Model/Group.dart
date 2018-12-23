import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id;
  String name;
  //List of users???
  Group({this.id, this.name});

  static Group fromDocument(DocumentSnapshot documentSnapshot) {
    return Group(
        id: documentSnapshot.documentID, name: documentSnapshot["name"]);
  }
}
