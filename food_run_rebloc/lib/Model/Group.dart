import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id;
  String name;
  String password;
  String adminPassword;
  int numberOfUsers;
  //List of users???
  Group(
      {this.id,
      this.name,
      this.numberOfUsers,
      this.password,
      this.adminPassword});

  static Group fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Group(
        id: documentSnapshot.documentID,
        name: documentSnapshot["name"],
        numberOfUsers: documentSnapshot["numberOfUsers"],
        password: documentSnapshot["password"],
        adminPassword: documentSnapshot["adminPassword"]);
  }

  static Map<String, dynamic> toMap(Group group) {
    return <String, dynamic>{
      "name": group.name,
      "numberOfUsers": group.numberOfUsers,
      "password": group.password,
      "adminPassword": group.adminPassword,
    };
  }
}
