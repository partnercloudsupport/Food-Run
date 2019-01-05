import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class UsersBloc {
  static final String usersCollectionRefrence = "Users";
  PublishSubject<User> _userStream = PublishSubject<User>();
  Observable<User> get userStream => _userStream.stream;
  Stream<List<User>> get users => _getUsers();
  List<User> _users;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User signedInUser;
  static UsersBloc _instance;
  UsersBloc._() {
    _getUsers();
  }

  static UsersBloc getInstance() {
    if (_instance == null) {
      return UsersBloc._();
    }
    return _instance;
  }

  Future<FirebaseAuthData> sendEmailVerification(User user) async {
    FirebaseAuthData firebaseAuthData =
        new FirebaseAuthData(user: null, message: "Email verification sent!");
    bool errorOccurred = false;
    FirebaseUser firebaseUser = await _auth
        .createUserWithEmailAndPassword(
            email: user.email, password: user.password)
        .catchError((platformException) {
      print("Error sending email verification to firebaseuser");
      if (platformException is PlatformException) {
        firebaseAuthData.message = platformException.message;
        errorOccurred = true;
      }
    });
    if (errorOccurred) {
      return firebaseAuthData;
    }

    _createUserInFirestore(user, firebaseUser);
    await firebaseUser.sendEmailVerification();
    return firebaseAuthData;
  }

  Future<FirebaseAuthData> signInEmailUser(User user) async {
    FirebaseAuthData firebaseAuthData = new FirebaseAuthData(user: null);
    bool errorOccurred = false;
    FirebaseUser firebaseUser = await _auth
        .signInWithEmailAndPassword(email: user.email, password: user.password)
        .catchError((platformException) {
      print("Error signing email user in");
      if (platformException is PlatformException) {
        firebaseAuthData.message = platformException.message;
        errorOccurred = true;
      }
    });
    if (errorOccurred) {
      return firebaseAuthData;
    } else {
      if (!firebaseUser.isEmailVerified) {
        firebaseAuthData.message = "Must verify account before signing in!";
      } else {
        firebaseAuthData.message = "Welcome back ${firebaseUser.email}";
        firebaseAuthData.user = await _getUser(firebaseUser.uid);
      }
    }
    return firebaseAuthData;
  }

  void addNewGoogleUser(User user) async {
    GoogleSignInAccount googleUser = await _googleSignIn
        .signIn()
        .catchError((_) => print("GoogleSignInAccount failed"));
    GoogleSignInAuthentication googleAuth = await googleUser.authentication
        .catchError((_) => print("GoogleSignInAuth failed"));
    FirebaseUser user = await _auth
        .signInWithGoogle(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        )
        .catchError((_) => print("Failed to get Firebase User from tokens"));
    print("signed in " + user.displayName);
  }

  Future<User> _getUser(String uid) async {
    return await Firestore.instance
        .collection(usersCollectionRefrence)
        .document(uid)
        .get()
        .then((docSnapshot) {
      return User.fromDocument(docSnapshot);
    }).catchError((error) => print(error));
  }

  void _createUserInFirestore(User user, FirebaseUser firebaseUser) {
    user.id = firebaseUser.uid;
    Firestore.instance
        .collection(usersCollectionRefrence)
        .document(firebaseUser.uid)
        .setData(User.toMap(user));
  }

  void addGroupToUser(User user, Group group) {
    if (user.groupIds == null) {
      user.groupIds = <String>[group.id];
    } else {
      user.groupIds.add(group.id);
    }
    Firestore.instance
        .collection(usersCollectionRefrence)
        .document(user.id)
        .updateData(User.toMap(user))
        .then((_) => print("added group to user"))
        .catchError((error) => print(error));
  }

  bool isMember(User user, Group group) {
    if (user.groupIds == null) {
      return false;
    }
    user.groupIds.forEach((groupId) {
      if (groupId == group.id) {
        return true;
      }
    });
    return false;
  }

  Future<User> getUser(String id) async {
    DocumentSnapshot signinUserSnap = await Firestore.instance
        .collection(usersCollectionRefrence)
        .document(id)
        .get();
    signedInUser = User.fromDocument(signinUserSnap);
    Firestore.instance
        .collection(usersCollectionRefrence)
        .document(id)
        .snapshots()
        .asyncMap((doc) => User.fromDocument(doc))
        .listen((user) {
      signedInUser = user;
      _userStream.add(signedInUser);
    });
    return signedInUser;
  }

  void leaveGroup(String id) {
    if (signedInUser.groupIds != null) {
      print("Removing groupId from user info");
      signedInUser.groupIds.remove(id);
      Firestore.instance
          .collection(usersCollectionRefrence)
          .document(signedInUser.id)
          .updateData(User.toMap(signedInUser));
    }
  }

  Future<Null> userVolunteerForResturant(Resturant resturant) async {
    if (signedInUser.volunteeredResturants.contains(resturant.id)) {
      signedInUser.volunteeredResturants.remove(resturant.id);
      print("${signedInUser.name} is NOT a volunteer");
    } else {
      print("${signedInUser.name} IS a volunteer");
      signedInUser.volunteeredResturants.add(resturant.id);
    }
    await Firestore.instance
        .collection(usersCollectionRefrence)
        .document(signedInUser.id)
        .updateData({
          "volunteeredResturants": signedInUser.volunteeredResturants,
        })
        .then((_) => print("User volunteer status updated"))
        .catchError((error) => print(error));
  }

  Future<void> removeAsAdmin(User user, Group group) async {
    user.adminForGroups.remove(group.id);
    await Firestore.instance
        .collection(usersCollectionRefrence)
        .document(user.id)
        .updateData({"adminForGroups": user.adminForGroups})
        .then((_) => print("user removed as admin"))
        .catchError((error) => print(error));
  }

  void makeAdmin(Group group) {
    signedInUser.adminForGroups.add(group.id);
    Firestore.instance
        .collection(usersCollectionRefrence)
        .document(signedInUser.id)
        .updateData({"adminForGroups": signedInUser.adminForGroups}).then((_) {
      print("Updated adminforgroups");
    }).catchError((error) => print(error));
  }

  Future removeGroupFromMembers(Group group) async {
    await getUsers(group.id);
    if (_users != null) {
      List<User> usersToUpdate =
          _users.where((user) => user.groupIds.contains(group.id)).toList();

      WriteBatch writeBatch = Firestore.instance.batch();
      for (int i = 0; i < usersToUpdate.length; i++) {
        User user = usersToUpdate[i];
        DocumentReference reference = Firestore.instance
            .collection(usersCollectionRefrence)
            .document(user.id);

        user.groupIds.remove(group.id);
        user.volunteeredResturants.remove(group.id);
        user.adminForGroups.remove(group.id);

        writeBatch.updateData(reference, {
          "groupIds": user.groupIds,
          "volunteeredGroups": user.volunteeredResturants,
          "adminForGroups": user.adminForGroups,
        });
      }
      writeBatch
          .commit()
          .then((_) => print("Users had the group removed from them"))
          .catchError((error) => print(error));
    }
  }

  Stream<List<User>> _getUsers() {
    return Firestore.instance
        .collection(usersCollectionRefrence)
        .snapshots()
        .map((querySnapshot) {
      _users = querySnapshot.documents
          .map((documentSnap) => User.fromDocument(documentSnap))
          .toList();
      return _users;
    });
  }

  Future<List<User>> getUsers(String groupId) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(usersCollectionRefrence)
        .where("groupIds", arrayContains: groupId)
        .getDocuments();

    if (querySnapshot.documents.length > 0) {
      _users =
          querySnapshot.documents.map((doc) => User.fromDocument(doc)).toList();
      print("Got users");
      return querySnapshot.documents
          .map((docSnap) => User.fromDocument(docSnap))
          .toList();
    }
    return null;
  }

  Future<bool> usernameIsAvailable(String username) async {
    if (username == null) {
      print("username is null");
      return false;
    }
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(usersCollectionRefrence)
        .where(
          "upperName",
          isEqualTo: username.toUpperCase(),
        )
        .getDocuments();
    if (querySnapshot.documents.length > 0) {
      print("userName is NOT available");
      return false;
    } else {
      print("userName IS available");
      return true;
    }
  }

  Future<Null> updateUsername(String username, User user) {
    user.name = username;
    Firestore.instance
        .collection(usersCollectionRefrence)
        .document(user.id)
        .updateData(User.toMap(user))
        .then((_) {
      print("User updated name");
    }).catchError((error) {
      print(error);
    });
  }
}

class FirebaseAuthData {
  String message;
  User user;
  FirebaseAuthData({this.message, this.user});
}
