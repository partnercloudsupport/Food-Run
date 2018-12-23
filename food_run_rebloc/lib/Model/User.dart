import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  bool isAdmin;
  bool isVolunteer;

  User({this.id, this.name, this.isVolunteer: false, this.isAdmin: false});
  @override
  bool operator ==(other) {
    if (other is User) {
      return this.name == other.name &&
          this.isVolunteer == other.isVolunteer &&
          this.isAdmin == other.isAdmin;
    }
    return false;
  }

  static User fromDocument(DocumentSnapshot documentSnap) {
    return new User(
      id: documentSnap.documentID,
      name: documentSnap["name"],
      isVolunteer: documentSnap["isVolunteer"] ?? false,
      isAdmin: documentSnap["isAdmin"] ?? false,
    );
  }

  static Map<String, dynamic> toMap(User user) {
    return <String, dynamic>{
      "name": user.name,
      "isVolunteer": user.isVolunteer ?? false,
      "isAdmin": user.isAdmin ?? false,
    };
  }

  static User fromMap(Map map) {
    return User(
        name: map["name"],
        isVolunteer: map["isVolunteer"] ?? false,
        isAdmin: map["isAdmin"] ?? false);
  }
}
