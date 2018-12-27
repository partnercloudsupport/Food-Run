import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  bool isAdmin;
  bool isVolunteer;
  String email;
  String password;
  List<String> groupIds;
  User({
    this.id,
    this.name,
    this.isVolunteer: false,
    this.isAdmin: false,
    this.email,
    this.password,
    this.groupIds,
  });
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
        groupIds: List.from(documentSnap["groupIds"]));
  }

  static Map<String, dynamic> toMap(User user) {
    return <String, dynamic>{
      "name": user.name,
      "isVolunteer": user.isVolunteer ?? false,
      "isAdmin": user.isAdmin ?? false,
      "groupIds": user.groupIds
    };
  }

  static User fromMap(Map map) {
    return User(
        name: map["name"],
        isVolunteer: map["isVolunteer"] ?? false,
        isAdmin: map["isAdmin"] ?? false,
        groupIds: map["groupIds"]);
  }
}
