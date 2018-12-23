import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/Model/Group.dart';
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
        .map((docSnap) => Group.fromDocument(docSnap))
        .toList();
  }).handleError((_) => print("Unable to load the groups"));

  Stream<List<Group>> getResults(String searchInput) {
    return _groups.map((groups) {
      return groups.where((Group group) {
        return group.name.toUpperCase().contains(searchInput.toUpperCase());
      }).toList();
    });
  }

  Stream<Group> _searchFirestoreForGroup(String searchInput) {
    return Firestore.instance
        .collection(groupsCollectionRefrence)
        .document(searchInput)
        .snapshots()
        .asyncMap((docSnap) => Group.fromDocument(docSnap));
  }
}
