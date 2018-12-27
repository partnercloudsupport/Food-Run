import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:rxdart/rxdart.dart';

class MockGroupsBloc {
  static final String groupsCollectionRefrence = "Groups";
  ReplaySubject<String> _searchInput = ReplaySubject<String>();
  Stream<List<Group>> _groups;
  List<Group> _groupsData = [
    Group(name: "GMR"),
    Group(name: "Fry's"),
    Group(name: "UCLA"),
    Group(name: "M51A Crew"),
    Group(name: "Triangle"),
  ];

  MockGroupsBloc() {
    _groups = _getMockGroups();
  }

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
        .asyncMap((docSnap) => Group.fromDocumentSnapshot(docSnap));
  }

  Stream<List<Group>> _getMockGroups() {
    Future<List<Group>> groups =
        Future.delayed(Duration(seconds: 2)).then((groups) {
      print("Successfully loaded MOCK groups");
      return _groupsData;
    });
    //TODO: fromFutures vs fromFuture
    return Stream.fromFuture(groups)
        .handleError((_) => print("Unable to load the MOCK groups"));
  }
}
