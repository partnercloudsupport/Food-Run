import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class GroupsBloc {
  static final String groupsCollectionRefrence = "Groups";
  Stream<List<Group>> _groups = Firestore.instance
      .collection(groupsCollectionRefrence)
      .snapshots()
      .take(20)
      .asyncMap((groupsSnap) {
    print("Loaded the groups properly");
    return groupsSnap.documents
        .map((docSnap) => Group.fromDocumentSnapshot(docSnap))
        .toList();
  }).handleError((_) => print("Unable to load the groups"));

  User user;
  PublishSubject<User> userStream = PublishSubject<User>();

  GroupsBloc({@required this.user}) {
    userStream.add(user);
  }

  Stream<List<Group>> getResults(String searchInput) {
    if (searchInput == "" || searchInput == null) {
      return Stream.empty();
    }
    return _groups.map((groups) {
      return groups.where((Group group) {
        return group.name.toUpperCase().contains(searchInput.toUpperCase());
      }).toList();
    });
  }

  Stream<List<Group>> _getUsersGroups(List<String> usersGroupsId) {
    List<Group> groups = [];
    ReplaySubject<List<Group>> replaySubject = ReplaySubject<List<Group>>();

    if (usersGroupsId == null) {
      print("usersGroupsId is null");
      return Stream.empty();
    } else if (usersGroupsId.length == 0) {
      print("usersGroupsId is empty");
      replaySubject.add([]);
      return replaySubject.stream;
    }
    usersGroupsId.forEach((groupId) {
      Firestore.instance
          .collection(groupsCollectionRefrence)
          .document(groupId)
          .get()
          .then((groupSnapshot) {
        Group group = Group.fromDocumentSnapshot(groupSnapshot);
        groups.add(group);
        replaySubject.add(groups);
      });
    });
    return replaySubject.stream;
  }

  Future addNewGroup(Group group) async {
    await Firestore.instance
        .collection(groupsCollectionRefrence)
        .add(Group.toMap(group))
        .then((_) {
      print("added ${group.name} to groups");
    }).catchError((error) => print(error));
    print("Successfully completed query for ${group.name}");

    //We don't need to check if username is taken cause we check before we add
  }

  bool isCorrectGroupPassword(String attempt, Group group) {
    return attempt == group.password;
  }

  void updateAdminSettings(Group group) {
    Firestore.instance
        .collection(groupsCollectionRefrence)
        .document(group.id)
        .updateData({
      "canAddOrders": group.canAddOrders,
      "canRemoveOrders": group.canRemoveOrders,
      "canAddResturants": group.canAddResturants,
      "canRemoveResturants": group.canRemoveResturants,
    }).then((_) {
      print("Updated admin settings");
    }).catchError((error) => print(error));
  }

  void deleteGroup(Group group) {
    Firestore.instance
        .collection(groupsCollectionRefrence)
        .document(group.id)
        .delete()
        .then((_) {
      print("Group deleted");
    }).catchError((error) {
      print(error);
    });
  }

  Stream<List<Group>> getUsersGroups(User signedInUser) {
    return _getUsersGroups(signedInUser.groupIds);
  }

  void addUserToGroup(User user, Group group) {
    if (!group.memberIds.contains(user.id)) {
      group.memberIds.add(user.id);
      Firestore.instance
          .collection(groupsCollectionRefrence)
          .document(group.id)
          .updateData({"memberIds": group.memberIds})
          .then((_) => print("Added userId to group"))
          .catchError((error) => print(error));
    }
  }

  void addUserToAdminIds(User signedInUser, Group group) {
    if (!group.adminIds.contains(signedInUser.id)) {
      group.adminIds.add(user.id);
      Firestore.instance
          .collection(groupsCollectionRefrence)
          .document(group.id)
          .updateData({"adminIds": group.adminIds})
          .then((_) => print("Added userId to group's adminIds"))
          .catchError((error) => print(error));
    }
  }

  void addResturantToGroup(Resturant resturant, Group group) {
    DocumentReference documentReference = Firestore.instance
        .collection(groupsCollectionRefrence)
        .document(group.id);
    group.resturantIds.add(documentReference.documentID);
    documentReference
        .updateData({"resturantIds": group.resturantIds})
        .then((_) => print("Added resturantsId to group's resturantsId"))
        .catchError((error) => print(error));
  }

  void updateGroup(Group group) {
    Firestore.instance
        .collection(groupsCollectionRefrence)
        .document(group.id)
        .updateData(Group.toMap(group))
        .then((_) => print("Updated group"))
        .catchError((error) => print(error));
  }

  Stream<List<String>> memberIds(Group group) {
    return Firestore.instance
        .collection(groupsCollectionRefrence)
        .document(group.id)
        .get()
        .asStream()
        .map((docSnap) => List.from(docSnap["memberIds"]));
  }

  Future<bool> isGroupnameAvailable(String name) async {
    return Firestore.instance
        .collection(groupsCollectionRefrence)
        .where("upperName", isEqualTo: name.toUpperCase().toString())
        .getDocuments()
        .then((querySnapshot) {
      if (querySnapshot.documents.length > 0) {
        print("group name is taken");
        return false;
      } else {
        print("group name is available");
        return true;
      }
    });
  }

  Future<List<String>> getResturantsIds(User signedInUser) async {
    List<String> resturantIds = [];
//    Firestore.instance.runTransaction((transaction) {
//      signedInUser.groupIds.forEach((groupId) async {
//        DocumentReference reference = Firestore.instance
//            .collection(groupsCollectionRefrence)
//            .document(groupId);
//        DocumentSnapshot snapshot = await transaction.get(reference);
//        Group group = Group.fromDocumentSnapshot(snapshot);
//        group.resturantIds.forEach((resturantId) {
//          resturantIds.add(resturantId);
//        });
//      });
//    });
    signedInUser.groupIds.forEach((groupId) async {
      Firestore.instance
          .collection(groupsCollectionRefrence)
          .document(groupId)
          .get()
          .then((snapshot) {
        Group group = Group.fromDocumentSnapshot(snapshot);
        group.resturantIds.forEach((resturantId) {
          resturantIds.add(resturantId);
        });
      });
      return resturantIds;
    });
  }
}
