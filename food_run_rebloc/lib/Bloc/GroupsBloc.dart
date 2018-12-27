import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class GroupsBloc {
  static final String groupsCollectionRefrence = "Groups";
  ReplaySubject<String> _searchInput = ReplaySubject<String>();
  Stream<List<Group>> _groups = Firestore.instance
      .collection(groupsCollectionRefrence)
      .snapshots()
      .asyncMap((groupsSnap) {
    print("Loaded the groups properly");
    return groupsSnap.documents
        .map((docSnap) => Group.fromDocumentSnapshot(docSnap))
        .toList();
  }).handleError((_) => print("Unable to load the groups"));

  User user;

  Stream<List<Group>> get usersGroups => _getUsersGroups(user.groupIds);
  GroupsBloc({@required this.user});

  Stream<List<Group>> getResults(String searchInput) {
    return _groups.map((groups) {
      return groups.where((Group group) {
        return group.name.toUpperCase().contains(searchInput.toUpperCase());
      }).toList();
    });
  }

  Stream<List<Group>> _getUsersGroups(List<String> usersGroupsId) {
    if (usersGroupsId == null) {
      print("usersGroupsId is null");
      return null;
    }
    List<Group> groups = [];
    ReplaySubject<List<Group>> replaySubject = ReplaySubject<List<Group>>();
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

  Stream<Group> _searchFirestoreForGroup(String searchInput) {
    return Firestore.instance
        .collection(groupsCollectionRefrence)
        .document(searchInput)
        .snapshots()
        .asyncMap((docSnap) => Group.fromDocumentSnapshot(docSnap));
  }

  Future<bool> addNewGroup(Group group) async {
    print("Need to implement addNewGroup");
    //Check if Groupname is taken

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(groupsCollectionRefrence)
        .where("name", isEqualTo: group.name)
        .getDocuments()
        .then((_) {
      print("Got query of groups with name ${group.name}");
    }).catchError((error) => print(error));

    if (querySnapshot == null) {
      await _addNewGroup(group);
      return false;
    }
    if (querySnapshot.documents.length > 0) {
      return true;
    } else {
      await _addNewGroup(group);
      return false;
    }
  }

  Future<Null> _addNewGroup(Group group) async {
    Firestore.instance
        .collection(groupsCollectionRefrence)
        .add(Group.toMap(group))
        .then((_) => print("Group ${group.name} added"))
        .catchError((error) => print(error));
  }

  bool isCorrectGroupPassword(String attempt, Group group) {
    return attempt == group.password;
  }
}
