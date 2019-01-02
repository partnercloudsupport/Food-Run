import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id;
  String name;
  String password;
  String adminPassword;
  int numberOfUsers;
  List<String> memberIds;
  List<String> resturantIds;
  List<String> adminIds;
  bool canAddOrders;
  bool canRemoveOrders;
  bool canAddResturants;
  bool canRemoveResturants;

  Group(
      {this.id,
      this.name,
      this.numberOfUsers,
      this.password,
      this.adminPassword,
      this.memberIds,
      this.resturantIds,
      this.adminIds,
      this.canAddOrders: false,
      this.canRemoveOrders: false,
      this.canAddResturants: false,
      this.canRemoveResturants: false});

  static Group fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.data == null) {
      return null;
    }
    return Group(
      id: documentSnapshot.documentID,
      name: documentSnapshot["name"],
      numberOfUsers: documentSnapshot["numberOfUsers"],
      password: documentSnapshot["password"],
      adminIds: List.from(documentSnapshot["adminIds"] ?? null),
      memberIds: List.from(documentSnapshot["memberIds"] ?? null),
      resturantIds: List.from(documentSnapshot["resturantIds"] ?? null),
      adminPassword: documentSnapshot["adminPassword"],
      canAddOrders: documentSnapshot["canAddOrders"] ?? false,
      canRemoveOrders: documentSnapshot["canRemoveOrders"] ?? false,
      canAddResturants: documentSnapshot["canAddResturants"] ?? false,
      canRemoveResturants: documentSnapshot["canRemoveResturants"] ?? false,
    );
  }

  static Map<String, dynamic> toMap(Group group) {
    return <String, dynamic>{
      "name": group.name,
      "upperName": group.name.toUpperCase(),
      "numberOfUsers": group.numberOfUsers,
      "password": group.password,
      "adminPassword": group.adminPassword,
      "adminIds": group.adminIds ?? [],
      "memberIds": group.memberIds ?? [],
      "resturantIds": group.resturantIds ?? [],
      "canAddOrders": group.canAddOrders ?? false,
      "canRemoveOrders": group.canRemoveOrders ?? false,
      "canAddResturants": group.canAddResturants ?? false,
      "canRemoveResturants": group.canRemoveResturants ?? false
    };
  }

  static Group copyWith(Group group) {
    return Group(
        id: group.id,
        name: group.name,
        numberOfUsers: group.numberOfUsers,
        password: group.password,
        adminPassword: group.adminPassword,
        memberIds: group.memberIds,
        adminIds: group.adminIds,
        resturantIds: group.resturantIds,
        canAddOrders: group.canAddOrders,
        canRemoveOrders: group.canRemoveOrders,
        canAddResturants: group.canAddResturants,
        canRemoveResturants: group.canRemoveResturants);
  }
}
