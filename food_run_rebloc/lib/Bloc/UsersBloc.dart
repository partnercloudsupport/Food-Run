import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UsersBloc {
  static final String usersCollectionRefrence = "Users";
  Stream<List<User>> get users => Firestore.instance
      .collection(usersCollectionRefrence)
      .snapshots()
      .map((querySnapshot) => querySnapshot.documents
          .map((documentSnap) => User.fromDocument(documentSnap))
          .toList());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UsersBloc();

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
}

class FirebaseAuthData {
  String message;
  User user;
  FirebaseAuthData({this.message, this.user});
}
