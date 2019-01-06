import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Order.dart';

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
  List<String> volunteeredResturants;
  List<String> activeOrders;
  List<String> activeResturants;
  String get testName => name.toUpperCase();
  User(
      {this.id,
      this.name,
      this.volunteeredResturants = const [],
      this.activeResturants = const [],
      this.adminForGroups = const [],
      this.email,
      this.password,
      this.groupIds = const [],
      this.activeOrders = const []});
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
        volunteeredResturants:
            List.from(documentSnap["volunteeredResturants"] ?? []),
        activeResturants: List.from(documentSnap["activeResturants"] ?? []),
        adminForGroups: List.from(documentSnap["adminForGroups"] ?? []),
        email: documentSnap["email"],
        password: documentSnap["password"],
        activeOrders: List.from(documentSnap["activeOrders"] ?? []),
        groupIds: List.from(documentSnap["groupIds"] ?? []));
  }

  static Map<String, dynamic> toMap(User user) {
    Map<String, dynamic> map = <String, dynamic>{
      "id": user.id,
      "name": user.name,
      "upperName": user.name.toUpperCase(),
      "email": user.email,
      "password": user.password,
      "activeResturants": user.activeResturants ?? [],
      "volunteeredResturants": user.volunteeredResturants ?? [],
      "adminForGroups": user.adminForGroups ?? [],
      "groupIds": user.groupIds ?? [],
      "activeOrders": user.activeOrders ?? []
    };
    return map;
  }

  static User fromMap(Map map) {
    User user = User(
        id: map["id"],
        name: map["name"],
        email: map["email"],
        password: map["password"],
        activeResturants: map["activeResturants"],
        activeOrders: List.from(map["activeOrders"]),
        volunteeredResturants: List.from(map["volunteeredResturants"]),
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
        return;
      }
    });
    if (!isAdmin) {
      print("user is NOT admin");
    }
    return isAdmin;
  }

  @override
  String toString() {
    return "$name with id $id";
  }
}
