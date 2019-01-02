import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/Model/Group.dart';

/*
Test name is upper case version of the name.
There to help us check if a username is taken
 */
class User {
  String id;
  String name;
  String email;
  String password;
  List<String> adminForGroups;
  List<String> groupIds;
  List<String> volunteeredGroups;
  String get testName => name.toUpperCase();
  User(
      {this.id,
      this.name,
      this.volunteeredGroups,
      this.adminForGroups,
      this.email,
      this.password,
      this.groupIds});
  @override
  bool operator ==(other) {
    if (other is User) {
      return this.name == other.name &&
          //this.isVolunteer == other.isVolunteer &&
          this.id == other.id;
    }
    return false;
  }

  static User fromDocument(DocumentSnapshot documentSnap) {
    return new User(
        id: documentSnap.documentID,
        name: documentSnap["name"],
        volunteeredGroups: List.from(documentSnap["volunteeredGroups"]),
        adminForGroups: List.from(documentSnap["adminForGroups"]),
        email: documentSnap["email"],
        password: documentSnap["password"],
        groupIds: List.from(documentSnap["groupIds"]));
  }

  static Map<String, dynamic> toMap(User user) {
    Map<String, dynamic> map = <String, dynamic>{
      "id": user.id,
      "name": user.name,
      "upperName": user.name.toUpperCase(),
      "email": user.email,
      "password": user.password,
      "volunteeredGroups": user.volunteeredGroups ?? [],
      "adminForGroups": user.adminForGroups ?? [],
      "groupIds": user.groupIds ?? [],
    };
    return map;
  }

  static User fromMap(Map map) {
    User user = User(
        id: map["id"],
        name: map["name"],
        email: map["email"],
        password: map["password"],
        volunteeredGroups: List.from(map["volunteeredGroups"]),
        adminForGroups: List.from(map["adminForGroups"]),
        groupIds: List.from(map["groupIds"]));
    return user;
  }

  bool isAdmin(Group group) {
    bool isAdmin = false;
    this.adminForGroups.forEach((groupId) {
      print(groupId);
      if (groupId == group.id) {
        print("user is admin");
        isAdmin = true;
      }
    });
    if (!isAdmin) {
      print("user is NOT admin");
    }
    return isAdmin;
  }
}
